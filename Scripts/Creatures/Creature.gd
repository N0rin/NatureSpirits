extends Node
class_name Creature

signal health_changed
signal effects_changed
signal stats_changed
signal status_condition_changed
const STATUS_CONDITION_STRENGTH = 1
const STACK_STRENGTH = 3

var battle_slot : int
var interface : Node
var speed_variation
var previous_action : Action
var repetition_counter : int
var made_turn = false
var round_counter = 0

export(String) var custom_name = "" setget ,get_display_name
var current_hp = 1 setget change_health

export(int) var max_hp_bonus = 0
export(int) var stability_bonus = 0
export(int) var balance_bonus = 0
export(int) var leaf_bonus = 0
export(int) var aroma_bonus = 0

var active_quests = []

var stability_stacks = 0 setget _set_stability_stacks
var balance_stacks = 0 setget _set_balance_stacks
var leaf_stacks = 0 setget _set_leaf_stacks
var aroma_stacks = 0 setget _set_aroma_stacks

#Kampfwerte könnte man nochmal extra verschachteln
var stagger_stacks = 0
var is_protected = false
var protect_counter = 0
var is_knocked_over = false
var bond_stacks = 0
var rooted = 0
var shield = 0
var no_stat_decrease = 0
var symbiosis = false
var fire_boost = 0
var strong_spikes = 0
var repeating = 0

var burn_stacks = 0 setget _set_burn_stacks
var frost_stacks = 0 setget _set_frost_stacks
var wet_stacks = 0 setget _set_wet_stacks
var moss_stacks = 0 setget _set_moss_stacks
var charge_stacks = 0 setget _set_charge_stacks

export(Resource) var base_values

export(Array, Resource) var moves = [null, null, null, null, null]
export(Array, Resource) var learned_spells

func _ready():
	pass

func get_appearance():
	return base_values.appearance

func get_current_hp():
	return current_hp

func get_display_name():
	if custom_name == "":
		return base_values.name
	return custom_name

func get_max_hp():
	return base_values.max_life + max_hp_bonus

func get_stability():
	if get_parent().get_parent().get_parent().has_field_effect("Mycel"):
		return base_values.stability + stability_bonus + STACK_STRENGTH * stability_stacks + frost_stacks * STATUS_CONDITION_STRENGTH
	
	return base_values.stability + stability_bonus + STACK_STRENGTH * stability_stacks + (frost_stacks - moss_stacks) * STATUS_CONDITION_STRENGTH

func get_balance():
	return base_values.balance + balance_bonus + STACK_STRENGTH * balance_stacks + (wet_stacks - frost_stacks) * STATUS_CONDITION_STRENGTH

func get_leaf():
	return base_values.leaf + leaf_bonus + STACK_STRENGTH * leaf_stacks + (moss_stacks - burn_stacks) * STATUS_CONDITION_STRENGTH

func get_aroma():
	return base_values.aroma + aroma_bonus + STACK_STRENGTH * aroma_stacks + (burn_stacks - wet_stacks) * STATUS_CONDITION_STRENGTH

func apply_burn(amount):
	var burn_counter = amount
	
	if frost_stacks > 0:
		frost_stacks -= burn_counter
		if frost_stacks < 0:
			burn_counter = frost_stacks * -1
			frost_stacks = 0
		else:
			burn_counter = 0
	
	if wet_stacks > 0:
		wet_stacks -= burn_counter
		if wet_stacks < 0:
			burn_counter = wet_stacks * -1
			wet_stacks = 0
		else:
			burn_counter = 0
	
	if burn_counter > 0:
		if moss_stacks > 0:
			burn_stacks += burn_counter + 1
			moss_stacks -= 1
		else:
			burn_stacks = burn_counter
	
	emit_signal("effects_changed", self)

func apply_frost(amount):
	
	if burn_stacks > 0:
		return
	
	if amount > 0:
		if wet_stacks > 0:
			frost_stacks += amount + 1
			wet_stacks -= 1
		else:
			frost_stacks += amount
	
	emit_signal("effects_changed", self)

func apply_wet(amount):
	var wet_counter = amount
	
	if burn_stacks > 0:
		burn_stacks -= wet_counter
		if burn_stacks < 0:
			wet_counter = burn_stacks * -1
			burn_stacks = 0
		else:
			wet_counter = 0
	
	if frost_stacks > 0:
		frost_stacks += wet_counter
	else:
		wet_stacks += wet_counter
	
	emit_signal("effects_changed", self)

func apply_moss(amount):
	
	if burn_stacks > 0:
		burn_stacks += amount
	else:
		moss_stacks += amount
	
	emit_signal("effects_changed", self)

func apply_charge(amount):
	charge_stacks += amount
	
	emit_signal("effects_changed", self)

func reset_stat_stacks():
	stability_stacks = 0
	balance_stacks = 0
	leaf_stacks = 0
	aroma_stacks = 0
	
	emit_signal("stats_changed", self)

func reset_status_effects():
	burn_stacks = 0
	frost_stacks = 0
	wet_stacks = 0
	moss_stacks = 0
	charge_stacks = 0
	
	emit_signal("effects_changed", self)

func reset_temporary_changes():
	reset_stat_stacks()
	stagger_stacks = 0
	is_protected = false
	protect_counter = 0
	previous_action = null
	bond_stacks = 0
	is_knocked_over = false
	no_stat_decrease = 0
	symbiosis = false
	fire_boost = 0
	repeating = 0
	round_counter = 1
	
	for list in active_quests:
		for quest in list[1]:
			quest.reset_values()
			
			for subquest in quest.subquests:
				subquest.reset_values()

