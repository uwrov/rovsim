extends Camera

# Copy of CameraView1 for the 2nd camera

onready var target = null

func _ready():

	target = get_tree().get_root().find_node("Camera2", true, false)


func _process(_delta):

	# Copy global transform so the viewport camera follows exact position/rotation
	global_transform = target.global_transform
	# Keep projection parameters in sync
	fov = target.fov
	near = target.near
	far = target.far
