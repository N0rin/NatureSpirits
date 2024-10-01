extends Decider
class_name PlayerControl

enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}

var stored_knowledge
var stored_iteration

func make_decision(predictions, iteration, knowledge):
	var left_fighter
	var right_fighter
	var reserves
	
	stored_iteration = iteration
	stored_knowledge = knowledge
	
	if knowledge.is_ally:
		left_fighter = knowledge.battlefield.get_fighter(LEFT_ALLY)
		right_fighter = knowledge.battlefield.get_fighter(RIGHT_ALLY)
		reserves = knowledge.battlefield.get_ally_reserve()
	else:
		left_fighter = knowledge.battlefield.get_fighter(LEFT_ENEMY)
		right_fighter = knowledge.battlefield.get_fighter(RIGHT_ENEMY)
		reserves = knowledge.battlefield.get_enemy_reserve()
	
	interface.connect("input_received", self, "receive_player_input")
	interface.ask_for_player_input(left_fighter, right_fighter, reserves, knowledge)
	

func receive_player_input(actions):
	interface.disconnect("input_received", self, "receive_player_input")
	emit_signal("decision_made", actions, stored_iteration, stored_knowledge)
