extends RigidBody

export var volume = 0.02
export var water_density = 1000.0
export var gravity = 9.81
export var drag = 1.5

func _physics_process(delta):
	# Buoyancy force
	var buoyant_force = water_density * volume * gravity
	add_force(Vector3.UP * buoyant_force, Vector3.ZERO)

	# Simple linear water drag
	add_force(-drag * linear_velocity, Vector3.ZERO)
