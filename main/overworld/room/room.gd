class_name Room
extends Node2D

@export var camera_limit_bot: float 
@export var camera_limit_top: float
@export var camera_limit_left: float 
@export var camera_limit_right: float 

@export var persist_music: bool = false
@export var music: AudioStream
@export var volume: float = -4.0

@onready var anchors: Node2D = $Anchors

func _ready() -> void:
	$CollisionTileMap.collision_visibility_mode = 0
