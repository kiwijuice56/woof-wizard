class_name GameOver
extends CanvasLayer

func game_over() -> void:
	$Control/AnimationPlayer.play("gameover")
	await $Control/AnimationPlayer.animation_finished
