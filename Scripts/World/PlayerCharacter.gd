extends KinematicBody2D

signal collision

var velocity : Vector2 = Vector2()
const speed_factor = 200

func read_input():
	if Input.is_action_pressed("up"):
		velocity.y += -1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x += -1
	
	velocity = velocity.normalized()
	move_and_slide(velocity * speed_factor)
	velocity = Vector2(0,0)

func _physics_process(delta):
	read_input()
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		emit_signal("collision", collision.collider)
