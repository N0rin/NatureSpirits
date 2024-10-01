extends Resource
class_name AAA_Condition

export(bool) var is_checking_user = false
export(String, "Inconsequential", "Before Target", "After Target") var move_order
export(Resource) var factor

export (int) var chance = 100
export (bool) var is_cost = false
export (bool) var is_fail_condition = false

export(int) var burn = 0
export(int) var frost = 0
export(int) var wet = 0
export(int) var moss = 0
export(int) var charged = 0

export(int) var light = 0

export(int) var min_round = 0
export(int) var max_round = 0
export(int) var repetitions = 0

export(String, "None", "Lightning", "Fire", "Frost", "Water", "Wind", "Ground") var required_aura = "None"
export(String, "None", "Fog", "Mycel", "Ember") var required_terrain = "None"
export(String, "None", "Rain") var required_weather = "None"

export(int) var stagger = 0
export(int) var rooted = 0
export(int) var bond = 0

export(String, "No", "Minimum", "Maximum", "Equal", "Raw Minimum", "Raw Maximum") var check_stat_boosts = "No"
export(bool) var check_stability = false
export(bool) var check_balance = false
export(bool) var check_leaf = false
export(bool) var check_aroma = false
export(bool) var check_speed = false
export(int) var stability_boost = 0
export(int) var balance_boost = 0
export(int) var leaf_boost = 0
export(int) var aroma_boost = 0
export(int) var speed_boost = 0


func check_condition(user, target):
	if factor is Resource:
		var value = factor.get_factor(user, target, 0)
		if is_checking_user:
			if is_fail_condition:
				return not check_target_value(user, value)
			else:
				return check_target_value(user, value)
		else:
			if is_fail_condition:
				return not check_target_value(target, value)
			else:
				return check_target_value(target, value)
	
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if chance < rng.randi_range(1, 100):
		if is_fail_condition:
			return true
		else:
			return false
	
	
	match move_order:
		"Inconsequential":
			pass
		"Before Target":
			if target.made_turn:
				if is_fail_condition:
					return true
				else:
					return false
		"After Target":
			if not target.made_turn:
				if is_fail_condition:
					return true
				else:
					return false
	
	if is_checking_user:
		if is_fail_condition:
			return not check_target(user)
		else:
			return check_target(user)
	else:
		if is_fail_condition:
			return not check_target(target)
		else:
			return check_target(target)

