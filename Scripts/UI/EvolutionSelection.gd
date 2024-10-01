extends Control

signal evolution_finished

var creature_list


func load_creature_list(creatures):
	creature_list = creatures
	
	for iterator in creatures.size():
		set_creature_button(iterator, creatures[iterator])
	
	if creatures.size() < 2:
		$CreatureList/Creature2.hide()
	if creatures.size() < 3:
		$CreatureList/Creature3.hide()
	if creatures.size() < 4:
		$CreatureList/Creature4.hide()
	if creatures.size() < 5:
		$CreatureList/Creature5.hide()
	if creatures.size() < 6:
		$CreatureList/Creature6.hide()

func evolve_creature(creature):
	creature.evolve()

func set_creature_button(slot, creature):
	$CreatureList.get_child(slot).text = creature.get_display_name()

func _on_creature1_pressed():
	evolve_creature(creature_list[0])
	emit_signal("evolution_finished", true)

func _on_creature2_pressed():
	evolve_creature(creature_list[1])
	emit_signal("evolution_finished", true)

func _on_creature3_pressed():
	evolve_creature(creature_list[2])
	emit_signal("evolution_finished", true)

func _on_creature4_pressed():
	evolve_creature(creature_list[3])
	emit_signal("evolution_finished", true)

func _on_creature5_pressed():
	evolve_creature(creature_list[4])
	emit_signal("evolution_finished", true)

func _on_creature6_pressed():
	evolve_creature(creature_list[5])
	emit_signal("evolution_finished", true)


func _on_exit_pressed():
	emit_signal("evolution_finished", false)

