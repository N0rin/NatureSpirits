extends Control

signal slot_chosen
enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}


func show_targets(targets, is_targeting_active):
	hide_targets()
	if is_targeting_active:
		$EnemyLeft/MultiText.hide()
		$EnemyRight/MultiText.hide() 
		$AllyLeft/MultiText.hide()
		$AllyRight/MultiText.hide()
	else:
		$EnemyLeft/MultiText.show()
		$EnemyRight/MultiText.show() 
		$AllyLeft/MultiText.show()
		$AllyRight/MultiText.show()
	
	for target in targets:
		if target == LEFT_ENEMY:
			$EnemyLeft.show()
		if target == RIGHT_ENEMY:
			$EnemyRight.show() 
		if target == LEFT_ALLY:
			$AllyLeft.show()
		if target == RIGHT_ALLY:
			$AllyRight.show()

func hide_targets():
	$EnemyLeft.hide()
	$EnemyRight.hide() 
	$AllyLeft.hide()
	$AllyRight.hide()

func show_damage_preview(index, damage, accuracy, max_life, is_multitarget, is_status):
	var slot
	if index == LEFT_ALLY:
		slot = $AllyLeft
	if index == RIGHT_ALLY:
		slot = $AllyRight
	if index == LEFT_ENEMY:
		slot = $EnemyLeft
	if index == RIGHT_ENEMY:
		slot = $EnemyRight
	
	if is_status:
		slot.get_node("DamagePreview").text = "X"
		slot.get_node("KoFactor").text = ""
	else:
		slot.get_node("DamagePreview").text = str(damage)
		if damage != 0:
			slot.get_node("KoFactor").text = "%.2f" % (max_life / damage)
		else:
			slot.get_node("KoFactor").text = ""
	slot.get_node("AccPreview").text = "%s%%" % str(accuracy)
	
	if is_multitarget:
		slot.get_node("MultiText").show()
	else:
		slot.get_node("MultiText").hide()
	
	slot.show()


func _on_Enemy_Left_pressed():
	emit_signal("slot_chosen", [LEFT_ENEMY])

func _on_Enemy_Right_pressed():
	emit_signal("slot_chosen", [RIGHT_ENEMY])

func _on_Ally_Left_pressed():
	emit_signal("slot_chosen", [LEFT_ALLY])

func _on_Ally_Right_pressed():
	emit_signal("slot_chosen", [RIGHT_ALLY])
