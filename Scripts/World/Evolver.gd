extends KinematicBody2D
class_name Evolver

export(int) var uses = 1

func get_exit():
	return $PlayerExit.global_position
