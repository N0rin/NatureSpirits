extends Resource
class_name AAA_Factor

export(String, "Additive", "Multiplicative") var mode

export(Resource) var condition
export(int) var flat_value = 0

#base_value: Base Damage of the spell
#condition_value: Value depends on the condition
#flat_value: Value is set in the Factor-Resource

func get_factor(attacker, defender, base_value):
	var condition_value = 0
	if condition is Resource:
		 condition_value = condition.return_value(attacker, defender)
	
	match(mode):
		"Additive":
			return condition_value + base_value + flat_value
		"Multiplicative":
			return base_value * (condition_value + flat_value)
		_:
			return condition_value