func check_target(creature):
	
	if burn > 0:
		if creature.burn_stacks < burn:
			return false
		elif is_cost:
			creature.burn_stacks -= burn
	
	if frost > 0:
		if creature.frost_stacks < frost:
			if is_cost:
				reroll_cost_changes(creature, burn)
			return false
		elif is_cost:
			creature.frost_stacks -= frost
	
	if wet > 0:
		if creature.wet_stacks < wet:
			if is_cost:
				reroll_cost_changes(creature, burn, frost)
			return false
		elif is_cost:
			creature.wet_stacks -= wet
	
	if moss > 0:
		if creature.moss_stacks < moss:
			if is_cost:
				reroll_cost_changes(creature, burn, frost, wet)
			return false
		elif is_cost:
			creature.moss_stacks -= moss
	
	if charged > 0:
		if creature.charge_stacks < charged:
			if is_cost:
				reroll_cost_changes(creature, burn, frost, wet, moss)
			return false
		elif is_cost:
			creature.charge_stacks -= charged
	
	if light > 0:
		if creature.get_parent().get_parent().light_counter < light:
			if is_cost:
				reroll_cost_changes(creature, burn, frost, wet, moss, charged)
			return false
		elif is_cost:
			creature.get_parent().get_parent().light_counter -= light
	
	if min_round > creature.round_counter:
		if is_cost:
			reroll_cost_changes(creature, burn, frost, wet, moss, charged, light)
		return false
	
	if max_round > 0:
		if max_round < creature.round_counter:
			if is_cost:
				reroll_cost_changes(creature, burn, frost, wet, moss, charged, light)
			return false
	
	if repetitions > 0:
		if creature.repetition_counter < repetitions:
			if is_cost:
				reroll_cost_changes(creature, burn, frost, wet, moss, charged, light)
			return false
		elif is_cost:
			creature.repetition_counter -= repetitions
	
	if required_aura != "None":
		if not creature.get_parent().get_parent().get_parent().has_field_effect(required_aura):
			return false
	if required_terrain != "None":
		if not creature.get_parent().get_parent().get_parent().has_field_effect(required_terrain):
			return false
	if required_weather != "None":
		if not creature.get_parent().get_parent().get_parent().has_field_effect(required_weather):
			return false
	
	if stagger > 0:
		if creature.stagger_stacks < stagger:
			return false
	
	if rooted > 0:
		if creature.rooted < rooted:
			return false
	
	if bond > 0:
		if creature.bond_stacks < bond:
			return false
	
	
	match check_stat_boosts:
		"Minimum":
			if check_stability:
				if creature.stability_stacks < stability_boost:
					return false
			if check_balance:
				if creature.balance_stacks < balance_boost:
					return false
			if check_leaf:
				if creature.leaf_stacks < leaf_boost:
					return false
			if check_aroma:
				if creature.aroma_stacks < aroma_boost:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks < speed_boost:
							return false
					"Balance":
						if creature.balance_stacks < speed_boost:
							return false
					"Leaf":
						if creature.leaf_stacks < speed_boost:
							return false
					"Aroma":
						if creature.aroma_stacks < speed_boost:
							return false
		"Maximum":
			if check_stability:
				if creature.stability_stacks > stability_boost:
					return false
			if check_balance:
				if creature.balance_stacks > balance_boost:
					return false
			if check_leaf:
				if creature.leaf_stacks > leaf_boost:
					return false
			if check_aroma:
				if creature.aroma_stacks > aroma_boost:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks > speed_boost:
							return false
					"Balance":
						if creature.balance_stacks > speed_boost:
							return false
					"Leaf":
						if creature.leaf_stacks > speed_boost:
							return false
					"Aroma":
						if creature.aroma_stacks > speed_boost:
							return false
		"Equal":
			if check_stability:
				if creature.stability_stacks != stability_boost:
					return false
			if check_balance:
				if creature.balance_stacks != balance_boost:
					return false
			if check_leaf:
				if creature.leaf_stacks != leaf_boost:
					return false
			if check_aroma:
				if creature.aroma_stacks != aroma_boost:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks != speed_boost:
							return false
					"Balance":
						if creature.balance_stacks != speed_boost:
							return false
					"Leaf":
						if creature.leaf_stacks != speed_boost:
							return false
					"Aroma":
						if creature.aroma_stacks != speed_boost:
							return false
		"Raw Minimum":
			if check_stability:
				if creature.get_stability() < stability_boost:
					return false
			if check_balance:
				if creature.get_balance() < balance_boost:
					return false
			if check_leaf:
				if creature.get_leaf() < leaf_boost:
					return false
			if check_aroma:
				if creature.get_aroma() < aroma_boost:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.get_stability() < speed_boost:
							return false
					"Balance":
						if creature.get_balance() < speed_boost:
							return false
					"Leaf":
						if creature.get_leaf() < speed_boost:
							return false
					"Aroma":
						if creature.get_aroma() < speed_boost:
							return false
		"Raw Maximum":
			if check_stability:
				if creature.get_stability() > stability_boost:
					return false
			if check_balance:
				if creature.get_balance() > balance_boost:
					return false
			if check_leaf:
				if creature.get_leaf() > leaf_boost:
					return false
			if check_aroma:
				if creature.get_aroma() > aroma_boost:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.get_stability() > speed_boost:
							return false
					"Balance":
						if creature.get_balance() > speed_boost:
							return false
					"Leaf":
						if creature.get_leaf() > speed_boost:
							return false
					"Aroma":
						if creature.get_aroma() > speed_boost:
							return false
	
	return true

