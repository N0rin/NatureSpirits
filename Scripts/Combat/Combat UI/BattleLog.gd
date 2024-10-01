extends MarginContainer

onready var messages = $Messages
var attack_message = "%s uses %s"
var switch_message = "%s was switched out in favor of %s"
var stunned_message = "%s is stunned and can't attack"
var knocked_over_recover_message = "%s recovers from being knocked over"
var mossed_message = "The moss hinders %s action"
var frozen_message = "%s is frozen and can't move"
var switch_fail_message = "%s can't leave the battlefield"

var damage_message = "%s takes %s damage"
var failed_move_message = "But it failed!"
var miss_message = "Miss!"
var protected_message = "%s is protected!"
var shield_break_message = "The shield breaks"
var moss_protected_message = "The moss protected %s!"
var stagger_message = "(Stagger)"
var stun_message = "(Stun)"
var knockout_message = "(KO)"
var protect_message = "%s is protected against attacks"
var shield_message = "%s is shielded against attacks(%s)"

var stat_change_message = "%s got "
var status_condition_message = "  %s got %sx %s"
var heal_message = "%s got healed"
var recoil_message = "%s took recoil damage"
var symbiosis_message = "%s is in a symbiosis"
var no_stat_decrease_message = "The values of %s can't be lowered(%s)"
var bond_message = "%s got constricted(%s)"
var knock_over_message = "%s was knocked over"
var root_message = "%s is rooted(%s)"
var light_message = "%s lights appear on the side of %s"

var status_condition_add_message = "%s %s added"
var status_condition_remove_message = "%s %s removed"
var fire_damage_message = "%s takes %s damage from its burn"
var moss_damage_message = "%s takes %s damage from the moss"
var moss_symbiosis_message = "Symbiosis heals %s"

var log_iterator = 0
var stat_value_iterator = -1

func _receive_event(event, data):
	match event:
		"Attack":
			announce_attack(data["attacker"], data["action"])
		"Switch":
			announce_switch(data["switch_out"], data["switch_in"])
		"Stunned":
			announce_stunned(data["victim"])
		"Knocked_Over_Recover":
			announce_knocked_over_recover(data["victim"])
		"Mossed":
			announce_mossed(data["victim"])
		"Frozen":
			announce_frozen(data["victim"])
		"Failed_Switch":
			announce_switch_failed(data["victim"])
		"Damage":
			announce_damage(data["defender"], data["value"])
		"Miss":
			announce_miss()
		"Failed_Move":
			announce_fail()
		"Protected":
			announce_protection(data["target"])
		"Shield_Break":
			announce_shield_break()
		"Moss_Protection":
			announce_moss_protection(data["target"])
		"Stagger":
			announce_stagger()
		"Stun":
			announce_stun()
		"Knockout":
			announce_knockout()
		"Protect":
			announce_protect(data["user"], data["success"])
		"Shield":
			announce_shield(data["target"], data["value"])
		"Stat_Change":
			announce_stat_change(data["target"], data["stat"], data["value"])
		"Status_Condition":
			announce_applied_status_condition(data["target"], data["condition"], data["value"])
		"Heal":
			announce_heal(data["target"])
		"Recoil_Damage":
			announce_recoil(data["target"])
		"Symbiosis":
			announce_symbiosis(data["target"])
		"No_Stat_Decrease":
			announce_no_stat_decrease(data["target"], data["value"])
		"Bond":
			announce_bond(data["target"], data["value"])
		"Rooted":
			announce_rooted(data["target"], data["value"])
		"Knocked_Over":
			announce_knock_over(data["target"])
		"Light":
			announce_light(data["target"], data["value"])
		"Status_Condition_Change":
			announce_status_conditon_change(data["condition"], data["value"])
		"Fire_Damage":
			announce_fire_damage(data["target"], data["value"])
		"Moss_Damage":
			announce_moss_damage(data["target"], data["value"])
		"Moss_Symbiosis":
			announce_moss_symbiosis(data["target"])
		"Add_Separator":
			add_separator()
		"Reset_Stat_Value_Iterator":
			_reset_stat_value_iterator()
		"New_Line":
			newline()

