class_name CombatButton
extends Button

@export var title_name: String
var cost: String = ""
var combo: String = ""
var action: Action

func initialize(new_action: Action, fighter: Fighter) -> void:
	action = new_action
	title_name = action.display_name
	if new_action.icon != null:
		icon = new_action.icon 
	
	if action.display_name in ["copal", "flan", "leche"]:
		cost = ""
		combo = "x" + str(GlobalData.data.inventory[action.display_name])
		disabled = GlobalData.data.inventory[action.display_name] <= 0
	else:
		cost = str(action.cost)
		combo = ""
		for i in new_action.combo:
			combo += "WDSA".substr(i, 1)
		disabled = fighter.stats.sp < action.cost
