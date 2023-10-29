extends Position3D

const COLOR_STANDARD = Color(0.5, 0.5, 0.5, 0.2)
const COLOR_COMPLETE = Color(0.5, 1.0, 0.5, 0.2)
const COLOR_HIGHLIGHT = Color(1.0, 1.0, 1.0, 0.2)

func _ready():
	pass

func color_complete():
	$ROV23Visual.material_override.albedo_color = COLOR_COMPLETE

func color_highlight():
	$ROV23Visual.material_override.albedo_color = COLOR_HIGHLIGHT

func color_standard():
	$ROV23Visual.material_override.albedo_color = COLOR_STANDARD
