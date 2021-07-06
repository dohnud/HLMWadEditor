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

# Called when the node enters the scene tree for the first time.
func _init():
	var config = File.new()
	config.open('config.txt', File.READ)
	base_wad_path = config.get_line()
	
	var num = min(int(config.get_line()), 6)
	for i in range(num):
		recent_patches.append(config.get_line())
	config.close()

func _ready():
	
	asset_tree = get_node(asset_tree)
	if OS.get_screen_size().x > 1920:
		theme.default_font.size *= 2
		asset_tree.bold_font.size *= 2
		tomakebiggerfont.size *= 2
	asset_tree_container = get_node(asset_tree_container)
	meta_editor_node = get_node(meta_editor_node)
	room_editor_node = get_node(room_editor_node)
	sprite_editor_node = get_node(sprite_editor_node)
	background_editor_node = get_node(background_editor_node)
	object_editor_node = get_node(object_editor_node)
	sound_editor_node = get_node(sound_editor_node)
	atlas_editor_node = get_node(atlas_editor_node)
	editor_tabs = get_node(editor_tabs)
	
	open_wad(base_wad_path)

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
		wad.get_bin(CollisionMasksBin.file_path)
		base_wad = wad
		_on_SearchBar_text_entered('')
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
	print(asset_path)
	if '.meta' in asset_path:
		editor_tabs.current_tab = 1
		selected_asset_name = asset_path
		selected_asset_data = meta_editor_node.set_asset(asset_path)
		meta_editor_node.spritelist_node.grab_focus()
	if '.gmeta' in asset_path:
		editor_tabs.current_tab = 1
		selected_asset_name = asset_path
		selected_asset_data = meta_editor_node.set_asset(asset_path)
		meta_editor_node.spritelist_node.grab_focus()
		selected_asset_data.is_gmeta = true
	if 'Rooms/' == asset_path.substr(0,len('Rooms/')):
		editor_tabs.current_tab = 2
		selected_asset_name = asset_path.substr(len('Rooms/'))
		selected_asset_data = room_editor_node.set_room(selected_asset_name)
	if 'Sprites/' == asset_path.substr(0,len('Sprites/')):
		editor_tabs.current_tab = 3
		selected_asset_name = asset_path.substr(len('Sprites/'))
		selected_asset_data = sprite_editor_node.set_sprite(selected_asset_name)
	if 'Objects/' == asset_path.substr(0,len('Objects/')):
		editor_tabs.current_tab = 5
		selected_asset_name = asset_path.substr(len('Objects/'))
		selected_asset_data = object_editor_node.set_object(selected_asset_name)
	if 'Backgrounds/' == asset_path.substr(0,len('Backgrounds/')):
		editor_tabs.current_tab = 4
		selected_asset_name = asset_path.substr(len('Backgrounds/'))
		selected_asset_data = background_editor_node.set_background(selected_asset_name)
	if 'Sounds/' == asset_path.substr(0,len('Sounds/')):
		editor_tabs.current_tab = 7
		selected_asset_name = asset_path.substr(len('Sounds/'))
		selected_asset_data = sound_editor_node.set_sound(selected_asset_name)
	if 'Metadata/' == asset_path.substr(0,len('Metadata/')):
		editor_tabs.current_tab = 6
		selected_asset_name = asset_path.substr(len('Metadata/'))
		selected_asset_data = atlas_editor_node.set_atlas(selected_asset_name)

func open_file_dialog(name, filter, oncomplete):
	pass

func open_patchwad(file_path):
	var pwad = Wad.new()
	if !pwad.opens(file_path, File.READ_WRITE):
		pwad.parse_header()
		base_wad.patchwad_list = []
		base_wad.patch(pwad)
		OS.set_window_title('HLMWadEditor - ' + file_path)

