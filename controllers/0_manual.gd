extends "res://controller.gd"

### YOU MAY ADD VARIABLES HERE ###
### you may add whatever other variables you think would be helpful ###

# a method that's called whenever the waypoint is updated
# you may want to reset/recalculate certain things in your controller
func _waypoint_updated() -> void:
	pass


# a method you write that will run the ROV to the current waypoint
# returns an array of [force: Vector3, torque: Vector3]
func _get_control_output() -> Array:
	var force := Vector3.ZERO
	var torque := Vector3.ZERO
	
	var fx_input = Input.get_axis("rov_translate_right", "rov_translate_left")
	var fy_input = Input.get_axis("rov_translate_backward", "rov_translate_forward") * 3.0
	var fz_input = Input.get_axis("rov_translate_down", "rov_translate_up") * 2.0
	
	var tx_input = Input.get_axis("rov_yaw_right", "rov_yaw_left") * 0.25
	var ty_input = Input.get_axis("rov_tilt_up", "rov_tilt_down") * 0.25
	var tz_input = Input.get_axis("rov_roll_left", "rov_roll_right") * 0.25
	
#	if latency > 0.0:
#		yield(get_tree().create_timer(latency), "timeout")
	
	force.x = fx_input
	force.z = fy_input
	force.y = fz_input
	
	torque.y = tx_input
	torque.x = ty_input
	torque.z = tz_input
	
	return [force, torque]
