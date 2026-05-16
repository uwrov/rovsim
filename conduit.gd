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

var wall_normal_y_threshold := 0.6 

# Logically derived matrix based on thruster orientations and positions.
# Target axes (columns): 0:Right, 1:Up, 2:Backward, 3:Pitch(Zeroed), 4:YawLeft, 5:RollLeft
#const thruster_mat = [
#	[ 1.0,  0.0,  0.0,  0.0,  0.0, -20.0], # 0: top (Side-R)
#	[ 1.0,  0.0,  0.0,  0.0,  0.0,  20.0], # 1: bottom (Side-R)
#	[ 0.0,  1.0,  0.0,  0.0,  0.0, -20.0], # 2: left_up (Up)
#	[ 0.0,  1.0,  0.0,  0.0,  0.0,  20.0], # 3: right_up (Up)
#	[ 0.0,  0.0,  1.0,  0.0, -20.0,  0.0], # 4: left_back (Back)
#	[ 0.0,  0.0,  1.0,  0.0,  0.0,  0.0], # 5: right_back (Back)
#]

const thruster_mat = [[ 0.52,  0.0 , -0.0 ,  0.0 ,  1.57,  0.0 ],
	   [ 0.48, -0.0 ,  0.0 ,  0.0 , -1.57, -0.0 ],
	   [-0.02, -0.0 ,  0.5 ,  0.0 , -1.57,  0.0 ],
	   [ 0.02, -0.0 ,  0.5 ,  0.0 ,  1.57, -0.0 ],
	   [ 0.05,  0.51, -0.0 ,  0.0 , -0.0 ,  3.15],
	   [-0.05,  0.49, -0.0 ,  0.0 ,  0.0 , -3.15]]
onready var thrusters = [
	$top,
	$bottom,
	$left_up,
	$right_up,
	$left_back,
	$right_back
]

func _ready():
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
	
	print(control_vector)
	var powers = mat_transform(thruster_mat, control_vector)
	powers = limit_powers(powers)
	print(powers)
	
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

			# Reflect velocity across the contact normal and scale by bounce_energy
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

func set_fclp(path):
	forward_camera_location_path = path
	var fcl = get_node_or_null("ForwardCameraLocation")
	if fcl:
		fcl.remote_path = NodePath("../" + str(forward_camera_location_path))

func set_dclp(path):
	downward_camera_location_path = path
	var dcl = get_node_or_null("DownwardCameraLocation")
	if dcl:
		dcl.remote_path = NodePath("../" + str(downward_camera_location_path))

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
