extends MarginContainer

onready var alignment_label = $Margin/VBox/Grid/Alignment
onready var element_label = $Margin/VBox/Grid/Element
onready var stability_label = $Margin/VBox/Grid/Stability
onready var balance_label = $Margin/VBox/Grid/Balance
onready var leaf_label = $Margin/VBox/Grid/Leaf
onready var aroma_label = $Margin/VBox/Grid/Aroma
onready var speedstat_label = $Margin/VBox/Speedstat

func set_info(creature, selected_creature):
	clear()
	alignment_label.append_bbcode(" Alignment: %s" % creature.base_values.type)
	if creature.base_values.type == "":
		alignment_label.clear()
	
	element_label.append_bbcode("Element: %s" % creature.base_values.element)
	if creature.base_values.element == "":
		element_label.clear()

	stability_label.append_bbcode(" Stability: %s" % creature.get_stability())
	
	balance_label.append_bbcode("Balance: %s" % creature.get_balance())
	
	leaf_label.append_bbcode(" Leaf: %s" % creature.get_leaf())
	
	aroma_label.append_bbcode("Aroma: %s" % creature.get_aroma())
	
	speedstat_label.append_bbcode(" Speed depends on %s" % creature.base_values.speedstat)
	if selected_creature != creature:
		var chance = get_outspeed_chance(creature.get_base_speed() - selected_creature.get_base_speed())
		speedstat_label.newline()
		speedstat_label.append_bbcode("%s%% chance to move before %s" % [chance, selected_creature.get_display_name()])


func get_outspeed_chance(speed_difference):
	if speed_difference < -4:
		return 0
	if speed_difference > 4:
		return 100
	
	match speed_difference:
		-4:
			return 2
		-3:
			return 8
		-2:
			return 18
		-1:
			return 32
		0:
			return 50
		1:
			return 68
		2:
			return 82
		3:
			return 92
		4:
			return 98

func clear():
	alignment_label.clear()
	element_label.clear()
	stability_label.clear()
	balance_label.clear()
	leaf_label.clear()
	aroma_label.clear()
	speedstat_label.clear()
