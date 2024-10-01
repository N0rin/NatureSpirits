extends Node2D

signal selected_replacement
signal fight_ended
enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}

onready var interface = $CombatInterface
onready var battlefield = $BattleQueue/Battlefield
onready var battle_queue = $BattleQueue
var ally_commander
var enemy_commander

onready var waiting_for_input = false

var menu_iterator = 0
var chosen_action : Action
var target_mode : bool
var is_targeting_active = true

#Knockout Handling muss überarbeitet werden

func _ready():
	interface.connect("move_selected", self, "_move_chosen")
	interface.connect("target_selected", self, "_selection_made")
	interface.connect("switch_selected", self, "_switch_chosen")
	interface.connect("go_back", self, "_menu_back")
	interface.combat_menu.connect("show_info", self, "_toggle_info")
	battle_queue.connect("battle_log_event", interface.battle_log, "_receive_event")
	battle_queue.connect("knockout", self, "_knockout")
	battle_queue.connect("switch", self, "_switch_creature")
	battle_queue.connect("modifier_connect", self, "_connect_modifier")
	battle_queue.connect("modifier_disconnect", self, "_disconnect_modifier")
	battle_queue.connect("round_finished", self, "handle_knockouts")


func add_fighter(loaded_creature, slot, is_ally):
	if loaded_creature is Creature:
		var creature = loaded_creature.duplicate()
		creature.active_quests = loaded_creature.active_quests
		creature.current_hp = creature.base_values.max_life
		match slot:
			1:
				if is_ally:
					$BattleQueue/Battlefield/Ally/Left.add_child(creature)
				else:
					$BattleQueue/Battlefield/Enemy/Left.add_child(creature)
			2:
				if is_ally:
					$BattleQueue/Battlefield/Ally/Right.add_child(creature)
				else:
					$BattleQueue/Battlefield/Enemy/Right.add_child(creature)
			3:
				if is_ally:
					$BattleQueue/Battlefield/Ally/Reserves.add_child(creature)
				else:
					$BattleQueue/Battlefield/Enemy/Reserves.add_child(creature)
			4:
				if is_ally:
					$BattleQueue/Battlefield/Ally/Reserves.add_child(creature)
				else:
					$BattleQueue/Battlefield/Enemy/Reserves.add_child(creature)
			5:
				if is_ally:
					$BattleQueue/Battlefield/Ally/Reserves.add_child(creature)
				else:
					$BattleQueue/Battlefield/Enemy/Reserves.add_child(creature)
			6:
				if is_ally:
					$BattleQueue/Battlefield/Ally/Reserves.add_child(creature)
				else:
					$BattleQueue/Battlefield/Enemy/Reserves.add_child(creature)

func add_commanders(commanders):
	$Commanders/AllyCommander.add_child(commanders[0])
	$Commanders/EnemyCommander.add_child(commanders[1])
	ally_commander = $Commanders/AllyCommander.get_child(0)
	enemy_commander = $Commanders/EnemyCommander.get_child(0)
	ally_commander.connect("actions_chosen", self, "receive_ally_commands")
	enemy_commander.connect("actions_chosen", self, "receive_enemy_commands")


func initialize_combat():
	battle_queue.connect("switch", self, "_switch_creature")
	
	battlefield.initialize_battlefield()
	battle_queue.initialize_queue(battlefield.get_fighter(LEFT_ALLY), battlefield.get_fighter(RIGHT_ALLY),
			battlefield.get_fighter(LEFT_ENEMY), battlefield.get_fighter(RIGHT_ENEMY))
	
	connect_interface()
	ally_commander.interface = interface
	enemy_commander.interface = interface
	
	interface.show_marker()
	$Win.hide()
	$Lose.hide()
	$Background.show()
	interface.combat_menu.show()
	interface.display.show()
	
	
	ally_commander.knowledge  = Knowledge.new()
	ally_commander.knowledge.battlefield = battlefield
	ally_commander.knowledge.is_ally = true
	
	enemy_commander.knowledge = Knowledge.new()
	enemy_commander.knowledge.battlefield = battlefield
	enemy_commander.knowledge.is_ally = false
	
	combat_round_start()

