extends AA_SpellModifier
class_name AAA_UtilityModifier

signal battle_log_event

#export(String, "On-Hit", "Before", "After") var activation

export(int) var heal_percentage
export(bool) var stagger = false
export(bool) var stun = false
export(bool) var knock_over = false
export(bool) var protection = false
export(bool) var advances_protect_counter = false
export(int) var shield = 0
export(int) var bond = 0
export(int) var rooted = 0


func apply_effects_on_target(user: Creature, target : Creature):
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var battlefield = target.get_parent().get_parent().get_parent()
	
	if heal_percentage > 0:
		var heal_value =(target.get_max_hp() * heal_percentage) / 100
		target.change_health(round(target.current_hp + heal_value))
		emit_signal("battle_log_event", "Heal", {"target": target.get_display_name()})
		if battlefield.has_field_effect("Mycel"):
			battlefield.get_partner(target.battle_slot).change_health(
						round(battlefield.get_partner(target.battle_slot).current_hp + heal_value / 2))
	elif heal_percentage < 0:
		var damage_value =(target.get_max_hp() * heal_percentage) / 100
		target.change_health(round(target.current_hp + damage_value))
		emit_signal("battle_log_event", "Recoil", {"target": target.get_display_name()})
	
	
	if protection and 100 / (target.protect_counter + 1) >= rng.randi_range(1, 100):
		print(rng.randi_range(1, 100))
		print(rng.randi_range(1, 100))
		target.is_protected = true
		if advances_protect_counter:
			target.protect_counter += 1
		emit_signal("battle_log_event", "Protect", {"target": target.get_display_name(), "success": true})
	elif protection:
		target.protect_counter = 0
		emit_signal("battle_log_event", "Protect", {"target": target.get_display_name(), "success": false})
	
	if shield > 0:
		target.shield += shield
		if advances_protect_counter:
			target.protect_counter += 1
		emit_signal("battle_log_event", "Shield", {"target": target.get_display_name(), "value": shield})
	if stagger and not target.made_turn:
		target.stagger_stacks += 1
		emit_signal("battle_log_event", "Stagger", {})
	if stun and not target.made_turn:
		target.stagger_stacks += 2
		emit_signal("battle_log_event", "Stun", {})
	if knock_over and target.get_stability() < user.get_stability():
		target.is_knocked_over = true
		emit_signal("battle_log_event", "Knocked_Over", {"target": target.get_display_name()})
	if bond > 0:
		target.bond_stacks += bond
		emit_signal("battle_log_event", "Bond", {"target": target.get_display_name(), "value": bond})
	if rooted > 0:
		target.rooted += rooted
		emit_signal("battle_log_event", "Root", {"target": target.get_display_name(), "value": rooted})
	if rooted == -1:
		target.rooted = rooted
		emit_signal("battle_log_event", "Root", {"target": target.get_display_name(), "value": rooted})
	
	return true


func connect_signals(battle_log):
	connect("battle_log_event", battle_log, "receive_event")

	
func disconnect_signals(battle_log):
	disconnect("battle_log_event", battle_log, "receive_event")
