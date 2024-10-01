extends Control

func _ready():
	pass

func fill_slot(creature):
	$Picture.texture = creature.get_appearance()
	$Picture.show()
	$MarginContainer/Lifebar/Gauge.max_value = creature.get_max_hp()
	$MarginContainer/Lifebar/Gauge.value = creature.get_current_hp()
	$MarginContainer/Lifebar/NinePatchRect/Counter.text = str(creature.get_current_hp())
	
	$ModCounter/EffectCounter/Burn/Counter.text = str(creature.burn_stacks)
	$ModCounter/EffectCounter/Frost/Counter.text = str(creature.frost_stacks)
	$ModCounter/EffectCounter/Wet/Counter.text = str(creature.wet_stacks)
	$ModCounter/EffectCounter/Moss/Counter.text = str(creature.moss_stacks)
	$ModCounter/EffectCounter/Charge/Counter.text = str(creature.charge_stacks)
	
	$MarginContainer/Lifebar.show()
	$ModCounter.show()
	reload_stat_counter(creature)
	reload_effect_counter(creature)

func change_health(health):
	$MarginContainer/Lifebar/Gauge.value = health
	$MarginContainer/Lifebar/NinePatchRect/Counter.text = str(health)

func reload_effect_counter(creature):
	set_counter($ModCounter/EffectCounter/Burn/Counter, creature.burn_stacks, str(creature.burn_stacks))
	set_counter($ModCounter/EffectCounter/Frost/Counter, creature.frost_stacks, str(creature.frost_stacks))
	set_counter($ModCounter/EffectCounter/Wet/Counter, creature.wet_stacks, str(creature.wet_stacks))
	set_counter($ModCounter/EffectCounter/Moss/Counter, creature.moss_stacks, str(creature.moss_stacks))
	set_counter($ModCounter/EffectCounter/Charge/Counter, creature.charge_stacks, str(creature.charge_stacks))


func set_counter(counter, value, string):
	counter.text = string
	if value == 0:
		counter.get_parent().hide()
	else:
		counter.get_parent().show()

func reload_stat_counter(creature):
	set_counter($ModCounter/StatCounter/Stability/Counter, creature.stability_stacks,"S%+d" % creature.stability_stacks)
	set_counter($ModCounter/StatCounter/Balance/Counter, creature.balance_stacks, "B%+d" % creature.balance_stacks)
	set_counter($ModCounter/StatCounter/Leaf/Counter, creature.leaf_stacks,"L%+d" % creature.leaf_stacks)
	set_counter($ModCounter/StatCounter/Aroma/Counter, creature.aroma_stacks, "A%+d" % creature.aroma_stacks)

func clear_slot():
	$MarginContainer/Lifebar.hide()
	$ModCounter.hide()
	$Picture.hide()
