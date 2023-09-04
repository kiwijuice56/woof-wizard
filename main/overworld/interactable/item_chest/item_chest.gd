class_name ItemChest
extends Interactable

@export var item: String
@export var cnt: int
@export var convo: Array[Line]

func _ready() -> void:
	super._ready()
	convo = convo.duplicate(true)
	assert(unique_id != "")
	if unique_id in GlobalData.data:
		$Sprite2D.frame = 1
		can_interact = false

func event() -> void:
	await text_box.trans_in()
	$AudioStreamPlayer.play()
	$Sprite2D.frame = 1
	var old_text: String = convo[0].text
	convo[0].text = convo[0].text % [item, cnt]
	var a: bool = await text_box.convo(convo)
	convo[0].text = old_text
	await text_box.trans_out()
	if item in GlobalData.data.inventory:
		GlobalData.data.inventory[item] += cnt
	else:
		GlobalData.data.inventory[item] = cnt
	can_interact = false
	GlobalData.data[unique_id] = true
	
