extends Node
class_name BattleQueue

signal battle_log_event
signal knockout
signal switch
signal modifier_connect
signal modifier_disconnect
signal round_finished

enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}

onready var battlefield = $Battlefield
onready var damage_calculator = $DamageCalculator
onready var sorter = $Sorter
onready var switch = preload("res://Resources/Creatures/Spells/0_Technical/Switch.tres")
onready var recharge = preload("res://Resources/Creatures/Spells/0_Technical/Recharge.tres")

var round_counter = 1
var fighters = []
var actions = []

onready var fire_effect = preload("res://Resources/CombatModifier/Fire_Fire.tres")
onready var frost_effect = preload("res://Resources/CombatModifier/Frost_Water.tres")
onready var water_effect = preload("res://Resources/CombatModifier/Water_Ground.tres")
onready var lightning_effect = preload("res://Resources/CombatModifier/Lightning_Lightning.tres")
onready var ground_effect = preload("res://Resources/CombatModifier/Ground_Ground.tres")

onready var frost_attack = preload("res://Resources/CombatModifier/Frost_Attack.tres")
onready var water_attack = preload("res://Resources/CombatModifier/Water_Attack.tres")
onready var ground_attack = preload("res://Resources/CombatModifier/Ground_Attack.tres")

func ready():
	pass
	#switch = preload("res://Resources/Creatures/Spells/0_Technical/Switch.tres")
	#recharge = preload("res://Resources/Creatures/Spells/0_Technical/Recharge.tres")

func initialize_queue(left_ally, right_ally, left_enemy, right_enemy):
	fighters = []

	if left_ally is Creature:
		fighters.append(left_ally)
	if right_ally is Creature:
		fighters.append(right_ally)
	if left_enemy is Creature:
		fighters.append(left_enemy)
	if right_enemy is Creature:
		fighters.append(right_enemy)


func execute_combat_turn():
	
	for creature in fighters:
		creature.prepare_for_turn()
	
	for action in actions:
		apply_priority_boni(action)
	
	while actions.size() > 0:
		
		actions.sort_custom($Sorter, "sort_for_battle_queue")
		var action = actions.pop_front()
		
		if is_fighter_unable_to_move(action.user):
			action.user.made_turn = true
			action.user.repetition_counter = 0
			action.user.repeating = 0
			yield(get_tree().create_timer(2.0), "timeout")
			continue
		
		if action.move == switch:
			if test_for_ally(action.user.battle_slot):
				emit_signal("battle_log_event", "Switch", {"switch_out": action.user.get_display_name(), 
						"switch_in": battlefield.get_ally_reserve()[action.target[0]].get_display_name()})
			else:
				emit_signal("battle_log_event", "Switch", {"switch_out": action.user.get_display_name(), 
						"switch_in": battlefield.get_enemy_reserve()[action.target[0]].get_display_name()})
		else:
			emit_signal("battle_log_event", "Attack", {"attacker": action.user.get_display_name(), 
					"action": action.move.name})
				
		execute_action(action)
		emit_signal("battle_log_event", "Reset_Stat_Value_Iterator", {})
		
		if action.move != switch:
			action.user.made_turn = true
		yield(get_tree().create_timer(2.0), "timeout")
	
	advance_round_counter()
	emit_signal("round_finished")

func is_fighter_unable_to_move(creature):
	if creature.current_hp <= 0:
		return true
	
	if creature.stagger_stacks >= 2:
		emit_signal("battle_log_event", "Stunned", {"victim":creature.get_display_name()})
		return true
	
	if creature.is_knocked_over:
		creature.is_knocked_over = false
		emit_signal("battle_log_event", "Knock_Over_Recover", {"victim": creature.get_display_name()})
		return true
	
	if creature.frost_stacks >= 5:
		emit_signal("battle_log_event", "Frozen", {"victim": creature.get_display_name()})
		return true
	
	if creature.moss_stacks >= 5:
		emit_signal("battle_log_event", "Mossed", {"victim": creature.get_display_name()})
		return true
	
	return false

