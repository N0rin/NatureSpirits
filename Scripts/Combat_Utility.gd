extends Node

func convert_targets(user, string, battlefield):
	var selection = []
	var is_user_enemy = false
	if user == GameEnums.LEFT_ENEMY or user == GameEnums.RIGHT_ENEMY:
		is_user_enemy = true

	match string:
		"Others":
			selection = [GameEnums.LEFT_ALLY, GameEnums.RIGHT_ALLY, GameEnums.LEFT_ENEMY, GameEnums.RIGHT_ENEMY]
			selection.erase(user)
		"Enemies": 
			if is_user_enemy:
				selection = [GameEnums.LEFT_ALLY, GameEnums.RIGHT_ALLY]
			else:
				selection = [GameEnums.LEFT_ENEMY, GameEnums.RIGHT_ENEMY]
		"All":
			selection = [GameEnums.LEFT_ALLY, GameEnums.RIGHT_ALLY, GameEnums.LEFT_ENEMY, GameEnums.RIGHT_ENEMY]
		"Allies":
			if is_user_enemy:
				selection = [GameEnums.LEFT_ENEMY, GameEnums.RIGHT_ENEMY]
			else:
				selection = [GameEnums.LEFT_ALLY, GameEnums.RIGHT_ALLY]
		"Self":
			selection = [user]
		"Partner":
			selection = [user*-1]
		"None":
			pass

	if battlefield.get_fighter(GameEnums.LEFT_ALLY) == null:
		selection.erase(GameEnums.LEFT_ALLY)
	if battlefield.get_fighter(GameEnums.RIGHT_ALLY) == null:
		selection.erase(GameEnums.RIGHT_ALLY)
	if battlefield.get_fighter(GameEnums.LEFT_ENEMY) == null:
		selection.erase(GameEnums.LEFT_ENEMY)
	if battlefield.get_fighter(GameEnums.RIGHT_ENEMY) == null:
		selection.erase(GameEnums.RIGHT_ENEMY)

	return selection
