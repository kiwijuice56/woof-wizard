class_name Effect
extends Node2D

func start(target: Fighter) -> void:
	visible = true
	global_position = target.global_position
	$AnimationPlayer.play("effect")
	await $AnimationPlayer.animation_finished
	queue_free()