func advance_round_counter():
	emit_signal("battle_log_event", "Add_Separator", {})
	
	for fighter in fighters:
		fighter.progress_quests("RoundEnd", {"self": fighter, "fighters": fighters})
	
	for fighter in fighters:
		if battlefield.has_field_effect("Rain"):
			fighter.apply_wet(1)
	
	for fighter in fighters:
		if battlefield.has_field_effect("Ember"):
			fighter.apply_burn(1)
	
	for fighter in fighters:
		if fighter.burn_stacks > 0:
			fighter.change_health(fighter.current_hp - fighter.burn_stacks)
			emit_signal("battle_log_event", "Fire_Damage", {"target": fighter.get_display_name(), "value": fighter.burn_stacks})
			if fighter.current_hp <= 0:
				emit_signal("knockout", fighter)
			if fighter.moss_stacks > 0:
				fighter.moss_stacks -= 1
				fighter.burn_stacks += 1
	
	for fighter in fighters:
		if fighter.frost_stacks > 0 and fighter.wet_stacks > 0:
			fighter.wet_stacks -= 1
			fighter.frost_stacks += 1
	
	for fighter in fighters:
		if fighter.symbiosis and fighter.moss_stacks > 0:
			fighter.change_health(fighter.current_hp + 2 * fighter.moss_stacks)
			emit_signal("battle_log_event", "Moss_Symbiosis", {"target": fighter.get_display_name()})
			if battlefield.has_field_effect("Mycel"):
				battlefield.get_partner(fighter.battle_slot).change_health(fighter.current_hp + fighter.moss_stacks)
	
	for fighter in fighters:
		if fighter.moss_stacks > 4:
			fighter.change_health(fighter.current_hp - 5)
			emit_signal("battle_log_event", "Moss_Damage", {"target": fighter.get_display_name(), "value": 5})
			if fighter.current_hp <= 0:
				emit_signal("knockout", fighter)
	
	for fighter in fighters:
		fighter.reset_turn_effects()
	
	battlefield.aura_duration = decrease(battlefield.aura_duration)
	battlefield.terrain_duration = decrease(battlefield.terrain_duration)
	battlefield.weather_duration = decrease(battlefield.weather_duration)

	round_counter += 1
	
	emit_signal("battle_log_event", "Add_Separator", {})
	emit_signal("battle_log_event", "Add_Separator", {})


