extends Resource
class_name Decider

signal decision_made
signal interface_request

onready var interface

#Move-Validierung muss wahrscheinlich zu Creature verschoben werden.

func make_decision(predictions, iteration, knowledge):
	var left_attacker = null
	var right_attacker = null
	var actions = [] 
	
	if knowledge.is_ally:
		left_attacker = knowledge.battlefield.get_fighter(GameEnums.LEFT_ALLY)
		right_attacker = knowledge.battlefield.get_fighter(GameEnums.RIGHT_ALLY)
	else:
		left_attacker  = knowledge.battlefield.get_fighter(GameEnums.LEFT_ENEMY)
		right_attacker = knowledge.battlefield.get_fighter(GameEnums.RIGHT_ENEMY)
	
	if left_attacker is Creature:
		actions.append(process_restrictions(get_action(left_attacker, knowledge)))
	if right_attacker is Creature:
		actions.append(process_restrictions(get_action(right_attacker, knowledge)))
	
	emit_signal("decision_made", actions, iteration, knowledge)


func process_restrictions(action : Action) -> Action:
	if action.user.repeating > 0:
		return action.user.previous_action
	
	elif action.user.previous_action != null:
		if action.user.previous_action.move.uses_additional_spell == "After":
			var new_action = Action.new()
			new_action.target = action.user.previous_action.target
			new_action.user = action.user
			new_action.move = action.user.previous_action.move.extra_spell
			return new_action
	
	return action


func sort_by_weight(a, b):
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	
	if a[1] == b[1]:
		if rng.randi()%2 == 0:
			return false
		else:
			return true
	
	if a[1] > b[1]:
		return true
	else:
		return false

func get_action(attacker: Creature, knowledge : Knowledge) -> Action:
	return get_action_list(attacker, knowledge)[0]

func get_switch_in(slot : int, knowledge : Knowledge) -> int:
	return 0

func get_action_list(attacker, knowledge) -> Array:
	#Switch Action fehlt
	
	var left_enemy = null
	var right_enemy = null
	var partner = null
	var is_targeting_left = true
	var action_list = []
	
	if knowledge.is_ally:
		left_enemy = knowledge.battlefield.get_fighter(GameEnums.LEFT_ENEMY)
		right_enemy = knowledge.battlefield.get_fighter(GameEnums.RIGHT_ENEMY)
	else:
		left_enemy = knowledge.battlefield.get_fighter(GameEnums.LEFT_ALLY)
		right_enemy = knowledge.battlefield.get_fighter(GameEnums.RIGHT_ALLY)
	
	partner = knowledge.battlefield.get_partner(attacker.battle_slot)
	
	for move in attacker.moves:
		if move == null:
			continue
		
		if move.multitarget:
			var action = Action.new()
			action.user = attacker
			action.move = move
			action.target = CombatUtility.convert_targets(attacker.battle_slot, move.targets, knowledge.battlefield)
			action_list.append(action)
		
		else:
			if left_enemy is Creature:
				match move.targets:
					"Others", "Enemies", "All":
						var left_action = Action.new()
						left_action.user = attacker
						left_action.move = move
						left_action.target = [left_enemy.battle_slot]
						action_list.append(left_action)
			
			if right_enemy is Creature:
				match move.targets:
					"Others", "Enemies", "All":
						var right_action = Action.new()
						right_action.user = attacker
						right_action.move = move
						right_action.target = [right_enemy.battle_slot]
						action_list.append(right_action)
			
			if partner is Creature:
				match move.targets:
					"Others", "All", "Allies", "Partner":
						var on_partner_action = Action.new()
						on_partner_action.user = attacker
						on_partner_action.move = move
						on_partner_action.target = [partner.battle_slot]
						action_list.append(on_partner_action)
			
			match move.targets:
				"All", "Allies", "Self":
					var on_self_action = Action.new()
					on_self_action.user = attacker
					on_self_action.move = move
					on_self_action.target = [attacker.battle_slot]
					action_list.append(on_self_action)
	
	return action_list


