# Time: 1:05.19
# Concept:
# If the total distance is greater than some constant, enter "point" mode
# Point towards goal to maximize speed
# When within some constant distance of the goal, return to standard "rotate to goal position" mode 

extends "res://controller.gd"

const ROT_KP_POINT = 0.5
const ROT_KP_FINE = 0.5
const ROT_KI = 0.1
const ROT_KD = -0.1

const POS_KP_POINT = 3.0
const POS_KP_FINE = 5.0
const POS_KI = 0.0
const POS_KD_POINT = 0.0
const POS_KD_FINE = 0.0

const POINT_DISTANCE = 0.5
const ROLL_DISTANCE = 0.5

# integral term of PID controllers
var rot_i = Vector3.ZERO
var pos_i = Vector3.ZERO

var rot_error_previous := Vector3.ZERO
var rov_transform_previous := Transform.IDENTITY

var fine_position_flag = false;

# a method that's called whenever the waypoint is updated
# you may want to reset/recalculate certain things in your controller
func _waypoint_updated() -> void:
	rot_i = Vector3.ZERO
	pos_i = Vector3.ZERO


# a method you write that will run the ROV to the current waypoint
# returns an array of [force: Vector3, torque: Vector3]
func _get_control_output() -> Array:
	var force := Vector3.ZERO
	var torque := Vector3.ZERO
	
	# By taking the cross product of each axis's displacement from its target
	# orientation, we get the torque vector that would get each axis to its
	# target orientation as efficiently as possible. We add these to get an
	# error rotation, in the form of an axis with a magnitude.
	
	# If within some distance, point toward the target instead of mimicking its rotation
	var rot_error_world;
	
	# (UNIMPLEMENTED) If the target is super far away in either x or z by some certain amount, point directly to it. Otherwise, just do x and z.
	if (!(abs(rov_transform.origin.x - waypoint_transform.origin.x) > ROLL_DISTANCE || abs(rov_transform.origin.z - waypoint_transform.origin.z) > ROLL_DISTANCE)):
		waypoint_transform.origin.y = rov_transform.origin.y
		
	if (rov_transform.origin.distance_to(waypoint_transform.origin) > POINT_DISTANCE):	
		fine_position_flag = true;
		# var target_transform = Transform(waypoint_rotation_quat, Vector3(waypoint_transform.origin.x, rov_transform.origin.y, waypoint_transform.origin.z))
		var target_basis = waypoint_transform.looking_at(rov_transform.origin, Vector3(0, 1, 0))
		
		rot_error_world = (
			+ rov_basis.x.cross(target_basis.basis.x)
			+ rov_basis.y.cross(target_basis.basis.y)
			+ rov_basis.z.cross(target_basis.basis.z)
		)
	else:
		if (fine_position_flag):
			fine_position_flag = false
			rot_i = Vector3.ZERO
			pos_i = Vector3.ZERO
		rot_error_world = (
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
	var rot_d = lrot.xform_inv(rotation_to(rov_transform_previous, rov_transform) / delta)
	
	if (rov_transform.origin.distance_to(waypoint_transform.origin) > POINT_DISTANCE):	
		torque = (
			+ ROT_KP_POINT * rot_p
			+ ROT_KD * rot_d
		)
	else:
		torque = (
			+ ROT_KP_FINE * rot_p
			+ ROT_KI * rot_i
			+ ROT_KD * rot_d
		)	
	
	var pos_error = rov_transform.xform_inv(waypoint_translation)
	
	var pos_p = pos_error
	pos_i += pos_error * delta
	var pos_d = (rov_transform.origin - rov_transform_previous.origin) / delta
	if (rov_transform.origin.distance_to(waypoint_transform.origin) > POINT_DISTANCE):	
		force = (
			+ POS_KP_POINT * pos_p
			+ POS_KI * pos_i
			+ POS_KD_POINT * pos_d
		) 
	else:
		force = (
			+ POS_KP_FINE * pos_p
			+ POS_KI * pos_i
			+ POS_KD_FINE * pos_d
		) 
	rov_transform_previous = rov_transform
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
