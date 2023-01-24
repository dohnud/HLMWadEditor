extends WindowDialog



onready var app = get_tree().get_nodes_in_group('App')[0]
var patchwad :Wad= null
var file_dict = {}


var current_import_file_index = 0
var current_import_percent_index = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !visible: return
	
	var import_file_path = file_dict.keys()[current_import_file_index]
	# meta files
	if file_dict[import_file_path]:
		if import_file_path.ends_with('.meta'):
			if true in file_dict[import_file_path].values():
				current_import_percent_index += 1
				$MarginContainer/VBoxContainer/Control.text = import_file_path
				$MarginContainer/VBoxContainer/ProgressBar.value = float(current_import_percent_index)/float(import_file_total)
				var src_meta = null
				var dst_meta = app.base_wad.open_asset(import_file_path)
				if patchwad.exists(import_file_path):
					src_meta = patchwad.open_asset(import_file_path)
					if !(false in file_dict[import_file_path].values()):
						dst_meta = src_meta # shortcut to skip compilation
					for sprite in file_dict[import_file_path].keys():
						if file_dict[import_file_path][sprite]:
							merge_sprite(dst_meta, src_meta, sprite, import_file_path)
					app.base_wad.changed_files[import_file_path] = dst_meta
				else:
					src_meta = app.base_wad.parse_orginal_meta(import_file_path, 0, patchwad.sprite_sheet(import_file_path.replace('.meta','.png')))
#					src_meta.texture_page.get_data().save_png('lookatme.png')
					if !(false in file_dict[import_file_path].values()):
						dst_meta = src_meta # shortcut to skip compilation
#					src_meta.texture_page = patchwad.sprite_sheet(import_file_path.replace('.meta','.png'))
					for sprite in src_meta.sprites.get_animation_names():
#						for i in src_meta.sprites.get_frame_count(sprite):
#							src_meta.sprites.get_frame(sprite, i).atlas = src_meta.texture_page
						if file_dict[import_file_path][sprite]:
							merge_sprite(dst_meta, src_meta, sprite, import_file_path)
					app.base_wad.changed_files[import_file_path] = dst_meta
				app.base_wad.changed_files[import_file_path.replace('.meta', '.png')] = dst_meta.texture_page
		# everything else files
		else:
			current_import_percent_index += 1
			$MarginContainer/VBoxContainer/Control.text = import_file_path
			$MarginContainer/VBoxContainer/ProgressBar.value = float(current_import_percent_index)/float(import_file_total)
			app.base_wad.changed_files[import_file_path] = patchwad.open_asset(import_file_path)
	current_import_file_index += 1
	if current_import_file_index == len(file_dict.keys()):
		hide()
		get_parent().hide()
		app.meta_editor_node.frametexturerect.update()
		app.asset_tree.update()
		file_dict = null
		current_import_file_index = 0
		patchwad = null

func merge_sprite(dst_meta:Meta, src_meta:Meta, sprite:String, rsc_file_path:String):
	var old_n = app.selected_asset_name 
	var old_d = app.selected_asset_data
	app.selected_asset_name = rsc_file_path
	app.selected_asset_data = dst_meta
	var frame_count = src_meta.sprites.get_frame_count(sprite)
	var region = src_meta.sprites.get_frame(sprite, 0).region
	var w = region.size.x
	var h = region.size.y
	var nb = 'Backgrounds/' != sprite.substr(0,len('Backgrounds/'))
	var base_spritebin = app.base_wad.get_bin(SpritesBin)
	var patch_spritebin = patchwad.get_bin(SpritesBin)
	var base_collisionbin = app.base_wad.get_bin(CollisionMasksBin)
	var patch_collisionbin = patchwad.get_bin(CollisionMasksBin)
	if Vector2(w,h) != dst_meta.sprites.get_frame(sprite,0).region.size or dst_meta.sprites.get_frame_count(sprite) != frame_count:
		dst_meta.needs_recalc = true
		dst_meta.sprites.remove_animation(sprite)
		dst_meta.sprites.add_animation(sprite)
		if nb and collision_toggle and wants_collision:
			patchwad.goto(CollisionMasksBin.get_file_path())
			var import_mask = patch_collisionbin.find(base_spritebin.sprite_data[sprite]['id'], patchwad)
			if import_mask != null:
				base_collisionbin.masks[base_spritebin.sprite_data[sprite]['id']] = import_mask
			else:
				ErrorLog.show_user_error("Attempted to import collision for sprite:" + sprite + ". But none was found!")
