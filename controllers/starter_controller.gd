extends "res://controller.gd"

const ROT_KP = 0.3
const POS_KP = 2.0


# Deliberately simple starting point for students: proportional control only.
func _get_control_output() -> Array:
	var pos_error = rov_transform.xform_inv(waypoint_translation)
	var rot_error_world = rotation_to(rov_transform, waypoint_transform)
	var rot_error = rov_basis.xform_inv(rot_error_world)
	return [pos_error * POS_KP, rot_error * ROT_KP]


func rotation_to(a: Transform, b: Transform) -> Vector3:
	# Axis-angle error also works for the mission's 180-degree heading change,
	# where the original sum of axis cross products produces zero torque.
	var rotation = (b.basis * a.basis.transposed()).get_rotation_quat().normalized()
	var axis = Vector3(rotation.x, rotation.y, rotation.z)
	var sine = axis.length()
	if sine < 0.000001:
		return Vector3.ZERO
	var angle = wrapf(2.0 * atan2(sine, rotation.w), -PI, PI)
	return axis * (angle / sine)
