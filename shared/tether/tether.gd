extends RigidBody

export(int, 1, 1000) var rope_length = 10
export var curl = 0.1
export var height = 0.0002
export var segment_scene: PackedScene
export(NodePath) var attached_body_path

var rope_segments = []
var rope_joints = []

func _ready():
	call_deferred("create_rope")

func create_rope():
	if not rope_segments.empty():
		return
	# Keep generated bodies in a fixed world frame, owned by this tether so
	# removing it also frees the whole chain. The container must not follow
	# the first segment's simulated motion.
	var generated = Spatial.new()
	generated.name = "Segments"
	add_child(generated)
	generated.set_as_toplevel(true)
	generated.global_transform = Transform()
	var attached_body = get_node(attached_body_path) if not attached_body_path.is_empty() else null
	if attached_body:
		add_collision_exception_with(attached_body)
	rope_segments.append(self)
	var previous_body = self
	var segment_height = $MeshInstance.mesh.height
	var initial_basis = global_transform.basis.orthonormalized()
	var connection = global_transform.origin + initial_basis.y * segment_height / 2.0
	var rise = clamp(height, -segment_height, segment_height)
	var horizontal_step = sqrt(max(segment_height * segment_height - rise * rise, 0.0))
	var yaw = 0.0
	for i in range(1, rope_length):
		var direction = ((initial_basis.y * cos(yaw) - initial_basis.z * sin(yaw)) * horizontal_step + initial_basis.x * rise) / segment_height
		var side = initial_basis.x.cross(direction)
		if side.length_squared() < 0.000001:
			side = initial_basis.z
		side = side.normalized()
		var segment = segment_scene.instance()
		segment.mass = mass
		segment.gravity_scale = gravity_scale
		segment.linear_damp = linear_damp
		segment.angular_damp = angular_damp
		segment.collision_layer = collision_layer
		segment.collision_mask = collision_mask
		segment.transform = Transform(Basis(direction.cross(side).normalized(), direction, side), connection + direction * segment_height / 2.0)
		generated.add_child(segment)
		if attached_body:
			segment.add_collision_exception_with(attached_body)
		rope_segments.append(segment)
		var pin_joint = PinJoint.new()
		generated.add_child(pin_joint)
		pin_joint.translation = connection
		pin_joint.set_node_a(pin_joint.get_path_to(previous_body))
		pin_joint.set_node_b(pin_joint.get_path_to(segment))
		pin_joint.set_param(PinJoint.PARAM_BIAS, 0.3)
		pin_joint.set_param(PinJoint.PARAM_DAMPING, 1.0)
		pin_joint.set_param(PinJoint.PARAM_IMPULSE_CLAMP, 0.0)
		rope_joints.append(pin_joint)
		connection += direction * segment_height
		previous_body = segment
		yaw += curl
