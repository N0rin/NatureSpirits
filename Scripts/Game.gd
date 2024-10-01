extends Node

onready var combat = $Combat
onready var world = $GameWorld
onready var spell_selection = preload("res://Scenes/UI/SpellSelection.tscn").instance()
onready var evolution_selection = preload("res://Scenes/UI/EvolutionSelection.tscn").instance()

var last_collider = null
#Wechsel zwischen Spielwelt und Kampf muss reibungslos verlaufen
#Encounter müssen irgendwie geladen werden

func _ready():
	combat.connect("fight_ended", self, "on_battle_finished")
	spell_selection.connect("spell_selection_finished", self, "on_spell_selection_finished")
	evolution_selection.connect("evolution_finished", self, "on_evolution_selection_finished")
	$GameWorld/PlayerCharacter.connect("collision", self, "on_player_collision")
	
	for node in $PlayerData/Team.get_children():
		if node.get_child_count() > 0:
			for spell in node.get_child(0).learned_spells:
				node.get_child(0).append_new_quests(spell)
	

func start_fight():
	remove_child(world)
	
	$Combat.show()
	$Combat.initialize_combat()

func load_encounter_data(encounter_data):
	combat.add_fighter($PlayerData/Team/Slot1.get_child(0), 1, true)
	combat.add_fighter($PlayerData/Team/Slot2.get_child(0), 2, true)
	combat.add_fighter($PlayerData/Team/Slot3.get_child(0), 3, true)
	combat.add_fighter($PlayerData/Team/Slot4.get_child(0), 4, true)
	combat.add_fighter($PlayerData/Team/Slot5.get_child(0), 5, true)
	combat.add_fighter($PlayerData/Team/Slot6.get_child(0), 6, true)
	
	combat.add_fighter(encounter_data.get_fighter(1), 1, false)
	combat.add_fighter(encounter_data.get_fighter(2), 2, false)
	combat.add_fighter(encounter_data.get_fighter(3), 3, false)
	combat.add_fighter(encounter_data.get_fighter(4), 4, false)
	combat.add_fighter(encounter_data.get_fighter(5), 5, false)
	combat.add_fighter(encounter_data.get_fighter(6), 6, false)
	
	if encounter_data.aura_duration > 0:
		combat.battlefield.set_aura(encounter_data.aura_type, encounter_data.aura_duration)
	if encounter_data.terrain_duration > 0:
		combat.battlefield.set_terrain(encounter_data.terrain_type, encounter_data.terrain_duration)
	if encounter_data.weather_duration > 0:
		combat.battlefield.set_weather(encounter_data.weather_type, encounter_data.weather_duration)
	
	combat.add_commanders(encounter_data.get_commanders())

func on_player_collision(collider):
	last_collider = collider
	
	if collider is Encounter:
		collider.connect("encounter", self, "on_encounter")
		collider.send_encounter()
		#collider.disconnect("encounter", self, "on_encounter")
	
	if collider is Station:
		
		if $GameWorld/PlayerCharacter != null:
			if collider.get_node("CollisionBox").disabled == false:
				$GameWorld/PlayerCharacter.global_position = collider.get_exit()
		
		collider.get_node("CollisionBox").disabled = true
		
		var creatures = []
		for iterator in $PlayerData/Team.get_child_count():
			if $PlayerData/Team.get_child(iterator).get_child_count() > 0:
				var path = "PlayerData/Team/Slot%s"
				creatures.append(get_node(path % (iterator+1) ).get_child(0))
		
		spell_selection.load_creature_list(creatures)
		remove_child(world)
		add_child(spell_selection)
		collider.get_node("CollisionBox").disabled = false
	
	if collider is Evolver:
		if collider.uses > 0:
			if $GameWorld/PlayerCharacter != null:
				if collider.get_node("CollisionBox").disabled == false:
					$GameWorld/PlayerCharacter.global_position = collider.get_exit()
			
			collider.get_node("CollisionBox").disabled = true
			
			var creatures = []
			for iterator in $PlayerData/Team.get_child_count():
				if $PlayerData/Team.get_child(iterator).get_child_count() > 0:
					var path = "PlayerData/Team/Slot%s"
					creatures.append(get_node(path % (iterator+1) ).get_child(0))
			
			evolution_selection.load_creature_list(creatures)
			remove_child(world)
			add_child(evolution_selection)
			collider.get_node("CollisionBox").disabled = false
	
	if collider is TeamEvolver:
		if collider.get_node("CollisionBox").disabled == false:
			$PlayerData.remove_child($PlayerData/Team)
			var new_team = collider.get_node("Team")
			new_team.get_parent().remove_child(new_team)
			$PlayerData.add_child(new_team)
		collider.get_node("CollisionBox").disabled = true
		collider.hide()


func on_encounter(encounter_data):
	load_encounter_data(encounter_data)
	start_fight()

func on_battle_finished():
	combat.hide()
	add_child(world)
	
	for node in $PlayerData/Team.get_children():
		if node.get_child_count() > 0:
			node.get_child(0).learn_spells()

func on_spell_selection_finished():
	remove_child(spell_selection)
	add_child(world)

func on_evolution_selection_finished(used_function):
	remove_child(evolution_selection)
	if used_function:
		last_collider.uses -= 1
	add_child(world)