#			app.base_wad.get_bin(CollisionMasksBin.get_file_path()).resize(base_spritebin.sprite_data[sprite]['id'], w,h, frame_count) # :D
			app.base_wad.changed_files[CollisionMasksBin.get_file_path()] = base_collisionbin
		for i in range(frame_count):
			var f = src_meta.sprites.get_frame(sprite, i)
			dst_meta.sprites.add_frame(sprite, f)
			if nb and !collision_toggle and wants_collision:
				var b_list = base_collisionbin.compute_new_mask(base_spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
				base_spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
				base_spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
		if nb:
			base_spritebin.sprite_data[sprite]['size'] = Vector2(w, h)
			if sprite_toggle:
				var p_spritebin_sprite = patch_spritebin.sprite_data[sprite]
				base_spritebin.sprite_data[sprite]['center'] = p_spritebin_sprite['center']
			base_spritebin.sprite_data[sprite]['frame_count'] = frame_count
#			app.base_wad.get_bin(CollisionMasksBin.get_file_path()).resize(base_spritebin.sprite_data[sprite]['id'], d,h, frame_count) # :D
#			app.base_wad.changed_files[CollisionMasksBin.get_file_path()] = app.base_wad.get_bin(CollisionMasksBin.get_file_path())
			app.base_wad.changed_files[SpritesBin.get_file_path()] = base_spritebin
			app.base_wad.changed_files[app.selected_asset_name] = dst_meta # mark .meta as changed cuz it was
			app._on_RecalculateSheetButton_pressed() # recalc sprite sheet in background
		else:
			var tilesheet = sprite.substr(sprite.find_last('/')+1)
			app.base_wad.backgroundbin.background_data[tilesheet]['size'] = Vector2(w,h)
			app.base_wad.changed_files[BackgroundsBin.get_file_path()] = app.base_wad.backgroundbin
#			app.base_wad.backgroundbin.background_data[tilesheet]['tile_size'] = Vector2(w/frame_count, w/frame_count)
	else:
#		var dest_image = Image.new()
#		dest_image.create(meta.texture_page.get_width(), meta.texture_page.get_height(), false, Image.FORMAT_RGBA8)
		dst_meta.needs_recalc = false
		var img = dst_meta.texture_page.get_data()
		if nb:
			if collision_toggle and wants_collision:
				patchwad.goto(CollisionMasksBin.get_file_path())
				var import_mask = patch_collisionbin.find(base_spritebin.sprite_data[sprite]['id'], patchwad)
				if import_mask != null:
					base_collisionbin.masks[base_spritebin.sprite_data[sprite]['id']] = import_mask
					var p_spritebin_sprite = patch_spritebin.sprite_data[sprite]
					base_spritebin.sprite_data[sprite]['mask_x_bounds'] = p_spritebin_sprite['mask_x_bounds']
					base_spritebin.sprite_data[sprite]['mask_y_bounds'] = p_spritebin_sprite['mask_y_bounds']
				else:
					ErrorLog.show_user_error("Attempted to import collision for sprite:" + sprite + ". But none was found!")
				app.base_wad.changed_files[CollisionMasksBin.get_file_path()] = base_collisionbin
			else:
				base_collisionbin.resize(base_spritebin.sprite_data[sprite]['id'], w,h, frame_count)
		var skip_blit = src_meta == dst_meta
		for i in range(frame_count):
			var f :MetaTexture= src_meta.sprites.get_frame(sprite, i)
			var of :MetaTexture= dst_meta.sprites.get_frame(sprite,i)
			if !skip_blit:
				var tf = f.atlas.get_data()
				if tf.get_format() != Image.FORMAT_RGBA8:
					tf.convert(Image.FORMAT_RGBA8)
				img.blit_rect(tf, f.region, of.region.position)
			if nb:
				if !collision_toggle and wants_collision:
					var b_list = base_collisionbin.compute_new_mask(base_spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
					base_spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
					base_spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
					app.base_wad.changed_files[CollisionMasksBin.get_file_path()] = base_collisionbin
#				if collision_toggle:
#					var collisionbin = patchwad.get_bin(CollisionMasksBin.get_file_path())
#					patchwad.goto(CollisionMasksBin.get_file_path())
#					var import_mask = collisionbin.find(base_spritebin.sprite_data[sprite]['id'], patchwad)
#					app.base_wad.get_bin(CollisionMasksBin.get_file_path()).masks[base_spritebin.sprite_data[sprite]['id']] = import_mask
				if sprite_toggle:
					var s = patchwad.get_bin(SpritesBin)
					if s:
						var p_spritebin_sprite = s.sprite_data.get(sprite, null)
						if p_spritebin_sprite:
		#					app.base_wad.changed_files[CollisionMasksBin.get_file_path()] = app.base_wad.get_bin(CollisionMasksBin.get_file_path())
		#					app.base_wad.changed_files[SpritesBin.get_file_path()] = base_spritebin
		#				if !skip_sprite_data_update:
							base_spritebin.sprite_data[sprite]['size'] = p_spritebin_sprite['size']
							base_spritebin.sprite_data[sprite]['center'] = p_spritebin_sprite['center']
							base_spritebin.sprite_data[sprite]['frame_count'] = p_spritebin_sprite['frame_count']
							app.base_wad.changed_files[SpritesBin.get_file_path()] = base_spritebin
			elif patchwad.exists(BackgroundsBin.get_file_path()):
				var tilesheet = sprite.substr(sprite.find_last('/')+1)
				var b = app.base_wad.backgroundbin
				app.base_wad.backgroundbin.background_data[tilesheet]['size'] = Vector2(w,h)
				app.base_wad.changed_files[BackgroundsBin.get_file_path()] = app.base_wad.backgroundbin
		dst_meta.texture_page.set_data(img)
	app.base_wad.changed_files[app.selected_asset_name.replace('.meta','.png')] = dst_meta.texture_page
	app.selected_asset_name = old_n
	app.selected_asset_data = old_d


var sprite_toggle = false
var collision_toggle = false
var import_file_total = 1
var wants_collision = false
func _on_ImportPatchWindowDialog_confirmed():
	var pw = app.get_node('ImportantPopups/ImportPatchWindowDialog')
	file_dict = pw.file_dict
	patchwad = pw.patchwad
#	pw.patchwad = null
	wants_collision = pw.collision_toggle
	collision_toggle = patchwad.exists(CollisionMasksBin.get_file_path())
	sprite_toggle = patchwad.exists(SpritesBin.get_file_path())
	import_file_total = 1
	current_import_percent_index = 1
	$MarginContainer/VBoxContainer/Control.text = ''
	for f in file_dict.keys():
		import_file_total += int((file_dict[f] is bool and file_dict[f]) or (file_dict[f] is Dictionary and true in file_dict[f].values()))
	print(import_file_total)
	_process(1)
	get_parent().show()
	popup()

