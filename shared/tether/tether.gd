extends RigidBody

export var rope_length = 10
export var curl = 0.1
export var height = 0.0002
export var segment_scene: PackedScene

var rope_segments = []

func _ready():
	#Engine.time_scale = 0.00001
	call_deferred("create_rope")

func create_rope():
	rope_segments.append(self)
	var previous_body = self
	var segment_height = find_node("MeshInstance", true, false).mesh.height
	
	var parent = get_parent()
	
	var yaw = 0
	
	for i in range(1, rope_length):
		var segment = segment_scene.instance()
		parent.add_child(segment)
		
		segment.rotation = previous_body.rotation
		segment.rotation.y = -yaw
		segment.rotation.z = (PI / 2) - sin(height / segment_height)
		var seg_x = cos(yaw) * -segment_height
		var seg_y = height
		var seg_z = sin(yaw) * -segment_height
		segment.translation = previous_body.translation + Vector3(seg_x, seg_y, seg_z)
		
		rope_segments.append(segment)
		
		var pin_joint = PinJoint.new()
		parent.add_child(pin_joint)
		pin_joint.translation = previous_body.translation + Vector3(seg_x / 2, seg_y / 2, seg_z / 2)
		
		pin_joint.set_node_a(pin_joint.get_path_to(previous_body))
		pin_joint.set_node_b(pin_joint.get_path_to(segment))
		
		pin_joint.set_param(PinJoint.PARAM_BIAS, 0.3)
		pin_joint.set_param(PinJoint.PARAM_DAMPING, 1.0)
		pin_joint.set_param(PinJoint.PARAM_IMPULSE_CLAMP, 0.0)
		
		previous_body = segment
		yaw += curl

