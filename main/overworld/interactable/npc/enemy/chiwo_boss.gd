class_name ChiwoBoss
extends Enemy

var cutscene: PackedScene = preload("res://main/title/end_cutscene.tscn")

func event() -> void:
	await text_box.trans_in()
	await text_box.convo(convo)
	await text_box.trans_out()
	
	$CustomAnimationPlayer2.play("kill_losers")
	await $CustomAnimationPlayer2.animation_finished
	
	$EncounterPlayer.play()
	await get_tree().get_root().get_node("Main").enter_battle(encounter, music, volume, background)
	
	player.can_move = false
	player.can_interact = false
	
	get_tree().get_root().get_node("Main/MusicPlayer").play_track(preload("res://main/asset/music/beauty_flow.ogg"), -4)
	
	var c: EndCutscene = cutscene.instantiate()
	add_child(c)
	await c.play()
	
	await text_box.trans_in()
	await text_box.convo(death_convo)
	await text_box.trans_out()
	
	get_tree().paused = true
