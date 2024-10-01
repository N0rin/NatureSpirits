extends Button
class_name SpellSelectButton

signal selected_button

var is_activated = false
var spell
var position

func set_spell(new_spell, new_position):
	if new_spell != null:
		set_text(new_spell.name)
	spell = new_spell
	position = new_position

func toggle_activation():
	if is_activated:
		set_activation(false)
	else:
		set_activation(true)

func set_activation(activation_status):
	if activation_status:
		is_activated = true
		$InactiveButton.hide()
	else:
		is_activated = false
		$InactiveButton.show()

func set_text(new_text):
	text = new_text
	$InactiveButton.text = new_text

func toggle_lock():
	if disabled:
		disabled = false
		$InactiveButton.disabled = false
	else:
		disabled = true
		$InactiveButton.disabled = true

func _on_active_button_pressed():
	toggle_activation()
	emit_signal("selected_button", self, true)


func _on_inactive_button_pressed():
	toggle_activation()
	emit_signal("selected_button", self, false)
