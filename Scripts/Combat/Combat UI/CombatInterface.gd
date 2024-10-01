extends Control

enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}

signal input_received

onready var combat_menu = $CombatMenu
onready var display = $Display
onready var selection_menu = $Selection
onready var marker = $Marker
onready var battle_log = $BattleLog
onready var battle_info = $BattleInfo
onready var spell_info = $SpellInfo

onready var switch : Resource


onready var is_ally = true
onready var is_fighter_left = true
onready var is_waiting_for_input = false

var fighter_left
var fighter_right
var fighting_reserves
var knowledge

var skip_left = false
var skip_right = false

var chosen_move_index_left : int
var chosen_move_index_right : int
var chosen_targets_left : Array
var chosen_targets_right : Array

#Wahrscheinlich gibt es noch überflüssige Funktionen
#UI-Kram am Besten in die Attribute verlagern

func _ready():
	combat_menu.connect("selected_move", self, "_received_move")
	combat_menu.connect("go_back", self, "_received_go_back")
	combat_menu.connect("selected_switch", self, "_received_switch")
	selection_menu.connect("slot_chosen", self, "_received_target")
	combat_menu.connect("hide_selection", selection_menu, "hide_targets")
	combat_menu.connect("show_info", self, "_toggle_info")
	
	switch = preload("res://Resources/Creatures/Spells/0_Technical/Switch.tres")


func _received_move(move_index):
	var chosen_move
	var fighter
	
	if is_fighter_left:
		chosen_move_index_left = move_index
		chosen_move = fighter_left.moves[move_index]
		fighter = fighter_left
	else:
		chosen_move_index_right = move_index
		chosen_move = fighter_right.moves[move_index]
		fighter = fighter_right

	spell_info.show()
	spell_info.set_info(chosen_move)
	
	selection_menu.hide_targets()
	var targets = CombatUtility.convert_targets(fighter.battle_slot, chosen_move.targets, fighter.get_parent().get_parent().get_parent())
	
	for target_fighter in get_parent().battle_queue.fighters:
		if targets.has(target_fighter.battle_slot):
			var index = target_fighter.battle_slot
			var damage = get_parent().battle_queue.damage_calculator.get_preview_damage(chosen_move, fighter, target_fighter, get_parent().battlefield)
			var accuracy = get_parent().battle_queue.get_accuracy(chosen_move, fighter, target_fighter)
			var max_life = target_fighter.base_values.max_life
			var is_multitarget = chosen_move.multitarget
			
			var is_status = false
			if chosen_move.type == "Status":
				is_status = true
			
			selection_menu.show_damage_preview(index, damage, accuracy, max_life, is_multitarget, is_status)

func _received_switch(switch_slot):
	if is_fighter_left:
		chosen_move_index_left = 5
		chosen_targets_left = [switch_slot]
	else:
		chosen_move_index_right = 5
		chosen_targets_right = [switch_slot]
	
	reset_menu()
	
	if is_fighter_left and not skip_right:
		is_fighter_left = false
		initialize_menu(fighter_right, fighting_reserves)
	else:
		combat_menu.hide()
		combat_menu.unlock_ally_switch_slots()
		combat_menu.unlock_enemy_switch_slots()
		send_input()

func _received_target(selection):
	
	if is_fighter_left:
		if fighter_left.moves[chosen_move_index_left].multitarget:
			chosen_targets_left = CombatUtility.convert_targets(fighter_left.battle_slot, 
					fighter_left.moves[chosen_move_index_left].targets, fighter_left.get_parent().get_parent().get_parent())
		else:
			chosen_targets_left = selection
		
	else:
		if fighter_right.moves[chosen_move_index_right].multitarget:
			chosen_targets_right = CombatUtility.convert_targets(fighter_right.battle_slot, 
					fighter_right.moves[chosen_move_index_right].targets, fighter_right.get_parent().get_parent().get_parent())
		else:
			chosen_targets_right = selection
	
	reset_menu()

	if is_fighter_left and not skip_right:
		is_fighter_left = false
		initialize_menu(fighter_right, fighting_reserves)
	else:
		combat_menu.hide()
		combat_menu.unlock_ally_switch_slots()
		combat_menu.unlock_enemy_switch_slots()
		send_input()