func execute_action(action):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var defender
	var total_damage_dealt = 0
	
	if action.move == switch:
		if action.user.rooted == 0:
			emit_signal("switch", action.user.battle_slot, action.target[0])
			return
		else:
			emit_signal("battle_log_event", "Failed_Switch", {"victim": action.user.get_display_name()})
			return
	
	if not apply_modifier(action.move, action.user, action.target, "Before"):
		emit_signal("battle_log_event", "Failed_Move", {})
		return
	
	action.user.set_repetition_counter(action)
	
	if action.move.element == "Lightning":
		var lightning_targets = fighters.duplicate()
		lightning_targets.erase(action.user)
		for target in lightning_targets.duplicate():
			if target.charge_stacks < 1:
				lightning_targets.erase(target)
		if lightning_targets.size() > 0:
			action.target.clear()
			if action.target.size() <= 1:
				action.target.append(lightning_targets[rng.randi_range(0, lightning_targets.size()-1)].battle_slot)
			else:
				for fighter in lightning_targets:
					action.target.append(fighter.battle_slot)
	
	for defender_slot in action.target:
		defender = battlefield.get_fighter(defender_slot)
		
		if defender == null:
			if (defender_slot < -1 or defender_slot > 1) and action.user.battle_slot < 2 and action.user.battle_slot > -2:
				defender_slot *= -1
			elif (action.user.battle_slot < -1 or action.user.battle_slot > 1) and defender_slot < 2 and defender_slot > -2:
				defender_slot *= -1
			defender = battlefield.get_fighter(defender_slot)
			
			if defender == null:
				emit_signal("battle_log_event", "Miss", {})
				continue
		
		if action.move.condition is Resource and (action.move.uses_additional_spell == "No" or action.move.uses_additional_spell == "After"):
			if action.move.condition.check_condition(action.user, defender) == false:
				emit_signal("battle_log_event", "Failed_Move", {})
				continue
		
		if action.move.condition is Resource and (action.move.uses_additional_spell == "On Condition"):
			if action.move.condition.check_condition(action.user, defender) == true:
				action.move = action.move.extra_spell
		elif action.move.condition is Resource and (action.move.uses_additional_spell == "Not on Condition"):
			if action.move.condition.check_condition(action.user, defender) == false:
				action.move = action.move.extra_spell
		
		if defender.is_protected:
			emit_signal("battle_log_event", "Protected" , {"target": defender.get_display_name()})
			
			#progress_attack_quests(action, defender, false, 0)
			continue
		
		var iterator = 0
		var attack_count = action.move.attack_count
		if action.move.attack_count_factor is Resource:
			attack_count = action.move.attack_count_factor.get_factor(action.user, defender, attack_count)
		if attack_count <= 0:
			emit_signal("battle_log_event", "Failed_Move", {})
		
		while iterator < attack_count:
			iterator += 1
			
			if defender.current_hp < 0:
				continue
			
			if get_accuracy(action.move, action.user, defender) < rng.randi_range(1, 100):
				emit_signal("battle_log_event", "Miss", {})
				
				#progress_attack_quests(action, defender, false, 0)
				continue
			
			if defender.shield > 0:
				defender.shield -= 1
				emit_signal("battle_log_event", "Protected" , {"target": defender.get_display_name()})
				if defender.shield == 0:
					emit_signal("battle_log_event", "Shield_Break", {})
				
				#progress_attack_quests(action, defender, false, 0)
				continue
			
			if defender.moss_stacks > 4:
				emit_signal("battle_log_event", "Moss_Protection" , {"target": defender.get_display_name()})
				defender.moss_stacks = 0
				
				#progress_attack_quests(action, defender, false, 0)
				continue
			
			var damage = apply_damage(action.move, action.user, defender)
			total_damage_dealt += damage
			
			#action.user.connect_quests_with_modifier()
			apply_modifier(action.move, action.user, [defender.battle_slot], "On-Hit")
			apply_element_offense_interactions(action.move, action.user, defender)
			
			#progress_attack_quests(action, defender, true, damage)
			
			if action.user.current_hp <= 0:
				emit_signal("knockout", action.user)
	
	
	apply_modifier(action.move, action.user, action.target, "After")
	
	
	
	action.user.previous_action = action

	if total_damage_dealt == 0:
			action.user.repetition_counter = 0
			action.user.repeating = 0
	
func apply_damage(move, attacker, defender):
	if move.type == "Status":
		return -1
	
	var damage = damage_calculator.get_damage(move, attacker, defender, battlefield)
	defender.change_health(defender.current_hp - damage)
	emit_signal("battle_log_event", "Damage", {"defender": defender.get_display_name(), "value": damage})
	
	if move.element == "Lightning":
		attacker.charge_stacks = 0
		defender.charge_stacks = 0
	
	if defender.current_hp <= 0:
		emit_signal("knockout", defender)
	
	
	if defender.strong_spikes > 0:
		attacker.change_health(attacker.current_hp - round(attacker.get_max_hp / 2))
		if attacker.current_hp <= 0:
			emit_signal("knockout", attacker)
	
	emit_signal("battle_log_event", "New_Line", {})
	
	return damage

