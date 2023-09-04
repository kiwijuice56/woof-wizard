class_name Player
extends Area2D

@onready var menu: OverworldInterface = get_tree().get_root().get_node("Main/OverworldLayer/OverworldInterface")

@export_range(1, 60, 1, "suffix:pixel/s") var speed: float = 32.0
@export_range(1, 120, 1, "suffix:pixel/s") var fall_speed: float = 32.0

var can_interact: bool = true
var can_move: bool = false
var on_floor: bool = false
var first_landing: bool = true

func _physics_process(delta: float) -> void:
	if position.y >= $Camera2D.limit_bottom + 32:
		get_tree().get_root().get_node("Main").game_over()
	
	if not can_move:
		can_interact = false
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
		return
	
	if $AnimationPlayer.current_animation in ["jump_up", "jump_down"]:
		return
	
	# Gravity
	$FloorLeftRayCast2D.force_raycast_update()
	$FloorRightRayCast2D.force_raycast_update()
	if not $FloorLeftRayCast2D.is_colliding() and not $FloorRightRayCast2D.is_colliding():
		can_interact = false
		if on_floor:
			$AnimationPlayer.play("jump_down")
			await $AnimationPlayer.animation_finished
			$Sprite2D.position.y = 0
			$Camera2D.position.y = 0
			position.y += 8
		position.y += delta * fall_speed 
		on_floor = false
		return
	elif not on_floor:
		on_floor = true
		can_interact = true
		if not first_landing:
			$ThudPlayer.play()
		else:
			# workaround to prevent the landing sound when room is loading
			first_landing = false
		position.y = snapped(position.y, 4) 
	
	# Jumping and falling
	if Input.is_action_just_pressed("ui_up"):
		if can_change_elevation(-1):
			can_interact = false
			$AnimationPlayer.play("jump_up")
			await $AnimationPlayer.animation_finished
			$ThudPlayer.play()
			$Sprite2D.position.y = 0
			$Camera2D.position.y = 0
			position.y -= 8
			can_interact = true
		else:
			$AnimationPlayer.play("up")
	elif Input.is_action_just_pressed("ui_down"):
		if can_change_elevation(1):
			can_interact = false
			$AnimationPlayer.play("jump_down")
			await $AnimationPlayer.animation_finished
			$ThudPlayer.play()
			$Sprite2D.position.y = 0
			$Camera2D.position.y = 0
			position.y += 8
			can_interact = true
		else:
			$AnimationPlayer.play("down")
	# Walking
	elif Input.is_action_pressed("ui_left"):
		$WallRayCast2D.target_position.x = -2
		$WallRayCast2D.force_raycast_update()
		if not $WallRayCast2D.is_colliding():
			$AnimationPlayer.play("walk_left")
			position.x -= delta * speed
		else:
			$AnimationPlayer.play("left")
	
	elif Input.is_action_pressed("ui_right"):
		$WallRayCast2D.target_position.x = 1
		$WallRayCast2D.force_raycast_update()
		if not $WallRayCast2D.is_colliding():
			$AnimationPlayer.play("walk_right")
			position.x += delta * speed
		else:
			$AnimationPlayer.play("right")
	elif $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()

func can_change_elevation(dir: int) -> bool:
	$FloorLeftRayCast2D.position.y += dir * 8
	$FloorRightRayCast2D.position.y += dir * 8
	
	$FloorLeftRayCast2D.force_raycast_update()
	$FloorRightRayCast2D.force_raycast_update()
	
	$FloorLeftRayCast2D.position.y -= dir * 8
	$FloorRightRayCast2D.position.y -= dir * 8
	return $FloorLeftRayCast2D.is_colliding() and $FloorRightRayCast2D.is_colliding()

func pan_camera(amt: Vector2, time: float = 0.2) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Camera2D, "position", $Camera2D.position + amt, time)
	await tween.finished
