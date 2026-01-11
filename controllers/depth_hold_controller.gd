extends "res://controller.gd"

class_name DepthHoldController

# target depth (meters, negative is down)
@export var target_depth := -3.0

# PID gains
@export var kp := 40.0
@export var kd := 10.0
@export var ki := 0.0

var integral := 0.0
var last_depth := 0.0

func _get_control_output() -> Array:
	var force := Vector3.ZERO
	var torque := Vector3.ZERO

	# current depth from ROV position
	var current_depth = rov_translation.y

	# vertical velocity
	var vertical_velocity = (current_depth - last_depth) / delta

	# PID
	var error = target_depth - current_depth
	integral += error * delta

	var vertical_force = (
		kp * error
		- kd * vertical_velocity
		+ ki * integral
	)

	# Apply force ONLY in vertical direction
	force = Vector3.UP * vertical_force

	last_depth = current_depth

	return [force, torque]