func check_target_value(creature, compare_value):
	
	if burn > 0:
		if creature.burn_stacks < compare_value:
			return false
		elif is_cost:
			creature.burn_stacks -= compare_value
	
	if frost > 0:
		if creature.frost_stacks < compare_value:
			return false
		elif is_cost:
			creature.frost_stacks -= compare_value
	
	if wet > 0:
		if creature.wet_stacks < compare_value:
			return false
		elif is_cost:
			creature.wet_stacks -= compare_value
	
	if moss > 0:
		if creature.moss_stacks < compare_value:
			return false
		elif is_cost:
			creature.moss_stacks -= compare_value
	
	if charged > 0:
		if creature.charge_stacks < compare_value:
			return false
		elif is_cost:
			creature.charge_stacks -= compare_value
	
	
	if light > 0:
		if creature.get_parent().get_parent().light_counter < compare_value:
			return false
		elif is_cost:
			creature.get_parent().get_parent().light_counter -= compare_value
	
	if min_round > 0:
		if is_cost:
			if creature.round_counter < (compare_value +1):
				return false
			else:
				creature.round_counter -= compare_value
		elif creature.round_counter < compare_value:
			return false
	
	if max_round > 0:
		if creature.round_counter > compare_value:
			return false
		elif is_cost:
			creature.round_counter += compare_value
	
	if repetitions > 0:
		if creature.repetition_counter < compare_value:
			return false
		elif is_cost:
			creature.repetition_counter -= compare_value
	
	match check_stat_boosts:
		"Minimum":
			if check_stability:
				if creature.stability_stacks < stability_boost * compare_value:
					return false
			if check_balance:
				if creature.balance_stacks < balance_boost * compare_value:
					return false
			if check_leaf:
				if creature.leaf_stacks < leaf_boost * compare_value:
					return false
			if check_aroma:
				if creature.aroma_stacks < aroma_boost * compare_value:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks < speed_boost * compare_value:
							return false
					"Balance":
						if creature.balance_stacks < speed_boost * compare_value:
							return false
					"Leaf":
						if creature.leaf_stacks < speed_boost * compare_value:
							return false
					"Aroma":
						if creature.aroma_stacks < speed_boost * compare_value:
							return false
		"Maximum":
			if check_stability:
				if creature.stability_stacks > stability_boost * compare_value:
					return false
			if check_balance:
				if creature.balance_stacks > balance_boost * compare_value:
					return false
			if check_leaf:
				if creature.leaf_stacks > leaf_boost * compare_value:
					return false
			if check_aroma:
				if creature.aroma_stacks > aroma_boost * compare_value:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks > speed_boost * compare_value:
							return false
					"Balance":
						if creature.balance_stacks > speed_boost * compare_value:
							return false
					"Leaf":
						if creature.leaf_stacks > speed_boost * compare_value:
							return false
					"Aroma":
						if creature.aroma_stacks > speed_boost * compare_value:
							return false
		"Equal":
			if check_stability:
				if creature.stability_stacks != stability_boost * compare_value:
					return false
			if check_balance:
				if creature.balance_stacks != balance_boost * compare_value:
					return false
			if check_leaf:
				if creature.leaf_stacks != leaf_boost * compare_value:
					return false
			if check_aroma:
				if creature.aroma_stacks != aroma_boost * compare_value:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks != speed_boost * compare_value:
							return false
					"Balance":
						if creature.balance_stacks != speed_boost * compare_value:
							return false
					"Leaf":
						if creature.leaf_stacks != speed_boost * compare_value:
							return false
					"Aroma":
						if creature.aroma_stacks != speed_boost * compare_value:
							return false
		"Raw Minimum":
			if check_stability:
				if creature.get_stability() < stability_boost * compare_value:
					return false
			if check_balance:
				if creature.get_balance() < balance_boost * compare_value:
					return false
			if check_leaf:
				if creature.get_leaf() < leaf_boost * compare_value:
					return false
			if check_aroma:
				if creature.get_aroma() < aroma_boost * compare_value:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.get_stability() < speed_boost * compare_value:
							return false
					"Balance":
						if creature.get_balance() < speed_boost * compare_value:
							return false
					"Leaf":
						if creature.get_leaf() < speed_boost * compare_value:
							return false
					"Aroma":
						if creature.get_aroma() < speed_boost * compare_value:
							return false
		"Raw Maximum":
			if check_stability:
				if creature.get_stability() > stability_boost * compare_value:
					return false
			if check_balance:
				if creature.get_balance() > balance_boost * compare_value:
					return false
			if check_leaf:
				if creature.get_leaf() > leaf_boost * compare_value:
					return false
			if check_aroma:
				if creature.get_aroma() > aroma_boost * compare_value:
					return false
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.get_stability() > speed_boost * compare_value:
							return false
					"Balance":
						if creature.get_balance() > speed_boost * compare_value:
							return false
					"Leaf":
						if creature.get_leaf() > speed_boost * compare_value:
							return false
					"Aroma":
						if creature.get_aroma() > speed_boost * compare_value:
							return false
	
	return true

func return_value(user, target):
	if is_checking_user:
		return determine_value(user)
	else:
		return determine_value(target)

