class_name MusicPlayer
extends Node

@export var global_offset: float = -14

func stop_music() -> void:
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
	tween = tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($AudioStreamPlayer, "volume_db", -80.0, 0.3)
	await tween.finished

func play_track(track: AudioStream, volume: float) -> void:
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
	tween = tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($AudioStreamPlayer, "volume_db", -80.0, 0.3)
	await tween.finished
	$AudioStreamPlayer.stream = track
	$AudioStreamPlayer.playing = true
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween = tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($AudioStreamPlayer, "volume_db", volume + global_offset, 0.3)
	await tween.finished
