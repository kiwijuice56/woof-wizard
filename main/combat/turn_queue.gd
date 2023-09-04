class_name TurnQueue
extends Node2D

@onready var combat_ui: CombatInterface = get_tree().get_root().get_node("Main/CombatLayer/CombatInterface")

var player_party: Array[Fighter]
var enemy_party: Array[Fighter]

func _agility_sort(a: Fighter, b: Fighter) -> bool:
	return a.stats.agi > b.stats.agi

func initialize_parties(p: Array[Fighter], encounter: Array[PackedScene]) -> void:
	player_party = []
	player_party.append_array(p)
	for player in player_party:
		player.is_player = true
		player.initialize_battle_stats()
	combat_ui.initialize_party_members(player_party)
	
	enemy_party = []
	for enemy in encounter:
		var new_enemy: Fighter = enemy.instantiate()
		add_child(new_enemy)
		new_enemy.initialize_battle_stats()
		enemy_party.append(new_enemy)

func position_fighters() -> void:
	# only works for parties of 2, ofc
	for i in range(len(player_party)):
		player_party[i].global_position = $BattlePositions.get_child(i).global_position
	for i in range(len(enemy_party)):
		var pivot: Node2D = $BattlePositions.get_child(1 + len(enemy_party))
		enemy_party[i].global_position = pivot.get_child(i).global_position

func battle() -> int:
	combat_ui.get_node("%InfoLabel").text = "a battle breaks out!!!"
	$DelayTimer.start(2.0)
	await $DelayTimer.timeout
	
	while true:
		# Check for battle end
		if len(strip_dead(player_party)) == 0 or len(strip_dead(enemy_party)) == 0:
			break
		
		# Make decisions before the turn starts
		var decisions: Dictionary = {}
		for fighter in player_party:
			if fighter.is_alive():
				# We leave dead party members for players, in case of revival spells
				decisions[fighter] = await combat_ui.select_action(fighter, player_party, strip_dead(enemy_party))
				$DelayTimer.start(0.1)
				await $DelayTimer.timeout
		for fighter in enemy_party: 
			# {stupidball : {action: fight, targets: stupidballs}}
			if fighter.is_alive():
				decisions[fighter] = fighter.brain.get_action(fighter, strip_dead(player_party), strip_dead(enemy_party))
		
		combat_ui.get_node("%InfoLabel").text = ""
		
		# Get the turn order
		var turn_order: Array[Fighter] = strip_dead(player_party) + strip_dead(enemy_party)
		turn_order.sort_custom(_agility_sort)
		
		for fighter in turn_order:
			if len(strip_dead(player_party)) == 0 or len(strip_dead(enemy_party)) == 0:
				break
			
			# Do their turn!
			if fighter.is_alive():
				# We need to check if an action would fail (against dead targets)
				# so that the player doesn't waste a turn
				var alive_targets: Array[Fighter] = strip_dead(decisions[fighter].targets)
				
				# Exception for revival spells
				if decisions[fighter].action.target_dead:
					alive_targets = decisions[fighter].targets
				
				# This will only ever be true for single target attacks, otherwise
				# the battle would have ended ... only need to check if 
				# the action was towards own party or other party
				while len(alive_targets) == 0:
					var new_fighter: Fighter
					if not decisions[fighter].targets[0].is_player:
						new_fighter = enemy_party.pick_random()
					else:
						new_fighter= player_party.pick_random()
					
					if new_fighter.is_alive():
						alive_targets.append(new_fighter)
				
				# show that the fighter is going to move
				fighter.get_node("AnimationPlayer").play("turn")
				await fighter.get_node("AnimationPlayer").animation_finished
				
				# all status effect code
				if "burning" in fighter.status_effects:
					fighter.stats.hp = max(1, fighter.stats.hp - ceil(fighter.stats.max_hp * 0.05))
					fighter.get_node("BurningPlayer").play()
					combat_ui.get_node("%InfoLabel").text = fighter.display_name + " is burning!"
					$DelayTimer.start(0.8)
					await $DelayTimer.timeout
				if "blessed" in fighter.status_effects:
					fighter.get_node("BlessedPlayer").play()
					fighter.stats.hp = min(fighter.stats.max_hp, fighter.stats.hp + ceil(fighter.stats.max_hp * 0.10))
					fighter.stats.sp = min(fighter.stats.max_sp, fighter.stats.sp + ceil(fighter.stats.max_sp * 0.10))
					combat_ui.get_node("%InfoLabel").text = fighter.display_name + " is blessed!"
					$DelayTimer.start(0.8)
					await $DelayTimer.timeout
				if "dizzy" in fighter.status_effects and not fighter.is_player and randf() < 0.35:
					fighter.get_node("DizzyPlayer").play()
					combat_ui.get_node("%InfoLabel").text = fighter.display_name + " is dumbfounded!"
					$DelayTimer.start(0.8)
					await $DelayTimer.timeout
					
					# since we skipped the code below, we need to tick status once
					fighter.tick_status()
					
					continue
				
				
				fighter.tick_status()
				
				# Display what action is taking place
				combat_ui.get_node("%InfoLabel").text = decisions[fighter].action.attack_description % fighter.display_name
				
				$DelayTimer.start(0.4)
				await $DelayTimer.timeout
				
				if decisions[fighter].action is Combo:
					decisions[fighter].action.player_party = strip_dead(player_party)
					decisions[fighter].action.enemy_party = strip_dead(enemy_party)
				await decisions[fighter].action.commit(fighter, alive_targets)
				
				$DelayTimer.start(0.4)
				await $DelayTimer.timeout
				
				combat_ui.get_node("%InfoLabel").text = ""
	if len(strip_dead(player_party)) == 0:
		get_tree().get_root().get_node("Main").game_over()
	$DelayTimer.start(1.0)
	await $DelayTimer.timeout
	combat_ui.get_node("%InfoLabel").text = ""
	
	var exp_gain: int = 0
	for fighter in enemy_party:
		exp_gain += fighter.stats.ex
	return exp_gain

func strip_dead(party: Array[Fighter]) -> Array[Fighter]:
	var new_party: Array[Fighter] = []
	for member in party:
		if member.is_alive():
			new_party.append(member)
	return new_party
