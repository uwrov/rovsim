extends RigidBody

# Body-axis requests supplied by main.gd's active Controller.
var control_translation := Vector3.ZERO
var control_torque := Vector3.ZERO

# Simplified neutral buoyancy: the submerged displacement follows body mass.
# Engine gravity is disabled in the scene so weight is applied only once here.
const GRAVITY = 9.8
const WATER_SURFACE_Y = -0.04
const SUBMERSION_DEPTH = 0.2
const THRUST_PER_POWER = 7.0

# Local force (X, Y, Z), then torque (X, Y, Z)
const thruster_mat = [
	[0.5, 0.0, 0.0, 0.0, 0.0, -1.572327], # top: +X
	[0.5, 0.0, 0.0, 0.0, 0.0,  1.572327], # bottom: +X
	[0.0, 0.5, 0.0, 0.0, 0.0,  1.572327], # left_up: +Y
	[0.0, 0.5, 0.0, 0.0, 0.0, -1.572327], # right_up: +Y
	[0.371069, 0.0, 0.5, 0.0, -3.144654, 0.0], # left_back: +Z
	[-0.371069, 0.0, 0.5, 0.0, 3.144654, 0.0], # right_back: +Z
]
onready var thrusters = [
	$top,
	$bottom,
	$left_up,
	$right_up,
	$left_back,
	$right_back
]

func _physics_process(_delta):
	var cob_location = $COB.global_transform.origin - global_transform.origin
	var submerged = clamp((WATER_SURFACE_Y - global_transform.origin.y) / SUBMERSION_DEPTH, 0.0, 1.0)
	var weight_force = mass * GRAVITY
	add_force(Vector3.UP * weight_force * submerged, cob_location)
	add_force(Vector3.DOWN * weight_force, Vector3.ZERO)
	
	var control_vector = [
		control_translation.x, control_translation.y, control_translation.z,
		control_torque.x, control_torque.y, control_torque.z
	]
	
	var powers = mat_transform(thruster_mat, control_vector)
	powers = limit_powers(powers)
	
	for i in range(thrusters.size()):
		run_thruster(thrusters[i], powers[i])

func run_thruster(thruster: Spatial, power: float):
	# add_force expects a world-axis offset measured from the body origin.
	var position = thruster.global_transform.origin - global_transform.origin
	var direction = thruster.get_global_transform().basis.y
	add_force(direction * power * THRUST_PER_POWER, position)

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

