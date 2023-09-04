class_name ComboCircle
extends Node2D

@export var gradient: GradientTexture1D

var fall_speed: float = 2.0
var strength: float = 0.0
var letter_cnt: int = 0

signal pressed(dir: int)

func _ready() -> void:
	visible = false
	set_physics_process(false)
	set_process_input(false)

func _physics_process(delta: float) -> void:
	%Outer.scale -= Vector2(1, 1) * fall_speed * delta
	%Outer.modulate = gradient.gradient.sample(get_strength())
	fall_speed += 0.015
	if %Outer.scale.length() <= 0.1:
		pressed.emit(-1)

func _input(event: InputEvent) -> void:
	var inputs: Array[String] = ["ui_up", "ui_right", "ui_down", "ui_left"]
	for i in range(len(inputs)):
		if event.is_action_pressed(inputs[i], false):
			$HelpLabel.visible = false
			pressed.emit(i)

func time_attack(speed: float = 2) -> int:
	$Timer.start(0.2)
	await $Timer.timeout
	
	%Outer.scale = Vector2(1.3, 1.3) 
	$Label.text = ""
	%Outer.modulate = gradient.gradient.sample(0)
	
	fall_speed = speed
	
	set_physics_process(true)
	set_process_input(true)
	
	var idx: int = await pressed
	
	strength = get_strength()
	if strength <= 0:
		idx = -1
	
	$Label.modulate = gradient.gradient.sample(get_strength())
	$Letters.get_child(letter_cnt).modulate.a = 1.0
	$Letters.get_child(letter_cnt).set("theme_override_colors/font_color", $Label.modulate) 
	
	if idx != -1:
		$CrashPlayer.play()
		
		$Letters.get_child(letter_cnt).text = "WDSA".substr(idx, 1)
		$Label.text = "WDSA".substr(idx, 1)
	else:
		$MissPlayer.play()
		$Label.text = "X"
		$Letters.get_child(letter_cnt).text = "X"
	
	letter_cnt += 1
	
	set_physics_process(false)
	set_process_input(false)
	
	return idx

func show_circle() -> void:
	# $HelpLabel.visible = true
	$HelpLabel/AnimationPlayer.seek(0)
	
	%Outer.scale = Vector2(1.3, 1.3) 
	$Label.text = ""
	%Outer.modulate = gradient.gradient.sample(0)
	
	for letter in $Letters.get_children():
		letter.text = ""
	
	$SkillLabel.text = ": "
	letter_cnt = 0
	visible = true

func hide_circle() -> void:
	visible = false

func set_combo_label(skill_name: String) -> void:
	$SkillLabel.text += skill_name

func get_strength() -> float:
	if %Outer.scale.x >= .75 or %Outer.scale.x <= 0.25:
		return 0.0
	else:
		return pow(1.0 - abs(0.25 - (%Outer.scale.x - .25)) / 0.25, 3)
