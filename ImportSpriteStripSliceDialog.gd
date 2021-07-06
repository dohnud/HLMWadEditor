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
	if Vector2(d,h) != meta.sprites.get_frame(sprite,0).region.size or meta.sprites.get_frame_count(sprite) < frame_count:
		var nb = 'Backgrounds/' != sprite.substr(0,len('Backgrounds/'))
		meta.needs_recalc = true
		meta.sprites.remove_animation(sprite)
		meta.sprites.add_animation(sprite)
		app.base_wad.get_bin(CollisionMasksBin.file_path).resize(app.base_wad.spritebin.sprite_data[sprite]['id'], d,h, frame_count) # :D
		for i in range(frame_count):
			var f = MetaTexture.new()
			f.region = Rect2(i*d, 0, d, h)
			f.atlas = texture
			meta.sprites.add_frame(sprite, f)
			if nb:
				app.base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(app.base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
		app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
		app.meta_editor_node.frametexturerect.update()
		if nb:
			app.base_wad.spritebin.sprite_data[sprite]['size'] = Vector2(d, h)
			app.base_wad.spritebin.sprite_data[sprite]['frame_count'] = frame_count
#			app.base_wad.get_bin(CollisionMasksBin.file_path).resize(app.base_wad.spritebin.sprite_data[sprite]['id'], d,h, frame_count) # :D
#			app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
			app.base_wad.changed_files[SpritesBin.file_path] = app.base_wad.spritebin
			app.base_wad.changed_files[app.selected_asset_name] = app.selected_asset_data # mark .meta as changed cuz it was
			app._on_RecalculateSheetButton_pressed() # recalc sprite sheet in background
		else:
			var tilesheet = sprite.substr(len('Backgrounds/'))
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
					img.blit_rect(f.atlas.get_data(), f.region, of.region.position)
					app.base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(app.base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
					app.base_wad.changed_files[CollisionMasksBin.file_path] = app.base_wad.get_bin(CollisionMasksBin.file_path)
				meta.texture_page.set_data(img)
	hide()
	get_parent().hide()


func _on_ImportSpriteStripSliceDialog_about_to_show():
	pass
