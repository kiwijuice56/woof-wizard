class_name Npc
extends Interactable

@export var convo: Array[Line]
@export var convo_a: Array[Line]
@export var convo_b: Array[Line]

var disable_convo: bool = false

func event() -> void:
	await text_box.trans_in()
	var a: bool = await text_box.convo(convo)
	if not disable_convo and convo_a != null and convo_b != null:
		await text_box.convo(convo_a if a else convo_b)
	await text_box.trans_out()
