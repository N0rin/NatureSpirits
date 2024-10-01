extends Node

export(int) var match_count = 1

export(String, "None", "Lightning", "Fire", "Frost", "Water", "Wind", "Ground") var aura_type = "None"
export(int) var aura_duration = 0
export(String, "None", "Rain") var weather_type = "None"
export(int) var weather_duration = 0
export(String, "None", "Fog", "Mycel", "Ember") var terrain_type = "None"
export(int) var terrain_duration = 0

func get_fighter(slot):
	match slot:
		1:
			return $Slot1.get_child(0)
		2:
			return $Slot2.get_child(0)
		3:
			return $Slot3.get_child(0)
		4:
			return $Slot4.get_child(0)
		5:
			return $Slot5.get_child(0)
		6:
			return $Slot6.get_child(0)

func get_commanders():
	var ally = $AllyCommander.get_child(0)
	var enemy = $EnemyCommander.get_child(0)
	$AllyCommander.remove_child(ally)
	$EnemyCommander.remove_child(enemy)
	return [ally, enemy]
