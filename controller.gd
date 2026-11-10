class_name Controller
extends Reference
# Extend this script in controllers/ and override _get_control_output().
# See docs/CONTROLLERS.md for coordinate frames, command scaling, and limits.

# Seconds in the current physics tick, updated before _get_control_output().
var delta: float

# World-space vehicle pose and derived helpers.
var rov_transform: Transform setget set_rov_transform
var rov_translation: Vector3
var rov_basis: Basis
var rov_rotation_quat: Quat
var rov_rotation_radians: Vector3

# Return [translation_request: Vector3, torque_request: Vector3] in body axes.
# The vehicle mixes and limits these requests before applying thruster forces.
func _get_control_output() -> Array:
	return [Vector3.ZERO, Vector3.ZERO]


func tick(_rov_transform: Transform, _delta: float) -> void:
	delta = _delta
	set_rov_transform(_rov_transform)


# Update the pose and all derived helpers together.
func set_rov_transform(transform: Transform) -> void:
	rov_transform = transform
	rov_translation = rov_transform.origin
	rov_basis = rov_transform.basis
	rov_rotation_quat = rov_basis.get_rotation_quat()
	rov_rotation_radians = rov_rotation_quat.get_euler()

