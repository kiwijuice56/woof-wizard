class_name Attack
extends Action
# also include healing spells

# these toggles are bad coding practice, but id rather have this quick and dirty solution than
# make a bunch more classes atm
@export var heal: bool = false
@export var affect_sp: bool = false
@export var inflicts_burning: bool = false
@export var inflicts_blessed: bool = false
@export var inflicts_dizzy: bool = false

@export var power: float = 1.0

func commit(actor: Fighter, targets: Array[Fighter]) -> void:
	actor.stats.sp -= cost
	# horrible code, but all items are attacks so this is ok
	if display_name in ["copal", "flan", "leche"]:
		if GlobalData.data.inventory[display_name] <= 0:
			return
		GlobalData.data.inventory[display_name] -= 1
	
	# We need to move players to enemy sprite
	var old_position: Vector2 = actor.global_position
	if actor.is_player and not targets[0].is_player:
		actor.global_position = targets.pick_random().global_position + Vector2(12, 0)
	
	# Play animations
	var anim_name: String = display_name
	if actor.has_node("CustomAnimationPlayer") and actor.get_node("CustomAnimationPlayer").has_animation(anim_name):
		actor.get_node("CustomAnimationPlayer").play(anim_name)
	else:
		actor.get_node("AnimationPlayer").play("status" if heal else "hit")
	
	await actor.impact
	
	for target in targets:
		# yeah this is what im resorting to. sorry. yandere dev code
		if display_name == "copal":
			target.reset_status()
		
		if inflicts_burning:
			target.add_status("burning")
		if inflicts_blessed:
			target.add_status("blessed")
		if inflicts_dizzy:
			target.add_status("dizzy")
		
		if power > 0:
			if affect_sp:
				target.stats.sp -= calculate_damage(actor, target) if not heal else -ceil(target.stats.max_sp * power)
			else:
				target.stats.hp -= calculate_damage(actor, target) if not heal else -ceil(target.stats.max_hp * power)
		var new_effect: Effect = effect.instantiate()
		get_tree().get_root().add_child(new_effect)
		new_effect.start(target)
	
	# Recover player sprite to their corner of the screen
	if actor.has_node("CustomAnimationPlayer") and actor.get_node("CustomAnimationPlayer").has_animation(anim_name):
		await actor.get_node("CustomAnimationPlayer").animation_finished
		actor.get_node("CustomAnimationPlayer").play("RESET")
	
	actor.global_position = old_position

func calculate_damage(attacker: Fighter, target: Fighter) -> int:
	var atk: int = attacker.stats.atk
	if attacker.is_player and "atk charm" in GlobalData.data.inventory:
		print("atk charm used")
		atk += int(0.14 * atk)
	var def: int = target.stats.def
	if target.is_player and "def charm" in GlobalData.data.inventory:
		print("def charm used")
		def += int(0.14 * def)
	
	var atk_pow: int = int((atk + attacker.stats.level / 3.0 + power + randf() * 0.1 * attacker.stats.atk) * pow(1.45, attacker.atk_buff))
	var def_pow: int = int((def * 1.2 + target.stats.level / 6.0) * pow(1.7, target.def_buff))
	return ceil(atk_pow * 6.0 / (6.0 + def_pow))
