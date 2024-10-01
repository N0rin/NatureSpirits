extends Control

signal spell_selection_finished

var creature_list
var selected_creature

func load_creature_list(creatures):
	creature_list = creatures
	
	for iterator in creatures.size():
		set_creature_button(iterator, creatures[iterator])
	
	if creatures.size() < 2:
		$HBoxContainer/CreatureList/Creature2.hide()
	if creatures.size() < 3:
		$HBoxContainer/CreatureList/Creature3.hide()
	if creatures.size() < 4:
		$HBoxContainer/CreatureList/Creature4.hide()
	if creatures.size() < 5:
		$HBoxContainer/CreatureList/Creature5.hide()
	if creatures.size() < 6:
		$HBoxContainer/CreatureList/Creature6.hide()

func set_creature_button(slot, creature):
	$HBoxContainer/CreatureList.get_child(slot).text = creature.get_display_name()

func load_creature(creature):
	reset_menu()
	selected_creature = creature
	
	for iterator in creature.moves.size():
		if creature.moves[iterator] == null:
			continue
		
		var new_button = preload("res://Scenes/UI/SpellSelectButton.tscn").instance()
		new_button.toggle_activation()
		new_button.set_spell(creature.moves[iterator], iterator)
		new_button.connect("selected_button", self, "on_spell_selected")
		$HBoxContainer/SpellSelection/SelectedSpells.add_child(new_button)
	
	var unselected_spells = creature.learned_spells.duplicate()
	
	for iterator in creature.moves.size():
		unselected_spells.erase(creature.moves[iterator])
	
	for iterator in unselected_spells.size():
		var new_button = preload("res://Scenes/UI/SpellSelectButton.tscn").instance()
		new_button.set_spell(unselected_spells[iterator], iterator + 5)
		new_button.connect("selected_button", self, "on_spell_selected")
		$HBoxContainer/SpellSelection/ScrollContainer/UnselectedSpells.add_child(new_button)
	
	
	if get_spell_selection().size() == 1:
		toggle_lock_all_active_spells()
	if get_spell_selection().size() == 5:
		toggle_lock_all_inactive_spells()

func on_spell_selected(button, was_active):
	if was_active:
		if get_spell_selection().size() == 5:
			toggle_lock_all_inactive_spells()
			
		move_button(button)
		
		if get_spell_selection().size() == 1:
			toggle_lock_all_active_spells()
	else:
		if get_spell_selection().size() == 1:
			toggle_lock_all_active_spells()
			
		move_button(button)
		
		if get_spell_selection().size() == 5:
			toggle_lock_all_inactive_spells()

func toggle_lock_all_active_spells():
	for button in get_spell_selection():
		toggle_button_lock(button)

func toggle_lock_all_inactive_spells():
	for button in get_spells():
		if get_spell_selection().find(button) == -1:
			toggle_button_lock(button)
	
func toggle_button_lock(button):
	button.toggle_lock()

func move_button(button):
	button.get_parent().remove_child(button)
	if button.is_activated:
		$HBoxContainer/SpellSelection/SelectedSpells.add_child(button)
	else:
		$HBoxContainer/SpellSelection/ScrollContainer/UnselectedSpells.add_child(button)

func reset_menu():
	selected_creature = null
	for button in $HBoxContainer/SpellSelection/ScrollContainer/UnselectedSpells.get_children():
		button.queue_free()
	for button in $HBoxContainer/SpellSelection/SelectedSpells.get_children():
		button.queue_free()

func _on_apply_button_pressed():
	selected_creature.moves.clear()
	for button in get_spell_selection():
		selected_creature.moves.append(button.spell)
	while selected_creature.moves.size() < 5:
		selected_creature.moves.append(null)

func get_spell_selection() -> Array:
	return $HBoxContainer/SpellSelection/SelectedSpells.get_children()

func get_spells() -> Array:
	return get_spell_selection() + $HBoxContainer/SpellSelection/ScrollContainer/UnselectedSpells.get_children()

func _on_creature1_pressed():
	load_creature(creature_list[0])

func _on_creature2_pressed():
	load_creature(creature_list[1])

func _on_creature3_pressed():
	load_creature(creature_list[2])

func _on_creature4_pressed():
	load_creature(creature_list[3])

func _on_creature5_pressed():
	load_creature(creature_list[4])

func _on_creature6_pressed():
	load_creature(creature_list[5])


func _on_exit_pressed():
	emit_signal("spell_selection_finished")