func determine_value(creature):
	var return_value = 0
	
	if burn > 0:
		return_value += creature.burn_stacks / burn
	if frost:
		return_value += creature.frost_stacks / frost
	if wet > 0:
		return_value += creature.wet_stacks / wet
	if moss > 0:
		return_value += creature.moss_stacks / moss
	if charged > 0:
		return_value += creature.charge_stacks / charged
	
	if light > 0:
		return_value += creature.get_parent().get_parent().light_counter / light
	
	if min_round > 0:
		return_value += clamp(creature.round_counter - min_round, 0, 1000)
	
	if max_round > 0:
		return_value += clamp(creature.round_counter, 0, max_round)
	
	if repetitions > 0:
		return_value += creature.repetition_counter / repetitions
	
	match check_stat_boosts:
		"Minimum":
			if check_stability:
				if creature.stability_stacks >= stability_boost :
					return_value += creature.stability_stacks
			if check_balance:
				if creature.balance_stacks >= balance_boost:
					return_value += creature.balance_stacks
			if check_leaf:
				if creature.leaf_stacks >= leaf_boost:
					return_value += creature.leaf_stacks
			if check_aroma:
				if creature.aroma_stacks >= aroma_boost:
					return_value += creature.aroma_stacks
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks >= speed_boost:
							return_value += creature.stability_stacks
					"Balance":
						if creature.balance_stacks >= speed_boost:
							return_value += creature.balance_stacks
					"Leaf":
						if creature.leaf_stacks >= speed_boost:
							return_value += creature.leaf_stacks
					"Aroma":
						if creature.aroma_stacks >= speed_boost:
							return_value += creature.aroma_stacks
		"Maximum":
			if check_stability:
				if creature.stability_stacks <= stability_boost:
					return_value += creature.stability_stacks
			if check_balance:
				if creature.balance_stacks <= balance_boost:
					return_value += creature.balance_stacks
			if check_leaf:
				if creature.leaf_stacks <= leaf_boost:
					return_value += creature.leaf_stacks
			if check_aroma:
				if creature.aroma_stacks <= aroma_boost:
					return_value += creature.aroma_stacks
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks <= speed_boost:
							return_value += creature.stability_stacks
					"Balance":
						if creature.balance_stacks <= speed_boost:
							return_value += creature.balance_stacks
					"Leaf":
						if creature.leaf_stacks <= speed_boost:
							return_value += creature.leaf_stacks
					"Aroma":
						if creature.aroma_stacks <= speed_boost:
							return_value += creature.aroma_stacks
		"Equal":
			if check_stability:
				if creature.stability_stacks == stability_boost:
					return_value += creature.stability_stacks
			if check_balance:
				if creature.balance_stacks == balance_boost:
					return_value += creature.balance_stacks
			if check_leaf:
				if creature.leaf_stacks == leaf_boost:
					return_value += creature.leaf_stacks
			if check_aroma:
				if creature.aroma_stacks == aroma_boost:
					return_value += creature.aroma_stacks
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.stability_stacks == speed_boost:
							return_value += creature.stability_stacks
					"Balance":
						if creature.balance_stacks == speed_boost:
							return_value += creature.balance_stacks
					"Leaf":
						if creature.leaf_stacks == speed_boost:
							return_value += creature.leaf_stacks
					"Aroma":
						if creature.aroma_stacks == speed_boost:
							return_value += creature.aroma_stacks
		"Raw Minimum":
			if check_stability:
				if creature.get_stability() >= stability_boost:
					return_value += creature.get_stability()
			if check_balance:
				if creature.get_balance() >= balance_boost:
					return_value += creature.get_balance()
			if check_leaf:
				if creature.get_leaf() >= leaf_boost:
					return_value += creature.get_leaf()
			if check_aroma:
				if creature.get_aroma() >= aroma_boost:
					return_value += creature.get_aroma()
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.get_stability() >= speed_boost:
							return_value += creature.get_stability()
					"Balance":
						if creature.get_balance() >= speed_boost:
							return_value += creature.get_balance()
					"Leaf":
						if creature.get_leaf() >= speed_boost:
							return_value += creature.get_leaf()
					"Aroma":
						if creature.get_aroma() >= speed_boost:
							return_value += creature.get_aroma()
		"Raw Maximum":
			if check_stability:
				if creature.get_stability() <= stability_boost:
					return_value += creature.get_stability()
			if check_balance:
				if creature.get_balance() <= balance_boost:
					return_value += creature.get_balance()
			if check_leaf:
				if creature.get_leaf() <= leaf_boost:
					return_value += creature.get_leaf()
			if check_aroma:
				if creature.get_aroma() <= aroma_boost:
					return_value += creature.get_aroma()
			if check_speed:
				match creature.base_values.speedstat:
					"Stability":
						if creature.get_stability() <= speed_boost:
							return_value += creature.get_stability()
					"Balance":
						if creature.get_balance() <= speed_boost:
							return_value += creature.get_balance()
					"Leaf":
						if creature.get_leaf() <= speed_boost:
							return_value += creature.get_leaf()
					"Aroma":
						if creature.get_aroma() <= speed_boost:
							return_value += creature.get_aroma()
	return return_value

func reroll_cost_changes(creature, burn_cost = 0, frost_cost= 0, wet_cost= 0, moss_cost= 0, charged_cost= 0, light_cost= 0):
	creature.burn_stacks += burn_cost
	creature.frost_stacks += frost_cost
	creature.wet_stacks += wet_cost
	creature.moss_stacks += moss_cost
	creature.charge_stacks += charged_cost
	creature.get_parent().get_parent().light_counter += light_cost
