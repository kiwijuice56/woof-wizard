class_name TextBox
extends CanvasLayer

const LABEL_SIZE: int = 18

signal advanced

var choice_idx: int = 0
var visible_char: int = 0:
	set(val):
		%Label.visible_characters = val
		if int(val) != visible_char:
			$VoicePlayer.stream = sound
			$VoicePlayer.play()
		visible_char = val
var sound: AudioStream 

func _ready() -> void:
	%Label.text = ""
	%Label.custom_minimum_size.y = 0
	%ChoiceContainer.visible = false
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept", false):
		advanced.emit()
	
	# everything from beyond here is for choice selection
	if not %ChoiceContainer.visible:
		return
	
	if event.is_action_pressed("ui_up", false):
		UISound.play_sound(UISound.select_sound)
		choice_idx = 0 if choice_idx == 1 else 1
	if event.is_action_pressed("ui_down", false):
		UISound.play_sound(UISound.select_sound)
		choice_idx = 1 if choice_idx == 0 else 0
	
	if choice_idx == 0:
		$AnimationPlayer.play("flicker_a")
	else:
		$AnimationPlayer.play("flicker_b")

func trans_in() -> void:
	%PersonIcon.visible = false
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%Label, "custom_minimum_size:y", LABEL_SIZE, 0.125)
	await tween.finished

func trans_out() -> void:
	%Label.visible_characters = 0
	%Label.text = ""
	%PersonIcon.visible = false
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%Label, "custom_minimum_size:y", 0, 0.125)
	await tween.finished
	visible = false

# convos are only linear with a choice at the end
# choice_a and choice_b only matter if they are the last in the sequence
func convo(lines: Array[Line]) -> bool:
	for i in range(len(lines)):
		$MiniDelay.start()
		await $MiniDelay.timeout
		
		var line: Line = lines[i]
		%Label.visible_characters = 0
		%Label.text = line.text
		%PersonIcon.visible = true
		%PersonIcon.texture = line.icon
		sound = line.voice
		
		visible_char = 0
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "visible_char", len(line.text), line.speed * len(line.text) * 0.8)
		await tween.finished
		
		if i == len(lines) - 1:
			
			if line.choice_a != "":
				%ChoiceContainer.visible = true
				$AnimationPlayer.play("flicker_a")
				choice_idx = 0
				
				await advanced
				if choice_idx == 0:
					UISound.play_sound(UISound.accept_sound)
				else:
					UISound.play_sound(UISound.cancel_sound)
				
				%ChoiceContainer.visible = false
				
				return choice_idx == 0
			else:
				await advanced
				$AcceptPlayer.play()
		else:
			$AnimationPlayer.play("flicker")
			await advanced
			$AcceptPlayer.play()
			$AnimationPlayer.play("RESET")
			
	%PersonIcon.visible = false
	return false

