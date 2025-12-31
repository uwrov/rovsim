extends Camera

export var target_path: NodePath
var target: RigidBody

export var follow_distance = 5.0

export var follow_speed = 5.0
export var rotation_speed = 3.0
export var mouse_sensitivity = 0.002

var camera_angle_x = 0.0
var camera_angle_y = 0.0

func _ready():
	target = get_node(target_path)
	
	update_camera_position()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	update_camera_position()

func _input(event):
	if event is InputEventMouseMotion:
		camera_angle_y -= event.relative.x * mouse_sensitivity
		camera_angle_x -= event.relative.y * mouse_sensitivity

func update_camera_position():
	var target_pos = target.global_transform.origin
	
	var base_rotation = Transform()
	base_rotation = base_rotation.rotated(Vector3.UP, camera_angle_y)
	base_rotation = base_rotation.rotated(Vector3.RIGHT, camera_angle_x)
	var target_rotation_y = target.global_transform.basis.get_euler().y
	base_rotation = base_rotation.rotated(Vector3.UP, target_rotation_y)
	
	
	var offset = Vector3(0, 0, follow_distance)
	var rotated_offset = base_rotation.basis * offset
	
	var desired_position = target_pos + rotated_offset
	
	global_transform.origin = desired_position
	
	look_at(target_pos, Vector3.UP)
