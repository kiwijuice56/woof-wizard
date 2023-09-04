class_name InitialCutscene
extends Sprite2D

func play() -> void:
	$FallPlayer.play()
	await $FallPlayer.finished
	$MagoFall.play()
	await get_tree().create_timer(0.3).timeout
	$ChiwoFall.play()
	await $ChiwoFall.finished
