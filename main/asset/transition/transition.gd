class_name Transition
extends CanvasLayer

func trans_in(type: String = "default") -> void:
	$AnimationPlayer.play("in")
	await $AnimationPlayer.animation_finished

func trans_out(type: String = "default") -> void:
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
