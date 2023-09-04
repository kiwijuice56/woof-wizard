class_name ChiwoRunAway
extends Npc

@export var convo2: Array[Line]

func _ready() -> void:
	super._ready()
	assert(unique_id != "")
	if unique_id in GlobalData.data:
		can_interact = false
		queue_free()

func event() -> void:
	player.set_physics_process(false)
	
	player.get_node("AnimationPlayer").play("collapsed")
	await player.get_node("AnimationPlayer").animation_finished
	
	$CustomAnimationPlayer.play("get_up")
	await $CustomAnimationPlayer.animation_finished
	
	$AnimationPlayer.play("hop")
	await $AnimationPlayer.animation_finished
	
	await text_box.trans_in()
	await text_box.convo(convo)
	await text_box.trans_out()
	
	player.get_node("AnimationPlayer").play("collapsed")
	$AnimationPlayer.play("hop")
	await $AnimationPlayer.animation_finished
	$CustomAnimationPlayer.play("run")
	await $CustomAnimationPlayer.animation_finished
	
	player.get_node("AnimationPlayer").play("get_up")
	await player.get_node("AnimationPlayer").animation_finished
	
	await text_box.trans_in()
	await text_box.convo(convo2)
	await text_box.trans_out()
	
	call_deferred("queue_free")
	GlobalData.data[unique_id] = true
	
	player.set_physics_process(true)
