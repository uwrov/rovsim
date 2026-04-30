extends Position3D

const COLOR_STANDARD = Color(0.5, 0.5, 0.5, 0.2)
const COLOR_COMPLETE = Color(0.5, 1.0, 0.5, 0.2)
const COLOR_HIGHLIGHT = Color(1.0, 1.0, 1.0, 0.2)
var completed: bool = false

func _ready():
	pass

func color_complete():
	completed = true
	$ROV23Visual.material_override.albedo_color = COLOR_COMPLETE

func color_highlight():
	# don't override the completed (green) color — only highlight if not completed
	if not completed:
		$ROV23Visual.material_override.albedo_color = COLOR_HIGHLIGHT

func color_standard():
	completed = false
	$ROV23Visual.material_override.albedo_color = COLOR_STANDARD
