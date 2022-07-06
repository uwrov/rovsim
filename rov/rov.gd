extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var cob_location = $COB.get_global_transform().origin - get_global_transform().origin
	add_force(Vector3.UP * 98, cob_location)
	add_force(Vector3.DOWN * 98, Vector3.ZERO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	apply_torque_impulse(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)))
