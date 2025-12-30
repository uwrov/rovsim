extends RigidBody3D

@export var volume := 0.02
@export var water_density := 1000.0
@export var gravity := 9.81
@export var drag := 1.5

func _physics_process(delta):
    # Buoyancy force
    var buoyant_force = water_density * volume * gravity
    apply_force(Vector3.UP * buoyant_force)

    # Simple water drag
    apply_force(-drag * linear_velocity)