func simulate_turn():
	pass


#func simulate_action():
#		var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	var defender
#	var total_damage_dealt = 0
#
#	if action.move == switch:
#		if action.user.rooted == 0:
#			emit_signal("switch", action.user.battle_slot, action.target[0])
#			return
#		else:
#			emit_signal("battle_log_event", "Failed_Switch", {"victim": action.user.get_display_name()})
#			return
#
#	var test  = apply_modifier(action.move, action.user, action.target, "Before")
#	if not test:
#		emit_signal("battle_log_event", "Failed_Move", {})
#		return
#
#	action.user.set_repetition_counter(action)
#
#	if action.move.element == "Lightning":
#		var lightning_targets = fighters.duplicate()
#		lightning_targets.erase(action.user)
#		for target in lightning_targets.duplicate():
#			if target.charge_stacks < 1:
#				lightning_targets.erase(target)
#		if lightning_targets.size() > 0:
#			action.target.clear()
#			if action.target.size() <= 1:
#				action.target.append(lightning_targets[rng.randi_range(0, lightning_targets.size()-1)].battle_slot)
#			else:
#				for fighter in lightning_targets:
#					action.target.append(fighter.battle_slot)
#
#	for defender_slot in action.target:
#		defender = battlefield.get_fighter(defender_slot)
#
#		if defender == null:
#			emit_signal("battle_log_event", "Miss", {})
#			continue
#
#		if action.move.condition is Resource and (action.move.uses_additional_spell == "No" or action.move.uses_additional_spell == "After"):
#			if action.move.condition.check_condition(action.user, defender) == false:
#				emit_signal("battle_log_event", "Failed_Move", {})
#				continue
#
#		if action.move.condition is Resource and (action.move.uses_additional_spell == "On Condition"):
#			if action.move.condition.check_condition(action.user, defender) == true:
#				action.move = action.move.extra_spell
#		elif action.move.condition is Resource and (action.move.uses_additional_spell == "Not on Condition"):
#			if action.move.condition.check_condition(action.user, defender) == false:
#				action.move = action.move.extra_spell
#
#		if defender.is_protected:
#			emit_signal("battle_log_event", "Protected" , {"target": defender.get_display_name()})
#			continue
#
#		var iterator = 0
#		var attack_count = action.move.attack_count
#		if action.move.attack_count_factor is Resource:
#			attack_count = action.move.attack_count_factor.get_factor(action.user, defender, attack_count)
#		if attack_count <= 0:
#			emit_signal("battle_log_event", "Failed_Move", {})
#
#		while iterator < attack_count:
#			iterator += 1
#
#			if defender.current_hp < 0:
#				continue
#
#			if get_accuracy(action.move, defender) < rng.randi_range(1, 100):
#				emit_signal("battle_log_event", "Miss", {})
#				continue
#
#			if defender.shield > 0:
#				defender.shield -= 1
#				emit_signal("battle_log_event", "Protected" , {"target": defender.get_display_name()})
#				if defender.shield == 0:
#					emit_signal("battle_log_event", "Shield_Break", {})
#				continue
#
#			if defender.moss_stacks > 4:
#				emit_signal("battle_log_event", "Moss_Protection" , {"target": defender.get_display_name()})
#				defender.moss_stacks = 0
#				continue
#
#			var damage = apply_damage(action.move, action.user, defender)
#			total_damage_dealt += damage
#
#			apply_modifier(action.move, action.user, [defender.battle_slot], "On-Hit")
#
#			if action.user.current_hp <= 0:
#				emit_signal("knockout", action.user)
#
#
#	apply_modifier(action.move, action.user, action.target, "After")
#
#	action.user.previous_action = action
#
#	if total_damage_dealt == 0:
#			action.user.repetition_counter = 0
#			action.user.repeating = 0
