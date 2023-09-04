class_name Devour
extends Attack

func commit(actor: Fighter, targets: Array[Fighter]) -> void:
	actor.stats.sp -= cost
	
	# We need to move players to enemy sprite
	var old_position: Vector2 = actor.global_position
	if actor.is_player:
		actor.global_position = targets.pick_random().global_position + Vector2(12, 0)
	
	# Play animations
	var anim_name: String = display_name
	if actor.has_node("CustomAnimationPlayer") and actor.get_node("CustomAnimationPlayer").has_animation(anim_name):
		actor.get_node("CustomAnimationPlayer").play(anim_name)
	else:
		actor.get_node("AnimationPlayer").play("hit")
	
	await actor.impact
	
	var total_damage: int = 0
	
	for target in targets:
		var dmg: int = calculate_damage(actor, target)
		target.stats.hp -= dmg
		total_damage += dmg
		var new_effect: Effect = effect.instantiate()
		get_tree().get_root().add_child(new_effect)
		new_effect.start(target)
	
	# Recover player sprite to their corner of the screen
	if actor.has_node("CustomAnimationPlayer") and actor.get_node("CustomAnimationPlayer").has_animation(anim_name):
		await actor.get_node("CustomAnimationPlayer").animation_finished
		actor.get_node("CustomAnimationPlayer").play("RESET")
	
	actor.global_position = old_position
	actor.stats.hp += ceil(total_damage / 2.0)
