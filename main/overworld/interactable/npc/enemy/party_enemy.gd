class_name PartyEnemy
extends Enemy

@export var join: String = "loofa"
@export var join_convo: Array[Line]

func _ready() -> void:
	super._ready()
	assert(unique_id != "")
	if unique_id in GlobalData.data:
		can_interact = false
		queue_free()

func event() -> void:
	await text_box.trans_in()
	await text_box.convo(convo)
	await await text_box.trans_out()
	
	if len(encounter) > 0:
		$EncounterPlayer.play()
		await get_tree().get_root().get_node("Main").enter_battle(encounter, music, volume, background)
	
		player.can_move = false
		player.can_interact = false
		
		await text_box.trans_in()
		await text_box.convo(death_convo)
		await text_box.trans_out()
	
	$JoinPlayer.play()
	await $JoinPlayer.finished
	
	await text_box.trans_in()
	await text_box.convo(join_convo)
	await text_box.trans_out()
	
	get_tree().get_root().get_node("Main/PlayerParty").add_party_member(join)
	GlobalData.data.party_config.append(join)
	
	$EnemyAnimationPlayer.play("die")
	await $EnemyAnimationPlayer.animation_finished
	
	can_interact = false
	call_deferred("queue_free")
	GlobalData.data[unique_id] = true
	
	player.can_move = true
	player.can_interact = true
