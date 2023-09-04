class_name Interactable
extends Area2D

@onready var text_box: TextBox = get_tree().get_root().get_node("Main/TextBox")
@onready var trans: Transition = get_tree().get_root().get_node("Main/Transition")
@export var unique_id: String
@export var auto_interact: bool = false

var player: Player
var can_interact: bool = true

signal interacted

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	set_process_input(false)

@warning_ignore("shadowed_variable")
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept", false) and player.can_interact:
		interact()

func _on_area_entered(area: Area2D) -> void:
	if not area is Player:
		return
	player = area
	if auto_interact:
		interact()
	else:
		set_process_input(true)

func _on_area_exited(area: Area2D) -> void:
	if not area is Player or auto_interact:
		return
	player = null
	set_process_input(false)

func interact() -> void:
	if not can_interact:
		return
	if get_tree().get_root().get_node("Main").loading:
		await get_tree().get_root().get_node("Main").room_loaded
	
	player.can_move = false
	player.can_interact = false
	await event()
	player.can_move = true
	player.can_interact = true

func event() -> void:
	pass
