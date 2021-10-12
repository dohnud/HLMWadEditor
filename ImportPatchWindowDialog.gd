extends WindowDialog

onready var app = get_tree().get_nodes_in_group('App')[0]
var patchwad :Wad= null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var file_dict = {}
func _on_ImportWadFileDialog_file_selected(path):
	get_parent().show()
	popup()
	var wad = Wad.new()
	file_dict = {}
	if !wad.opens(path, File.READ):
		wad.parse_header()
		patchwad = wad
		var tree_r :Tree = $MarginContainer/VBoxContainer/Resources
		tree_r.clear()
		var root_r = tree_r.create_item()
		tree_r.set_hide_root(true)
		for f in patchwad.file_locations.keys():
			# do not list texture files that have a .meta partner, same for fonts
			if f.ends_with('.png') and (patchwad.file_locations.has(f.replace('.png', '.meta')) or patchwad.file_locations.has(f.replace('.png', '.fnt'))):
				continue
			file_dict[f] = false
			var child1 = tree_r.create_item(root_r)
			child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			child1.set_editable(0, true)
			child1.set_text(0, f)
#			child1.set_text_align(0, TreeItem.ALIGN_RIGHT)
#			child1.set_selectable(0, false)
			if f.ends_with('.meta') or f.ends_with('.png'):
				var m:Meta = null
				# create phantom meta so u can extract specific sprites
				if f.ends_with('.png'):
					m = app.base_wad.parse_orginal_meta(f.replace('.png', '.meta'))
					child1.set_text(0, f.replace('.png', '.meta'))
					file_dict[f.replace('.png', '.meta')] = {}
					file_dict.erase(f)
				else:
					m = patchwad.parse_meta(f)
					file_dict[f] = {}
				for sprite in m.sprites.get_animation_names():
					var child2 = tree_r.create_item(child1)
					child2.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
					child2.set_editable(0, true)
					child2.set_text(0, sprite)
					child1.collapsed = true
					file_dict[child1.get_text(0)][sprite] = false
		tree_r.grab_focus()


func _on_Resources_item_edited():
	var t :Tree = $MarginContainer/VBoxContainer/Resources
	var ti :TreeItem= t.get_selected()
	if ti != null:
		var checked = ti.is_checked(0)
		if ti.get_text(0).ends_with('.meta'):
			file_dict[ti.get_text(0)] = {}
			var sprite_ti :TreeItem= ti.get_children()
			while sprite_ti != null:
				sprite_ti.set_checked(0, checked)
				file_dict[ti.get_text(0)][sprite_ti.get_text(0)] = checked
				sprite_ti = sprite_ti.get_next()
		elif ti.get_parent().get_text(0).ends_with('.meta'):
			if checked:
				ti.get_parent().set_checked(0, true)
			if !file_dict.has(ti.get_parent().get_text(0)) or !(file_dict[ti.get_parent().get_text(0)] is Dictionary):
				file_dict[ti.get_parent().get_text(0)] = {}
			file_dict[ti.get_parent().get_text(0)][ti.get_text(0)] = checked
		else:
			file_dict[ti.get_text(0)] = checked



func _on_cancelButton_pressed():
	patchwad = null
	file_dict = {}
	hide()
	get_parent().hide()

var file_list = []
func _on_okButton_pressed():
	var t :Tree = $MarginContainer/VBoxContainer/Resources
	var index = 0
	var ti_file :TreeItem= t.get_root().get_children()
