extends "res://controller.gd"

# Body-axis requests; preserve the project's established input directions.
func _get_control_output() -> Array:
	var force = Vector3(
		Input.get_axis("rov_translate_right", "rov_translate_left"),
		Input.get_axis("rov_translate_down", "rov_translate_up") * 2.0,
		Input.get_axis("rov_translate_backward", "rov_translate_forward") * 3.0)
	var torque = Vector3(
		Input.get_axis("rov_tilt_up", "rov_tilt_down") * 0.25,
		Input.get_axis("rov_yaw_right", "rov_yaw_left") * 0.25,
		Input.get_axis("rov_roll_left", "rov_roll_right") * 0.25)
	return [force, torque]
