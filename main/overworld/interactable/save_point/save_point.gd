class_name SavePoint
extends Interactable

@export var save_convo: Array[Line]
@export var save_convo2: Array[Line]

func event() -> void:
	await text_box.trans_in()
	var a: bool = await text_box.convo(save_convo)
	await text_box.trans_out()
	if a:
		GlobalData.save_data()
		$AudioStreamPlayer.playing = true
		await get_tree().create_timer(1.0).timeout
		await text_box.trans_in()
		await text_box.convo(save_convo2)
		await text_box.trans_out()
	
