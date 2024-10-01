extends AA_SpellModifier
class_name AAA_StatusModifier

signal battle_log_event


export(String, "Add", "Subtract", "Consume" , "Heal", "Multiply") var mode = "Add"
export(int) var burn = 0
export(int) var frost = 0
export(int) var wet = 0
export(int) var moss = 0
export(int) var charge = 0


func apply_effects_on_target(user: Creature, target : Creature):
	
	match mode:
		
		"Subtract":
			if burn > 0:
				target.burn_stacks = clamp(target.burn_stacks - burn, 0, 100)
			if frost > 0:
				target.frost_stacks = clamp(target.frost_stacks - frost, 0, 100)
			if wet > 0:
				target.wet_stacks = clamp(target.wet_stacks - wet , 0, 100)
			if moss > 0:
				target.moss_stacks = clamp(target.moss_stacks - moss , 0, 100)
			if charge > 0:
				target.charge_stacks = clamp(target.charge_stacks - charge, 0, 100)
			return true
		
		"Consume":
			if burn <= target.burn_stacks:
				target.burn_stacks -= burn
			else:
				return false
			if frost <= target.frost_stacks:
				target.frost_stacks -= frost
			else:
				return false
			if wet <= target.wet_stacks:
				target.wet_stacks -= wet
			else:
				return false
			if moss <= target.moss_stacks:
				target.moss_stacks -= moss
			else:
				return false
			if charge <= target.charge_stacks:
				target.charge_stacks -= charge
			else:
				return false
			return true
	
		"Heal":
			if burn > 0:
				target.burn_stacks = 0
			if frost > 0:
				target.frost_stacks = 0
			if wet > 0:
				target.wet_stacks = 0
			if moss > 0:
				target.moss_stacks = 0
			if charge > 0:
				target.charge_stacks = 0
			return true
	
		"Multiply":
			if burn > 0:
				target.burn_stacks = target.burn_stacks * burn
			if frost > 0:
				target.frost_stacks = target.frost_stacks * frost
			if wet > 0:
				target.wet_stacks = target.wet_stacks * wet
			if moss > 0:
				target.moss_stacks = target.moss_stacks * moss
			if charge > 0:
				target.charge_stacks = target.charge_stacks * charge
			return true
	
		_:
			target.apply_burn(burn)
			emit_signal("battle_log_event", "Status_Condition", {"target": target.get_display_name(), "condition": "Burn", "value": burn})
			target.apply_frost(frost)
			emit_signal("battle_log_event", "Status_Condition", {"target": target.get_display_name(), "condition": "Frost", "value": frost})
			target.apply_wet(wet)
			emit_signal("battle_log_event", "Status_Condition", {"target": target.get_display_name(), "condition": "Wet", "value": wet})
			target.apply_moss(moss)
			emit_signal("battle_log_event", "Status_Condition", {"target": target.get_display_name(), "condition": "Moss", "value": moss})
			target.apply_charge(charge)
			emit_signal("battle_log_event", "Status_Condition", {"target": target.get_display_name(), "condition": "Charge", "value": charge})
			return true
	
	


func connect_signals(battle_log):
	connect("battle_log_event", battle_log, "_receive_event")

	
func disconnect_signals(battle_log):
	disconnect("battle_log_event", battle_log, "_receive_event")

#func get_activation():
#	print("Activation:"+ activation)
#	return activation
