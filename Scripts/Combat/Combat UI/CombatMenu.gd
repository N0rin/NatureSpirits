extends MarginContainer

signal selected_move
signal selected_switch
signal selected_replacement
signal go_back
signal hide_selection
signal show_info

enum {MAIN, MOVES, SELECTION, CHANGE, INFO}
var menu_state = MAIN
var move_letter = -1
var first_ally_switch = -1
var is_creature_ally = true
onready var main_selection = $Container/MainSelection
onready var fight_selection = $Container/FightSelection
onready var ally_switch_selection = $Container/AllySwitchSelection
onready var enemy_switch_selection = $Container/EnemySwitchSelection
onready var knockout_replacement = $Container/KnockoutSelection
onready var back = $Container/Back

#Funktionen sollten noch sortiert werden
#Back funktioniert noch nicht

func _on_Fight_pressed():
	main_selection.hide()
	fight_selection.show()
	back.show()
	menu_state = MOVES

func _on_Change_pressed():
	main_selection.hide()
	if is_creature_ally:
		ally_switch_selection.show()
	else:
		enemy_switch_selection.show()
	
	back.show()
	menu_state = CHANGE

func _on_Info_pressed():
	main_selection.hide()
	emit_signal("show_info", true)
	back.show()
	menu_state = INFO
	
func _on_Back_pressed():
	unlock_moves()
	
	if menu_state == MAIN:
		emit_signal("go_back", true)
	
	if menu_state == MOVES:
		main_selection.show()
		fight_selection.hide()
		menu_state = MAIN
		emit_signal("go_back", false)
	
	if menu_state == CHANGE:
		main_selection.show()
		ally_switch_selection.hide()
		enemy_switch_selection.hide()
		menu_state = MAIN
		emit_signal("go_back", false)
	
	if menu_state == SELECTION:
		main_selection.show()
		fight_selection.hide()
		menu_state = MAIN
		emit_signal("hide_selection")
		emit_signal("go_back", false)
	
	if menu_state == INFO:
		main_selection.show()
		menu_state == MAIN
		emit_signal("show_info", false)
		emit_signal("go_back", false)

func reset():
	fight_selection.hide()
	ally_switch_selection.hide()
	enemy_switch_selection.hide()
	knockout_replacement.hide()
	back.hide()
	main_selection.show()
	menu_state = MAIN
	unlock_moves()
	
	for node in ally_switch_selection.get_children():
		node.hide()
	
	for node in enemy_switch_selection.get_children():
		node.hide()
	
	for node in knockout_replacement.get_children():
		node.hide()

func reset_replacements():
	for node in knockout_replacement.get_children():
		node.hide()

func unlock_moves():
	$Container/FightSelection/Move1.disabled = false
	$Container/FightSelection/Move2.disabled = false
	$Container/FightSelection/Move3.disabled = false
	$Container/FightSelection/Move4.disabled = false
	$Container/FightSelection/Move5.disabled = false

func unlock_ally_switch_slots():
	$Container/AllySwitchSelection/Slot3.disabled = false
	$Container/AllySwitchSelection/Slot4.disabled = false
	$Container/AllySwitchSelection/Slot5.disabled = false
	$Container/AllySwitchSelection/Slot6.disabled = false

func unlock_enemy_switch_slots():
	$Container/EnemySwitchSelection/Slot3.disabled = false
	$Container/EnemySwitchSelection/Slot4.disabled = false
	$Container/EnemySwitchSelection/Slot5.disabled = false
	$Container/EnemySwitchSelection/Slot6.disabled = false

func unlock_replacement():
	$Container/KnockoutSelection/Slot3.disabled = false
	$Container/KnockoutSelection/Slot4.disabled = false
	$Container/KnockoutSelection/Slot5.disabled = false
	$Container/KnockoutSelection/Slot6.disabled = false

func show_back():
	back.show()

func hide_back():
	back.hide()

