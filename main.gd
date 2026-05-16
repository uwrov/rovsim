extends Spatial
var waypoints_caught = 0
const CONTROLLER_BASE = "res://controllers/"
var CONTROLLERS = load_controllers()
onready var cob = $"%ControllerOptionButton"

var active_controller: Controller

onready var waypoints = $Waypoints.get_children()
onready var score_label = $HUD/ScoreLabel

func _ready():
	print(CONTROLLERS)
#	active_controller = CONTROLLERS["0_manual.gd"].new()
	var cnames = CONTROLLERS.keys()
	cnames.sort()
	for filename in cnames:
		cob.add_item(filename)
	cob.select(0)  # selects first controller in list
	_on_ControllerOptionButton_item_selected(0)  # and runs the signal
	for waypoint in waypoints: waypoint.color_highlight()
	_update_score_label()

func _physics_process(delta):
	var rovt = $ROV23.global_transform
	for waypoint in waypoints:
		if about_the_same(rovt, waypoint.global_transform) and !waypoint.completed:
			waypoint.completed = true
			waypoint.color_complete()
			waypoints_caught += 1
			_update_score_label()
	
		active_controller.tick(rovt, waypoint.global_transform, delta)
	var ctrl := active_controller._get_control_output()
	$ROV23.control_translation = ctrl[0]
	$ROV23.control_torque = ctrl[1]
#	print(ctrl)

func about_the_same(a: Transform, b: Transform, pos_delta=0.35, rot_delta = 0.5) -> bool:
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

func _input(event):
	# Reset waypoints when backslash is pressed
	if event is InputEventKey and event.pressed and not event.echo:
		var pressed_backslash := false
		if event.scancode == KEY_BACKSLASH:
			pressed_backslash = true
		else:
			var key_text = OS.get_scancode_string(event.scancode)
			if key_text == "BACKSLASH" or key_text == "\\":
				pressed_backslash = true
		if pressed_backslash:
			for waypoint in waypoints:
				waypoint.completed = false
				waypoint.color_highlight()
			waypoints_caught = 0
			_update_score_label()

func _update_score_label():
	if score_label:
		score_label.text = "Score: %d" % waypoints_caught


func _on_ControllerOptionButton_item_selected(index):
	var cname: String = cob.get_item_text(index)
	print(cname)
	active_controller = CONTROLLERS[cname].new()
