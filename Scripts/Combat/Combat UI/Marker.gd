extends TextureRect
enum {LEFT_ALLY=-1, RIGHT_ALLY=1, LEFT_ENEMY=-2, RIGHT_ENEMY=2}
var slot = 0


func set_slot(new_slot):
	slot = new_slot
	if slot == LEFT_ALLY:
		self.rect_position = Vector2(230,540)
	if slot == RIGHT_ALLY:
		self.rect_position = Vector2(712,540)
	if slot == LEFT_ENEMY:
		self.rect_position = Vector2(1190,6)
	if slot == RIGHT_ENEMY:
		self.rect_position = Vector2(1670,6)