func _on_Move1_pressed():
	send_move(0)
	$Container/FightSelection/Move1.disabled = true
	$Container/FightSelection/Move2.disabled = false
	$Container/FightSelection/Move3.disabled = false
	$Container/FightSelection/Move4.disabled = false
	$Container/FightSelection/Move5.disabled = false
	menu_state = SELECTION

func _on_Move2_pressed():
	send_move(1)
	$Container/FightSelection/Move1.disabled = false
	$Container/FightSelection/Move2.disabled = true
	$Container/FightSelection/Move3.disabled = false
	$Container/FightSelection/Move4.disabled = false
	$Container/FightSelection/Move5.disabled = false
	menu_state = SELECTION

func _on_Move3_pressed():
	send_move(2)
	$Container/FightSelection/Move1.disabled = false
	$Container/FightSelection/Move2.disabled = false
	$Container/FightSelection/Move3.disabled = true
	$Container/FightSelection/Move4.disabled = false
	$Container/FightSelection/Move5.disabled = false
	menu_state = SELECTION

func _on_Move4_pressed():
	send_move(3)
	$Container/FightSelection/Move1.disabled = false
	$Container/FightSelection/Move2.disabled = false
	$Container/FightSelection/Move3.disabled = false
	$Container/FightSelection/Move4.disabled = true
	$Container/FightSelection/Move5.disabled = false
	menu_state = SELECTION

func _on_Move5_pressed():
	send_move(4)
	$Container/FightSelection/Move1.disabled = false
	$Container/FightSelection/Move2.disabled = false
	$Container/FightSelection/Move3.disabled = false
	$Container/FightSelection/Move4.disabled = false
	$Container/FightSelection/Move5.disabled = true
	menu_state = SELECTION

func send_move(selected_move):
	emit_signal("selected_move", selected_move)

func _on_Ally_Slot3_pressed():
	$Container/AllySwitchSelection/Slot3.disabled = true
	send_switch(0)

func _on_Ally_Slot4_pressed():
	$Container/AllySwitchSelection/Slot4.disabled = true
	send_switch(1)

func _on_Ally_Slot5_pressed():
	$Container/AllySwitchSelection/Slot5.disabled = true
	send_switch(2)

func _on_Ally_Slot6_pressed():
	$Container/AllySwitchSelection/Slot6.disabled = true
	send_switch(3)

func lock_ally_switch_slot(slot):
	match(slot):
		0:
			$Container/AllySwitchSelection/Slot3.disabled = true
		1:
			$Container/AllySwitchSelection/Slot4.disabled = true
		2:
			$Container/AllySwitchSelection/Slot5.disabled = true
		3:
			$Container/AllySwitchSelection/Slot6.disabled = true

func _on_Enemy_Slot3_pressed():
	$Container/EnemySwitchSelection/Slot3.disabled = true
	send_switch(0)

func _on_Enemy_Slot4_pressed():
	$Container/EnemySwitchSelection/Slot4.disabled = true
	send_switch(1)

func _on_Enemy_Slot5_pressed():
	$Container/EnemySwitchSelection/Slot5.disabled = true
	send_switch(2)

func _on_Enemy_Slot6_pressed():
	$Container/EnemySwitchSelection/Slot6.disabled = true
	send_switch(3)

func send_switch(selected_switch):
	emit_signal("selected_switch", selected_switch)


func _on_KO_Slot3_pressed():
	$Container/KnockoutSelection/Slot3.disabled = true
	send_replacement(0)

func _on_KO_Slot4_pressed():
	$Container/KnockoutSelection/Slot4.disabled = true
	send_replacement(1)

func _on_KO_Slot5_pressed():
	$Container/KnockoutSelection/Slot5.disabled = true
	send_replacement(2)

func _on_KO_Slot6_pressed():
	$Container/KnockoutSelection/Slot6.disabled = true
	send_replacement(3)

func send_replacement(replacement):
	emit_signal("selected_replacement", replacement)

