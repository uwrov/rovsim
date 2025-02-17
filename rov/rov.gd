extends RigidBody

export(NodePath) var forward_camera_location_path setget set_fclp
export(NodePath) var downward_camera_location_path setget set_dclp
export(Array, NodePath) var waypoints
export var use_controller := false
export(Script) var controller_script

var latency = 0.0  # 0.6 is realistic
var framerate = 0  # if nonzero, limits FPS; 10 is realistic

var control_translation := Vector3.ZERO
var control_torque := Vector3.ZERO


func _ready():
	print(mat_transform(thruster_mat, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]))
	if framerate > 0:
		Engine.target_fps = framerate

func _process(delta):
	pass

func _physics_process(delta):
	var cob_location = $COB.get_global_transform().origin - get_global_transform().origin
	var cob_influence = clamp((-0.04 - get_global_transform().origin.y) * 5.0, 0.0, 1.0)
	
	add_force(Vector3.UP * 98 * cob_influence, cob_location)
	add_force(Vector3.DOWN * 98, Vector3.ZERO)
	
	var control_vector = [
		control_translation.x, -control_translation.z, control_translation.y,
		control_torque.x, -control_torque.z, control_torque.y
	]
	
	var powers = mat_transform(thruster_mat, control_vector)
	powers = limit_powers(powers)
	run_thruster($ThrusterForwardRight, powers[0])
	run_thruster($ThrusterForwardLeft, powers[1])
	run_thruster($ThrusterForwardTop, powers[2])
	run_thruster($ThrusterSidewaysTop, powers[3])
	run_thruster($ThrusterUpRight, powers[4])
	run_thruster($ThrusterUpLeft, powers[5])


func run_thruster(thruster: Spatial, power: float):
	var position = self.transform.basis.xform(thruster.translation)
	var direction = thruster.get_global_transform().basis.y
	add_force(direction * power * 7.0, position)


# TODO: instead of this janky setup, we should instead have actual cameras in the scene which are
# moved/used appropriately by the parent scene
func set_fclp(path):
	forward_camera_location_path = path
	$ForwardCameraLocation.remote_path = NodePath("../" + str(forward_camera_location_path))

func set_dclp(path):
	downward_camera_location_path = path
	$DownwardCameraLocation.remote_path = NodePath("../" + str(downward_camera_location_path))


const thruster_mat = [
	[-0.56872684, -0.2962075 ,  0.06098061, -2.58392615,  0.0       ,  3.37723719],
	[ 0.56872684, -0.29594525,  0.06085717, -2.57869565,  0.0       , -3.37723719],
	[ 0.0       , -0.40784713, -0.12183778,  5.1626218 ,  0.0       ,  0.0       ],
	[ 0.99999988,  0.0       ,  0.0       ,  0.0       ,  0.0       ,  0.0       ],
	[-0.38736916,  0.0       ,  0.50033773,  0.0       ,  3.37723753,  0.0       ],
	[ 0.38736916,  0.0       ,  0.49966227,  0.0       , -3.37723753,  0.0       ]
]


func mat_transform(mat, vector):
	var result := []
	result.resize(6)
	for i in range(6):
		var sum = 0.0;
		for j in range(6):
			sum += mat[i][j] * vector[j]
		result[i] = sum
	return result

func limit_powers(powers: Array) -> Array:
	var max_power = max(abs(powers.max()), abs(powers.min()))
	max_power *= 2.0
	var norm_factor = 1.0 if max_power < 1.0 else (1 / max_power)
	var result = []
	for i in range(len(powers)):
		result.append(powers[i] * norm_factor)
	return result
