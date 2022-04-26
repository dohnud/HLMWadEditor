extends WindowDialog

onready var app = get_tree().get_nodes_in_group('App')[0]


var texture :ImageTexture= null
var f_count = 1

var meta :Meta = null
var sprite = null

func _on_ImportSpriteStripDialog_file_selected(path):
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		print('ouch couldnt load that image')
		app.show_error_dialog('failed to open image')
		return
	if image.get_size().x*image.get_size().y + meta.texture_page.get_size().x * meta.texture_page.get_size().y > 4000*4000:
		app.show_error_dialog('Sprite too big!')
		return
	texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	$VBoxContainer/Panel/ImportSpriteStripPreview.texture = texture
	get_parent().show()
	popup()

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		_on_Button_pressed()
	if visible and event.is_action_pressed("ui_up"):
		$VBoxContainer/HBoxContainer/HBoxContainer2/PanelContainer/HBoxContainer/SpinBox.value = f_count + 1
	if visible and event.is_action_pressed("ui_down"):
		$VBoxContainer/HBoxContainer/HBoxContainer2/PanelContainer/HBoxContainer/SpinBox.value = max(1,f_count - 1)

func _on_SpinBox_value_changed(value):
	f_count = int(value)

# Note to self:
# Removed a some import_mode stuff and moved it to the Extended branch
func _on_Button_pressed():
	var frame_count = f_count
	var row_max = 0
	if row_max == 0: row_max = frame_count
	var w = texture.get_width()
	var h = texture.get_height()
	var d = w / (frame_count)
	var nb = 'Backgrounds/' != sprite.substr(0,len('Backgrounds/'))
	var collision_toggle = $VBoxContainer/HBoxContainer/HBoxContainer2/PanelContainer2/HBoxContainer/CheckButton.pressed
	var collision_bin = app.base_wad.get_bin(CollisionMasksBin.file_path)
	if Vector2(d,h) != meta.sprites.get_frame(sprite,0).region.size or meta.sprites.get_frame_count(sprite) != frame_count:
		meta.needs_recalc = true
		meta.sprites.remove_animation(sprite)
		meta.sprites.add_animation(sprite)
		if nb and collision_toggle:
			collision_bin.resize(app.base_wad.spritebin.sprite_data[sprite]['id'], d,h, frame_count) # :D
			app.base_wad.changed_files[CollisionMasksBin.file_path] = collision_bin
		for i in range(frame_count):
			var f = MetaTexture.new()
			f.region = Rect2(i*d, 0, d, h)
			f.atlas = texture
			meta.sprites.add_frame(sprite, f)
			if nb and collision_toggle:
				var b_list = app.base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(app.base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
				app.base_wad.spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
				app.base_wad.spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
		app.meta_editor_node.frametexturerect.update()
		if nb:
#			if collision_toggle:
			app.base_wad.spritebin.sprite_data[sprite]['size'] = Vector2(d, h)
			app.base_wad.spritebin.sprite_data[sprite]['frame_count'] = frame_count
	#			app.base_wad.get_bin(CollisionMasksBin.file_path).resize(app.base_wad.spritebin.sprite_data[sprite]['id'], d,h, frame_count) # :D
	#			app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
			app.base_wad.changed_files[SpritesBin.file_path] = app.base_wad.spritebin
			app.base_wad.changed_files[app.selected_asset_name] = app.selected_asset_data # mark .meta as changed cuz it was
			app._on_RecalculateSheetButton_pressed() # recalc sprite sheet in background
		else:
			var tilesheet = sprite.substr(sprite.find_last('/')+1)
			app.base_wad.backgroundbin.background_data[tilesheet]['size'] = Vector2(w,h)
			app.base_wad.changed_files[BackgroundsBin.file_path] = app.base_wad.backgroundbin
		#		app.base_wad.backgroundbin.background_data[tilesheet]['tile_size'] = Vector2(w/frame_count, w/frame_count)
	else:
#		var dest_image = Image.new()
#		dest_image.create(meta.texture_page.get_width(), meta.texture_page.get_height(), false, Image.FORMAT_RGBA8)
		meta.needs_recalc = false
		for s in meta.sprites.get_animation_names():
			var img = meta.texture_page.get_data()
			if s == sprite:
				for i in range(frame_count):
					var f = MetaTexture.new()
					f.region = Rect2(i*d, 0, d, h)
					f.atlas = texture
					var of :MetaTexture= meta.sprites.get_frame(s,i)
					var tf = f.atlas.get_data()
					if tf.get_format() != Image.FORMAT_RGBA8:
						tf.convert(Image.FORMAT_RGBA8)
					img.blit_rect(tf, f.region, of.region.position)
					if nb:
#						if  app.base_wad.get_bin(CollisionMasksBin.file_path).mask_data.has(app.base_wad.spritebin.sprite_data[sprite]['id']):
						if collision_toggle:
							var b_list = app.base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(app.base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
							app.base_wad.spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
							app.base_wad.spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
							app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
							app.base_wad.changed_files[SpritesBin.file_path] = app.base_wad.spritebin
					else:
						var tilesheet = sprite.substr(sprite.find_last('/')+1)
						app.base_wad.backgroundbin.background_data[tilesheet]['size'] = Vector2(w,h)
						app.base_wad.changed_files[BackgroundsBin.file_path] = app.base_wad.backgroundbin
				meta.texture_page.set_data(img)
	app.base_wad.changed_files[app.selected_asset_name.replace('.meta','.png')] = meta.texture_page
	hide()
	get_parent().hide()


func _on_ImportSpriteStripSliceDialog_about_to_show():
	pass
