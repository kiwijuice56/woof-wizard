class_name EndCutscene
extends Node2D

func play() -> void:
	$AnimationPlayer.play("trans_in")
	await $AnimationPlayer.animation_finished