func reset_turn_effects():
	is_protected = false
	stagger_stacks = 0
	if made_turn:
		round_counter += 1
	made_turn = false
	
	rooted = decrease(rooted)
	shield = decrease(shield)
	no_stat_decrease = decrease(no_stat_decrease)
	fire_boost = decrease(fire_boost)
	strong_spikes = decrease(strong_spikes)
	
	if repetition_counter >= repeating:
		repeating = 0
	
	for list in active_quests:
		for quest in list[1]:
			if quest.reset_chain_on_round_end:
				quest.success_chain = 0
				quest.is_modifier_successful = false
				
				for subquest in quest.subquests:
					if subquest.reset_chain_on_round_end:
						subquest.success_chain = 0
						subquest.is_modifier_successful = false

func set_repetition_counter(action):
	if not previous_action is Action:
		previous_action = action
		return
	
	if action.move == previous_action.move:
		repetition_counter += 1
	else:
		repetition_counter = 0

#Sollte man allgemein verfügbar machen
func decrease(value : int):
	if value > 0:
		return value - 1
	return value

func prepare_for_turn():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	speed_variation = rng.randi_range(-2, 2)
	
	print(get_display_name()) #Debug
	print(speed_variation) #Debug

func return_valid_actions():
	var move0 = is_move_valid(0)
	var move1 = is_move_valid(1)
	var move2 = is_move_valid(2)
	var move3 = is_move_valid(3)
	var move4 = is_move_valid(4)
	var switching = true
	
	if rooted > 0:
		switching = false
	
	return [move0, move1, move2, move3, move4, switching]

func is_move_valid(move_slot : int):
	#TODO
	return true

func append_new_quests(move : Resource) -> void:
	for spell in base_values.potential_moves:
		if spell.evolves_from == move:
			active_quests.append([spell, spell.evolve_quests.duplicate(), 0])

func learn_spells() -> void:
	var finished_quests = []
	for iterator in active_quests.size():
		if active_quests[iterator][0].required_xp <= active_quests[iterator][2]:
			finished_quests.append(active_quests[iterator])
	
	for quest in finished_quests:
		learned_spells.append(quest[0])
		active_quests.erase(quest)
		append_new_quests(quest[0])

func progress_quests(type : String, data : Dictionary) -> void:
	for list in active_quests:
		for quest in list[1]:
			if quest.requirement_type == type:
				list[2] += quest.receive_hit_data(data)
				
			for subquest in quest.subquests:
				if subquest.requirement_type == type:
					subquest.receive_hit_data(data)

func connect_quests_with_modifier() -> void:
	for list in active_quests:
		for quest in list[1]:
			if quest.requires_successfull_modifier:
				quest.connect_modifier()
				
			for subquest in quest.subquests:
				if quest.requires_successfull_modifier:
					subquest.connect_modifier()

func get_speed() -> int:
	match base_values.speedstat:
		"Stability":
			if get_stability() > 0:
				return get_stability() + speed_variation
		"Balance":
			if get_balance() > 0:
				return get_balance() + speed_variation
		"Leaf":
			if get_leaf() > 0:
				return get_leaf() + speed_variation
		"Aroma": 
			if get_aroma() > 0:
				return get_aroma() + speed_variation
		"None":
			return -1
	return 0

func get_base_speed() -> int:
	match base_values.speedstat:
		"Stability":
			if get_stability() > 0:
				return get_stability()
		"Balance":
			if get_balance() > 0:
				return get_balance()
		"Leaf":
			if get_leaf() > 0:
				return get_leaf()
		"Aroma": 
			if get_aroma() > 0:
				return get_aroma()
		"None":
			return -1
	return 0


func change_health(value):
	current_hp = value
	if base_values is Resource and current_hp > get_max_hp():
		current_hp = get_max_hp()
	emit_signal("health_changed", current_hp)

#wird das hier überhaupt verwendet?
func get_action():
	var move_index = interface.load_menu(self)
	var action = Action.new()
	var spell : AA_Spell = self.moves[move_index]
	action.user = self
	action.move = move_index
	interface.activate_targeting(self.battle_slot, spell.targets, spell.targeting)
	action.target = yield(interface, "target_selected")
	return action


func _set_stability_stacks(value):
	stability_stacks = value
	emit_signal("stats_changed", self)

func _set_balance_stacks(value):
	balance_stacks = value
	emit_signal("stats_changed", self)

func _set_leaf_stacks(value):
	leaf_stacks = value
	emit_signal("stats_changed", self)

func _set_aroma_stacks(value):
	aroma_stacks = value
	emit_signal("stats_changed", self)

func _set_burn_stacks(value):
	emit_signal("status_condition_changed", "Burn", value - burn_stacks)
	burn_stacks = value
	emit_signal("effects_changed", self)

func _set_frost_stacks(value):
	emit_signal("status_condition_changed", "Frost", value - frost_stacks)
	frost_stacks = value
	emit_signal("effects_changed", self)

func _set_wet_stacks(value):
	emit_signal("status_condition_changed", "Wet", value - wet_stacks)
	wet_stacks = value
	emit_signal("effects_changed", self)

func _set_moss_stacks(value):
	emit_signal("status_condition_changed", "Moss", value - moss_stacks)
	moss_stacks = value
	emit_signal("effects_changed", self)

func _set_charge_stacks(value):
	emit_signal("status_condition_changed", "Charge", value - charge_stacks)
	charge_stacks = value
	emit_signal("effects_changed", self)

func evolve() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var random_index = rng.randi() % base_values.evolutions.size()
	
	evolve_index(random_index)

func evolve_index(index : int) -> void:
	var new_species = base_values.evolutions[index].new_species
	base_values = new_species

func is_familiar_with_element(element : String) -> bool:
	for move in moves:
		if move != null:
			if move.element == element:
				return true
	
	return false
