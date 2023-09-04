class_name ChiwoKidnap
extends Npc

@export var convo2: Array[Line]

func _ready() -> void:
	super._ready()
	assert(unique_id != "")
	if unique_id in GlobalData.data:
		can_interact = false
		queue_free()

func event() -> void:
	player.get_node("AnimationPlayer").stop()
	player.set_physics_process(false)
	await player.pan_camera(Vector2(20, 0), 1.0)
	
	await text_box.trans_in()
	await text_box.convo(convo)
	await text_box.trans_out()
	
	$Chiwo/AnimationPlayer.play("run")
	$CustomAnimationPlayer.play("kidnap")
	await $CustomAnimationPlayer.animation_finished
	await player.pan_camera(Vector2(-20, 0), 0.4)
	
	call_deferred("queue_free")
	GlobalData.data[unique_id] = true
	
	player.set_physics_process(true)
