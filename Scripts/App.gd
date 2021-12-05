extends Control

export(NodePath) var asset_tree
export(NodePath) var asset_tree_container
export(NodePath) var meta_editor_node 
export(NodePath) var room_editor_node
export(NodePath) var sprite_editor_node
export(NodePath) var background_editor_node
export(NodePath) var object_editor_node
export(NodePath) var sound_editor_node
export(NodePath) var atlas_editor_node
export(NodePath) var font_editor_node
export(NodePath) var editor_tabs
export(PackedScene) var compilenotif

export(Font) var tomakebiggerfont

var base_wad :Wad = null
var base_wad_path = ''
var recent_patches = []

var selected_asset_list_path = ''
var selected_asset_name = ''
var selected_asset_data = null
var selected_asset_treeitem = null
var thread = null

var show_base_wad = true
var show_advanced = false


var f_prefixes = ['Sprites/', 'Objects/', 'Rooms/', 'Backgrounds/']#, 'Metadata/']
var advanced_stuff_filter = {
	SpritesBin.file_path:0,
	ObjectsBin.file_path:0,
	RoomsBin.file_path:0,
	BackgroundsBin.file_path:0,
#	SoundsBin.file_path:0,
#	AtlasesBin.file_path:0
}

# Called when the node enters the scene tree for the first time.
func _init():
	base_wad_path = Config.settings.base_wad_path
	recent_patches = Config.settings.recent_patches

func _ready():
	
	asset_tree = get_node(asset_tree)
	var text_scale_multiplier = clamp(OS.get_screen_size().x / 1920,1,2)
	if text_scale_multiplier  > 1:
		theme.default_font.size *= text_scale_multiplier
		asset_tree.bold_font.size *= text_scale_multiplier
		tomakebiggerfont.size *= text_scale_multiplier
		$NotifList.margin_left *=text_scale_multiplier
		OS.set_window_size(Vector2(1024, 680)*text_scale_multiplier)
	var menu_node_list = $Main/TopMenu/MenuItems.get_children()
	for n in menu_node_list:
		if n is MenuButton:
			n.text = '  ' + n.text + '  '
	asset_tree_container = get_node(asset_tree_container)
	meta_editor_node = get_node(meta_editor_node)
	room_editor_node = get_node(room_editor_node)
	sprite_editor_node = get_node(sprite_editor_node)
	background_editor_node = get_node(background_editor_node)
	object_editor_node = get_node(object_editor_node)
	sound_editor_node = get_node(sound_editor_node)
	atlas_editor_node = get_node(atlas_editor_node)
	font_editor_node = get_node(font_editor_node)
	editor_tabs = get_node(editor_tabs)
	
	if !open_wad(base_wad_path):
		$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Label.hide()
		$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Button.show()

func open_wad(file_path):
	var wad = Wad.new()
#	file_path = file_path
	if !wad.opens(file_path, File.READ):
		wad.parse_header()
		if show_advanced:
			var s :SpritesBin= wad.parse_sprite_data()
			var o :ObjectsBin= wad.parse_objects()
			var r :RoomsBin = wad.parse_rooms()
			var b :BackgroundsBin = wad.parse_backgrounds()
#		wad.get_ bin(CollisionMasksBin.file_path)
		base_wad = wad
		_on_SearchBar_text_entered('')
		return true
	return false
#		var files = wad.new_files.keys()
#		files += wad.file_locations.keys()
#		for file in files:
#			if "Atlas" in file and (".meta" in file or ".gmeta" in file):
#				asset_tree.create_path(file)
#		for sprite_name in s.sprite_data.keys():
#			asset_tree.create_path('Sprites/' + sprite_name)
#		for background_name in b.background_data.keys():
#			asset_tree.create_path('Backgrounds/' + background_name)
#		for object_name in o.object_data.keys():
#			asset_tree.create_path('Objects/' + object_name)
#		for room_name in r.room_data.keys():
#			asset_tree.create_path('Rooms/' + room_name)

