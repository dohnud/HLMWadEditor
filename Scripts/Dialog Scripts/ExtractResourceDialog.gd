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
		if !f.open(path, File.WRITE):
			var bw = app.base_wad
			var file = app.selected_asset_list_path
			if r is Texture:
				f.store_buffer(r.get_data().save_png_to_buffer())
			elif r is Meta:
				if path.ends_with('.gmeta') and !r.is_gmeta:
					r.convert_to_gmeta(app.base_wad.get_bin(SpritesBin))
				r.write(f)
			elif r is PhyreMeta:
				r.write(f)
			elif r is SpritesBin:
				if bw.goto(file) == null:
#					$ErrorDialog.popup()
					ErrorLog.show_generic_error()
				else:
					for p in bw.patchwad_list:
						if p.exists(file):
							bw = p
							break
					bw.goto(file)
					r.write(bw, f)
			elif r is CollisionMasksBin:
				if bw.goto(file) == null:
					ErrorLog.show_generic_error()
				else:
					for p in bw.patchwad_list:
						if p.exists(file):
							bw = p
							break
					bw.goto(file)
					r.write(bw, f)
			elif r is BinParser:
				print('writing a bin... hmmm i wonder')
				r.write(f)
			elif r is WadSound:
				r.write(f)
			elif r is WadFont:
				r.write(f)
			elif r is Array:
				f.store_buffer(bw.get(file))
			f.close()
	get_parent().hide()
