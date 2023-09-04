class_name Enemy
extends Npc

@export var death_convo: Array[Line]
@export var music: AudioStream
@export var volume: float = -4
@export var encounter: Array[PackedScene]
@export var background: PackedScene

func _ready() -> void:
	super._ready()
	assert(unique_id != "")
	if unique_id in GlobalData.data:
		can_interact = false
		queue_free()

func event() -> void:
	if len(convo) > 0:
		await super.event()
	$EncounterPlayer.play()
	await get_tree().get_root().get_node("Main").enter_battle(encounter, music, volume, background)
	convo = death_convo
	disable_convo = true # disable the extra branches
	
	player.can_move = false
	player.can_interact = false
	
	if len(death_convo) > 0:
		await super.event()
	
	can_interact = false
	
	$EnemyAnimationPlayer.play("die")
	await $EnemyAnimationPlayer.animation_finished
	call_deferred("queue_free")
	GlobalData.data[unique_id] = true
	
	player.can_move = true
	player.can_interact = true
