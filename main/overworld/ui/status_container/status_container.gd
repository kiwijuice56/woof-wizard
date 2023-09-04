class_name StatusContainer
extends VBoxContainer

signal confirmed(yes: bool)

var can_back: bool = false
var can_confirm: bool = false
var is_level_up: bool = false
var idx: int = 0

func _ready() -> void:
	set_process_input(false)
	for node in %FlickerContainer.get_children():
		node.modulate.a = 0

func _input(event: InputEvent) -> void:
	if can_back and event.is_action_pressed("ui_cancel"):
		confirmed.emit(false)
		return
	if can_confirm and event.is_action_pressed("ui_accept", false):
		confirmed.emit(true)
		return
	if not is_level_up:
		return
	
	var old_idx: int = idx
	
	if event.is_action_pressed("ui_up", false):
		UISound.play_sound(UISound.select_sound)
		idx -= 1
	if event.is_action_pressed("ui_down", false):
		UISound.play_sound(UISound.select_sound)
		idx += 1
	if idx < 0:
		idx = 2
	if idx > 2:
		idx = 0
	
	if idx != old_idx:
		for node in %FlickerContainer.get_children():
			node.modulate.a = 0
		$AnimationPlayer.play("flicker_" + str(idx))

func show_fighter(fighter: Fighter, mode: String = "status") -> String:
	var stat: String = ""
	
	for node in %FlickerContainer.get_children():
		node.modulate.a = 0
	
	%Icon.texture = fighter.party_icon
	%Name.text = fighter.display_name
	
	%LvLabel.text = "lv: " + str(fighter.stats.level)
	%XPLabel.text = "xp: " + str(min(999, fighter.stats.ex))
	%HLabel.text = str(fighter.stats.max_hp)
	%SLabel.text = str(fighter.stats.max_sp)
	%AtkLabel.text = "atk: " + str(fighter.stats.atk)
	%DefLabel.text = "def: " + str(fighter.stats.def)
	%WitLabel.text = "wit: " + str(fighter.stats.agi)
	
	if mode == "status":
		is_level_up = false
		can_back = true
		
		%TitleLabel.text = "status"
		set_process_input(true)
		await confirmed
	else:
		var choice: bool = false
		idx = 0
		
		while not choice:
			for node in %FlickerContainer.get_children():
				node.modulate.a = 0
			$AnimationPlayer.play("flicker_" + str(idx))
			
			is_level_up = true
			can_confirm = true
			can_back = false
			
			%TitleLabel.text = "level up\na stat!"
			
			set_process_input(true)
			await confirmed
			UISound.play_sound(UISound.accept_sound)
			
			%TitleLabel.text = "are you\nsure?"
			%StatContainer.get_child(idx).text = ["atk", "def", "wit"][idx] + ": " + str(int(%StatContainer.get_child(idx).text.substr(4)) + 1)
			is_level_up = false
			can_back = true
			
			for node in %FlickerContainer.get_children():
				node.modulate.a = 0
			$AnimationPlayer.stop()
			%FlickerContainer.get_child(idx).modulate.a = 1.0
			
			choice = await confirmed
			if not choice:
				%StatContainer.get_child(idx).text = ["atk", "def", "wit"][idx] + ": " + str(int(%StatContainer.get_child(idx).text.substr(4)) - 1)
				UISound.play_sound(UISound.cancel_sound)
			else:
				UISound.play_sound(UISound.accept_sound)
				stat = ["atk", "def", "agi"][idx]
	set_process_input(false)
	is_level_up = false
	can_back = false
	can_confirm = false
	return stat
