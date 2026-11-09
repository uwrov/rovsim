extends Spatial

const CONTROLLER_BASE = "res://controllers/"
const DEFAULT_CONTROLLER = "starter_controller.gd"
const WAYPOINT_POSITION_TOLERANCE = 0.02 # meters
const WAYPOINT_HEADING_TOLERANCE = 0.05 # radians
var CONTROLLERS = load_controllers()
onready var cob = $"%ControllerOptionButton"
onready var timer_label = $HUD/MissionPanel/MissionStats/TimerLabel
onready var waypoint_count_label = $HUD/MissionPanel/MissionStats/WaypointCountLabel
onready var mission_status_label = $HUD/MissionPanel/MissionStats/MissionStatusLabel

var active_controller: Controller

onready var waypoints = $Waypoints.get_children()
var waypoint_i = 0
var mission_complete = false
var waypoints_hit = 0
var mission_elapsed = 0.0
var inspection_elapsed = 0.0

#CamSwitch variable
onready var cam1 = $ConduitSimplified/CameraMount1/Camera1
onready var cam2 = $ConduitSimplified/CameraMount2/Camera2

func _ready():
	var controller_name = DEFAULT_CONTROLLER
	for argument in OS.get_cmdline_args():
		if argument.begins_with("--current="):
			var value = argument.trim_prefix("--current=")
			if value.is_valid_float():
				$ConduitSimplified.current_force_world = Vector3(float(value), 0, 0)
			else:
				push_warning("Expected a current force in newtons, for example --current=0")
		elif argument.begins_with("--controller="):
			var requested = argument.trim_prefix("--controller=")
			if CONTROLLERS.has(requested):
				controller_name = requested
			else:
				push_warning("Unknown controller: " + requested)
	var cnames = CONTROLLERS.keys()
	cnames.sort()
	for filename in cnames:
		cob.add_item(filename)
	var selected_index = cnames.find(controller_name)
	cob.select(selected_index)
	_on_ControllerOptionButton_item_selected(selected_index)
	_initialize_waypoints()
	if len(waypoints) > 0:
		_set_active_waypoint(0)
	
	$OverviewCamera.make_current()

func _physics_process(delta):
	var rovt = $ConduitSimplified.global_transform
	if len(waypoints) == 0:
		return

	var wayt = _get_waypoint_transform()
	
	# Enforce sequence: only the active waypoint can be completed.
	if not mission_complete:
		mission_elapsed += delta
		if _waypoint_reached(rovt, wayt, delta):
			_complete_current_waypoint()
			wayt = _get_waypoint_transform()
		_update_mission_hud()
	
	active_controller.tick(rovt, wayt, delta)
	if active_controller.has_method("set_navigation_state"):
		active_controller.set_navigation_state($ConduitSimplified.linear_velocity, $ConduitSimplified.angular_velocity, waypoint_i)
	var ctrl := active_controller._get_control_output()
	$ConduitSimplified.control_translation = ctrl[0]
	$ConduitSimplified.control_torque = ctrl[1]

func _waypoint_reached(rovt: Transform, target: Transform, delta: float) -> bool:
	var waypoint = waypoints[waypoint_i]
	if not about_the_same(rovt, target):
		inspection_elapsed = 0.0
		return false
	if not waypoint.inspection:
		return true
	var rov = $ConduitSimplified
	if rov.linear_velocity.length() > waypoint.inspection_linear_speed or rov.angular_velocity.length() > waypoint.inspection_angular_speed:
		inspection_elapsed = 0.0
		return false
	inspection_elapsed += delta
	return inspection_elapsed + 0.000001 >= waypoint.inspection_hold_time

func _get_waypoint_transform(index = -1) -> Transform:
	if index < 0:
		index = waypoint_i
	var target = waypoints[index].global_transform
	# Conduit has no independent pitch control; follow position and heading.
	var heading = target.basis.get_euler().y
	target.basis = Basis(Vector3.UP, heading)
	return target

func _initialize_waypoints() -> void:
	for i in range(len(waypoints)):
		waypoints[i].color_standard()
	waypoint_i = 0
	mission_complete = false
	waypoints_hit = 0
	mission_elapsed = 0.0
	inspection_elapsed = 0.0
	_update_mission_hud()

func _update_mission_hud() -> void:
	var centiseconds = int(mission_elapsed * 100.0)
	timer_label.text = "Time: %02d:%02d.%02d" % [centiseconds / 6000, (centiseconds / 100) % 60, centiseconds % 100]
	waypoint_count_label.text = "Waypoints: %d/%d" % [waypoints_hit, len(waypoints)]
	if mission_complete:
		mission_status_label.text = "Mission complete"
	elif waypoints.empty():
		mission_status_label.text = "No waypoints"
	elif waypoints[waypoint_i].inspection:
		mission_status_label.text = "Inspect: %s\nHold still: %.2f / %.2f s" % [waypoints[waypoint_i].name, inspection_elapsed, waypoints[waypoint_i].inspection_hold_time]
	else:
		mission_status_label.text = "Transit: %s" % waypoints[waypoint_i].name

func _set_active_waypoint(index: int) -> void:
	waypoint_i = clamp(index, 0, len(waypoints) - 1)
	inspection_elapsed = 0.0
	waypoints[waypoint_i].color_highlight()
	if active_controller:
		active_controller.set_waypoint_transform(_get_waypoint_transform())

func _complete_current_waypoint() -> void:
	if mission_complete:
		return
	waypoints[waypoint_i].color_complete()
	waypoints_hit += 1
	if waypoint_i >= len(waypoints) - 1:
		mission_complete = true
		return
	_set_active_waypoint(waypoint_i + 1)

func about_the_same(a: Transform, b: Transform, pos_delta=WAYPOINT_POSITION_TOLERANCE, rot_delta=WAYPOINT_HEADING_TOLERANCE) -> bool:
	var position_ok = (a.origin - b.origin).length() < pos_delta
	var heading_error = wrapf(a.basis.get_euler().y - b.basis.get_euler().y, -PI, PI)
	var rotation_ok = abs(heading_error) < rot_delta
	
	return position_ok and rotation_ok

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
	if active_controller.has_method("configure_navigation"):
		var route = []
		for i in range(len(waypoints)):
			route.append({"transform": _get_waypoint_transform(i), "inspection": waypoints[i].inspection})
		active_controller.configure_navigation(route, $ConduitSimplified.mass, $ConduitSimplified.linear_damp, $ConduitSimplified.angular_damp)
	if len(waypoints) > 0:
		active_controller.set_waypoint_transform(_get_waypoint_transform())

func _unhandled_key_input(event):
	if event.pressed and not event.echo and event.scancode == KEY_F2:
		var index = (cob.selected + 1) % cob.get_item_count()
		cob.select(index)
		_on_ControllerOptionButton_item_selected(index)
		get_tree().set_input_as_handled()

# More camswitch
func _process(delta):
	if Input.is_action_just_pressed("camSwitch"):
		if (cam1.current):
			cam2.make_current()
		else:
			cam1.make_current()
