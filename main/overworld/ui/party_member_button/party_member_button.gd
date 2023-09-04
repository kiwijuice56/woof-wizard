class_name PartyMemberButton
extends Button

var fighter: Fighter

func initialize(new_fighter: Fighter) -> void:
	fighter = new_fighter
	if fighter == null:
		icon = preload("res://main/overworld/ui/party_icon/not_found2.png")
		disabled = true
	else:
		icon = fighter.party_icon
