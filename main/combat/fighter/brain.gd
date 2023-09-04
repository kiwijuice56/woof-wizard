class_name Brain
extends Node

# randomly pick action is the default
func get_action(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Dictionary:
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
	
	return {"action": action, "targets": targets}
