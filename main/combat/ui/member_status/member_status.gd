class_name MemberStatus
extends VBoxContainer

var fighter: Fighter

func initialize(new_fighter: Fighter) -> void:
	fighter = new_fighter
	fighter.stats.hp_changed.connect(_on_hp_changed)
	fighter.stats.sp_changed.connect(_on_sp_changed)
	
	_on_hp_changed(0)
	_on_sp_changed(0)

func _on_hp_changed(change: int) -> void:
	%HPLabel.text = str(fighter.stats.hp)

func _on_sp_changed(change: int) -> void:
	%SPLabel.text = str(fighter.stats.sp)
