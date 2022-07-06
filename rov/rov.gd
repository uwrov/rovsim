extends RigidBody

var control_translation := Vector3.ZERO
var control_torque := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	print(mat_transform(thruster_mat, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]))

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


const thruster_mat = [[-0.56872684, -0.2962075 ,  0.06098061, -2.58392615,  0.0       ,  3.37723719],
			 [ 0.56872684, -0.29594525,  0.06085717, -2.57869565,  0.0       , -3.37723719],
			 [ 0.0       , -0.40784713, -0.12183778,  5.1626218 ,  0.0       ,  0.0       ],
			 [ 0.99999988,  0.0       ,  0.0       ,  0.0       ,  0.0       ,  0.0       ],
			 [-0.38736916,  0.0       ,  0.50033773,  0.0       ,  3.37723753,  0.0       ],
			 [ 0.38736916,  0.0       ,  0.49966227,  0.0       , -3.37723753,  0.0       ]]


func mat_transform(mat, vector):
	var result := []
	result.resize(6)
	for i in range(6):
		var sum = 0.0;
		for j in range(6):
			sum += mat[i][j] * vector[j]
		result[i] = sum
	return result
