extends Control


func show_fighters(left_ally, right_ally, left_enemy, right_enemy, slot):
	var selected_creature
	for creature in [left_ally, right_ally, left_enemy, right_enemy]:
		if creature == null:
			continue
		if creature.battle_slot == slot:
			selected_creature = creature
	
	if left_ally is Creature:
		$LeftAllyInfo.set_info(left_ally, selected_creature)
	if right_ally is Creature:
		$RightAllyInfo.set_info(right_ally, selected_creature)
	if left_enemy is Creature:
		$LeftEnemyInfo.set_info(left_enemy, selected_creature)
	if right_enemy is Creature:
		$RightEnemyInfo.set_info(right_enemy, selected_creature)

func set_aura(type, value):
	$TerrainInfo/Margin/VBox/Aura.clear()
	if value > 0 and type != "None":
		$TerrainInfo/Margin/VBox/Aura.show()
		$TerrainInfo/Margin/VBox/Aura.append_bbcode("%s (%s rounds)" % [type, value])

func set_terrain(type, value):
	$TerrainInfo/Margin/VBox/Terrain.clear()
	if value > 0 and type != "None":
		$TerrainInfo/Margin/VBox/Terrain.show()
		$TerrainInfo/Margin/VBox/Terrain.append_bbcode("%s (%s rounds)" % [type, value])

func set_weather(type, value):
	$TerrainInfo/Margin/VBox/Weather.clear()
	if value > 0 and type != "None":
		$TerrainInfo/Margin/VBox/Weather.show()
		$TerrainInfo/Margin/VBox/Weather.append_bbcode("%s (%s rounds)" % [type, value])

func set_ally_light(value):
	$TerrainInfo/Margin/VBox/AllyLight.clear()
	if value > 0:
		$TerrainInfo/Margin/VBox/AllyLight.show()
		$TerrainInfo/Margin/VBox/AllyLight.append_bbcode("%s light on your side" % value)

func set_enemy_light(value):
	$TerrainInfo/Margin/VBox/EnemyLight.clear()
	if value > 0:
		$TerrainInfo/Margin/VBox/EnemyLight.show()
		$TerrainInfo/Margin/VBox/EnemyLight.append_bbcode("%s light on enemy side" % value)

func reset_terrain_info():
	$TerrainInfo/Margin/VBox/Aura.hide()
	$TerrainInfo/Margin/VBox/Terrain.hide()
	$TerrainInfo/Margin/VBox/Weather.hide()
	$TerrainInfo/Margin/VBox/AllyLight.hide()
	$TerrainInfo/Margin/VBox/EnemyLight.hide()
