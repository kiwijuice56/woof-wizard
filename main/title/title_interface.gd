class_name TitleInterface
extends Control

signal confirmed
signal started

var cancel: bool = false
var idx: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept", false):
		confirmed.emit()
		UISound.play_sound(UISound.accept_sound)
	if cancel:
		return
	var old_idx: int = idx
	if event.is_action_pressed("ui_up", false):
		UISound.play_sound(UISound.select_sound)
		idx -= 1
	if event.is_action_pressed("ui_down", false):
		UISound.play_sound(UISound.select_sound)
		idx += 1
	if idx < 0:
		idx = 1
	if idx > 1:
		idx = 0
	if old_idx != idx:
		%IconContainer.get_child(old_idx).get_node("AnimationPlayer").stop()
		%IconContainer.get_child(old_idx).modulate.a = 0
		%IconContainer.get_child(idx).get_node("AnimationPlayer").play("flicker")

func show_title(starting_idx: int = 0) -> void:
	cancel = false
	for icon in %IconContainer.get_children():
		icon.modulate.a = 0
	idx = starting_idx
	%IconContainer.get_child(starting_idx).get_node("AnimationPlayer").play("flicker")
	set_process_input(true)
	await confirmed
	set_process_input(false)
	match idx:
		0:
			started.emit()
		1:
			%CreditScreen.visible = true
			cancel = true
			set_process_input(true)
			await confirmed
			set_process_input(false)
			%CreditScreen.visible = false
			show_title(1)
