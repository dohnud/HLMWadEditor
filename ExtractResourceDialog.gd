extends FileDialog


onready var app = get_tree().get_nodes_in_group('App')[0]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ExtractResourceDialog_file_selected(path):
	var r = app.selected_asset_data
	var f = File.new()
	f.open(path, File.WRITE)
	if '.gmeta' in path:
		if !r.is_gmeta:
			r.convert_to_gmeta(app.base_wad.spritebin)
	r.write(f)
	f.close()
	get_parent().hide()
