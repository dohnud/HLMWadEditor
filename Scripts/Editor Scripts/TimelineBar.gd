extends Panel


onready var parent = get_parent()
export var slider_path : NodePath
var slider:Range = null


# Called when the node enters the scene tree for the first time.
func _ready():
	slider = get_node(slider_path)



func update_pos():
	if parent == null : return
	if slider == null : return
	rect_position.x = parent.rect_size.x * slider.value - 2
