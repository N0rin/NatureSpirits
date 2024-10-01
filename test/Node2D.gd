extends Node2D
signal test

onready var warten = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var fuk = fuck_around()
	while warten:
		yield(get_tree(), "idle_frame")
	print("4")


func yell():
	emit_signal("test", "5")

func fuck_around():
	warten = true
	print("1")
	print(yield(self, "2"))
	print("3")
	warten = false


func _on_Button_pressed():
	yell()
