extends RigidBody

var control_translation := Vector3.ZERO
var control_torque := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	control_translation.x = Input.get_axis("rov_translate_right", "rov_translate_left")
	control_translation.z = Input.get_axis("rov_translate_backward", "rov_translate_forward")
	control_translation.y = Input.get_axis("rov_translate_down", "rov_translate_up")
	
	control_torque.y = Input.get_axis("rov_yaw_right", "rov_yaw_left")
	control_torque.x = Input.get_axis("rov_tilt_up", "rov_tilt_down")
	control_torque.z = Input.get_axis("rov_roll_left", "rov_roll_right")



func _physics_process(delta):
	var cob_location = $COB.get_global_transform().origin - get_global_transform().origin
	var cob_influence = clamp((-0.16 - get_global_transform().origin.y) * 5.0, 0.0, 1.0)

	add_force(Vector3.UP * 98 * cob_influence, cob_location)
	add_force(Vector3.DOWN * 98, Vector3.ZERO)
	
	add_central_force(self.transform.basis.xform(control_translation * 10))
	add_torque(self.transform.basis.xform(control_torque))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	pass
#	apply_torque_impulse(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)))
