extends RigidBody

var control_translation := Vector3.ZERO
var control_torque := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	print(mat_transform(thruster_mat, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]))

func _process(delta):
	var fx_input = Input.get_axis("rov_translate_right", "rov_translate_left")
	var fy_input = Input.get_axis("rov_translate_backward", "rov_translate_forward")
	var fz_input = Input.get_axis("rov_translate_down", "rov_translate_up")
	
	var tx_input = Input.get_axis("rov_yaw_right", "rov_yaw_left") * 0.25
	var ty_input = Input.get_axis("rov_tilt_up", "rov_tilt_down") * 0.25
	var tz_input = Input.get_axis("rov_roll_left", "rov_roll_right") * 0.25
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	control_translation.x = fx_input
	control_translation.z = fy_input
	control_translation.y = fz_input
	
	control_torque.y = tx_input
	control_torque.x = ty_input
	control_torque.z = tz_input
	
	



func _physics_process(delta):
	var cob_location = $COB.get_global_transform().origin - get_global_transform().origin
	var cob_influence = clamp((-0.16 - get_global_transform().origin.y) * 5.0, 0.0, 1.0)

	add_force(Vector3.UP * 98 * cob_influence, cob_location)
	add_force(Vector3.DOWN * 98, Vector3.ZERO)
	
#	add_central_force(self.transform.basis.xform(control_translation * 10))
#	add_torque(self.transform.basis.xform(control_torque))
	
	var control_vector = [
		control_translation.x, -control_translation.z, control_translation.y,
		control_torque.x, -control_torque.z, control_torque.y
	]
	
	var powers = mat_transform(thruster_mat, control_vector)
	run_thruster($ThrusterForwardRight, powers[0])
	run_thruster($ThrusterForwardLeft, powers[1])
	run_thruster($ThrusterForwardTop, powers[2])
	run_thruster($ThrusterSidewaysTop, powers[3])
	run_thruster($ThrusterUpRight, powers[4])
	run_thruster($ThrusterUpLeft, powers[5])
	
#	run_thruster($ThrusterSidewaysTop, 10.0)
	

func run_thruster(thruster: Spatial, power: float):
	var position = self.transform.basis.xform(thruster.translation)
	var direction = thruster.get_global_transform().basis.y
#	print(position)
#	print(direction)
	add_force(direction * power * 7.0, position)

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
