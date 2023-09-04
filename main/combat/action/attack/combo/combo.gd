class_name Combo
extends Attack

@onready var combo_circle: ComboCircle = get_tree().get_root().get_node("Main/CombatLayer/CombatInterface/ComboCircle")

var player_party: Array[Fighter]
var enemy_party: Array[Fighter]

func commit(actor: Fighter, targets: Array[Fighter]) -> void:
	# We need to move players to enemy sprite
	var old_position: Vector2 = actor.global_position
	actor.global_position = targets.pick_random().global_position + Vector2(12, 0)
	actor.visible = false
	
	combo_circle.show_circle()
	await get_tree().create_timer(0.5).timeout
	
	var original_power: float = power
	
	var inputs: Array[int] = []
	for i in range(3):
		if not targets[0].is_alive():
			break
		
		var idx: int = await combo_circle.time_attack(randf_range(0.5, 3.5) if "dizzy" in actor.status_effects else 2.0)
		inputs.append(idx)
		actor.visible = true
		
		if idx != -1:
			actor.get_node("CustomAnimationPlayer").stop()
			actor.get_node("CustomAnimationPlayer").play(str(idx))
			await actor.impact
			
			power = original_power + actor.stats.level * pow(1.25 * combo_circle.strength, 2)
			
			for target in targets:
				var dmg: int = ceil(calculate_damage(actor, target) * (combo_circle.strength * 0.2 + 0.6))
				actor.stats.sp += ceil(dmg * 0.5)
				target.stats.hp -= dmg
				var new_effect: Effect = effect.instantiate()
				get_tree().get_root().add_child(new_effect)
				new_effect.start(target)
			
			
			
			power = original_power
		else:
			actor.get_node("CustomAnimationPlayer").stop()
			actor.get_node("CustomAnimationPlayer").play("flop")
			await actor.impact
	
	await actor.get_node("CustomAnimationPlayer").animation_finished
	
	var combo_played: bool = false
	
	# Don't do any combo moves if the main target died
	if targets[0].is_alive():
		for action in actor.actions.get_children():
			var was_combo: bool = action.cost <= actor.stats.sp
			for i in range(3):
				if i >= len(action.combo) or i >= len(inputs) or action.combo[i] != inputs[i]:
					was_combo = false
					break
			if was_combo:
				combo_played = true
				combo_circle.set_combo_label(action.display_name)
				var new_targets: Array[Fighter] = targets
				if action.target_count == "all" or action.target_type == "own":
					new_targets = get_new_targets(action)
				
				await action.commit(actor, new_targets)
	
	# actions should clean up the animation state, so we need to clean up if
	# no further action was played
	if not combo_played:
		actor.get_node("CustomAnimationPlayer").play("RESET")
	actor.global_position = old_position
	
	combo_circle.hide_circle()

func get_new_targets(action: Action) -> Array[Fighter]:
	var party: Array[Fighter]
	var targets: Array[Fighter] = []
	
	if action.target_type == "own":
		party = player_party
	else:
		party = enemy_party
	
	if action.target_count == "single":
		targets.append(party.pick_random())
	else:
		targets.append_array(party)
	
	return targets
