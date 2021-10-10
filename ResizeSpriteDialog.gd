extends ConfirmationDialog

onready var app = get_tree().get_nodes_in_group('App')[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var current_tex_dim = Vector2.ONE

func _on_ResizeSpriteDialog_confirmed():
	var new_frame_count = $VBoxContainer/GridContainer/FrameCountSpinBox.value
	var new_frame_w = $VBoxContainer/GridContainer/WidthSpinBox.value
	var new_frame_h = $VBoxContainer/GridContainer/HeightSpinBox.value
	if new_frame_count* new_frame_w*new_frame_h + current_tex_dim.y*current_tex_dim.x > 4000*4000:
		popup()
		app.show_error_dialog('Dimensions entered too big!')
		return
	app._on_ResizeSpriteDialog_confirmed()
