extends Camera

# The camera mounted on the vehicle, assigned by the containing scene.
export(NodePath) var target_path
onready var target: Camera = get_node(target_path)

func _process(_delta):
	global_transform = target.global_transform
	fov = target.fov
	near = target.near
	far = target.far
