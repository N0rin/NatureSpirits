extends AA_SpellModifier
class_name AAA_SpecialModifier

signal battle_log_event



export(int) var repeats = 0
export(int) var no_stat_decrease = 0
export(bool) var symbiosis = false
export(int) var fire_boost = 0
export(int) var strong_spikes = 0


func apply_effects_on_target(user: Creature, target : Creature):
	
	if no_stat_decrease > 0:
		target.no_stat_decrease += no_stat_decrease
		emit_signal("battle_log_event", "No_Stat_Decrease", {"target": target.get_display_name(), "value":no_stat_decrease})
	if symbiosis:
		target.symbiosis = true
		emit_signal("battle_log_event", "Symbiosis", {"target": target.get_display_name()})
	if fire_boost > 0:
		target.fire_boost = fire_boost
	if strong_spikes > 0:
		target.strong_spikes = strong_spikes
	if repeats > 0 and repeats > target.repeating:
		target.repeating = repeats
	
	return true


func connect_signals(battle_log):
	connect("battle_log_event", battle_log, "_receive_event")
	
func disconnect_signals(battle_log):
	disconnect("battle_log_event", battle_log, "_receive_event")


func get_activation():
	print("Activation:"+ activation)
	return activation
