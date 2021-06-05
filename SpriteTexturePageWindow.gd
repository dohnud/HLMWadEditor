extends WindowDialog


onready var app = get_tree().get_nodes_in_group('App')[0]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	$VBoxContainer/Panel2/ImportSpriteStripPreview.texture = app.selected_asset_data.texture_page
	popup()
