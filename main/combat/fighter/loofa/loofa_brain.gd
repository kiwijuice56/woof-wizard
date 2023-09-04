class_name LoofaBrain
extends Brain

var turn_cnt: int = 0

# randomly pick action is the default
func get_action(fighter: Fighter, player_party: Array[Fighter], enemy_party: Array[Fighter]) -> Dictionary:
	turn_cnt += 1
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
		if action.display_name == "def up" and fighter.def_buff == 2:
			continue
		if action.display_name == "atk up" and fighter.atk_buff == 2:
			continue
		
		if turn_cnt <= 2 and not (action.display_name == "def up" or action.display_name == "atk up"):
			continue
		return {"action": action, "targets": targets}
	return {}
