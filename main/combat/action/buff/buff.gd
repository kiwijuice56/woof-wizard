class_name Buff
extends Action

@export_enum("def", "atk") var buff_type: String
@export var stage: int 

func commit(actor: Fighter, targets: Array[Fighter]) -> void:
	actor.stats.sp -= cost
	
	# We need to move players to enemy sprite
	var old_position: Vector2 = actor.global_position
	# BUT we don't want to do so if the targets are players, it just looks weird
	if actor.is_player and not targets[0].is_player:
		actor.global_position = targets.pick_random().global_position + Vector2(12, 0)
	
	# Play animations
	var anim_name: String = display_name
	if actor.has_node("CustomAnimationPlayer") and actor.get_node("CustomAnimationPlayer").has_animation(anim_name):
		actor.get_node("CustomAnimationPlayer").play(anim_name)
	else:
		actor.get_node("AnimationPlayer").play("status")
	
	await actor.impact
	
	for target in targets:
		if target.set_buff(buff_type + "_buff", stage):
			var new_effect: Effect = effect.instantiate()
			get_tree().get_root().add_child(new_effect)
			new_effect.start(target)
	
	# Recover player sprite to their corner of the screen
	if actor.has_node("CustomAnimationPlayer") and actor.get_node("CustomAnimationPlayer").has_animation(anim_name):
		await actor.get_node("CustomAnimationPlayer").animation_finished
		actor.get_node("CustomAnimationPlayer").play("RESET")
	
	actor.global_position = old_position
