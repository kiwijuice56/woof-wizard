class_name BallBrain
extends Brain

# randomly pick action is the default
func get_action(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Dictionary:
	while true:
		var action: Action = fighter.actions.get_children().pick_random()
		var party: Array[Fighter]
		var targets: Array[Fighter] = []
		
		if action.target_type == "own":
			party = enemy_party
		else:
			party = player_party
		
		if action.target_count == "single":
			targets.append(party.pick_random())
		else:
			targets.append_array(party)
		
		# basically, dont allow wasting buffs
		if action.display_name == "atk down" and targets[0].atk_buff == -2:
			continue
		if action.display_name == "canon" and "burning" in targets[0].status_effects:
			continue
		return {"action": action, "targets": targets}
	return {}
