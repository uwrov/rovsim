extends Spatial

const CONTROLLER_BASE = "res://controllers/"
var CONTROLLERS = load_controllers()
onready var cob = $"%ControllerOptionButton"

var active_controller: Controller

onready var waypoints = $Waypoints.get_children()
var waypoint_i = 0
var mission_complete = false

#CamSwitch variable
onready var cam1 = $ConduitSimplified/CameraMount1/Camera1
onready var cam2 = $ConduitSimplified/CameraMount2/Camera2

func _ready():
	print(CONTROLLERS)
#	active_controller = CONTROLLERS["0_manual.gd"].new()
	var cnames = CONTROLLERS.keys()
	cnames.sort()
	for filename in cnames:
		cob.add_item(filename)
	cob.select(0)  # selects first controller in list
	_on_ControllerOptionButton_item_selected(0)  # and runs the signal
	_initialize_waypoints()
	if len(waypoints) > 0:
		_set_active_waypoint(0)
	
	# Cam initialize, feel free to change
	cam1.make_current()

func _physics_process(delta):
	var rovt = $ConduitSimplified.global_transform
	if len(waypoints) == 0:
		return

	var wayt = waypoints[waypoint_i].global_transform
	
	# Enforce sequence: only the active waypoint can be completed.
	if not mission_complete and about_the_same(rovt, wayt):
		_complete_current_waypoint()
	
	active_controller.tick(rovt, wayt, delta)
	var ctrl := active_controller._get_control_output()
	$ConduitSimplified.control_translation = ctrl[0]
	$ConduitSimplified.control_torque = ctrl[1]
#	print(ctrl)

func _initialize_waypoints() -> void:
	for i in range(len(waypoints)):
		waypoints[i].color_standard()
	mission_complete = false

func _set_active_waypoint(index: int) -> void:
	waypoint_i = clamp(index, 0, len(waypoints) - 1)
	waypoints[waypoint_i].color_highlight()
	if active_controller:
		active_controller.set_waypoint_transform(waypoints[waypoint_i].global_transform)
		active_controller._waypoint_updated()

func _complete_current_waypoint() -> void:
	waypoints[waypoint_i].color_complete()
	if waypoint_i >= len(waypoints) - 1:
		mission_complete = true
		return
	_set_active_waypoint(waypoint_i + 1)

func about_the_same(a: Transform, b: Transform, pos_delta=0.01, rot_delta = 0.1) -> bool:
	var position_ok = (a.origin - b.origin).length() < pos_delta
	var rotation_ok = (
		+ a.basis.x.angle_to(b.basis.x)
		+ a.basis.y.angle_to(b.basis.y)
		+ a.basis.z.angle_to(b.basis.z)
	) < rot_delta
	
	return position_ok and rotation_ok

func load_controllers() -> Dictionary:
	var result = {}
	var dir = Directory.new()
	dir.open(CONTROLLER_BASE)
	dir.list_dir_begin(true, true)
	
	var filename = dir.get_next()
	while filename != "":
		result[filename] = load(CONTROLLER_BASE + filename)
		filename = dir.get_next()
	
	return result


func _on_ControllerOptionButton_item_selected(index):
	var cname: String = cob.get_item_text(index)
	print(cname)
	active_controller = CONTROLLERS[cname].new()
	if len(waypoints) > 0:
		active_controller.set_waypoint_transform(waypoints[waypoint_i].global_transform)
		active_controller._waypoint_updated()

# More camswitch
func _process(delta):
	if Input.is_action_just_pressed("camSwitch"):
		if (cam1.current):
			cam2.make_current()
		else:
			cam1.make_current()
