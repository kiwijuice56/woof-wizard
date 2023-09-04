class_name EndScreen
extends Control

@export var progress: float:
	set(val):
		progress = val
		%ExpLabel.text = """your party\ngot\n%d\nxp""" % int(progress * exp_gained)
var exp_gained: int = 0

signal advanced

func _ready() -> void:
	visible = false
	set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advanced.emit()

@warning_ignore("shadowed_global_identifier")
func battle_ended(exp: int) -> void:
	%Label.text = ""
	%ExpLabel.text = ""
	exp_gained = exp
	
	visible = true
	
	$PanelContainer.size.y = 0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($PanelContainer, "size:y", 54, 0.125)
	await tween.finished
	
	%Label.text = "victory!"
	%ExpLabel.text = """your party\ngot\n0\nxp"""
	
	$AnimationPlayer.play("gain_exp")
	await $AnimationPlayer.animation_finished
	$PanelContainer/AnimationPlayer.play("flicker")
	set_process_input(true)
	await advanced
	UISound.play_sound(UISound.accept_sound)
	set_process_input(true)
	$PanelContainer/AnimationPlayer.play("stop_flicker")
	
	%Label.text = ""
	%ExpLabel.text = ""

func trans_out() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($PanelContainer, "size:y", 0, 0.125)
	await tween.finished
	
	visible = false