func connect_interface():
	battlefield.get_fighter(LEFT_ALLY).set("interface", interface)
	battlefield.get_fighter(RIGHT_ALLY).set("interface", interface)
	battlefield.get_fighter(LEFT_ENEMY).set("interface", interface)
	battlefield.get_fighter(RIGHT_ENEMY).set("interface", interface)
	
	battlefield.get_fighter(LEFT_ALLY).connect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "change_health")
	battlefield.get_fighter(RIGHT_ALLY).connect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "change_health")
	battlefield.get_fighter(LEFT_ENEMY).connect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "change_health")
	battlefield.get_fighter(RIGHT_ENEMY).connect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "change_health")
	
	battlefield.get_fighter(LEFT_ALLY).connect("stats_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "reload_stat_counter")
	battlefield.get_fighter(RIGHT_ALLY).connect("stats_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "reload_stat_counter")
	battlefield.get_fighter(LEFT_ENEMY).connect("stats_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "reload_stat_counter")
	battlefield.get_fighter(RIGHT_ENEMY).connect("stats_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "reload_stat_counter")
	
	battlefield.get_fighter(LEFT_ALLY).connect("effects_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "reload_effect_counter")
	battlefield.get_fighter(RIGHT_ALLY).connect("effects_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "reload_effect_counter")
	battlefield.get_fighter(LEFT_ENEMY).connect("effects_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "reload_effect_counter")
	battlefield.get_fighter(RIGHT_ENEMY).connect("effects_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "reload_effect_counter")
	
	battlefield.get_fighter(LEFT_ALLY).connect("status_condition_changed", interface.battle_log, "announce_status_condition_change")
	battlefield.get_fighter(RIGHT_ALLY).connect("status_condition_changed", interface.battle_log, "announce_status_condition_change")
	battlefield.get_fighter(LEFT_ENEMY).connect("status_condition_changed", interface.battle_log, "announce_status_condition_change")
	battlefield.get_fighter(RIGHT_ENEMY).connect("status_condition_changed", interface.battle_log, "announce_status_condition_change")
	
	
	interface.load_display_slot(LEFT_ALLY, battlefield.get_fighter(LEFT_ALLY))
	interface.load_display_slot(RIGHT_ALLY, battlefield.get_fighter(RIGHT_ALLY))
	interface.load_display_slot(LEFT_ENEMY, battlefield.get_fighter(LEFT_ENEMY))
	interface.load_display_slot(RIGHT_ENEMY, battlefield.get_fighter(RIGHT_ENEMY))


func combat_round_start():
	interface.is_ally = true
	ally_commander.start_command_creation()

func receive_ally_commands(actions):
	battle_queue.actions.append_array(actions)
	
	interface.is_ally = false
	enemy_commander.start_command_creation()

func receive_enemy_commands(actions):
	battle_queue.actions.append_array(actions)
	
	combat_round()
	
func combat_round():
	battle_queue.execute_combat_turn()

func round_end():
	combat_round_start()

#TODO
func handle_knockouts():

	
	if ally_commander.player_controlled:
		interface.combat_menu.show()
		interface.combat_menu.main_selection.hide()
	
		if battlefield.get_fighter(LEFT_ALLY) == null:
			waiting_for_input = true
			replace_fighter(LEFT_ALLY)
			yield(wait_for_input(), "completed")
		interface.combat_menu.unlock_replacement()
		if battlefield.get_fighter(RIGHT_ALLY) == null:
			waiting_for_input = true
			replace_fighter(RIGHT_ALLY)
			yield(wait_for_input(), "completed")
		interface.combat_menu.unlock_replacement()
	
	else:
		if battlefield.get_fighter(LEFT_ALLY) == null:
			if battlefield.get_ally_reserve().size() > 0:
				var replacement_slot = ally_commander.get_replacement(LEFT_ALLY)
				_switch_creature(LEFT_ALLY, replacement_slot)
		if battlefield.get_fighter(RIGHT_ALLY) == null:
			if battlefield.get_ally_reserve().size() > 0:
				var replacement_slot = ally_commander.get_replacement(RIGHT_ALLY)
				_switch_creature(RIGHT_ALLY, replacement_slot)
	
	if enemy_commander.player_controlled:
		interface.combat_menu.show()
		interface.combat_menu.main_selection.hide()
	
		if battlefield.get_fighter(LEFT_ENEMY) == null:
			waiting_for_input = true
			replace_fighter(LEFT_ENEMY)
			yield(wait_for_input(), "completed")
		interface.combat_menu.unlock_replacement()
		if battlefield.get_fighter(RIGHT_ENEMY) == null:
			waiting_for_input = true
			replace_fighter(RIGHT_ENEMY)
			yield(wait_for_input(), "completed")
		interface.combat_menu.unlock_replacement()
	
	else:
		if battlefield.get_fighter(LEFT_ENEMY) == null:
			if battlefield.get_enemy_reserve().size() > 0:
				var replacement_slot = enemy_commander.get_replacement(LEFT_ENEMY)
				_switch_creature(LEFT_ENEMY, replacement_slot)
		if battlefield.get_fighter(RIGHT_ENEMY) == null:
			if battlefield.get_enemy_reserve().size() > 0:
				var replacement_slot = enemy_commander.get_replacement(RIGHT_ENEMY)
				_switch_creature(RIGHT_ENEMY, replacement_slot)
	
	
	
	if battlefield.get_fighter(LEFT_ALLY) == null and battlefield.get_fighter(RIGHT_ALLY) == null:
		game_over(false)
	elif battlefield.get_fighter(LEFT_ENEMY) == null and battlefield.get_fighter(RIGHT_ENEMY) == null:
		game_over(true)
	else:
		battle_queue.fighters.sort_custom($BattleQueue/Sorter, "sort_by_battle_slot")
		
		interface.combat_menu.main_selection.show()
		round_end()

func wait_for_input():
	while true:
		yield(get_tree(), "idle_frame")
		if waiting_for_input == false:
			break

func _selected_replacement(replacement):
	emit_signal("selected_replacement", replacement)
	waiting_for_input = false

func replace_fighter(slot):
	interface.combat_menu.reset_replacements()
	#reload_reserves()
	
	if battle_queue.test_for_ally(slot):
		interface.show_replacements(battlefield.get_ally_reserve())
		if battlefield.get_ally_reserve().size() < 1:
			interface.combat_menu.knockout_replacement.hide()
			waiting_for_input = false
			return
	else:
		interface.show_replacements(battlefield.get_enemy_reserve())
		if battlefield.get_enemy_reserve().size() < 1:
			interface.combat_menu.knockout_replacement.hide()
			waiting_for_input = false
			return
	
	var replacement_slot = yield(self, "selected_replacement")
	_switch_creature(slot, replacement_slot)
	interface.combat_menu.knockout_replacement.hide()
	waiting_for_input = false


func game_over(is_ally_winner):
	if is_ally_winner:
		$Win.show()
	else:
		$Lose.show()
	
	$Background.hide()
	interface.combat_menu.reset()
	interface.combat_menu.hide()
	interface.display.hide()
	interface.marker.hide()
	interface.battle_log.messages.clear()
	battlefield.clear_battlefield()
	
	emit_signal("fight_ended")


func _knockout(creature):
	
	interface.clear_display_slot(creature.battle_slot)
	
	match creature.battle_slot:
			LEFT_ENEMY:
				creature.disconnect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "change_health")
			RIGHT_ENEMY:
				creature.disconnect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "change_health")
			LEFT_ALLY:
				creature.disconnect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "change_health")
			RIGHT_ALLY:
				creature.disconnect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "change_health")

	battle_queue.fighters.erase(creature)
	interface.battle_log.announce_knockout()

	creature.get_parent().remove_child(creature)

func _switch_creature(battle_slot, switch_slot):
	var switch_out : Creature
	var switch_in : Creature
	var combat_slot: Node
	var reserve_slot: Node
	
	if battlefield.has_field_effect("Mycel") and battlefield.get_fighter(battle_slot) is Creature and battlefield.get_fighter(battle_slot).moss_stacks > 0:
		interface.battle_log.announce_switch_failed(battlefield.get_fighter(battle_slot).get_display_name())
		return
	
	match(battle_slot):
		LEFT_ALLY:
			switch_out = battlefield.get_fighter(LEFT_ALLY)
			if switch_out is Creature:
				switch_out.disconnect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "change_health")
				switch_out.disconnect("stats_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "reload_stat_counter")
				switch_out.disconnect("effects_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "reload_effect_counter")
			
			combat_slot = $BattleQueue/Battlefield/Ally/Left
			switch_in = battlefield.get_ally_creature(switch_slot +2)
			switch_in.connect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "change_health")
			switch_in.connect("stats_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "reload_stat_counter")
			switch_in.connect("effects_changed", $CombatInterface/Display/AllyDisplay/AllySlotLeft, "reload_effect_counter")

			
		RIGHT_ALLY:
			switch_out = battlefield.get_fighter(RIGHT_ALLY)
			if switch_out is Creature:
				switch_out.disconnect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "change_health")
				switch_out.disconnect("stats_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "reload_stat_counter")
				switch_out.disconnect("effects_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "reload_effect_counter")
			
			combat_slot = $BattleQueue/Battlefield/Ally/Right
			switch_in = battlefield.get_ally_creature(switch_slot +2)
			switch_in.connect("health_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "change_health")
			switch_in.connect("stats_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "reload_stat_counter")
			switch_in.connect("effects_changed", $CombatInterface/Display/AllyDisplay/AllySlotRight, "reload_effect_counter")
			
			
		LEFT_ENEMY:
			switch_out = battlefield.get_fighter(LEFT_ENEMY)
			if switch_out is Creature:
				switch_out.disconnect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "change_health")
				switch_out.disconnect("stats_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "reload_stat_counter")
				switch_out.disconnect("effects_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "reload_effect_counter")
			
			combat_slot = $BattleQueue/Battlefield/Enemy/Left
			switch_in = battlefield.get_enemy_creature(switch_slot +2)
			switch_in.connect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "change_health")
			switch_in.connect("stats_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "reload_stat_counter")
			switch_in.connect("effects_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotLeft, "reload_effect_counter")
			
		RIGHT_ENEMY:
			switch_out = battlefield.get_fighter(RIGHT_ENEMY)
			if switch_out is Creature:
				switch_out.disconnect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "change_health")
				switch_out.disconnect("stats_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "reload_stat_counter")
				switch_out.disconnect("effects_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "reload_effect_counter")
			
			combat_slot = $BattleQueue/Battlefield/Enemy/Right
			switch_in = battlefield.get_enemy_creature(switch_slot +2)
			switch_in.connect("health_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "change_health")
			switch_in.connect("stats_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "reload_stat_counter")
			switch_in.connect("effects_changed", $CombatInterface/Display/EnemyDisplay/EnemySlotRight, "reload_effect_counter")
		
	switch_in.connect("status_condition_changed", interface.battle_log, "announce_status_condition_change")
	
	reserve_slot = switch_in.get_parent()
	
	if switch_out is Creature:
		battle_queue.fighters.erase(switch_out)
		combat_slot.remove_child(switch_out)
		reserve_slot.add_child(switch_out)
		switch_out.battle_slot = 0
		switch_out.reset_temporary_changes()
		switch_out.disconnect("status_condition_changed", interface.battle_log, "announce_status_condition_change")

	
	battle_queue.fighters.append(switch_in)
	reserve_slot.remove_child(switch_in)
	combat_slot.add_child(switch_in)
	switch_in.battle_slot = battle_slot
	interface.load_display_slot(battle_slot, switch_in)

func _connect_modifier(modifier):
	modifier.connect_signals(interface.battle_log)

func _disconnect_modifier(modifier):
	modifier.disconnect_signals(interface.battle_log)
