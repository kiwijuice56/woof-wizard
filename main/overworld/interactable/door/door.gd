extends Interactable

@export var target_room: String
@export var target_anchor: String

func event() -> void:
	get_tree().get_root().get_node("Main").load_room(target_room, target_anchor)

func interact() -> void:
	player.can_move = false
	player.can_interact = false
	await event()
