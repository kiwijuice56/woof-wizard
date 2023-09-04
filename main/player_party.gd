class_name PlayerParty
extends Node2D

# internal name as key
@export var party_members: Dictionary = {
	"wizzrobe": preload("res://main/combat/fighter/wizzrobe/wizzrobe.tscn"),
	"loofa": preload("res://main/combat/fighter/loofa/loofa.tscn"),
	"chiqui": preload("res://main/combat/fighter/chiqui/chiqui.tscn")
}

# Same as party_members but with the value being the instance of that party member
var party_member_current: Dictionary = {}

func load_data() -> void:
	# Check if save data exists (for stats)
	if ResourceLoader.exists("user://wizzrobe.tres"):
		for member_internal_name in GlobalData.data.party_config:
			var fighter: Fighter = add_party_member(member_internal_name)
			fighter.set_stats(ResourceLoader.load("user://" + member_internal_name + ".tres"))
	else:
		# Default party
		add_party_member("wizzrobe")
		GlobalData.data.party_config = ["wizzrobe"]

func save_data() -> void:
	for member in get_ordered_party():
		ResourceSaver.save(member.stats, "user://" + member.internal_name + ".tres")

func add_party_member(member_internal_name: String) -> Fighter:
	var new_member: Fighter = party_members[member_internal_name].instantiate()
	add_child(new_member)
	party_member_current[member_internal_name] = new_member
	return new_member

func get_ordered_party() -> Array[Fighter]:
	var ordered_party: Array[Fighter] = []
	for internal_name in GlobalData.data.party_config:
		if len(ordered_party) >= 2:
			party_member_current[internal_name].visible = false 
		else:
			party_member_current[internal_name].visible = true
			ordered_party.append(party_member_current[internal_name])
	return ordered_party

func distribute_exp(xp: int, status: StatusContainer) -> void:
	for party_member in get_children():
		var xp_remaining: int = xp * party_member.stats.get_exp_multiplier()
		while xp_remaining > 0 and party_member.stats.ex + xp_remaining >= party_member.stats.get_exp_to_level():
			xp_remaining -= party_member.stats.get_exp_to_level() - party_member.stats.ex
			party_member.stats.level_up()
			
			status.visible = true
			UISound.play_sound(UISound.level_up_sound)
			var stat: String = await status.show_fighter(party_member, "level_up")
			party_member.stats.set(stat, party_member.stats.get(stat) + 1)
		party_member.stats.ex += xp_remaining
	status.visible = false
