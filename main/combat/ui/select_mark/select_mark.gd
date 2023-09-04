class_name SelectMark
extends Node2D

const EXTRA_MARK: String = "res://main/combat/ui/select_mark/select_mark.tscn"

var select_index: int = 0
var fighters: Array[Fighter]
var single: bool = false

signal accepted(cancel: bool)

func _ready() -> void:
	set_process_input(false)
	visible = false

func _input(event: InputEvent) -> void:
	var old_index: int = select_index
	
	if event.is_action_pressed("ui_cancel", false):
		accepted.emit(true)
		return
	if event.is_action_pressed("ui_accept", false):
		accepted.emit(false)
		return
	
	if not single:
		return
	
	if event.is_action_pressed("ui_left"):
		select_index -= 1
	if event.is_action_pressed("ui_right"):
		select_index += 1
	
	if select_index < 0:
		select_index = len(fighters) - 1
	elif select_index >= len(fighters):
		select_index = 0
	
	if select_index == old_index:
		return
	
	UISound.play_sound(UISound.select_sound)
	
	# reset anims
	$Sprite2D/AnimationPlayer.seek(0)
	fighters[select_index].get_node("AnimationPlayer").play("select")
	fighters[old_index].get_node("AnimationPlayer").play("RESET")
	
	global_position = fighters[select_index].global_position
	

func select(new_fighters: Array[Fighter]) -> int:
	visible = true
	single = true
	
	fighters = new_fighters
	select_index = 0
	set_process_input(true)
	
	$Sprite2D/AnimationPlayer.seek(0)
	
	global_position = fighters[0].global_position
	fighters[0].get_node("AnimationPlayer").play("select")
	
	var accept: bool = not await accepted
	
	visible = false
	fighters[select_index].get_node("AnimationPlayer").play("RESET")
	set_process_input(false)
	
	single = false
	
	return select_index if accept else -1

func select_all(new_fighters: Array[Fighter]) -> int:
	visible = false
	
	set_process_input(true)
	fighters = new_fighters
	
	var markers: Array[SelectMark] = []
	for fighter in fighters:
		var new_mark: SelectMark = load(EXTRA_MARK).instantiate()
		markers.append(new_mark)
		get_tree().get_root().add_child(new_mark)
		new_mark.visible = true
		new_mark.global_position = fighter.global_position
		fighter.get_node("AnimationPlayer").play("select")
		
	var accept: bool = not await accepted
	
	for marker in markers:
		marker.queue_free()
	for fighter in fighters:
		fighter.get_node("AnimationPlayer").play("RESET")
	
	set_process_input(false)
	return randi() % len(new_fighters) if accept else -1 