func apply_modifier(move, user, target_slots, activation):
	for modifier in move.user_modifiers:
		if modifier.get_activation() == activation:
			emit_signal("modifier_connect", modifier)
			if not modifier.apply_modifier(user, user):
				return false
			emit_signal("modifier_disconnect", modifier)
	
	for modifier in move.target_modifiers:
		if modifier.get_activation() == activation:
			for target_slot in target_slots:
				var target = battlefield.get_fighter(target_slot)
				if target is Creature:
					emit_signal("modifier_connect", modifier)
					if not modifier.apply_modifier(user, target):
						return false
					emit_signal("modifier_disconnect", modifier)
	return true

func apply_element_defense_interactions(move, user, defender):
	var modifier = null
	var target = defender
	
	match [move.element, defender.base_values.element]:
		["Fire", "Fire"]:
			modifier = fire_effect
		["Frost", "Water"]:
			modifier = frost_effect
		["Water", "Ground"]:
			modifier = water_effect
		["Lightning", "Lightning"]:
			modifier = lightning_effect
			target = user
		["Ground", "Ground"]:
			modifier = ground_effect
	
	
	if modifier != null:
		emit_signal("modifier_connect", modifier)
		fire_effect.apply_modifier(user, target)
		emit_signal("modifier_disconnect", modifier)


func apply_element_offense_interactions(move, user, defender):
	var modifier = null
	var target = defender
	
	match [move.element, user.base_values.element]:
		["Frost", "Frost"]:
			modifier = frost_attack
		["Water", "Water"]:
			modifier = water_attack
		["Ground", "Ground"]:
			modifier = ground_attack
	
	if modifier != null:
		emit_signal("modifier_connect", modifier)
		fire_effect.apply_modifier(user, target)
		emit_signal("modifier_disconnect", modifier)

func apply_priority_boni(action):
	if action.user.base_values.element == "Wind" and action.move.element == "Wind":
		action.extra_priority += 1


func progress_attack_quests(action : Action, defender : Creature, is_successful : bool, damage : int) -> void:
	action.user.progress_quests("Hit", {"action": action, "target": defender, "is_successful" : is_successful, "damage" : damage})
	defender.progress_quests("Defending", {"action": action, "target": defender, "is_successful" : is_successful, "damage" : damage})
	if battlefield.get_partner(action.user.battle_slot) is Creature:
		battlefield.get_partner(action.user.battle_slot).progress_quests("PartnerAttack", {"action": action, "target": defender, "is_successful" : is_successful, "damage" : damage})
	if battlefield.get_partner(defender.battle_slot) is Creature:
		battlefield.get_partner(defender.battle_slot).progress_quests("PartnerDefend", {"action": action, "target": defender, "is_successful" : is_successful, "damage" : damage})

#
#func apply_on_hit_modifier(move : AA_Spell, user, target):
#	for modifier in move.user_modifiers:
#		if modifier.get_activation() == "On-Hit":
#			emit_signal("modifier_connect", modifier)
#			modifier.apply_modifier(user, user)
#			emit_signal("modifier_disconnect", modifier)
#
#	for modifier in move.target_modifiers:
#		if modifier.get_activation() == "On-Hit":
#			emit_signal("modifier_connect", modifier)
#			modifier.apply_modifier(user, target)
#			emit_signal("modifier_disconnect", modifier)


func test_for_ally(slot):
	if slot == LEFT_ALLY:
		return true
	if slot == RIGHT_ALLY:
		return true
	return false

func decrease(value):
	if value > 1:
		return value - 1
	return value

func get_accuracy(move, user, target):
	if not move.can_miss:
		return 100
	
	var accuracy = move.accuracy
	accuracy += target.wet_stacks * 10
	if battlefield.has_field_effect("Fog") and move.multitarget == false:
		accuracy -= 20
	
	if user.base_values.element == "Fire" and move.element == "Fire":
		accuracy +=20
	
	if accuracy > 100:
		return 100
	
	return accuracy


func play_animation():
	yield(get_tree().create_timer(2.0), "timeout")
	return


func _on_Sorter_sorting_action_queue():
	sorter.battlefield = battlefield
