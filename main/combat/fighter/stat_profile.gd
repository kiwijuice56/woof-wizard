class_name StatProfile
extends Resource

signal hp_changed
signal sp_changed

@export var max_hp: int 
@export var max_sp: int
@export var hp: int:
	set(val):
		var old_hp: int = hp
		hp = clamp(val, 0, max_hp)
		if hide_next:
			hide_next = false
		else:
			hp_changed.emit(hp - old_hp)
@export var sp: int:
	set(val):
		var old_sp: int = sp
		sp = clamp(val, 0, max_sp)
		if hide_next:
			hide_next = false
		else:
			sp_changed.emit(sp - old_sp)

@export var atk: int
@export var def: int
@export var agi: int 

@export var ex: int
@export var level: int
@export var hp_growth: int
@export var sp_growth: int

var hide_next: bool = false

func initialize_battle_stats() -> void:
	hide_next = true
	sp = ceil(max_sp / 4.0)
	hide_next = true
	hp = max_hp

func level_up() -> void:
	level += 1
	max_hp += hp_growth + floor(agi / 3.0)
	max_sp += sp_growth + floor(agi / 4.0)
	ex = 0

func get_exp_multiplier() -> float:
	return 1.0 + 0.03 * agi

func get_exp_to_level() -> int:
	return ceil(10 + 0.8 * level + pow(level, 1.95))
