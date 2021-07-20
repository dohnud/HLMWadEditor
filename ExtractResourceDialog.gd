extends FileDialog


onready var app = get_tree().get_nodes_in_group('App')[0]

var r = null


func _on_ExtractResourceDialog_file_selected(path):
#	var r = app.selected_asset_data
	if r is Texture:
		r.get_data().save_png(path)
#	elif r is AudioStreamSample:
#		r.save_to_wav(path)
#	elif r is AudioStreamOGGVorbis:
#		var f = File.new()
#		f.open(path, File.WRITE)
#		f.store_buffer(r.data)
#		f.close()
	else:
		var f = File.new()
		f.open(path, File.WRITE)
		if '.gmeta' in path:
			if !r.is_gmeta:
				r.convert_to_gmeta(app.base_wad.spritebin)
		r.write(f)
		f.close()
	get_parent().hide()