func open_asset(asset_path):
	selected_asset_list_path = asset_path
#	print(asset_path)
	if asset_path.ends_with('.meta'):
		editor_tabs.current_tab = 1
		selected_asset_name = asset_path
		selected_asset_data = meta_editor_node.set_asset(asset_path)
		meta_editor_node.spritelist_node.grab_focus()
	if asset_path.ends_with('.gmeta'):
		editor_tabs.current_tab = 1
		selected_asset_name = asset_path
		selected_asset_data = meta_editor_node.set_asset(asset_path)
		meta_editor_node.spritelist_node.grab_focus()
		selected_asset_data.is_gmeta = true
	if asset_path.ends_with('.fnt'):
		editor_tabs.current_tab = 8
		selected_asset_name = asset_path
		selected_asset_data = font_editor_node.set_asset(asset_path)
#		meta_editor_node.spritelist_node.grab_focus()
		base_wad.parse_fnt(asset_path)
#	if 'Rooms/' == asset_path.substr(0,len('Rooms/')):
	if asset_path.begins_with('Rooms/'):
		editor_tabs.current_tab = 2
		selected_asset_name = asset_path.substr(len('Rooms/'))
		selected_asset_data = room_editor_node.set_room(selected_asset_name)
#	if 'Sprites/' == asset_path.substr(0,len('Sprites/')):
	if asset_path.begins_with('Sprites/'):
		editor_tabs.current_tab = 3
		selected_asset_name = asset_path.substr(len('Sprites/'))
		selected_asset_data = sprite_editor_node.set_sprite(selected_asset_name)
#	if 'Objects/' == asset_path.substr(0,len('Objects/')):
	if asset_path.begins_with('Objects/'):
		editor_tabs.current_tab = 5
		selected_asset_name = asset_path.substr(len('Objects/'))
		selected_asset_data = object_editor_node.set_object(selected_asset_name)
#	if 'Backgrounds/' == asset_path.substr(0,len('Backgrounds/')):
	if asset_path.begins_with('Backgrounds/'):
		editor_tabs.current_tab = 4
		selected_asset_name = asset_path.substr(len('Backgrounds/'))
		selected_asset_data = background_editor_node.set_background(selected_asset_name)
#	if 'Sounds/' == asset_path.substr(0,len('Sounds/')):
	if asset_path.begins_with('Sounds/'):
		editor_tabs.current_tab = 7
		selected_asset_name = asset_path
		selected_asset_data = sound_editor_node.set_sound(selected_asset_name)
	if asset_path.begins_with('Music/'):
		editor_tabs.current_tab = 7
		selected_asset_name = asset_path
		selected_asset_data = sound_editor_node.set_sound(selected_asset_name)
	if asset_path.begins_with('Metadata/'):
		editor_tabs.current_tab = 6
		selected_asset_name = asset_path.substr(len('Metadata/'))
		selected_asset_data = atlas_editor_node.set_atlas(selected_asset_name)
#	if selected_asset_data == null:
#		$ErrorDialog.popup()

func open_file_dialog(name, filter, oncomplete):
	pass

func open_patchwad(file_path):
	var pwad = Wad.new()
	if !pwad.opens(file_path, File.READ_WRITE):
		pwad.parse_header()
		base_wad.reset()
		base_wad.patchwad_list = []
		base_wad.patch(pwad)
		open_asset(selected_asset_list_path)
		OS.set_window_title('HLMWadEditor - ' + file_path)

func _on_SearchBar_text_entered(new_text=''):
	new_text = new_text.to_lower()
	asset_tree.reset()
	if new_text == '':
		if show_base_wad:
			for file in base_wad.file_locations.keys():
				if file.begins_with('Atlases/') and (file.ends_with('.meta') or file.ends_with('.gmeta')):
					asset_tree.create_path(file)
				if file.begins_with('Fonts/') and file.ends_with('.fnt'):
					asset_tree.create_path(file)
