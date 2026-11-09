extends Position3D

export var inspection := false
export(float, 0.1, 10.0, 0.1) var inspection_hold_time := 0.5
export(float, 0.0, 1.0, 0.01) var inspection_linear_speed := 0.03 # m/s
export(float, 0.0, 1.0, 0.01) var inspection_angular_speed := 0.05 # rad/s

const COLOR_STANDARD = Color(0.5, 0.5, 0.5, 0.2)
const COLOR_COMPLETE = Color(0.5, 1.0, 0.5, 0.2)
const COLOR_HIGHLIGHT = Color(1.0, 1.0, 1.0, 0.2)
const COLOR_INSPECTION = Color(1.0, 0.75, 0.2, 0.3)

onready var _visual_root = $ROV23Visual
var _shared_override_material: SpatialMaterial = null

func _ready():
	_shared_override_material = SpatialMaterial.new()
	_shared_override_material.resource_local_to_scene = true
	_shared_override_material.flags_transparent = true
	_shared_override_material.flags_unshaded = true
	color_standard()

func color_complete():
	_set_visual_color(COLOR_COMPLETE)

func color_highlight():
	_set_visual_color(COLOR_INSPECTION if inspection else COLOR_HIGHLIGHT)

func color_standard():
	_set_visual_color(COLOR_STANDARD)

func _set_visual_color(color: Color) -> void:
	if _visual_root is MeshInstance and _visual_root.mesh != null:
		if _visual_root.material_override == null:
			_visual_root.material_override = _shared_override_material
		_visual_root.material_override.albedo_color = color
		return

	_shared_override_material.albedo_color = color
	_apply_override_recursive(_visual_root)

func _apply_override_recursive(node: Node) -> void:
	if node is MeshInstance:
		node.material_override = _shared_override_material
	for child in node.get_children():
		_apply_override_recursive(child)