func _on_SearchBar_text_entered(new_text=''):
	asset_tree.reset()
	if new_text == '':
		var s :SpritesBin = null
		var sn = false
		var o :ObjectsBin = null
		var on = false
		var r :RoomsBin = null
		var rn = false
		var b :BackgroundsBin = null
		var bn = false
		var ss :SoundsBin = null
		var ssn = false
		var a :AtlasesBin = null
		var an = false
		if show_advanced:
			s = base_wad.spritebin
			o = base_wad.objectbin
			r = base_wad.roombin
			b = base_wad.backgroundbin
			ss = base_wad.get_bin(SoundsBin.file_path)
			a = base_wad.get_bin(AtlasesBin.file_path)
		if show_base_wad:
			for file in base_wad.file_locations.keys():
				if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
					asset_tree.create_path(file)
		for file in base_wad.new_files.keys() + base_wad.changed_files.keys():
			if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
				asset_tree.create_path(file, 1)
			if file == SpritesBin.file_path:
				sn = true
			if file == ObjectsBin.file_path:
				on = true
			if file == RoomsBin.file_path:
				rn = true
			if file == BackgroundsBin.file_path:
				bn = true
			if file == SoundsBin.file_path:
				ssn = true
			if file == AtlasesBin.file_path:
				an = true
		for p in base_wad.patchwad_list:
			for file in p.file_locations.keys():
				if "Atlas" == file.substr(0,len('Atlas'))\
				and (".meta" == file.substr(len(file)-len('.meta'))\
				or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
					asset_tree.create_path(file, 1)
				if "Atlas" == file.substr(0,len('Atlas'))\
				and ".png" == file.substr(len(file)-len('.png')):
					asset_tree.create_path(file.replace('.png','.meta'), 1)
				if file == SpritesBin.file_path:
					sn = true
				if file == ObjectsBin.file_path:
					on = true
				if file == RoomsBin.file_path:
					rn = true
				if file == BackgroundsBin.file_path:
					bn = true
				if file == SoundsBin.file_path:
					ssn = true
				if file == AtlasesBin.file_path:
					an = true
		if s and (show_base_wad or sn):
			for sprite_name in s.sprite_data.keys():
				asset_tree.create_path('Sprites/' + sprite_name, sn)
		if b and (show_base_wad or bn):
			for background_name in b.background_data.keys():
				asset_tree.create_path('Backgrounds/' + background_name, bn)
		if o and (show_base_wad or on):
			for object_name in o.object_data.keys():
				asset_tree.create_path('Objects/' + object_name, on)
		if r and (show_base_wad or rn):
			for room_name in r.room_data.keys():
				asset_tree.create_path('Rooms/' + room_name, rn)
		if ss and (show_base_wad or rn):
			for sound_name in base_wad.get_bin(SoundsBin.file_path).sound_data.keys():
				asset_tree.create_path('Sounds/' + sound_name, ssn)
		if a and (show_base_wad or rn):
			for meta_name in base_wad.get_bin(AtlasesBin.file_path).atlas_data.keys():
				asset_tree.create_path('Metadata/' + meta_name, an)
		return
#		op
	else:
		for file in base_wad.new_files.keys():
			if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
				if new_text in file:
					asset_tree.create_path(file, 1)
		if show_base_wad:
			for file in base_wad.file_locations.keys():
				if "Atlas" == file.substr(0,len('Atlas')) and (".meta" == file.substr(len(file)-len('.meta')) or ".gmeta" == file.substr(len(file)-len('.gmeta'))):
					if new_text in file:
						asset_tree.create_path(file)
			for room_name in base_wad.roombin.room_data.keys():
				if new_text in room_name:
					asset_tree.create_path('Rooms/' + room_name)
			for sprite_name in base_wad.spritebin.sprite_data.keys():
				if new_text in sprite_name:
					asset_tree.create_path('Sprites/' + sprite_name)
			for object_name in base_wad.objectbin.object_data.keys():
				if new_text in object_name:
					asset_tree.create_path('Objects/' + object_name)
			for background_name in base_wad.backgroundbin.background_data.keys():
				if new_text in background_name:
					asset_tree.create_path('Backgrounds/' + background_name)
			for sound_name in base_wad.get_bin(SoundsBin.file_path).sound_data.keys():
				if new_text in sound_name:
					asset_tree.create_path('Sounds/' + sound_name)
			for meta_name in base_wad.get_bin(AtlasesBin.file_path).atlas_data.keys():
				if new_text in meta_name:
					asset_tree.create_path('Metadata/' + meta_name)

var threads = {}
func _on_RecalculateSheetButton_pressed():
	var meta :Meta= meta_editor_node.meta
	base_wad.changed_files[selected_asset_name] = meta
	base_wad.changed_files[selected_asset_name.replace('.meta','.png')] = meta.texture_page
	asset_tree.set_bold(selected_asset_treeitem)
#	if thread and thread.is_active():
	if threads.has(selected_asset_name) and threads[selected_asset_name][0].is_active():
		print('waiting for thread to end...')
		threads[selected_asset_name][2]._on_CancelResolveButton_pressed()
		print('thread ended!')
#		threads.erase(selected_asset_name)
	var t = Thread.new()
	# Third argument is optional userdata, it can be any variable.
	meta.terminate_resolve = false
	print('Starting texture page resolve!')
	print(t.start(meta, "resolve", [meta.sprites, meta.texture_page], Thread.PRIORITY_HIGH))
	var nnotif = compilenotif.instance()
	threads[selected_asset_name] = [t, meta, nnotif]
	meta.connect('resolve_complete', nnotif, 'resolve_complete')
	meta.connect('resolve_progress', nnotif, 'update_resolve_progress')
	nnotif.asset_name = selected_asset_name
	nnotif.connect('resolve_complete', self, 'resolve_complete')
	nnotif.connect('cancel_resolve', self, '_on_CancelResolve')
	$NotifList.add_child(nnotif)

func _on_CancelResolve(asset_name=''):
	if threads[asset_name][0].is_active():
		threads[asset_name][1].terminate_resolve = true
		threads[asset_name][0].wait_to_finish()
		threads.erase(asset_name)

func resolve_complete(a):
	threads.erase(a)
	if wait_for_threads_to_resolve and len(threads) == 0:
		_on_SavePatchDialog_file_selected(wait_for_threads_to_resolve_path)
		$WaitForThreadsDone.popup()
	print('thread complete!')

func _on_WaitThreadsOk_pressed():
	wait_for_threads_to_resolve = true
	
func _on_WaitThreadsNo_pressed():
	wait_for_threads_to_resolve = false

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	for tuple in threads.values():
		tuple[0].wait_to_finish()


func _on_ExportSpriteStripButton_pressed():
	var w :FileDialog= get_node("ImportantPopups/ExportSpriteStripDialog")
	var meta = meta_editor_node.meta
	w.meta = meta
	w.sprite = meta_editor_node.current_sprite
	w.export_mode = 0
	w.mode = FileDialog.MODE_SAVE_FILE
	w.window_title = 'Export Sprite Strip to PNG'
	w.filters = ['*.png']
	get_node("ImportantPopups").show()
	w.popup()
func export_sprite_strips():
	var w :FileDialog= get_node("ImportantPopups/ExportSpriteStripDialog")
	var meta = meta_editor_node.meta
	w.meta = meta
	w.sprite = meta_editor_node.current_sprite
	w.export_mode = 1
	w.mode = FileDialog.MODE_OPEN_DIR
	w.window_title = 'Select a destination Folder'
	w.filters = []
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


func _on_AddResourceDialog_file_selected(path):
	base_wad.add_file(path)
	_on_SearchBar_text_entered('')


func _on_OpenPatchDialog_file_selected(path):
	open_patchwad(path)
	_on_SearchBar_text_entered('')


func _on_OpenWadDialog_file_selected(path):
	open_wad(path)
	var config = File.new()
	config.open('config.txt', File.WRITE)
	config.store_string(path+'\n')
	
	config.store_string(str(len(recent_patches)) + '\n')
	for p in recent_patches:
		config.store_string(p + '\n')


var wait_for_threads_to_resolve = false
var wait_for_threads_to_resolve_path = ''
func _on_SavePatchDialog_file_selected(path):
	wait_for_threads_to_resolve = false
	if len(threads) > 0:
		$WaitForThreadsDialog.popup()
		wait_for_threads_to_resolve_path = path
	var result = Wad.new()
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
	
	for file in files.keys():
		var c = f.get_position()
		var fc = files[file]
		if fc is Texture:
			f.store_buffer(fc.get_data().save_png_to_buffer())
		elif fc is Meta:
			fc.write(f)
		elif fc is BinParser:
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
	base_wad.changed_files[selected_asset_name.replace('.meta','.png')] = selected_asset_data.texture_page






