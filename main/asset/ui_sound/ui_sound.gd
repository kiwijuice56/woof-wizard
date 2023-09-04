extends Node

var accept_sound: AudioStream = preload("res://main/asset/ui_sound/accept.wav")
var cancel_sound: AudioStream = preload("res://main/asset/ui_sound/cancel.wav")
var select_sound: AudioStream = preload("res://main/asset/ui_sound/select.wav")
var level_up_sound: AudioStream = preload("res://main/asset/ui_sound/levleup.wav")

func play_sound(sound: AudioStream) -> void:
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.stream = sound
	new_player.volume_db = -7
	add_child(new_player)
	new_player.playing = true
	await new_player.finished
	new_player.queue_free()
