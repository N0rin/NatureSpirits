extends Control

onready var damage_label = $Margin/VBox/Grid/Damage
onready var element_label = $Margin/VBox/Grid/Element
onready var accuracy_label = $Margin/VBox/Grid/Accuracy
onready var attack_stat_label = $Margin/VBox/Grid/AttackStat
onready var priority_label = $Margin/VBox/Grid/Priority
onready var defense_stat_label = $Margin/VBox/Grid/DefenseStat
onready var description_label = $Margin/VBox/Description

func set_info(move):
	clear()
	if not move.base_damage == 0:
		damage_label.append_bbcode(" Damage: * %s" % move.base_damage)
	
	if not move.element == "":
		element_label.append_bbcode("Element: %s" % move.element)
	
	if move.can_miss:
		accuracy_label.append_bbcode(" Accuracy: %s%%" % move.accuracy)
	else:
		accuracy_label.append_bbcode(" Accuracy: Yes")
	
	if not move.used_stat == "":
		attack_stat_label.append_bbcode("Attack: %s" % move.used_stat)
	
	priority_label.append_bbcode("Priority: %+s" % move.priority)
	
	if not move.target_stat == "":
		defense_stat_label.append_bbcode("Defense: %s" % move.target_stat)
	
	description_label.append_bbcode(move.description)
	
func clear():
	damage_label.clear()
	element_label.clear()
	accuracy_label.clear()
	attack_stat_label.clear()
	priority_label.clear()
	defense_stat_label.clear()
	description_label.clear()
