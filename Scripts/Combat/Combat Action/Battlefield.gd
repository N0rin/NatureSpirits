extends Node
class_name Battlefield

enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}


onready var ally_side = $Ally
onready var enemy_side = $Enemy


var aura_type = "None"
var aura_duration = 0
var weather_type = "None"
var weather_duration = 0
var terrain_type = "None"
var terrain_duration = 0



func initialize_battlefield():

	
	get_fighter(LEFT_ALLY).battle_slot = LEFT_ALLY
	get_fighter(RIGHT_ALLY).battle_slot = RIGHT_ALLY
	get_fighter(LEFT_ENEMY).battle_slot = LEFT_ENEMY
	get_fighter(RIGHT_ENEMY).battle_slot = RIGHT_ENEMY


func clear_battlefield():
	aura_type = "None"
	aura_duration = 0
	weather_type = "None"
	weather_duration = 0
	terrain_type = "None"
	terrain_duration = 0
	
	ally_side.light_counter = 0
	ally_side.soul_counter = 0
	enemy_side.light_counter = 0
	enemy_side.soul_counter = 0
	
	for node in ally_side.get_children():
		for child in node.get_children():
			node.remove_child(child)
			child.free()
	for node in enemy_side.get_children():
		for child in node.get_children():
			node.remove_child(child)
			child.free()

func get_fighter(slot):
	
	match slot:
		LEFT_ALLY:
			return $Ally/Left.get_child(0)
		RIGHT_ALLY:
			return $Ally/Right.get_child(0)
		LEFT_ENEMY:
			return $Enemy/Left.get_child(0)
		RIGHT_ENEMY:
			return $Enemy/Right.get_child(0)
	
	return null

func has_field_effect(effect_name : String, min_duration = 1) -> bool:
	match effect_name:
		"Lightning", "Fire", "Frost", "Water", "Wind", "Ground":
			if aura_type == effect_name and aura_duration >= min_duration:
				return true
		
		"Fog", "Mycel", "Ember":
			if terrain_type == effect_name and terrain_duration >= min_duration:
				return true
	
		"Rain":
			if weather_type == effect_name and weather_duration >= min_duration:
				return true
	
	return false


func set_aura(type : String, duration : int) -> void:
	
	if aura_type == type and aura_duration >= duration:
		return
	
	aura_type = type
	aura_duration = duration

func set_terrain(type : String, duration :int) -> void:
	
	if terrain_type == type and terrain_duration >= duration:
		return
	
	terrain_type = type
	terrain_duration = duration

func set_weather(type : String, duration : int) -> void:
	
	if weather_type == type and terrain_duration >= duration:
		return
	
	weather_type = type
	weather_duration = duration

func get_partner(slot):
	return get_fighter(slot * -1)

func get_ally_creature(slot):
	match slot:
		0:
			return $Ally/Left.get_child(0)
		1:
			return $Ally/Right.get_child(0)
		2:
			return $Ally/Reserves.get_child(slot - 2)
		3:
			return $Ally/Reserves.get_child(slot - 2)
		4:
			return $Ally/Reserves.get_child(slot - 2)
		5:
			return $Ally/Reserves.get_child(slot - 2)

func get_enemy_creature(slot):
	match slot:
		0:
			return $Enemy/Left.get_child(0)
		1:
			return $Enemy/Right.get_child(0)
		2:
			return $Enemy/Reserves.get_child(slot - 2)
		3:
			return $Enemy/Reserves.get_child(slot - 2)
		4:
			return $Enemy/Reserves.get_child(slot - 2)
		5:
			return $Enemy/Reserves.get_child(slot - 2)

func get_ally_reserve():
	var reserves = []
	
	for creature in $Ally/Reserves.get_children():
		reserves.append(creature)
	
	return reserves

func get_enemy_reserve():
	var reserves = []
	
	for creature in $Enemy/Reserves.get_children():
		reserves.append(creature)
	
	return reserves
