extends FileDialog


onready var app = get_tree().get_nodes_in_group('App')[0]

var r = null


func _on_ReplaceResourceDialog_file_selected(path):
	if r is Texture:
		r.get_data().save_png(path)
	else:
		var f = File.new()
		if !f.open(path, File.READ):
			var bw : Wad = app.base_wad
			var file = app.selected_asset_list_path
			var new_asset = null
			if r is Texture:
				new_asset = Texture.new()
				new_asset.get_data().load(path)
			elif r is Meta:
				new_asset = Meta.new()
				new_asset.parse(f)
				new_asset.texture_page = bw.open_asset(file.replace('.meta', '.png'))
			elif r is PhyreMeta:
				new_asset = PhyreMeta.new()
				var a = bw.get_bin(phyreAtlasesBin)
				var s = bw.get_bin(phyreSpritesBin)
				var b = bw.get_bin(phyreBackgroundsBin)
				new_asset.parse(f, -1, s, a, b, file)
			elif r is SpritesBin:
				file = SpritesBin.get_file_path()
				if bw.goto(file) == null:
#					$ErrorDialog.popup()
					ErrorLog.show_generic_error()
				else:
					for p in bw.patchwad_list:
						if p.exists(file):
							bw = p
							break
					new_asset = SpritesBin.new()
					new_asset.parse(f)
			elif r is CollisionMasksBin:
				file = CollisionMasksBin.get_file_path()
				if bw.goto(file) == null:
					ErrorLog.show_generic_error()
				else:
					for p in bw.patchwad_list:
						if p.exists(file):
							bw = p
							break
					new_asset = CollisionMasksBin.new()
					new_asset.parse(f)
			elif r is phyreRoomsBin:
				file = phyreRoomsBin.get_file_path()
				if bw.goto(file) == null:
					ErrorLog.show_generic_error()
				else:
					for p in bw.patchwad_list:
						if p.exists(file):
							bw = p
							break
					new_asset = phyreRoomsBin.new()
					new_asset.parse(f)
#			elif r is WadSound:
#				r.write(f)
#			elif r is WadFont:
#				r.write(f)
#			elif r is Array:
#				f.store_buffer(bw.get(file))
			f.close()
			if new_asset != null:
				bw.changed_files[file] = new_asset
			else:
				ErrorLog.show_user_error("File may be corrupted or of a different type than expected")
	get_parent().hide()
