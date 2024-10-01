extends Decider
class_name SimpleDamageDecider
#Uses move, which does most damage according to damage preview.


func get_action(attacker, knowledge):
	var damage_calc = knowledge.battlefield.get_parent().get_node("DamageCalculator")
	var action_list = []
		
	for action in get_action_list(attacker, knowledge):
		var action_damage = get_action_damage(action, attacker.battle_slot, knowledge)
		action_list.append([action, action_damage])
		
	action_list.sort_custom(self, "sort_by_weight")
	
	return action_list[0][0]


func get_switch_in(slot : int, knowledge : Knowledge) -> int:
	var reserves = []
	var switch_list = []
	
	if knowledge.is_ally:
		reserves = knowledge.battlefield.get_ally_reserve()
	else:
		reserves = knowledge.battlefield.get_enemy_reserve()
	
	for creature in reserves:
		var highest_damage = 0
		for action in get_action_list(creature, knowledge):
			var action_damage = get_action_damage(action, slot, knowledge)
			if highest_damage < action_damage:
				highest_damage = action_damage
		switch_list.append([creature, highest_damage])
	
	switch_list.sort_custom(self, "sort_by_weight")
	
	return reserves.find(switch_list[0][0])


func get_action_damage(action : Action, slot : int, knowledge : Knowledge) -> int:
	var damage_calc = knowledge.battlefield.get_parent().get_node("DamageCalculator")
	var damage = 0
	
	match action.move.targets:
		"Allies", "Self", "Partner", "None":
			return 0
	if action.target == [slot * -1]:
		return -1
	
	for target in action.target:
		if knowledge.battlefield.get_fighter(target) is Creature:
			damage += damage_calc.get_preview_damage(action.move, action.user, knowledge.battlefield.get_fighter(target), knowledge.battlefield)
	
	return damage
