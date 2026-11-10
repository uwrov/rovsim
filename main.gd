extends Spatial

const CONTROLLER_BASE = "res://controllers/"
var CONTROLLERS = load_controllers()
onready var cob = $"%ControllerOptionButton"

var active_controller: Controller

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
	
	# Cam initialize, feel free to change
	cam1.make_current()

func _physics_process(delta):
	var rovt = $ConduitSimplified.global_transform
	active_controller.tick(rovt, delta)
	var ctrl := active_controller._get_control_output()
	$ConduitSimplified.control_translation = ctrl[0]
	$ConduitSimplified.control_torque = ctrl[1]
#	print(ctrl)

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
	print(cname)
	active_controller = CONTROLLERS[cname].new()

# More camswitch
func _process(delta):
	if Input.is_action_just_pressed("camSwitch"):
		if (cam1.current):
			cam2.make_current()
		else:
			cam1.make_current()
