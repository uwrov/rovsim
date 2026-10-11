extends Camera


onready var target = null

func _ready():
	# Make this camera the current camera for its Viewport
	# target = get_parent().get_parent().get_node("CameraMount1/Camera1")
	# Apparently referencing the node directly doesn't work?

	target = get_tree().get_root().find_node("Camera1", true, false)

func _process(_delta):

	# Copy global transform so the viewport camera follows exact position/rotation
	global_transform = target.global_transform
	# Keep projection parameters in sync
	fov = target.fov
	near = target.near
	far = target.far
