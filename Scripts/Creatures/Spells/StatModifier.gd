extends AA_SpellModifier
class_name AAA_StatModifier

signal battle_log_event

#export(String, "On-Hit", "Before", "After") var activation

export(int) var random_stat = 0

export(int) var stability_change = 0
export(int) var balance_change = 0
export(int) var leaf_change = 0
export(int) var aroma_change = 0


func apply_effects_on_target(user: Creature, target : Creature):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var extra_stability = stability_change
	var extra_balance = balance_change
	var extra_leaf = leaf_change
	var extra_aroma = aroma_change
	
	#Zufällige Vergabe von Stats
	if random_stat != 0:
		var select_pool = []
		var iterator = 0
		
		extra_stability = 0
		extra_balance = 0
		extra_leaf = 0
		extra_aroma = 0
		
		while iterator < stability_change:
			select_pool.append("Stability")
			iterator += 1
		iterator = 0
		while iterator < balance_change:
			select_pool.append("Balance")
			iterator += 1
		iterator = 0
		while iterator < leaf_change:
			select_pool.append("Leaf")
			iterator += 1
		iterator = 0
		while iterator < aroma_change:
			select_pool.append("Aroma")
			iterator += 1
		iterator = 0
		
		while iterator < abs(random_stat):
			var selector = rng.randi_range(1, select_pool.size()) -1

			match(select_pool[selector]):
				"Stability":
					if random_stat > 0:
						extra_stability += 1
					else:
						extra_stability -= 1
				"Balance":
					if random_stat > 0:
						extra_balance += 1
					else:
						extra_balance -= 1
				"Leaf":
					if random_stat > 0:
						extra_leaf += 1
					else:
						extra_leaf -= 1
				"Aroma":
					if random_stat > 0:
						extra_aroma += 1
					else:
						extra_aroma -= 1
			iterator += 1
	
	
	#Anwendung der Stat-Änderungen

	if extra_stability < 0 and target.no_stat_decrease > 0:
		pass
	else:
		target.stability_stacks += extra_stability
		emit_signal("battle_log_event", "Stat_Change", {"target": target.get_display_name(), "stat": "Stability", "value": extra_stability})
	
	if extra_balance < 0 and target.no_stat_decrease > 0:
		pass
	else:
		target.balance_stacks += extra_balance
		emit_signal("battle_log_event", "Stat_Change", {"target": target.get_display_name(), "stat": "Balance", "value" :extra_balance})
	
	if extra_leaf < 0 and target.no_stat_decrease > 0:
		pass
	else:
		target.leaf_stacks += extra_leaf
		emit_signal("battle_log_event", "Stat_Change", {"target": target.get_display_name(), "stat": "Leaf", "value": extra_leaf})
	
	if extra_aroma < 0 and target.no_stat_decrease > 0:
		pass
	else:
		target.aroma_stacks += extra_aroma
		emit_signal("battle_log_event", "Stat_Change", {"target": target.get_display_name(), "stat": "Aroma", "value": extra_aroma})
	
	return true

func connect_signals(battle_log):
	connect("battle_log_event", battle_log, "_receive_event")

	
func disconnect_signals(battle_log):
	disconnect("battle_log_event", battle_log, "_receive_event")

#func get_activation():
#	print("Activation:"+ activation)
#	return activation
