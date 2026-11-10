extends RigidBody

# Body-axis requests supplied by main.gd's active Controller.
var control_translation := Vector3.ZERO
var control_torque := Vector3.ZERO

var wall_normal_y_threshold := 0.4 

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
	var cob_location = $COB.get_global_transform().origin - get_global_transform().origin
	var cob_influence = clamp((-0.04 - get_global_transform().origin.y) * 5.0, 0.0, 1.0)
	
	add_force(Vector3.UP * 98 * cob_influence, cob_location)
	add_force(Vector3.DOWN * 98, Vector3.ZERO)
	
	var control_vector = [
		control_translation.x, control_translation.y, control_translation.z,
		control_torque.x, control_torque.y, control_torque.z
	]
	
	var powers = mat_transform(thruster_mat, control_vector)
	powers = limit_powers(powers)
	
	for i in range(thrusters.size()):
		run_thruster(thrusters[i], powers[i])

func _integrate_forces(state):
	# Use direct body state contacts to detect collisions and bounce off mostly-vertical
	if state.get_contact_count() == 0:
		return
	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		if normal == null:
			continue
		normal = normal.normalized()
		# If the contact normal is mostly horizontal (y small), it's likely a wall
		if abs(normal.y) < wall_normal_y_threshold:
			var v = state.linear_velocity

			# Reflect velocity across the contact normal.
			var reflected = v.bounce(normal) 
			state.linear_velocity = reflected
			# Slightly damp angular velocity on bounce to avoid wild spins
			state.angular_velocity = state.angular_velocity * 0.8
			# small nudge outward to reduce chance of sticking
			var trans = state.get_transform()
			trans.origin += normal * 0.01
			state.set_transform(trans)

func run_thruster(thruster: Spatial, power: float):
	var position = self.transform.basis.xform(thruster.translation)
	var direction = thruster.get_global_transform().basis.y
	add_force(direction * power * 7.0, position)

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