#				if "Sounds/" == file.substr(0,len('Sounds/')):
				if file.begins_with('Sounds/'):
#					if (".wav" == file.substr(len(file)-len('.wav'))):
					asset_tree.create_path(file)
#				if "Music/" == file.substr(0,len('Music/')):
				if file.begins_with('Music/'):
#					if (".wav" == file.substr(len(file)-len('.wav'))):
					asset_tree.create_path(file)
		for p in base_wad.patchwad_list:
			for file in p.file_locations.keys() + base_wad.new_files.keys() + base_wad.changed_files.keys():
				# if .meta is different or if texture page is different, mark as bold
				if file.begins_with('Atlases/'):
					if file.ends_with('.meta') or file.ends_with('.gmeta'):
						asset_tree.create_path(file, 1)
					if file.ends_with('.png'):
						asset_tree.create_path(file.replace('.png','.meta'), 1)
				# again for Fonts
				if file.ends_with('Fonts/'):
					if file.ends_with('.fnt'):
						asset_tree.create_path(file, 1)
					elif file.end_with("_0.png"):
						asset_tree.create_path(file.replace('_0.png','.fnt'), 1)
				# Sounds!
				if file.begins_with('Sounds/'):
#					if (".wav" == file.substr(len(file)-len('.wav'))):
					asset_tree.create_path(file, 1)
				if file.begins_with("Music/"):
#					if (".wav" == file.substr(len(file)-len('.wav'))):
					asset_tree.create_path(file, 1)
		var i = 0
		for f in advanced_stuff_filter.keys():
			if advanced_stuff_filter[f] and show_base_wad:
				var b = base_wad.get_bin(f)
				if b:
					var bb = base_wad.changed_files.has(f) or base_wad.new_files.has(f)
					for n in b.data.keys():
						asset_tree.create_path(f_prefixes[i] + n, bb)
			i += 1
		return
