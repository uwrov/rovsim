#### DO NOT MODIFY THIS FILE! ####
# instead, create a new script:
#   - inside the '/controllers/' folder
#   - inherits "res://controller.gd"
#   - Template -> Controller Template
#   - path -> res://controllers/your_controller_name.gd

class_name Controller
extends Reference
# A base for controllers that command the ROV's force and torque.
# Implement _get_control_output() to determine control outputs.

# time since the controller was last called
var delta: float

# information about the ROV's current transformation
var rov_transform: Transform setget set_rov_transform
var rov_translation: Vector3
var rov_basis: Basis
var rov_rotation_quat: Quat
var rov_rotation_radians: Vector3

# a method you write that commands the ROV
# returns an array of [force: Vector3, torque: Vector3]
func _get_control_output() -> Array:
	var force := Vector3.ZERO
	var torque := Vector3.ZERO
	
	### YOUR CODE GOES HERE ###
	### modify force & torque to create your control algoithm ###
	
	return [force, torque]


func tick(_rov_transform: Transform, _delta: float) -> void:
	delta = _delta
	set_rov_transform(_rov_transform)


# updates information helper variables whenever ROV transform is updated
func set_rov_transform(transform: Transform) -> void:
	rov_transform = transform
	rov_translation = rov_transform.origin 
	rov_basis = rov_transform.basis
	rov_rotation_quat = rov_basis.get_rotation_quat()
	rov_rotation_radians = rov_rotation_quat.get_euler()

