extends Node
class_name Sorter

signal sorting_action_queue

enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}
onready var rng = RandomNumberGenerator.new()
var battlefield

func _ready():
	rng.randomize() 

#Prüfen, ob Reihenfolge auch Korrekt ist.
func sort_for_battle_queue(a: Action, b: Action):
	emit_signal("sorting_action_queue")
	
	#skip wenn eine der Kreaturen bereits KO
	if a.user.current_hp <= 0:
		return false
	elif b.user.current_hp <= 0:
		return true
	
	#Setzt Kämpfer mit Stagger an das Ende der Liste
	if a.user.stagger_stacks < b.user.stagger_stacks:
		return true
	elif a.user.stagger_stacks > b.user.stagger_stacks:
		return false
	
	#Prioritätsvergleich
	if determine_priority(a) > determine_priority(b):
		return true
	elif determine_priority(a) < determine_priority(b):
		return false
	
	#Geschwindigkeitsvergleich
	if determine_speed(a.user) > determine_speed(b.user):
		return true
	elif determine_speed(a.user) < determine_speed(b.user):
		return false
	
	#Zufällige Auswahl bei Gleichstand
	if rng.randi()%2 == 0:
		return false
	return true


func sort_by_speed(a: Action, b: Action):
	if determine_speed(a.user) == determine_speed(b.user):
		if rng.randi()%2 == 0:
			return false
		else:
			return true
	elif determine_speed(a.user) > determine_speed(b.user):
		return false
	return true

func sort_by_battle_slot(a: Creature, b: Creature):
	if a.battle_slot == LEFT_ALLY:
		return true
	if (a.battle_slot == RIGHT_ALLY) and (b.battle_slot != LEFT_ALLY):
		return true
	if (a.battle_slot == LEFT_ENEMY) and (b.battle_slot == RIGHT_ENEMY):
		return true
	
	return false 


func determine_speed(user):
	return user.get_speed()

func determine_priority(action):
	var priority = action.move.priority + action.extra_priority
	priority -= action.user.bond_stacks/2
	if battlefield.has_field_effect("Mycel"):
		if action.move.type == "Status" and action.move.element == "Ground":
			priority += 1
	
	return priority
