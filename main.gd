extends Spatial

const CONTROLLER_BASE = "res://controllers/"
const DEFAULT_CONTROLLER = "0_manual.gd"
var CONTROLLERS = load_controllers()
onready var cob = $"%ControllerOptionButton"

var active_controller: Controller
onready var rov: RigidBody = $ConduitSimplified

onready var cam1 = $ConduitSimplified/CameraMount1/Camera1
onready var cam2 = $ConduitSimplified/CameraMount2/Camera2
onready var overview_camera = $OverviewCamera
onready var camera_panes = [$ViewportContainer, $ViewportContainerForward2]
var _onboard_camera: Camera
var _onboard_panes_visible = true

func _ready():
	var controller_name = DEFAULT_CONTROLLER
	for argument in OS.get_cmdline_args():
		if argument.begins_with("--controller="):
			var requested = argument.trim_prefix("--controller=")
			if CONTROLLERS.has(requested):
				controller_name = requested
			else:
				controller_name = DEFAULT_CONTROLLER
				push_warning("Unknown controller: " + requested + "; using " + DEFAULT_CONTROLLER)
	var cnames = CONTROLLERS.keys()
	cnames.sort()
	for filename in cnames:
		cob.add_item(filename)
	var index = cnames.find(controller_name)
	cob.select(index)
	_on_ControllerOptionButton_item_selected(index)
	_onboard_camera = cam1
	_onboard_camera.make_current()
	_update_camera_panes()

func _physics_process(delta):
	active_controller.tick(rov.global_transform, delta)
	var ctrl := active_controller._get_control_output()
	rov.control_translation = ctrl[0]
	rov.control_torque = ctrl[1]

func load_controllers() -> Dictionary:
	var result = {}
	var dir = Directory.new()
	dir.open(CONTROLLER_BASE)
	dir.list_dir_begin(true, true)
	
	var filename = dir.get_next()
	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".gd"):
			result[filename] = load(CONTROLLER_BASE + filename)
		filename = dir.get_next()
	dir.list_dir_end()
	
	return result


func _on_ControllerOptionButton_item_selected(index):
	var cname: String = cob.get_item_text(index)
	active_controller = CONTROLLERS[cname].new()

func _unhandled_key_input(event):
	if not event.pressed or event.echo:
		return
	if event.scancode == KEY_F2:
		var index = (cob.selected + 1) % cob.get_item_count()
		cob.select(index)
		_on_ControllerOptionButton_item_selected(index)
	elif event.scancode == KEY_F3:
		_toggle_view()
	elif event.scancode == KEY_ESCAPE and not overview_camera.current:
		_onboard_panes_visible = not _onboard_panes_visible
		_update_camera_panes()
	elif event.is_action_pressed("camSwitch") and not overview_camera.current:
		_onboard_camera = cam2 if cam1.current else cam1
		_onboard_camera.make_current()
	else:
		return
	get_viewport().set_input_as_handled()

func _toggle_view():
	if overview_camera.current:
		_onboard_camera.make_current()
	else:
		overview_camera.update_camera_position()
		overview_camera.make_current()
	_update_camera_panes()

func _update_camera_panes():
	var panes_visible = _onboard_panes_visible and not overview_camera.current
	for pane in camera_panes:
		pane.visible = panes_visible
	get_viewport().disable_3d = panes_visible