func send_input():
	var actions = []
	
	var left_action : Action
	if fighter_left != null:
		if fighter_left.repeating > 0:
			actions.append(fighter_left.previous_action)
		elif fighter_left.previous_action != null:
			if fighter_left.previous_action.move.uses_additional_spell == "After":
				var action = Action.new()
				action.target = fighter_left.previous_action.target
				action.user = fighter_left.previous_action.user
				action.move = fighter_left.previous_action.move.extra_spell
				actions.append(action)
			else:
				left_action = convert_action(fighter_left, chosen_move_index_left, chosen_targets_left)
				actions.append(left_action)
		else:
			left_action = convert_action(fighter_left, chosen_move_index_left, chosen_targets_left)
			actions.append(left_action)
	
	var right_action : Action
	if fighter_right != null:
		if fighter_right.repeating > 0:
			actions.append(fighter_right.previous_action)
		elif fighter_right.previous_action != null:
			if fighter_right.previous_action.move.uses_additional_spell == "After":
				var action = Action.new()
				action.target = fighter_right.previous_action.target
				action.user = fighter_right.previous_action.user
				action.move = fighter_right.previous_action.move.extra_spell
				actions.append(action)
			else:
				right_action = convert_action(fighter_right, chosen_move_index_right, chosen_targets_right)
				actions.append(right_action)
		else:
			right_action = convert_action(fighter_right, chosen_move_index_right, chosen_targets_right)
			actions.append(right_action)
	
	emit_signal("input_received", actions)



func _received_go_back(is_changing_fighter):

	spell_info.hide()

	if is_changing_fighter:
		is_fighter_left = true
		initialize_menu(fighter_left, fighting_reserves)
		combat_menu.unlock_ally_switch_slots()
		combat_menu.unlock_enemy_switch_slots()
		
	if is_fighter_left:
		hide_back()


func initialize(left_ally, right_ally, left_enemy, right_enemy):
	$Display/AllyDisplay/AllySlotLeft.fillslot(left_ally)
	$Display/AllyDisplay/AllySlotRight.fill_slot(right_ally)
	$Display/EnemyDisplay/EnemySlotLeft.fillslot(left_enemy)
	$Display/EnemyDisplay/EnemySlotRight.fillslot(right_enemy)

func reset_menu():
	combat_menu.reset()
	selection_menu.hide_targets()
	spell_info.hide()

func show_back():
	combat_menu.show_back()

func hide_back():
	combat_menu.hide_back()

func show_interface():
	combat_menu.show()
	selection_menu.show()
	display.show()

func show_marker():
	marker.show()

func hide_marker():
	marker.hide()

func set_marker(slot):
	marker.set_slot(slot)




func ask_for_player_input(left_creature, right_creature, reserves, new_knowledge):
	fighter_left = left_creature
	fighter_right = right_creature
	fighting_reserves = reserves
	knowledge = new_knowledge
	
	start_menu(fighter_left, fighter_right, fighting_reserves)




func convert_action(creature, chosen_move_index, chosen_targets):
	var action = Action.new()
	
	action.user = creature
	action.target = chosen_targets
	
	if chosen_move_index == 5:
		action.move = switch
	else:
		action.move = creature.moves[chosen_move_index]
	
	return action

func start_menu(left_creature: Creature, right_creature: Creature, reserves: Array):
	show_interface()
	is_fighter_left = true
	fighter_left = left_creature
	fighter_right = right_creature
	fighting_reserves = reserves
	
	skip_left = false
	skip_right = false
	
	
	if left_creature == null:
		skip_left = true
	elif left_creature.repeating > 0:
		skip_left = true
	elif left_creature.previous_action != null:
		if left_creature.previous_action.move.uses_additional_spell == "After":
			skip_left = true
	
	if right_creature == null:
		skip_right = true
	elif right_creature.repeating > 0:
		skip_right = true
	elif right_creature.previous_action != null:
		if right_creature.previous_action.move.uses_additional_spell == "After":
			skip_right = true
	
	
	if not skip_left:
		initialize_menu(left_creature, reserves)
	elif not skip_right:
		is_fighter_left = false
		initialize_menu(right_creature, reserves)
	else:
		combat_menu.hide()
		combat_menu.unlock_ally_switch_slots()
		combat_menu.unlock_enemy_switch_slots()
		send_input()