func announce_attack(attacker, action):
	start_message(attack_message % [attacker, action])

func announce_switch(switch_out, switch_in):
	start_message(switch_message % [switch_out, switch_in])

func announce_stunned(victim_name):
	start_message(stunned_message % victim_name)

func announce_knocked_over_recover(victim_name):
	start_message(knocked_over_recover_message % victim_name)

func announce_mossed(victim_name):
	start_message(mossed_message % victim_name)

func announce_frozen(victim_name):
	start_message(frozen_message % victim_name)


func announce_switch_failed(victim_name):
	add_to_current_message(switch_fail_message % victim_name)

func announce_damage(defender, damage):
	add_to_current_message(damage_message % [defender, damage])

func announce_miss():
	add_to_current_message(miss_message)

func announce_fail():
	add_to_current_message(failed_move_message)
	
func announce_protection(target_name):
	add_to_current_message(protected_message % target_name)

func announce_shield_break():
	add_to_current_message(shield_break_message)

func announce_moss_protection(target_name):
	add_to_current_message(moss_protected_message % target_name)

func announce_stagger():
	add_to_current_message(stagger_message)

func announce_stun():
	add_to_current_message(stun_message)

func announce_knockout():
	add_to_current_message(knockout_message)

func announce_protect(user_name, success):
	if success:
		add_to_current_message(protect_message % user_name)
	else:
		add_to_current_message(failed_move_message)

func announce_shield(target_name, value):
	add_to_current_message(shield_message % [target_name, value])


func announce_stat_change(target_name, stat_name, value):
	if value == 0:
		return
	
	if stat_value_iterator != log_iterator:
		add_to_current_message(stat_change_message % target_name)
		stat_value_iterator = log_iterator
	
	var iterator = 0
	if value > 0:
		while iterator < value:
			add_to_current_message("+")
			iterator +=1
	if value < 0:
		while iterator < -value:
			add_to_current_message("-")
			iterator +=1
	add_to_current_message("%s " % stat_name)

func announce_applied_status_condition(target_name, condition_name, value):
	if value == 0:
		return
	add_to_current_message(status_condition_message % [target_name, value, condition_name])

func announce_heal(target_name):
	add_to_current_message(heal_message % target_name)
	messages.newline()

func announce_recoil(target_name):
	add_to_current_message(recoil_message % target_name)

func announce_symbiosis(target_name):
	add_to_current_message(symbiosis_message % target_name)
	messages.newline()

func announce_no_stat_decrease(target_name, value):
	add_to_current_message(no_stat_decrease_message % [target_name, value])
	messages.newline()

func announce_bond(target_name, value):
	add_to_current_message(bond_message % [target_name, value])
	messages.newline()

func announce_rooted(target_name, value):
	add_to_current_message(root_message % [target_name, value])
	messages.newline()

func announce_knock_over(target_name):
	add_to_current_message(knock_over_message % target_name)
	messages.newline()

func announce_light(target_name, value):
	add_to_current_message(light_message % [value, target_name])
	messages.newline()


func announce_status_conditon_change(condition_name, value_change):
	if value_change < 0:
		add_to_current_message(status_condition_remove_message % [-value_change, condition_name])
		messages.newline()
	elif value_change > 0:
		add_to_current_message(status_condition_add_message % [value_change, condition_name])
		messages.newline()

func announce_fire_damage(target_name, value):
	messages.newline()
	add_to_current_message(fire_damage_message % [target_name, value])

func announce_moss_damage(target_name, value):
	messages.newline()
	add_to_current_message(moss_damage_message % [target_name, value])

func announce_moss_symbiosis(target_name):
	messages.newline()
	add_to_current_message(moss_symbiosis_message % target_name)

func start_message(string):
	messages.push_align(2)
	messages.append_bbcode("--------------------------")
	messages.newline()
	messages.append_bbcode(string+ "  ")
	messages.newline()
	log_iterator += 1

func newline():
	messages.newline()

func add_separator():
	messages.newline()
	messages.append_bbcode("--------------------------")

func add_to_current_message(string):
	messages.append_bbcode(string)

func reset():
	messages.hide()
	log_iterator = 0

func _reset_stat_value_iterator():
	stat_value_iterator = -1
