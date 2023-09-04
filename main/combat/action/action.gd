class_name Action
extends Node

@export var display_name: String
@export var attack_description: String
@export var description: String
@export var combo: Array[int] = [0, 0, 0]
@export_enum("own", "other") var target_type: String 
@export_enum("single", "all") var target_count: String 
@export var target_dead: bool = false
@export var cost: int
@export var effect: PackedScene
@export var icon: Texture

signal impact

func commit(actor: Fighter, targets: Array[Fighter]) -> void:
	pass