func initialize_menu(creature: Creature, reserves: Array):
	if creature.battle_slot == -1 or creature.battle_slot == 1:
		combat_menu.is_creature_ally = true
	else:
		combat_menu.is_creature_ally = false
	
	marker.set_slot(creature.battle_slot)
	
	if creature.moves[0] is Resource:
		$CombatMenu/Container/FightSelection/Move1.text = creature.moves[0].name
		$CombatMenu/Container/FightSelection/Move1.show()
	else:
		$CombatMenu/Container/FightSelection/Move1.hide()
	if creature.moves[1] is Resource:
		$CombatMenu/Container/FightSelection/Move2.text = creature.moves[1].name
		$CombatMenu/Container/FightSelection/Move2.show()
	else:
		$CombatMenu/Container/FightSelection/Move2.hide()
	if creature.moves[2] is Resource:
		$CombatMenu/Container/FightSelection/Move3.text = creature.moves[2].name
		$CombatMenu/Container/FightSelection/Move3.show()
	else:
		$CombatMenu/Container/FightSelection/Move3.hide()
	if creature.moves[3] is Resource:
		$CombatMenu/Container/FightSelection/Move4.text = creature.moves[3].name
		$CombatMenu/Container/FightSelection/Move4.show()
	else:
		$CombatMenu/Container/FightSelection/Move4.hide()
	if creature.moves[4] is Resource:
		$CombatMenu/Container/FightSelection/Move5.text = creature.moves[4].name
		$CombatMenu/Container/FightSelection/Move5.show()
	else:
		$CombatMenu/Container/FightSelection/Move5.hide()
	
	for iterator in range(reserves.size()):
		$CombatMenu/Container/AllySwitchSelection.get_child(iterator).text = reserves[iterator].get_display_name()
		$CombatMenu/Container/AllySwitchSelection.get_child(iterator).show()
		$CombatMenu/Container/EnemySwitchSelection.get_child(iterator).text = reserves[iterator].get_display_name()
		$CombatMenu/Container/EnemySwitchSelection.get_child(iterator).show()

func show_replacements(reserves: Array):
	$CombatMenu/Container/KnockoutSelection.show()
	for iterator in range(reserves.size()):
		$CombatMenu/Container/KnockoutSelection.get_child(iterator).text = reserves[iterator].get_display_name()
		$CombatMenu/Container/KnockoutSelection.get_child(iterator).show()

func activate_targeting(selection, is_targeting_active):
	selection_menu.show_targets(selection, is_targeting_active)



func load_display_slot(slot, creature):
	match slot:
		LEFT_ALLY:
			$Display/AllyDisplay/AllySlotLeft.fill_slot(creature)
		RIGHT_ALLY:
			$Display/AllyDisplay/AllySlotRight.fill_slot(creature)
		LEFT_ENEMY:
			$Display/EnemyDisplay/EnemySlotLeft.fill_slot(creature)
		RIGHT_ENEMY:
			$Display/EnemyDisplay/EnemySlotRight.fill_slot(creature)

func clear_display_slot(slot):
	match slot:
		LEFT_ALLY:
			$Display/AllyDisplay/AllySlotLeft.clear_slot()
		RIGHT_ALLY:
			$Display/AllyDisplay/AllySlotRight.clear_slot()
		LEFT_ENEMY:
			$Display/EnemyDisplay/EnemySlotLeft.clear_slot()
		RIGHT_ENEMY:
			$Display/EnemyDisplay/EnemySlotRight.clear_slot()


func _toggle_info(show: bool):
	if show:
		battle_info.show()
		battle_info.show_fighters(get_parent().battlefield.get_fighter(LEFT_ALLY), get_parent().battlefield.get_fighter(RIGHT_ALLY), 
				get_parent().battlefield.get_fighter(LEFT_ENEMY), get_parent().battlefield.get_fighter(RIGHT_ENEMY), marker.slot)
		battle_info.set_aura(get_parent().battlefield.aura_type, get_parent().battlefield.aura_duration)
		battle_info.set_terrain(get_parent().battlefield.terrain_type, get_parent().battlefield.terrain_duration)
		battle_info.set_weather(get_parent().battlefield.weather_type, get_parent().battlefield.weather_duration)
		battle_info.set_ally_light(get_parent().battlefield.ally_side.light_counter)
		battle_info.set_enemy_light(get_parent().battlefield.enemy_side.light_counter)
	else:
		battle_info.hide()
