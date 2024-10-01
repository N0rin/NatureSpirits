extends Node
class_name Commander

signal actions_chosen

onready var rng = RandomNumberGenerator.new()
onready var knowledge : Knowledge
onready var interface : Control
export(bool) var player_controlled = false
export(Array, Resource) var predicter_list
export(Array, int) var predicter_weights
export(Array, Resource) var decider_list
export(Array, int) var decider_weights

var predictions = []
var decisions = []

func _ready():
	rng.randomize()
	#N bissel gehackt
	decider_list[0].interface = interface


func start_command_creation():
	decider_list[0].interface = interface
	
	ask_predicter(0, knowledge)


func ask_predicter(iteration, knowledge):
	predicter_list[iteration].connect("prediction_made", self, "receive_prediction")
	predicter_list[iteration].make_prediction(iteration, knowledge)

func receive_prediction(prediction, iteration, knowledge):
	predictions.append([predicter_weights[iteration], prediction])
	predicter_list[iteration].disconnect("prediction_made", self, "receive_prediction")
	
	if iteration + 1 < predicter_list.size():
		ask_predicter(iteration + 1, knowledge)
	else:
		ask_decider(0, knowledge)


func ask_decider(iteration, knowledge):
	decider_list[iteration].connect("decision_made", self, "receive_decision")
	decider_list[iteration].make_decision(predictions, iteration, knowledge)

func receive_decision(decision, iteration, knowledge):
	decisions.append([decider_weights[iteration], decision])
	decider_list[iteration].disconnect("decision_made", self, "receive_decision")
	
	if iteration + 1 < decider_list.size():
		ask_decider(iteration + 1, knowledge)
	else:
		send_chosen_actions()


func send_chosen_actions():
	var weight_sum = 0
	for weight in decider_weights:
		weight_sum += weight
	
	var random_value = rng.randi_range(1, weight_sum)
	
	for decision in decisions:
		random_value -= decision[0]
		
		if random_value <= 0:
			emit_signal("actions_chosen", decision[1])
			decisions.clear()
			predictions.clear()
			break

func get_replacement(slot : int) -> int:
	var weight_sum = 0
	for weight in decider_weights:
		weight_sum += weight
	
	var random_value = rng.randi_range(1, weight_sum)
	
	for iterator in decider_list.size():
		random_value -= decider_weights[iterator]
		
		if random_value <= 0:
			return decider_list[iterator].get_switch_in(slot, knowledge)
	
	return 0
