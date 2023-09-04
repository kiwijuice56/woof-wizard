class_name OverworldInterface
extends Control

const PARTY_MEMBER_BUTTON: PackedScene = preload("res://main/overworld/ui/party_member_button/party_member_button.tscn")

@onready var player: Player = get_tree().get_root().get_node("Main/Player")
@onready var party: PlayerParty = get_tree().get_root().get_node("Main/PlayerParty")

var is_open: bool = false
var idx: int = 0

# Basically an ugly state machine
# 0 is the base level, where you choose a main command
# 1 is where you select a party member for some reason or another
# 2 is a panel state where you can only go back
var level: int = 0

signal choice(idx: int)
signal party_member_pressed(button: PartyMemberButton)
signal item_cancel

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed("ui_cancel", false):
		UISound.play_sound(UISound.cancel_sound)
		if level == 0:
			choice.emit(-1)
			close_menu()
		elif level == 1:
			level = 0
			party_member_pressed.emit(null)
		else:
			item_cancel.emit()
	elif not is_open and player.can_interact and player.can_move and player.on_floor and event.is_action_pressed("ui_cancel", false):
		UISound.play_sound(UISound.accept_sound)
		open_menu()
	
	if is_open and event.is_action_released("ui_accept", false):
		choice.emit(idx)
		return
	
	%ChoiceIconContainer.get_child(idx).modulate.a = 0
	
	if is_open and event.is_action_pressed("ui_up"):
		if level == 0 or level == 1:
			UISound.play_sound(UISound.select_sound)
		if level == 0:
			idx -= 1
	elif is_open and event.is_action_pressed("ui_down"):
		if level == 0 or level == 1:
			UISound.play_sound(UISound.select_sound)
		if level == 0:
			idx += 1
	
	if level == 0:
		if idx < 0:
			idx = 3
		if idx > 3:
			idx = 0
		%ChoiceIconContainer.get_child(idx).modulate.a = 1

func initialize() -> void:
	for icon in %ChoiceIconContainer.get_children():
		icon.modulate.a = 0
	%ChoiceIconContainer.get_child(idx).modulate.a = 1
	for button in %PartyContainer.get_children():
		button.get_parent().remove_child(button)
		button.queue_free()
	%ItemVBoxContainer.delete_items()
	for party_member in GlobalData.data.party_config:
		var new_button: PartyMemberButton = PARTY_MEMBER_BUTTON.instantiate()
		new_button.initialize(party.party_member_current[party_member])
		new_button.pressed.connect(emit_signal.bind("party_member_pressed", new_button))
		%PartyContainer.add_child(new_button)
	for i in range(5 - len(GlobalData.data.party_config)):
		var new_button: PartyMemberButton = PARTY_MEMBER_BUTTON.instantiate()
		new_button.initialize(null)
		%PartyContainer.add_child(new_button)
	%ItemLabel.text = """
	flan: %d
	leche: %d
	copal: %d""" % [GlobalData.data.inventory.flan, GlobalData.data.inventory.leche, GlobalData.data.inventory.copal]

func open_menu(starting_idx: int = 0, starting_level: int = 0, starting_member: int = 0) -> void:
	is_open = true
	
	player.can_interact = false
	player.can_move = false
	
	level = starting_level
	idx = starting_idx
	initialize()
	
	visible = true
	
	var choice_idx: int = starting_idx
	if level == 0:
		choice_idx = await choice
		if choice_idx == -1:
			return
		UISound.play_sound(UISound.accept_sound)
	
	for icon in %ChoiceIconContainer.get_children():
		icon.modulate.a = 0
	match choice_idx:
		0:
			level = 1
			var member: PartyMemberButton = await select_party_member(starting_member)
			get_viewport().gui_get_focus_owner().release_focus()
			if member == null:
				await open_menu(0)
				return
			UISound.play_sound(UISound.accept_sound)
			$PanelContainer.size.y = 0
			$PanelContainer.visible = true
			level = 2
			
			var tween: Tween = get_tree().create_tween()
			tween.tween_property($PanelContainer, "size:y", 54, 0.125)
			await tween.finished
			%StatusContainer.visible = true
			
			await %StatusContainer.show_fighter(member.fighter)
			%StatusContainer.visible = false
			
			tween = get_tree().create_tween()
			tween.tween_property($PanelContainer, "size:y", 0, 0.125)
			
			await tween.finished
			$PanelContainer.visible = false
			
			await open_menu(0, 1, member.get_index())
			return
		1:
			level = 1
			var member_a: PartyMemberButton = await select_party_member(starting_member)
			if member_a == null:
				await open_menu(1)
				return
			UISound.play_sound(UISound.accept_sound)
			member_a.disabled = true
			
			var member_b: PartyMemberButton = await select_party_member(member_a.get_index())
			if member_b == null:
				await open_menu(1, 1, member_a.get_index())
				return
			UISound.play_sound(UISound.accept_sound)
			
			var first_idx: int = GlobalData.data.party_config.find(member_a.fighter.internal_name)
			var second_idx: int = GlobalData.data.party_config.find(member_b.fighter.internal_name)
			GlobalData.data.party_config.insert(first_idx, member_b.fighter.internal_name)
			GlobalData.data.party_config.pop_at(first_idx + 1)
			
			GlobalData.data.party_config.insert(second_idx, member_a.fighter.internal_name)
			GlobalData.data.party_config.pop_at(second_idx + 1)
			
			await open_menu(1, 1, member_b.get_index())
			return
		2:
			$ItemPanelContainer.size.y = 0
			$ItemPanelContainer.visible = true
			%ItemVBoxContainer.visible = false
			level = 2
			
			var tween: Tween = get_tree().create_tween()
			tween.tween_property($ItemPanelContainer, "size:y", 54, 0.125)
			await tween.finished
			%ItemVBoxContainer.visible = true
			%ItemVBoxContainer.show_items()
			
			await item_cancel
			%ItemVBoxContainer.visible = false
			
			tween = get_tree().create_tween()
			tween.tween_property($ItemPanelContainer, "size:y", 0, 0.125)
			
			await tween.finished
			$ItemPanelContainer.visible = false
			
			await open_menu(2, 0)
			return
			

func close_menu() -> void:
	player.can_interact = true
	player.can_move = true
	
	set_process_input(true)
	
	is_open = false
	visible = false

func select_party_member(starting_idx: int = 0) -> PartyMemberButton:
	%PartyContainer.get_child(starting_idx).grab_focus()
	return await party_member_pressed
