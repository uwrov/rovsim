extends "res://controller.gd"

# This controller is a test controller based on alni's basic controller

const ROT_KP = 0.3
const ROT_KI = 0.0
const ROT_KD = -0.1

const POS_KP = 2.0

# integral term of rotation PID controller
var rot_i = Vector3.ZERO

var rot_error_previous := Vector3.ZERO
var rov_transform_previous := Transform.IDENTITY


# a method that's called whenever the waypoint is updated
# you may want to reset/recalculate certain things in your controller
func _waypoint_updated() -> void:
	pass


# a method you write that will run the ROV to the current waypoint
# returns an array of [force: Vector3, torque: Vector3]
func _get_control_output() -> Array:
	var force := Vector3.ZERO
	var torque := Vector3.ZERO
	
	# By taking the cross product of each axis's displacement from its target
	# orientation, we get the torque vector that would get each axis to its
	# target orientation as efficiently as possible. We add these to get an
	# error rotation, in the form of an axis with a magnitude.
	var rot_error_world = (
		+ rov_basis.x.cross(waypoint_basis.x)
		+ rov_basis.y.cross(waypoint_basis.y)
		+ rov_basis.z.cross(waypoint_basis.z)
	)
	
	# we calculate error & velocity in world space, but must transform to local
	# space to calculate the torque the ROV needs to exert locally
	var lrot = Transform(rov_basis, Vector3.ZERO)
	
	# transform to local coordinates
	var rot_error = lrot.xform_inv(rot_error_world)
	
	var rot_p = rot_error
	rot_i += rot_error * delta
	var rot_d = lrot.xform_inv((rotation_to(rov_transform_previous, rov_transform)) / delta)
	
	rov_transform_previous = rov_transform
	
	torque = (
		+ ROT_KP * rot_p
		+ ROT_KI * rot_i
		+ ROT_KD * rot_d
	)
	
	
	var pos_error = rov_transform.xform_inv(waypoint_translation)
	
	force = pos_error * POS_KP
	
	return [force, torque]


func rotation_to(a: Transform, b: Transform) -> Vector3:
	return (
		+ a.basis.x.cross(b.basis.x)
		+ a.basis.y.cross(b.basis.y)
		+ a.basis.z.cross(b.basis.z)
	)

## randomizes the setpoint for the ROV's orientation (the arrow onscreen)
#func _on_RandomizeTargetButton_pressed():
#	$Target.rotation_degrees = Vector3(
#		rand_range(-180, 180),
#		rand_range(-180, 180),
#		rand_range(-180, 180)
#	)
