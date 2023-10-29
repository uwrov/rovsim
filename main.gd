extends Spatial

const CONTROLLER_BASE = "res://controllers/"
var CONTROLLERS = load_controllers()
onready var cob = $"%ControllerOptionButton"

var active_controller: Controller

onready var waypoints = $Waypoints.get_children()
var waypoint_i = 0

func _ready():
	print(CONTROLLERS)
#	active_controller = CONTROLLERS["0_manual.gd"].new()
	var cnames = CONTROLLERS.keys()
	cnames.sort()
	for filename in cnames:
		cob.add_item(filename)
	cob.select(0)  # selects first controller in list
	_on_ControllerOptionButton_item_selected(0)  # and runs the signal
	waypoints[waypoint_i].color_highlight()

func _physics_process(delta):
	var rovt = $ROV23.global_transform
	var wayt = waypoints[waypoint_i].global_transform
	
	if about_the_same(rovt, wayt) or not waypoints[waypoint_i].visible:
		if waypoint_i >= len(waypoints) - 1:
			waypoint_i = 0
			for i in range(len(waypoints)):
				waypoints[i].color_standard()
		else:
			waypoints[waypoint_i].color_complete()
			waypoint_i += 1
			waypoints[waypoint_i].color_highlight()
		active_controller.set_waypoint_transform(waypoints[waypoint_i].global_transform)
		active_controller._waypoint_updated()
	
	active_controller.tick(rovt, wayt, delta)
	var ctrl := active_controller._get_control_output()
	$ROV23.control_translation = ctrl[0]
	$ROV23.control_torque = ctrl[1]
#	print(ctrl)

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