#		op
	else:
		if show_base_wad:
			for file in base_wad.file_locations.keys():
				var file_lower = file.to_lower()
				if "Atlases/" == file.substr(0,len('Atlases/')):
					if (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
						if new_text in file_lower:
							asset_tree.create_path(file)
					if ".png" == file.substr(len(file)-len('.png')):
						if new_text in file_lower:
							asset_tree.create_path(file.replace('.png','.meta'))
				if "Fonts/" == file.substr(0,len('Fonts/')):
					if (".fnt" == file.substr(len(file)-len('.fnt'))):
						if new_text in file_lower:
							asset_tree.create_path(file)
					elif "_0.png" == file.substr(len(file)-len('_0.png')):
						if new_text in file_lower:
							asset_tree.create_path(file.replace('_0.png','.fnt'))
				if file.begins_with('Sounds/'):
#					if (".wav" == file.substr(len(file)-len('.wav'))):
					if new_text in file_lower:
						asset_tree.create_path(file)
				if file.begins_with("Music/"):
#					if (".wav" == file.substr(len(file)-len('.wav'))):
					if new_text in file_lower:
						asset_tree.create_path(file)
		for p in base_wad.patchwad_list:
			for file in p.file_locations.keys() + base_wad.new_files.keys() + base_wad.changed_files.keys():
#			for file in base_wad.new_files.keys() + base_wad.changed_files.keys():
				var file_lower = file.to_lower()
				if file.begins_with('Atlases/'):
					if file.ends_with('.meta') or file.ends_with('.gmeta'):
						if new_text in file_lower:
							asset_tree.create_path(file, 1)
					if file.ends_with('.png'):
						if new_text in file_lower:
							asset_tree.create_path(file.replace('.png','.meta'), 1)
				if file.ends_with('Fonts/'):
					if file.ends_with('.fnt'):
						if new_text in file_lower:
							asset_tree.create_path(file, 1)
					elif file.end_with("_0.png"):
						if new_text in file_lower:
							asset_tree.create_path(file.replace('_0.png','.fnt'), 1)
				if file.begins_with('Sounds/'):
	#				if (".wav" == file.substr(len(file)-len('.wav'))):
					if new_text in file_lower:
						asset_tree.create_path(file, 1)
				if file.begins_with("Music/"):
	#				if (".wav" == file.substr(len(file)-len('.wav'))):
					if new_text in file_lower:
						asset_tree.create_path(file, 1)
		var i = 0
		for f in advanced_stuff_filter.keys():
			if advanced_stuff_filter[f]:
				var b = base_wad.get_bin(f)
				if b:
					var bb = base_wad.changed_files.has(f) or base_wad.new_files.has(f)
					for n in b.data.keys():
						if new_text in n.to_lower():
							asset_tree.create_path(f_prefixes[i] + n, bb)
			i += 1
		
	asset_tree.update()
var threads = {}
#func _on_RecalculateSheetButton_pressed():
#	var meta = selected_asset_data
#	if meta is WadFont:
#		meta = meta.meta
#	asset_tree.set_bold(selected_asset_treeitem)
##	if thread and thread.is_active():
#	if threads.has(selected_asset_name) and threads[selected_asset_name][0].is_active():
#		print('waiting for thread to end...')
#		threads[selected_asset_name][2]._on_CancelResolveButton_pressed()
#		print('thread ended!')
##		threads.erase(selected_asset_name)
#	var t = Thread.new()
#	# Third argument is optional userdata, it can be any variable.
#	meta.terminate_resolve = false
#	print('Starting texture page resolve!')
#	print(t.start(meta, "resolve", [meta.sprites, meta.texture_page], Thread.PRIORITY_HIGH))
#	var nnotif = compilenotif.instance()
#	threads[selected_asset_name] = [t, selected_asset_data, nnotif]
#	meta.connect('resolve_complete', nnotif, 'resolve_complete' [selected_asset_name])
#	meta.connect('resolve_progress', nnotif, 'update_resolve_progress')
#	nnotif.asset_name = selected_asset_name
#	nnotif.connect('resolve_complete', self, 'resolve_complete', [selected_asset_name])
#	nnotif.connect('cancel_resolve', self, '_on_CancelResolve')
#	$NotifList.add_child(nnotif)
#
#func _on_CancelResolve(asset_name=''):
#	if !threads.has(asset_name):
#		print('no thread working on: ', asset_name,'!')
#		return
#	if threads[asset_name][0].is_active():
#		threads[asset_name][1].terminate_resolve = true
#		threads[asset_name][0].wait_to_finish()
#		threads.erase(asset_name)
#
#func resolve_complete(asset):
#	base_wad.changed_files[asset] = threads[asset][2]
#	if threads[asset][2] is WadFont:
#		base_wad.changed_files[asset.replace('.'+asset.get_extension(),'_0.png')] = threads[asset][2].texture_page
#	else:
#		base_wad.changed_files[asset.replace('.'+asset.get_extension(),'.png')] = threads[asset][2].texture_page
#	threads.erase(asset)
#	if wait_for_threads_to_resolve and len(threads) == 0:
#		_on_SavePatchDialog_file_selected(wait_for_threads_to_resolve_path)
#		$WaitForThreadsDone.popup()
#	print('thread complete!')

func _recalc_collision():
	var meta = selected_asset_data
	if meta is Meta:
		for sprite in meta.sprites.get_animation_names():
			if base_wad.spritebin.sprite_data.has(sprite):
#				if base_wad.get_bin(CollisionMasksBin.file_path).mask_data.has(base_wad.spritebin.sprite_data[sprite].id):
				var fc = meta.sprites.get_frame_count(sprite)
				var f = meta.sprites.get_frame(sprite, 0)
				base_wad.get_bin(CollisionMasksBin.file_path).resize(base_wad.spritebin.sprite_data[sprite]['id'], f.region.size.x, f.region.size.y, fc)
				for i in range(fc):
					f = meta.sprites.get_frame(sprite, i)
					var b_list = base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
					base_wad.spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
					base_wad.spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
					base_wad.changed_files[CollisionMasksBin.file_path] = base_wad.get_bin(CollisionMasksBin.file_path)



var mutex = Mutex.new()

func _on_RecalculateSheetButton_pressed():
	var meta = selected_asset_data
	if selected_asset_data is WadFont:
		meta = selected_asset_data.meta
	if !(selected_asset_data is Meta):
		return
	asset_tree.set_bold(selected_asset_treeitem)
#	if thread and thread.is_active():
	if threads.has(selected_asset_name):
		print('waiting for thread to end...')
		if threads[selected_asset_name][1]:
			threads[selected_asset_name][1].queue_free()
		_on_CancelResolve(selected_asset_name)
		print('thread ended!')
#		threads.erase(selected_asset_name)
#	_recalc_collision()
#	var t = Thread.new()
	base_wad.changed_files[selected_asset_name] = meta
	# Third argument is optional userdata, it can be any variable.
#	meta.terminate_resolve = false
	print('Starting texture page resolve!')
	var nnotif = compilenotif.instance()
##	threads[selected_asset_name] = [t, meta, nnotif]
#	threads[meta] = [t, meta, nnotif, selected_asset_name, selected_asset_data]
	threads[selected_asset_name] = [meta, nnotif, selected_asset_name, selected_asset_data]
#	meta.connect('resolve_complete', nnotif, 'resolve_complete')
#	meta.connect('resolve_complete', self, 'resolve_complete')
#	meta.connect('resolve_complete', self, '_resolve_complete')
#	meta.connect('resolve_progress', nnotif, 'update_resolve_progress')
	nnotif.asset_name = selected_asset_name
	nnotif.asset = meta
#	print(t.start(meta, "resolve", [meta.sprites, meta.texture_page, mutex], Thread.PRIORITY_NORMAL))
	nnotif.connect('resolve_complete', self, '_resolve_complete')
	nnotif.connect('cancel_resolve', self, '_on_CancelResolve')
	$NotifList.add_child(nnotif)

func _on_CancelResolve(asset=''):
	if !threads.has(asset):
		print('no thread working on: ', asset,'!')
		return
#	if threads[asset][0].is_active():
#		print('still working here')
#	mutex.try_lock()
#	asset.terminate_resolve = true
#	mutex.unlock()
#	var r = threads[asset][0].wait_to_finish()
#	print(r)
	if threads[asset][1]:
		threads[asset][1].queue_free()
	threads.erase(asset)

func resolve_complete(asset_path):
#	call_deferred('_resolve_complete', meta)
	_resolve_complete(asset_path)

func _resolve_complete(asset_path):
#	mutex.unlock()
	if !threads.has(asset_path):
#		print('uh oh you gotta fix that...')
		return
#	var r = threads[meta][0].wait_to_finish()
#	if r == null:

	var meta = threads[asset_path][0]
	if threads[asset_path][3] is WadFont:
		base_wad.changed_files[asset_path.replace('.'+asset_path.get_extension(),'_0.png')] = meta.texture_page
	else:
		base_wad.changed_files[asset_path.replace('.'+asset_path.get_extension(),'.png')] = meta.texture_page
	print('thread complete!')
	_on_CancelResolve(asset_path)
	# reload the meta editor to show changes
	if selected_asset_data == meta:
		meta_editor_node._on_SpriteList_item_selected(meta_editor_node.current_sprite_list_index)
	if wait_for_threads_to_resolve and len(threads.keys()) == 0:
		_on_SavePatchDialog_file_selected(wait_for_threads_to_resolve_path)
		$WaitForThreadsDone.popup()
		wait_for_threads_to_resolve = false
#	if threads[asset][2] is WadFont:
#		base_wad.changed_files[asset.replace('.'+asset.get_extension(),'_0.png')] = threads[asset][2].texture_page
#	else:
#		base_wad.changed_files[asset.replace('.'+asset.get_extension(),'.png')] = threads[asset][2].texture_page
#	print('thread complete!')
#	threads.erase(asset)
#	if wait_for_threads_to_resolve and len(threads) == 0:
#		_on_SavePatchDialog_file_selected(wait_for_threads_to_resolve_path)
#		$WaitForThreadsDone.popup()


func _on_WaitThreadsOk_pressed():
	wait_for_threads_to_resolve = true
	$WaitForThreadsDialog.hide()
	
func _on_WaitThreadsNo_pressed():
	wait_for_threads_to_resolve = false
	$WaitForThreadsDialog.hide()

# Thread must be disposed (or "joined"), for portability.
#func _exit_tree():
#	for tuple in threads.values():
#		tuple[0].wait_to_finish()


func _on_ExportSpriteStripButton_pressed():
	var w :FileDialog= get_node("ImportantPopups/ExportSpriteStripDialog")
	var meta = meta_editor_node.meta
	w.meta = meta
	w.sprite = meta_editor_node.current_sprite
	w.export_mode = 0
	w.mode = FileDialog.MODE_SAVE_FILE
	get_node("ImportantPopups").show()
	w.popup()
	w.deselect_items()
	w.window_title = 'Export Sprite Strip to PNG'
	w.filters = ['*.png']
	w.current_file = ''
	w.get_line_edit().text = ''
	w.get_line_edit().text = meta_editor_node.current_sprite+'_strip.png'
	w.current_file = meta_editor_node.current_sprite+'_strip.png'

func export_sprite_strips():
	var w :FileDialog= get_node("ImportantPopups/ExportSpriteStripDialog")
	var meta = meta_editor_node.meta
	w.meta = meta
	w.sprite = meta_editor_node.current_sprite
	w.export_mode = 1
	w.mode = FileDialog.MODE_OPEN_DIR
	w.window_title = 'Select a destination Folder'
	w.filters = []
	w.current_file = ''
	w.get_line_edit().text = ''
	get_node("ImportantPopups").show()
	w.popup()

#func change_sprite_attr(sprite_name, attr, new_value):
#	pass

func _on_importSpriteStripButton_pressed():
	var w :FileDialog= get_node("ImportantPopups/ImportSpriteStripDialog")
	var nw :WindowDialog= get_node("ImportantPopups/ImportSpriteStripSliceDialog")
	var meta = meta_editor_node.meta
	nw.meta = meta
	nw.sprite = meta_editor_node.current_sprite
	get_node("ImportantPopups").show()
	w.popup()
	w.show_hidden_files = true
	w.show_hidden_files = false

func _on_AddResourceDialog_file_selected(path):
	base_wad.add_file(path)
	_on_SearchBar_text_entered('')


func _on_OpenPatchDialog_file_selected(path):
	open_patchwad(path)
	_on_SearchBar_text_entered('')
	if path in Config.settings.recent_patches:
		return
	Config.settings.recent_patches.append(path)
	if len(Config.settings.recent_patches) > 6:
		Config.settings.recent_patches.pop_front()
	recent_patches = Config.settings.recent_patches
	Config.save()


func _on_OpenWadDialog_file_selected(path):
	if open_wad(path):
		Config.settings.base_wad_path = path
		base_wad_path = Config.settings.base_wad_path
		Config.save()
		$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Label.hide()


var wait_for_threads_to_resolve = false
var wait_for_threads_to_resolve_path = ''
func _on_SavePatchDialog_file_selected(path):
	wait_for_threads_to_resolve = false
	print(threads.keys())
	if len(threads.keys()) > 0:
		$WaitForThreadsDialog.popup()
		wait_for_threads_to_resolve_path = path
		return
#	var result = Wad.new()
	var files = {}
	for fp in base_wad.changed_files:
		print(fp, ':', base_wad.changed_files[fp])
		files[fp] = base_wad.changed_files[fp]
	for fp in base_wad.new_files:
		print(fp, ':', base_wad.new_files[fp])
		files[fp] = base_wad.new_files[fp]
	
	var f = File.new()
	if f.open(path, File.WRITE):
		print('couldnt open',path,'\nfile in use?')
		return
	f.store_buffer(base_wad.identifier)

	var num_files = len(files.keys())
	f.store_32(num_files)
	var current_offset = 0
	var comebackf = {}
	for k in files.keys():
		# metadata
		f.store_32(len(k))
		f.store_buffer(PoolByteArray(k.to_ascii()))
		comebackf[k] = f.get_position()
		f.store_64(0xFFffFFffFFffFF) # len
		f.store_64(0xFFffFFffFFffFF) # offset
	
	asset_tree.reset()
	for k in files.keys():
		asset_tree.create_path(k)
	var dd = asset_tree.directory_dict
	print_dir(dd)
	f.store_32(len(fuckyoudirs.keys()))
	for d in fuckyoudirs.keys():
		f.store_32(len(d))
		f.store_string(d)
		f.store_32(len(fuckyoudirs[d]))
		for e in fuckyoudirs[d]:
			f.store_32(len(e[0]))
			f.store_string(e[0])
			f.store_8(e[1])
	var offset = f.get_position()
	
#	if !base_wad.is_open():
#		if base_wad.open(base_wad.file_path, File.READ):
#			$ErrorDialog.popup()
#			return
	for file in files.keys():
		var c = f.get_position()
		var fc = files[file]
		if fc is Texture:
			f.store_buffer(fc.get_data().save_png_to_buffer())
		elif fc is Meta:
			fc.write(f)
		elif fc is SpritesBin:
			if base_wad.goto(file) == null:
				$ErrorDialog.popup()
			else:
				fc.write(base_wad, f)
		elif fc is CollisionMasksBin:
			if base_wad.goto(file) == null:
				$ErrorDialog.popup()
			else:
				fc.write(base_wad, f)
		elif fc is BinParser:
			fc.write(f)
		elif fc is WadSound:
			fc.write(f)
		elif fc is WadFont:
			fc.write(f)
		var s = f.get_position() - c
		var o = c - offset
		f.seek(comebackf[file])
		f.store_64(s)
		f.store_64(o)
		f.seek(c+s)
	 


var fuckyoudirs = {}
func print_dir(d, i=''):
	for l in d['contents'].keys():
		if d['contents'][l] is Dictionary:
			var s = i + '/' + l
			if i == '': s = l
			if s == '/': s == ''
			fuckyoudirs[s] = []
			for k in d['contents'][l]['contents'].keys():
				if d['contents'][l]['contents'][k] is Dictionary:
					fuckyoudirs[s].append([k,1])
				else:
					fuckyoudirs[s].append([k,0])
			print_dir(d['contents'][l], s)


func _on_ImportSheetDialog_file_selected(path):
	var image = Image.new()
	var texture = ImageTexture.new()
	var err = image.load(path)
	if err != OK:
		print('ouch couldnt load: ', path)
		return null
	texture.create_from_image(image, 0)
	selected_asset_data.texture_page.set_size_override(texture.get_size())
	selected_asset_data.texture_page.set_data(texture.get_data())
	_recalc_collision()
	if selected_asset_data is WadFont:
		base_wad.changed_files[selected_asset_name.replace('.'+selected_asset_name.get_extension(),'_0.png')] = selected_asset_data.texture_page
	else:
		base_wad.changed_files[selected_asset_name.replace('.'+selected_asset_name.get_extension(),'.png')] = selected_asset_data.texture_page



# check threads
func _on_Timer_timeout():
#	for meta in threads.keys():
#		print(meta)
#		var tuple = threads[meta]
#		if !tuple[0].is_active():
#			if threads[meta][2]:
#				threads[meta][2].queue_free()
#			if wait_for_threads_to_resolve and len(threads) == 0:
#				_on_SavePatchDialog_file_selected(wait_for_threads_to_resolve_path)
#				$WaitForThreadsDone.popup()
#				wait_for_threads_to_resolve = false
#			threads.erase(meta)
	pass

func show_error_dialog(message=''):
	if !message:
		message='Error occured!\nCheck that no other program is utilizing the current base wad or that it has been moved.'
	var w = $ErrorDialog
	w.popup_centered()
	w.get_node("Label2").text=message

func _on_ResizeSpriteDialog_confirmed():
	var meta = selected_asset_data
	if meta is Meta:
		var sprite = $ResizeSpriteDialog/VBoxContainer/SpriteNameLabel.text
		if base_wad.spritebin.sprite_data.has(sprite):
			var fc = meta.sprites.get_frame_count(sprite)
			var nfc = int($ResizeSpriteDialog/VBoxContainer/GridContainer/FrameCountSpinBox.value)
			var new_size = Vector2(
				$ResizeSpriteDialog/VBoxContainer/GridContainer/WidthSpinBox.value,
				$ResizeSpriteDialog/VBoxContainer/GridContainer/HeightSpinBox.value
			)
			var old_size = Vector2.ZERO
			var empty_tex = ImageTexture.new()
			var empty_img = Image.new()
			empty_img.create(new_size.x, new_size.y, false, Image.FORMAT_RGBA8)
			empty_tex.create_from_image(empty_img, 0)
			for i in range(nfc):
				var f = MetaTexture.new()
				if i < fc:
					f = meta.sprites.get_frame(sprite, i)
					old_size = f.region.size
					if f.atlas == meta.texture_page and f.atlas.get_data():
						var new_atlas = ImageTexture.new()
						var new_image = f.atlas.get_data().get_rect(f.region)
						new_image.crop(new_size.x, new_size.y)
						new_atlas.create_from_image(new_image, 0)
						f.atlas = new_atlas
				else:
					f.atlas = empty_tex
					meta.sprites.add_frame(sprite, f)
				f.region = Rect2(Vector2.ZERO, new_size)
			if nfc < fc:
				for i in range(abs(fc-nfc)):
					meta.sprites.remove_frame(sprite, nfc)
			base_wad.changed_files[selected_asset_name] = meta
			if base_wad.spritebin.sprite_data.has(sprite):
				base_wad.spritebin.sprite_data[sprite]['size'] = new_size
				base_wad.spritebin.sprite_data[sprite]['frame_count'] = nfc
				base_wad.changed_files[SpritesBin.file_path] = base_wad.spritebin
				base_wad.get_bin(CollisionMasksBin.file_path).resize(base_wad.spritebin.sprite_data[sprite]['id'], new_size.x, new_size.y, fc)
				for i in range(nfc):
					var f = meta.sprites.get_frame(sprite, i)
					var b_list = base_wad.get_bin(CollisionMasksBin.file_path).compute_new_mask(base_wad.spritebin.sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
					base_wad.spritebin.sprite_data[sprite]['mask_x_bounds'] = b_list[0]
					base_wad.spritebin.sprite_data[sprite]['mask_y_bounds'] = b_list[1]
					base_wad.changed_files[CollisionMasksBin.file_path] = base_wad.get_bin(CollisionMasksBin.file_path)
			if old_size != new_size or fc != nfc:
				_on_RecalculateSheetButton_pressed()


func _on_Button_pressed():
	$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Button.hide()
	$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Label.show()
	$OpenWadDialog.popup()


func _on_ImportWadFileDialog_confirmed():
	pass # Replace with function body.
