extends KinematicBody2D
class_name Encounter

signal encounter

func send_encounter():
	if $CollisionBox.disabled == false:
		emit_signal("encounter", $EncounterData)
		hide()
	
	$CollisionBox.disabled = true