#	print(file_dict)
	for import_file_path in file_dict.keys():
		# meta files
		if file_dict[import_file_path]:
			if import_file_path.ends_with('.meta'):
				var m :Meta= null
				if patchwad.exists(import_file_path):
					m = patchwad.open_asset(import_file_path)
				else:
					m = app.base_wad.parse_orginal_meta(import_file_path)
					m.texture_page = patchwad.sprite_sheet(import_file_path.replace('.meta','.png'))
					for s in m.sprites.get_animation_names():
						for i in m.sprites.get_frame_count(s):
							m.sprites.get_frame(s, i).atlas = m.texture_page
				# check if meta file has all sprites checked
				var do_merge = false
				if file_dict[import_file_path] is Dictionary:
					do_merge = true
					if len(file_dict[import_file_path].values()) == len(m.sprites.get_animation_names()):
						do_merge = (false in file_dict[import_file_path].values())
				if do_merge:
					for sprite in file_dict[import_file_path].keys():
						if file_dict[import_file_path][sprite]:
							var dst_meta = app.base_wad.open_asset(import_file_path)
							merge_sprite(dst_meta, m, sprite, import_file_path)
				# otherwise just replace whole file
				else:
					app.base_wad.changed_files[import_file_path] = m
					app.base_wad.changed_files[import_file_path.replace('.meta', '.png')] = m.texture_page
			# everything else files
			else:
				app.base_wad.changed_files[import_file_path] = patchwad.open_asset(import_file_path)
		index += 1
		ti_file = ti_file.get_next()
	
	hide()
	get_parent().hide()
	

