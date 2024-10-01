extends Resource
class_name EvolveQuest

export(int) var xp_gain = 1
export(String, "Hit", "Defending", "PartnerAttack", "PartnerDefend", "RoundEnd") var requirement_type = "Hit"
export(String, "Normal", "SubQuests") var variant = "Normal"

export(bool) var success_required = true
export(int) var required_success_chain = 1
export(Resource) var required_spell = null
export(String, "None", "Stability", "Balance", "Leaf", "Aroma") var required_attacking_stat = "None"
export(String, "None", "Stability", "Balance", "Leaf", "Aroma") var required_defending_stat = "None"
export(String, "None", "Blank", "Lightning", "Fire", "Frost", "Water", "Wind", "Ground") var required_element = "None"
export(int) var required_min_damage = 0
export(int) var required_max_damage = 100
export(bool) var requires_knockout = false
export(bool) var rising_damage = false
export(String, "None", "Lightning", "Fire", "Frost", "Water", "Wind", "Ground") var required_aura = "None"
export(Resource) var connected_modifier = null
export(bool) var requires_successfull_modifier = false
export(bool) var reset_chain_on_xp_gain = true
export(bool) var reset_chain_on_round_end = false
export(String, "None", "Same Slot", "Different Slot", "Both", "Self") var required_target = "None"
export(String, "Self", "Partner", "All", "Enemies") var round_end_targets = "Self"
export(Resource) var condition = null
export(Array, Resource) var subquests

var success_chain = 0
var previous_damage = 0
var previous_slot = 0
var is_modifier_successful = false

func receive_hit_data(data : Dictionary) -> int:
	match requirement_type:
		#data: action : Action, target, is_successful : bool, damage : int
		"Hit", "Defending":
			if not check_hit_requirements(data.action, data.target, data.is_successful, data.damage):
				success_chain = 0
				return 0
			
			previous_damage = data.damage
			previous_slot = data.target.battle_slot
			
			success_chain += 1
			
			if success_chain >= required_success_chain:
				return xp_gain
				if reset_chain_on_xp_gain:
					success_chain = 0
	
		"RoundEnd":
			match variant:
				"Normal":
					match round_end_targets:
						"Self":
							if check_condition(data.self):
								return xp_gain
						"Partner":
							for fighter in data.fighters:
								if check_condition(fighter) and data.self.battle_slot *-1 == fighter.battle_slot:
									return xp_gain
						"Enemies":
							for fighter in data.fighters:
								if not check_condition(fighter) and data.self.battle_slot *-1 != fighter.battle_slot and data.self.battle_slot != fighter.battle_slot:
									return 0
							return xp_gain
						"All":
							for fighter in data.fighters:
								if not check_condition(fighter):
									return 0
							return xp_gain
				
				"SubQuests":
					if check_sub_quests():
						return xp_gain
				

	
	return 0

func check_hit_requirements(action : Action, target, is_successful : bool, damage : int) -> bool:
	
	if success_required and not is_successful:
		return false
	
	match required_target:
		"Same Slot":
			if target.battle_slot != previous_slot:
				return false
		"Different Slot":
			if target.battle_slot == previous_slot:
				return false
		"Both":
			if not action.move.multitarget:
				return false
		"Self":
			if target.battle_slot != action.user.battle_slot:
				return false
	
	if required_spell is Resource:
		if action.move != required_spell:
			return false
	
	if required_attacking_stat != "None" and action.move.used_stat != required_attacking_stat:
		return false
	if required_defending_stat != "None" and action.move.target_stat != required_defending_stat:
		return false
	if required_element != "None" and action.move.element != required_element:
		if required_element == "Blank" and action.move.element == "None":
			pass
		else:
			return false
	
	if damage < required_min_damage:
		return false
	if damage > required_max_damage:
		return false
	if rising_damage and not damage > previous_damage:
		return false
	if requires_knockout and target.current_hp > 0:
		return false
	
	if required_aura != "None":
		if not action.user.get_parent().get_parent().get_parent().has_field_effect(required_aura):
			return false
	
	if condition is Resource:
		if requirement_type == "Hit":
			if not condition.check_condition(action.user, target):
				return false
		if requirement_type == "Defending":
			if not condition.check_condition(target, action.user):
				return false
	
	return true

func check_condition(target) -> bool:
	if not condition.check_condition(target, target):
		return false
	
	return true

func reset_values() -> void:
	success_chain = 0
	previous_damage = 0
	previous_slot = 0
	is_modifier_successful = false

func on_modifier_success(success : bool) -> void:
	is_modifier_successful =  success

func connect_modifier() -> void:
	connected_modifier.connect("modifier_success", self, "on_modifier_success", CONNECT_ONESHOT)

func check_sub_quests() -> bool:
	for quest in subquests:
		if quest.success_chain < 1:
			return false
	
	return true
