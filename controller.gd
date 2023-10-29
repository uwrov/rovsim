#### DO NOT MODIFY THIS FILE! ####
# instead, create a new script:
#   - inside the '/controllers/' folder
#   - inherits "res://controller.gd"
#   - Template -> Controller Template
#   - path -> res://controllers/your_controller_name.gd

class_name Controller
extends Reference
# A base for a controller that drives the ROV to a desired waypoint.
# You should implement _get_control_input() to determine control outputs.
# You may optionally implement _waypoint_updated() to do something when the
# current target waypoint changes.

# time since the controller was last called
var delta: float

# information about the ROV's current transformation
var rov_transform: Transform setget set_rov_transform
var rov_translation: Vector3
var rov_basis: Basis
var rov_rotation_quat: Quat
var rov_rotation_radians: Vector3

# information about the current waypoint's transformation
var waypoint_transform: Transform setget set_waypoint_transform
var waypoint_translation: Vector3
var waypoint_basis: Basis
var waypoint_rotation_quat: Quat
var waypoint_rotation_radians: Vector3


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


func tick(_rov_transform: Transform, _waypoint_transform: Transform, _delta: float) -> void:
	delta = _delta
	set_rov_transform(_rov_transform)
	set_waypoint_transform(_waypoint_transform)


# updates information helper variables whenever ROV transform is updated
func set_rov_transform(transform: Transform) -> void:
	rov_transform = transform
	rov_translation = rov_transform.origin 
	rov_basis = rov_transform.basis
	rov_rotation_quat = rov_basis.get_rotation_quat()
	rov_rotation_radians = rov_rotation_quat.get_euler()


# updates information helper variables whenever Waypoint transform is updated
func set_waypoint_transform(transform: Transform) -> void:
	waypoint_transform = transform
	waypoint_translation = waypoint_transform.origin 
	waypoint_basis = waypoint_transform.basis
	waypoint_rotation_quat = waypoint_basis.get_rotation_quat()
	waypoint_rotation_radians = waypoint_rotation_quat.get_euler()
	_waypoint_updated()