func merge_sprite(dst_meta:Meta, src_meta:Meta, sprite, rsc_file_path):
	var old_n = app.selected_asset_name 
	var old_d = app.selected_asset_data
	app.selected_asset_name = rsc_file_path
	app.selected_asset_data = dst_meta
	var frame_count = src_meta.sprites.get_frame_count(sprite)
	var texture = src_meta.sprites.get_frame(sprite, 0).atlas
	var w = texture.get_width()
	var h = texture.get_height()
	var nb = 'Backgrounds/' != sprite.substr(0,len('Backgrounds/'))
	if Vector2(w,h) != dst_meta.sprites.get_frame(sprite,0).region.size or dst_meta.sprites.get_frame_count(sprite) != frame_count:
		dst_meta.needs_recalc = true
		dst_meta.sprites.remove_animation(sprite)
		dst_meta.sprites.add_animation(sprite)
		app.base_wad.get_bin(CollisionMasksBin.file_path).resize(app.base_wad.spritebin.sprite_data[sprite]['id'], w,h, frame_count) # :D
		for i in range(frame_count):
			var f = src_meta.sprites.get_frame(sprite, i)
			dst_meta.sprites.add_frame(sprite, f)
			if nb:
				var b_list = app.base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(app.base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
				app.base_wad.spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
				app.base_wad.spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
		app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
		if nb:
			app.base_wad.spritebin.sprite_data[sprite]['size'] = Vector2(w, h)
			app.base_wad.spritebin.sprite_data[sprite]['frame_count'] = frame_count
#			app.base_wad.get_bin(CollisionMasksBin.file_path).resize(app.base_wad.spritebin.sprite_data[sprite]['id'], d,h, frame_count) # :D
#			app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
			app.base_wad.changed_files[SpritesBin.file_path] = app.base_wad.spritebin
			app.base_wad.changed_files[app.selected_asset_name] = dst_meta # mark .meta as changed cuz it was
			app._on_RecalculateSheetButton_pressed() # recalc sprite sheet in background
		else:
			var tilesheet = sprite.substr(len('Backgrounds/'))
			app.base_wad.backgroundbin.background_data[tilesheet]['size'] = Vector2(w,h)
			app.base_wad.changed_files[BackgroundsBin.file_path] = app.base_wad.backgroundbin
		#		app.base_wad.backgroundbin.background_data[tilesheet]['tile_size'] = Vector2(w/frame_count, w/frame_count)
	else:
#		var dest_image = Image.new()
#		dest_image.create(meta.texture_page.get_width(), meta.texture_page.get_height(), false, Image.FORMAT_RGBA8)
		dst_meta.needs_recalc = false
		for s in dst_meta.sprites.get_animation_names():
			var img = dst_meta.texture_page.get_data()
			if s == sprite:
				for i in range(frame_count):
					var f = src_meta.sprites.get_frame(sprite, i)
					var of :MetaTexture= dst_meta.sprites.get_frame(s,i)
					var tf = f.atlas.get_data()
					if tf.get_format() != Image.FORMAT_RGBA8:
						tf.convert(Image.FORMAT_RGBA8)
					img.blit_rect(tf, f.region, of.region.position)
					if nb:
						if  app.base_wad.get_bin(CollisionMasksBin.file_path).mask_data.has(app.base_wad.spritebin.sprite_data[sprite]['id']):
							var b_list = app.base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(app.base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
							app.base_wad.spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
							app.base_wad.spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
							app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
							app.base_wad.changed_files[SpritesBin.file_path] = app.base_wad.spritebin
					else:
						var tilesheet = sprite.substr(len('Backgrounds/'))
						app.base_wad.backgroundbin.background_data[tilesheet]['size'] = Vector2(w,h)
						app.base_wad.changed_files[BackgroundsBin.file_path] = app.base_wad.backgroundbin
				dst_meta.texture_page.set_data(img)
	app.base_wad.changed_files[app.selected_asset_name.replace('.meta','.png')] = dst_meta.texture_page
	app.selected_asset_name = old_n
	app.selected_asset_data = old_d


func _on_SearchBar_text_entered(new_text=''):
	var t :Tree = $MarginContainer/VBoxContainer/Resources
	new_text = new_text.to_lower()
	t.clear()
	var root_r = t.create_item()
	t.set_hide_root(true)
	for f in file_dict.keys():
		# do not list texture files that have a .meta partner, same for fonts
		if f.ends_with('.png') and (file_dict.has(f.replace('.png', '.meta')) or file_dict.has(f.replace('_0.png', '.fnt'))):
			continue
#			file_list.append(f)
		if f.ends_with('.meta'):
			var do_it = false
			if new_text != '':
				for s in file_dict[f]:
					do_it = new_text in s.to_lower()
					if do_it:
						var child1 :TreeItem= t.create_item(root_r)
						child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
						child1.set_editable(0, true)
						child1.set_text(0, f)
						child1.collapsed = true
						for sprite in file_dict[f].keys():
							if new_text in sprite.to_lower() or new_text == '':
								var child2 = t.create_item(child1)
								child2.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
								child2.set_editable(0, true)
								child2.set_text(0, sprite)
				#					child2.set_text_align(0, TreeItem.ALIGN_RIGHT)
				#					child2.set_selectable(0, false)
								child1.collapsed = false
						break
			if (!do_it and new_text in f.to_lower()) or new_text == '':
				var child1 :TreeItem= t.create_item(root_r)
				child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
				child1.set_editable(0, true)
				child1.set_text(0, f)
				child1.collapsed = true
				for sprite in file_dict[f]:
					var child2 = t.create_item(child1)
					child2.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
					child2.set_editable(0, true)
					child2.set_text(0, sprite)
	#					child2.set_text_align(0, TreeItem.ALIGN_RIGHT)
	#					child2.set_selectable(0, false)
					child1.collapsed = true
		elif new_text in f.to_lower() or new_text == '':
			var child1 :TreeItem= t.create_item(root_r)
			child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			child1.set_editable(0, true)
			child1.set_text(0, f)
			child1.collapsed = true
#	var ti_file :TreeItem= t.get_root().get_children()
#	while ti_file != null:
#		var import_file_path = file_list[index]
#		if !(new_text in ti_file.get_text(0)):
#			ti_file.get_next_visible()
#			var m :Meta= patchwad.open_asset(import_file_path)
#			# check if meta file has all sprites checked
#			var do_merge = false
#			var ti_sprite :TreeItem= ti_file.get_children()
#			while ti_sprite != null:
#				# if not do meta merge :P
#				if new_text in ti_sprite.get_text(0):


func _on_selectAllButton_pressed():
	var t :Tree = $MarginContainer/VBoxContainer/Resources
	var ti = t.get_root().get_children()
	while ti != null:
		ti.set_checked(0, true)
		var ti_c = ti.get_children()
		while ti_c != null:
			ti_c.set_checked(0, 1)
			ti_c = ti_c.get_next()
		ti = ti.get_next()
	for f in file_dict.keys():
		if file_dict[f] is Dictionary:
			for s in file_dict[f].keys():
				file_dict[f][s] = true
		else:
			file_dict[f] = true
