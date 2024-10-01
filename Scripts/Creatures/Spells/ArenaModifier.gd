extends AA_SpellModifier
class_name AAA_ArenaModifier

signal battle_log_event

#export(String, "On-Hit", "Before", "After") var activation

export(int) var light = 0
export(int) var soul = 0
export(String, "None", "Lightning", "Fire", "Frost", "Water", "Wind", "Ground") var aura_type = "None"
export(int) var aura_duration = 0
export(String, "None", "Rain") var weather_type = "None"
export(int) var weather_duration = 0
export(String, "None", "Fog", "Mycel", "Ember") var terrain_type = "None"
export(int) var terrain_duration = 0


func apply_effects_on_target(user: Creature, target : Creature):
	var battlefield = target.get_parent().get_parent().get_parent()
	
	if light > 0:
		target.get_parent().get_parent().light_counter += light
		emit_signal("battle_log_event", "Light", {"target": target.get_display_name(), "value": light})
	if light < 0:
		if target.get_parent().get_parent().light_counter + light < 0:
			return false
		else:
			target.get_parent().get_parent().light_counter += light
			emit_signal("battle_log_event", "Light", {"target": target.get_display_name(), "value": light})
	
	if soul > 0:
		target.get_parent().get_parent().soul_counter += soul
		emit_signal("battle_log_event", "Soul", {"target": target.get_display_name(), "value": soul})
	if soul < 0:
		if target.get_parent().get_parent().soul_counter + soul < 0:
			return false
		else:
			target.get_parent().get_parent().soul_counter += soul
			emit_signal("battle_log_event", "Soul", {"target": target.get_display_name(), "value": soul})
	
	if aura_duration > 0:
		battlefield.set_aura(aura_type, aura_duration)
	
	if weather_duration > 0:
		battlefield.set_weather(weather_type, weather_duration)

	if terrain_duration > 0:
		battlefield.set_terrain(terrain_type, terrain_duration)
	
	return true

func connect_signals(battle_log):
	connect("battle_log_event", battle_log, "_receive_event")
	
func disconnect_signals(battle_log):
	disconnect("battle_log_event", battle_log, "_receive_event")

#func get_activation():
#	print("Activation:"+ activation)
#	return activation
