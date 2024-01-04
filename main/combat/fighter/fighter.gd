class_name Fighter
extends Sprite2D

@export var display_name: String
@export var internal_name: String
@export var stats: StatProfile
@export var party_icon: Texture

@onready var brain: Brain = $Brain
@onready var actions: Node = $Actions

var def_buff: int = 0
var atk_buff: int = 0
var agi_buff: int = 0

var is_player: bool = false

var status_effects: Dictionary

signal impact

func _ready() -> void:
	set_stats(stats.duplicate())

func _set(property: StringName, value: Variant) -> bool:
	if property == "offset":
		$Dizzy.offset = value
		$Blessed.offset = value
		$Dizzy.offset = value
		$Burning.offset = value
		$Dead.offset = value
		offset = value
		return true
	return false

func _on_hp_changed(change: int) -> void:
	$DamageLabel.text = ("+" if change > 0 else "") + str(change)
	$DamageLabel/AnimationPlayer.seek(0)
	$DamageLabel/AnimationPlayer.play("show")
	if stats.hp <= 0:
		die()
	elif change < 0:
		$AnimationPlayer.play("hurt")

func set_stats(new_stats: StatProfile) -> void:
	new_stats.hp_changed.connect(_on_hp_changed)
	stats = new_stats

func reset_buffs() -> void:
	def_buff = 0
	atk_buff = 0
	agi_buff = 0

func is_alive() -> bool:
	return stats.hp > 0

func die() -> void:
	$AnimationPlayer.play("death")
	
	if is_player:
		reset_buffs()
		reset_status()
		await $AnimationPlayer.animation_finished
		
		$Dead.visible = true
		scale.y = 1.0
		modulate.a = 1.0
		self_modulate.a = 0
		$DamageLabel.scale.y = 1

func add_status(status: String) -> void:
	if not status in status_effects:
		status_effects[status] = 3
		get_node(status.capitalize()).visible = true

func set_buff(type: String, count: int) -> bool:
	if get(type) >= 2 and count > 1 or get(type) <= -2 and count < 1:
		return false
	set(type, clamp(get(type) + count, -2, 2))
	return true

func tick_status() -> void:
	var updated_status: Dictionary = {}
	for status in status_effects:
		if status_effects[status] - 1 == 0:
			get_node(status.capitalize()).visible = false
		else:
			updated_status[status] = status_effects[status] - 1
	status_effects = updated_status

func reset_status() -> void:
	status_effects = {}
	$Burning.visible = false
	$Dizzy.visible = false
	$Blessed.visible = false
	$Dead.visible = false
	self_modulate.a = 1.0

func initialize_battle_stats() -> void:
	reset_buffs()
	reset_status()
	stats.initialize_battle_stats()
