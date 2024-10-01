extends Node
class_name DamageCalculator

export (String, "FLAT", "MODIFIER", "RELATIVE") var DAMAGE_MODE = "FLAT"
export(int) var ATTACK_BONUS = 5
export(int) var ELEMENT_BONUS = 3
export(int) var UNFAMILIAR_BONUS = 3


func damage_calc(base_damage, attack_value, defense_value):
	match(DAMAGE_MODE):
		"FLAT":
			return base_damage + attack_value - defense_value
		
		"MULTIPLIER":
			if base_damage == 0:
				return 0
			if attack_value == 0 and defense_value == 0:
				return base_damage
			
			var value_difference = attack_value - defense_value + ATTACK_BONUS
			return value_difference * (base_damage / 5)
		
		"RELATIVE":
			var damage = (float (base_damage + attack_value)) / (clamp(defense_value, 1, 1000))
			return ceil(damage)


func get_damage(move, attacker, defender, battlefield):
	
	var attacker_value = 0
	match move.used_stat:
		"Stability": attacker_value = attacker.get_stability()
		"Balance": attacker_value = attacker.get_balance()
		"Leaf": attacker_value = attacker.get_leaf()
		"Aroma": attacker_value = attacker.get_aroma()
	
	var defender_value = 0
	match move.used_stat:
		"Stability": defender_value = defender.get_stability()
		"Balance": defender_value = defender.get_balance()
		"Leaf": defender_value = defender.get_leaf()
		"Aroma": defender_value = defender.get_aroma()
	
	if move.does_crit or move.element == "Lightning" and attacker.base_values.element == "Lightning":
		defender_value = defender_value * 0.5
	
	var base_damage = move.base_damage
	
	base_damage += get_element_bonus(move, defender)
	base_damage += get_unfamiliar_bonus(move, defender)
	
	if move.damage_factor is Resource:
		base_damage = move.damage_factor.get_factor(attacker, defender, base_damage)
	
	if attacker.fire_boost > 0 and move.element == "Fire":
		base_damage = 2* base_damage
	
	var damage = 0.0
	
	damage = damage_calc(base_damage, attacker_value, defender_value)
	
	if damage < 0:
		damage = 0
	
	damage *= get_alignment_factor(move, defender)
	damage *= get_element_factor(move, defender)
	
	if move.element == "Lightning":
		if attacker.charge_stacks > 0:
			damage = (1 + 0.5 * attacker.charge_stacks) * damage
		if defender.charge_stacks > 0:
			damage = (1 + 0.5 * defender.charge_stacks) * damage

	if move.element == "Water" and battlefield.has_field_effect("Rain"):
		damage = 2* damage
	if move.element == "Fire" and battlefield.has_field_effect("Rain"):
		damage = 0.5* damage
	
	return round(damage)

func get_element_bonus(move, defender):
	
	match move.element:
		"Fire":
			match defender.base_values.type:
				"Moon":
					return ELEMENT_BONUS
		"Frost":
			match defender.base_values.type:
				"Sun":
					return ELEMENT_BONUS
		"Water":
			match defender.base_values.type:
				"Stars":
					return ELEMENT_BONUS
		"Wind":
			match defender.base_values.type:
				"Stars":
					return ELEMENT_BONUS
		"Lightning":
			match defender.base_values.type:
				"Earth":
					return ELEMENT_BONUS
	
	return 0

func get_unfamiliar_bonus(move, defender) -> int:
	
	if defender.is_familiar_with_element(move.element):
		return 0
	
	return UNFAMILIAR_BONUS

func get_alignment_factor(move, defender) -> float:
	return 1.0
	match defender.base_values.type:
		"Stars":
			if move.used_stat == "Aroma":
				return 0.5
		"Sun":
			if move.used_stat == "Leaf":
				return 0.5
		"Moon":
			if move.used_stat == "Balance":
				return 0.5
		"Earth":
			if move.used_stat == "Stability":
				return 0.5
		
	return 1.0

func get_element_factor(move, defender) -> float:
	match move.element:
		"Fire":
			match defender.base_values.element:
				"Frost": #"Wind"
					return 2.0
				"Water": #"Lightning"
					return 0.5
		"Frost":
			match defender.base_values.element:
				"Ground": #"Water"
					return 2.0
				"Fire":
					return 0.5
				#"Frost":
				#	return 0.0
		"Water":
			match defender.base_values.element:
				"Fire":
					return 2.0
				"Frost": #"Water"
					return 0.5
		"Wind":
			pass
			#match defender.base_values.element:
				#"Ground":
				#	return 2.0
				#"Fire":
				#	return 0.0
		"Lightning":
			match defender.base_values.element:
				"Wind": #"Fire", "Water", "Frost"
					return 2.0
				"Ground":
					return 0.5
		"Ground":
			match defender.base_values.element:
				"Water": #Lightning
					return 2.0
				"Wind":
					return 0.5
	return 1.0


func get_preview_damage(move, attacker, defender, battlefield):
	
	if move.condition is Resource and (move.uses_additional_spell == "On Condition"):
			if move.condition.check_condition(attacker, defender) == true:
				move = move.extra_spell
	elif move.condition is Resource and (move.uses_additional_spell == "Not on Condition"):
			if move.condition.check_condition(attacker, defender) == false:
				move = move.extra_spell
	if move.uses_additional_spell == "After" and move.base_damage == 0:
		move = move.extra_spell
	
	var attack_count = move.attack_count
	if move.attack_count_factor is Resource:
		attack_count = move.attack_count_factor.get_factor(attacker, defender, attack_count)
	
	var damage = get_damage(move, attacker, defender, battlefield)
	
	return attack_count * damage
