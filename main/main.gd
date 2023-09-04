class_name Main
extends Node

const ROOM_FOLDER: String = "res://main/overworld/room/"

signal room_loaded

@onready var player: Player = $Player

var room: Room
var current_room: String
var loading: bool = false

# Main game setup
func _ready() -> void:
	$CombatLayer.visible = false
	$PlayerParty.visible = false
	$MusicPlayer.play_track(preload("res://main/asset/music/beauty_flow.ogg"), -3)
	$TitleLayer/TitleInterface.show_title()
	
	await $TitleLayer/TitleInterface.started
	$TitleLayer/TitleInterface.visible = false
	$MusicPlayer.stop_music()
	await get_tree().create_timer(1.0).timeout
	
	if GlobalData.is_new_file():
		await $InitialLayer/InitialCutscene.play()
	
	start_game()

func start_game() -> void:
	GlobalData.load_data()
	
	await load_room(GlobalData.data.spawn_room, "SavePoint")
	$TitleLayer.visible = false

func load_room(room_name: String, spawn: String) -> void:
	loading = true
	
	current_room = room_name
	
	player.can_move = false
	player.can_interact = false
	
	await $Transition.trans_in()
	
	var file_name: String = ROOM_FOLDER + room_name + "/" + room_name + "_room.tscn"
	if is_instance_valid(room):
		room.queue_free()
	room = load(file_name).instantiate()
	add_child(room)
	move_child(room, 0)
	
	if room.music != $MusicPlayer.get_child(0).stream:
		$MusicPlayer.play_track(room.music, room.volume)
	
	player.get_node("Camera2D").limit_left = room.camera_limit_left
	player.get_node("Camera2D").limit_right = room.camera_limit_right
	player.get_node("Camera2D").limit_top = room.camera_limit_top
	player.get_node("Camera2D").limit_bottom = room.camera_limit_bot
	player.global_position = room.anchors.get_node(spawn).global_position
	
	await $Transition.trans_out()
	
	player.can_move = true
	player.can_interact = true
	
	loading = false
	room_loaded.emit()

func enter_battle(encounter: Array[PackedScene], music: AudioStream, volume: float, background: PackedScene) -> void:
	player.can_move = false
	await $Transition.trans_in()
	
	var background_new: Node2D = background.instantiate()
	$TurnQueue.add_child(background_new)
	$TurnQueue.move_child(background_new, 0)
	$TurnQueue/Cover.visible = true
	
	$MusicPlayer.play_track(music, volume)
	
	$TurnQueue.initialize_parties($PlayerParty.get_ordered_party(), encounter)
	$TurnQueue/CombatCamera.enabled = true
	$TurnQueue/CombatCamera.make_current()
	
	$PlayerParty.visible = true
	$TurnQueue.visible = true
	$TurnQueue.position_fighters()
	$CombatLayer.visible = true
	
	await $Transition.trans_out()
	
	var xp: int = await $TurnQueue.battle()
	
	end_battle()
	
	await $EndScreenLayer/EndScreen.battle_ended(xp)
	await $PlayerParty.distribute_exp(xp, $EndScreenLayer/EndScreen/PanelContainer/StatusContainer)
	await $EndScreenLayer/EndScreen.trans_out()
	
	await $Transition.trans_in()
	$TurnQueue/Cover.visible = false
	background_new.queue_free()
	$TurnQueue.visible = false
	$TurnQueue/CombatCamera.enabled = false
	$PlayerParty.visible = false
	$CombatLayer.visible = false
	await $Transition.trans_out()
	
	$MusicPlayer.play_track(room.music, room.volume)
	
	player.can_move = true

func end_battle() -> void:
	$MusicPlayer.play_track(preload("res://main/asset/music/victory.mp3"), -5)

func game_over() -> void:
	$MusicPlayer.stop_music()
	get_tree().paused = true
	await $GameOver.game_over()
	get_tree().reload_current_scene()
	get_tree().paused = false
