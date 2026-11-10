extends Camera

export var target_path: NodePath
var target: RigidBody

export var follow_distance = 5.0
export(float, 0.1, 20.0) var min_follow_distance = 0.6
export(float, 0.1, 50.0) var max_follow_distance = 10.0
export(float, 0.01, 1.0) var zoom_step = 0.15

export var mouse_sensitivity = 0.002

var camera_angle_x = 0.0
var camera_angle_y = 0.0

func _ready():
	target = get_node(target_path)
	max_follow_distance = max(max_follow_distance, min_follow_distance)
	follow_distance = clamp(follow_distance, min_follow_distance, max_follow_distance)
	
	update_camera_position()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	update_camera_position()

func _input(event):
	if current and event is InputEventMouseMotion:
		camera_angle_y -= event.relative.x * mouse_sensitivity
		camera_angle_x -= event.relative.y * mouse_sensitivity

func _unhandled_input(event):
	if not (event is InputEventMouseButton) or not event.pressed or not current:
		return
	var direction = 0.0
	if event.button_index == BUTTON_WHEEL_UP:
		direction = -1.0
	elif event.button_index == BUTTON_WHEEL_DOWN:
		direction = 1.0
	else:
		return
	var zoom_factor = pow(1.0 + zoom_step, direction * event.factor)
	follow_distance = clamp(follow_distance * zoom_factor, min_follow_distance, max_follow_distance)
	update_camera_position()
	get_viewport().set_input_as_handled()

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
