extends "res://controller.gd"

### YOU MAY ADD VARIABLES HERE ###
### you may add whatever other variables you think would be helpful ###

# a method you write that commands the ROV
# returns an array of [force: Vector3, torque: Vector3]
func _get_control_output() -> Array:
	var force := Vector3.ZERO
	var torque := Vector3.ZERO
	
	### YOUR CODE GOES HERE ###
	### modify force & torque to create your control algorithm ###
	
	return [force, torque]
