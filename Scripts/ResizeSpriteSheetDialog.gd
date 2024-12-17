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
	var new_frame_w = $VBoxContainer/GridContainer/WidthSpinBox.value
	var new_frame_h = $VBoxContainer/GridContainer/HeightSpinBox.value
	if new_frame_w > 4096 or new_frame_h > 4096:
		popup()
		app.show_error_dialog('Dimensions entered too big!\n Sprite Sheet sizes are limited to 4096x4096')
		return
	if new_frame_h < current_tex_dim.x or new_frame_w < current_tex_dim.y:
		popup()
		var yes = yield(ErrorLog.show_user_confirmation('Dimensions entered are smaller than original sprite sheet.\n Do you wish to continue?'), "choice_made")
		if not yes: return
	app._on_ResizeSpriteSheetDialog_confirmed(new_frame_w, new_frame_h, $VBoxContainer/GridContainer/RecalculateSpritesLabelButton.pressed)
