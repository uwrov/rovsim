extends "res://controller.gd"

# a method that's called whenever the waypoint is updated
# you may want to reset/recalculate certain things in your controller
func _waypoint_updated() -> void:
	pass


# a method you write that will run the ROV to the current waypoint
# returns an array of [force: Vector3, torque: Vector3]
func _get_control_output() -> Array:
	var force := Vector3.ZERO
	var torque := Vector3.ZERO
	
	### YOUR CODE GOES HERE ###
	### modify force & torque to create your control algoithm ###
	
	return [force, torque]
