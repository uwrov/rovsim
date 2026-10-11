extends Spatial

const FLUME_SCENE := preload("res://pool25-26/flume tank.tscn")
const WIND_SCENE := preload("res://pool25-26/windwave.tscn")

var current := ""
onready var parent_node := get_parent()
var default_transform := Transform()

func _ready():
	# Defer initialization to ensure other nodes (like a POOL instance declared
	# later in the scene file) are created first. This avoids duplicate POOL nodes.
	call_deferred("_init_pool")
	# Ensure this node receives input events
	set_process_input(true)
	set_process_unhandled_input(true)

func _init_pool():
	# run after the scene has finished instancing nodes
	var existing = parent_node.get_node_or_null("POOL")
	if existing:
		current = "flume"
		default_transform = existing.transform
		print("PoolManager: detected existing POOL instance, assuming flume; saved transform")
	else:
		var inst = FLUME_SCENE.instance()
		inst.name = "POOL"
		parent_node.add_child(inst)
		current = "flume"
		default_transform = inst.transform
		print("PoolManager: added flume POOL instance; saved transform")

func _input(event):
	# Toggle pool when user presses the B key in the running scene
	if event is InputEventKey and event.pressed and not event.echo:
		if event.scancode == KEY_B:
			toggle_pool()

func toggle_pool():
	if current == "flume":
		switch_to("windwave")
	else:
		switch_to("flume")

func switch_to_flume():
	# public wrapper
	switch_to("flume")

func switch_to_windwave():
	# public wrapper
	switch_to("windwave")
func switch_to(target: String):
	if current == target:
		return
	var old = parent_node.get_node_or_null("POOL")
	var tf := default_transform
	if old:
		# Recover the shared placement from the current scene's orientation.
		tf = old.transform * _scene_orientation(current).affine_inverse()
		parent_node.remove_child(old)
		old.queue_free()
	var scene = FLUME_SCENE if target == "flume" else WIND_SCENE
	var inst = scene.instance()
	inst.name = "POOL"
	# WindWave is upright in its editor scene; compensate at its instance root
	# to preserve the established runtime placement.
	inst.transform = tf * _scene_orientation(target)
	parent_node.add_child(inst)
	current = target
	print("PoolManager: switched to %s" % target)

func _scene_orientation(pool_name: String) -> Transform:
	if pool_name == "windwave":
		return Transform(Basis(Vector3(-1, 0, 0), Vector3(0, -1, 0), Vector3(0, 0, 1)), Vector3.ZERO)
	return Transform()
