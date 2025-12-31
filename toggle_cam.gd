extends ViewportContainer

var is_toggling = false

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.scancode == KEY_ESCAPE:
		if not is_toggling:
			toggle_visibility()

func toggle_visibility():
	is_toggling = true
	visible = not visible
	yield(get_tree().create_timer(0.2), "timeout")
	is_toggling = false
