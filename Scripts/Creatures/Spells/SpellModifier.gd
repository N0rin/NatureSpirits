extends Resource
class_name AA_SpellModifier

signal modifier_success

export(String, "On-Hit", "Before", "After") var activation = "On-Hit"
export(Resource) var condition


func apply_modifier(user, target):
	if condition is Resource:
		if not condition.check_condition(user, target):
			emit_signal("modifier_success", false)
			return
	
	emit_signal("modifier_success", true)
	return apply_effects_on_target(user, target)


func apply_effects_on_target(user, target):
	return true

func connect_signals(battle_log):
	pass

func disconnect_signals(battle_log):
	pass

func get_activation():
	print("Activation:"+ activation)
	return activation
