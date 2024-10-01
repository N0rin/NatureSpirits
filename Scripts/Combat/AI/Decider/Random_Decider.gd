extends Decider
class_name RandomDecider
#Uses a random Action

func get_action(attacker : Creature, knowledge : Knowledge) -> Action:
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	
	var action_list = get_action_list(attacker, knowledge)
	var random_value = rng.randi() % action_list.size()
	
	return action_list[random_value]


func get_switch_in(slot : int, knowledge : Knowledge) -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	var reserves = []
	
	if knowledge.is_ally:
		reserves = knowledge.battlefield.get_ally_reserve()
	else:
		reserves = knowledge.battlefield.get_enemy_reserve()
	
	return rng.randi() % reserves.size()
