class_name CombatInterface
extends Control

const BUTTON_SCENE: PackedScene = preload("res://main/combat/ui/combat_button/combat_button.tscn")

signal button_pressed(button: CombatButton)
signal button_focused(button: CombatButton)

var menu_top_level: bool = true

func _ready() -> void:
	set_process_input(false)
	%CenterInfo.visible = false
	for button in %TopChoices.get_children() + %SkillChoices.get_children() + %ItemChoices.get_children():
		button.pressed.connect(_action_selected.bind(button))
		button.focus_entered.connect(_action_hovered.bind(button))
	%TopChoices.get_child(0).focus_neighbor_left = %TopChoices.get_child(-1).get_path()
	%TopChoices.get_child(-1).focus_neighbor_right = %TopChoices.get_child(0).get_path()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left", false) or event.is_action_pressed("ui_right", false):
		UISound.play_sound(UISound.select_sound)
	if event.is_action_pressed("ui_cancel", false) and not menu_top_level:
		button_pressed.emit(%Back)

func _action_selected(button: CombatButton) -> void:
	button_pressed.emit(button)

func _action_hovered(button: CombatButton) -> void:
	%Cost.text = button.cost
	%Combo.text = button.combo
	%Title.text = button.title_name

func initialize_party_members(party: Array[Fighter]) -> void:
	%PartyMember1.initialize(party[0])
	if len(party) > 1:
		%PartyMember2.initialize(party[1])
		%PartyMember2.modulate.a = 1
	else:
		# Keep it invisible o.o
		%PartyMember2.modulate.a = 0

func initialize(fighter: Fighter) -> void:
	for button in %SkillChoices.get_children() + %ItemChoices.get_children():
		if button.title_name != "back":
			button.get_parent().remove_child(button)
			button.queue_free()
	for action in fighter.actions.get_children():
		var new_button: CombatButton = BUTTON_SCENE.instantiate()
		%SkillChoices.add_child(new_button)
		%SkillChoices.move_child(new_button, %SkillChoices.get_child_count() - 2)
		new_button.initialize(action, fighter)
		new_button.pressed.connect(_action_selected.bind(new_button))
		new_button.focus_entered.connect(_action_hovered.bind(new_button))
	%SkillChoices.get_child(0).focus_neighbor_left = %SkillChoices.get_child(-1).get_path()
	%SkillChoices.get_child(-1).focus_neighbor_right = %SkillChoices.get_child(0).get_path()
	
	for action in [fighter.get_node("Flan"), fighter.get_node("Leche"), fighter.get_node("Copal")]:
		var new_button: CombatButton = BUTTON_SCENE.instantiate()
		%ItemChoices.add_child(new_button)
		%ItemChoices.move_child(new_button, %ItemChoices.get_child_count() - 2)
		new_button.initialize(action, fighter)
		new_button.pressed.connect(_action_selected.bind(new_button))
		new_button.focus_entered.connect(_action_hovered.bind(new_button))
	%ItemChoices.get_child(0).focus_neighbor_left = %ItemChoices.get_child(-1).get_path()
	%ItemChoices.get_child(-1).focus_neighbor_right = %ItemChoices.get_child(0).get_path()

func select_action(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter], submenu: String = "", initial_idx: int = 0) -> Dictionary:
	var selection: Button
	initialize(fighter)
	%CenterInfo.visible = true
	
	if submenu == "":
		%InfoLabel.text = "what will %s do?" % fighter.display_name
		
		%ItemChoices.visible = false
		%SkillChoices.visible = false
		%TopChoices.visible = true
		
		menu_top_level = true
		%Fight.grab_focus()
		set_process_input(true)
		
		selection = await button_pressed
		submenu = selection.title_name
		UISound.play_sound(UISound.accept_sound)
		
		menu_top_level = false
		set_process_input(false)
	
	match submenu:
		"combo":
			%InfoLabel.text = "combo who?"
			%CenterInfo.visible = false
			var targets: Array[Fighter] = await select_targets(fighter.get_node("Combo"), fighter, player_party, enemy_party)
			# CANCEL
			if len(targets) == 0:
				UISound.play_sound(UISound.cancel_sound)
				return await select_action(fighter, player_party, enemy_party)
			UISound.play_sound(UISound.accept_sound)
			return {"action": fighter.get_node("Combo"), "targets": targets}
		"skill":
			%InfoLabel.text = "which skill?"
			%TopChoices.visible = false
			%SkillChoices.visible = true
			%SkillChoices.get_child(initial_idx).grab_focus()
			
			set_process_input(true)
			selection = await button_pressed
			set_process_input(false)
			
			# CANCEL
			if selection.title_name == "back":
				UISound.play_sound(UISound.cancel_sound)
				return await select_action(fighter, player_party, enemy_party)
			else:
				UISound.play_sound(UISound.accept_sound)
				%CenterInfo.visible = false
				var targets: Array[Fighter] = await select_targets(selection.action, fighter, player_party, enemy_party)
				# CANCEL
				if len(targets) == 0:
					UISound.play_sound(UISound.cancel_sound)
					return await select_action(fighter, player_party, enemy_party, "skill", selection.get_index())
				UISound.play_sound(UISound.accept_sound)
				return {"action": selection.action, "targets": targets}
		"item":
			%InfoLabel.text = "which item?"
			%TopChoices.visible = false
			%ItemChoices.visible = true
			%ItemChoices.get_child(initial_idx).grab_focus()
			
			set_process_input(true)
			selection = await button_pressed
			set_process_input(false)
			
			# CANCEL
			if selection.title_name == "back":
				UISound.play_sound(UISound.cancel_sound)
				return await select_action(fighter, player_party, enemy_party)
			else:
				UISound.play_sound(UISound.accept_sound)
				%CenterInfo.visible = false
				var targets: Array[Fighter] = await select_targets(selection.action, fighter, player_party, enemy_party)
				# CANCEL
				if len(targets) == 0:
					UISound.play_sound(UISound.cancel_sound)
					return await select_action(fighter, player_party, enemy_party, "item", selection.get_index())
				UISound.play_sound(UISound.accept_sound)
				return {"action": selection.action, "targets": targets}
	
	%CenterInfo.visible = false
	
	return {}

func select_targets(action: Action, actor: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Array[Fighter]:
	%InfoLabel.text = "%s who?" % action.display_name
	
	var party: Array[Fighter] = []
	var selection: Array[Fighter] = []
	if (action.target_type == "other" and actor.is_player) or (action.target_type == "own" and not actor.is_player):
		party = enemy_party
	else:
		party = player_party
	if action.target_count == "all":
		if (await $SelectMark.select_all(party)) != -1:
			selection.append_array(party)
	else:
		var idx: int = await $SelectMark.select(party)
		if idx != -1:
			selection.append(party[idx])
	return selection
