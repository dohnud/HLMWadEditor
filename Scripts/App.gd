extends Control

class_name App

export(NodePath) var asset_tree
export(NodePath) var asset_tree_container
export(NodePath) var meta_editor_node_path
var meta_editor_node
export(NodePath) var ags_editor_node 
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

var base_wad = null
var base_wad_path = ''
var recent_patches = []
var current_open_patch_path = ''

var selected_asset_list_path = ''
var selected_asset_name = ''
var selected_asset_data = null
var selected_asset_treeitem = null
var thread = null

var show_base_wad = true
var show_only_favorites = false
var show_advanced = false


const f_prefixes = ['Sprites/', 'Objects/', 'Rooms/', 'Backgrounds/']#, 'Metadata/']
onready var advanced_stuff_filter = {
	SpritesBin.get_file_path():0,
	ObjectsBin.get_file_path():0,
	RoomsBin.get_file_path():0,
	BackgroundsBin.get_file_path():0,
#	SoundsBin.get_file_path():0,
#	AtlasesBin.get_file_path():0
}

# Called when the node enters the scene tree for the first time.
func _init():
	base_wad_path = Config.settings.base_wad_path
	recent_patches = Config.settings.recent_patches

func _ready():
	for k in Config.settings.advanced_preferences:
		advanced_stuff_filter[k] = Config.settings.advanced_preferences[k]
	
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
	meta_editor_node = get_node(meta_editor_node_path)
	ags_editor_node = get_node(ags_editor_node)
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
	if base_wad: print('unref', base_wad.unreference())
#	file_path = file_path
	if !wad.opens(file_path, File.READ):
		if !wad.parse_header():
			# one or more files is corrupted
			ErrorLog.show_user_error("One or more resources is corrupted or missing!")
		if show_advanced:
			var s :SpritesBin= wad.parse_sprite_data()
			var o :ObjectsBin= wad.parse_objects()
			var r :RoomsBin = wad.parse_rooms()
			var b :BackgroundsBin = wad.parse_backgrounds()
#		wad.get_ bin(CollisionMasksBin.get_file_path())
		base_wad = wad
#		yield(get_tree(), "idle_frame")
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
		selected_asset_name = asset_path #
		meta_editor_node = get_node(meta_editor_node_path) #
		selected_asset_data = meta_editor_node.set_asset(asset_path)
		meta_editor_node.spritelist_node.grab_focus()
		selected_asset_data.is_hm1 = false
	if asset_path.ends_with('.ags.phyre'):
		editor_tabs.current_tab = 9
		meta_editor_node = ags_editor_node # im lazy
		selected_asset_name = asset_path 
		selected_asset_data = ags_editor_node.set_asset(asset_path)
		selected_asset_data.is_hm1 = true
		ags_editor_node.spritelist_node.grab_focus()
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
	if base_wad == null:
		ErrorLog.show_user_error("No base wad opened!!!!!!!\nDo that !!!!!!!")
		return
	var pwad = Wad.new()
	if !pwad.opens(file_path, File.READ_WRITE):
		if !pwad.parse_header():
			# one or more files is corrupted
			ErrorLog.show_user_error("One or more resources is corrupted or missing!\ncontact a developer!")
		else:
			base_wad.reset()
			base_wad.patchwad_list = []
			base_wad.patch(pwad)
			open_asset(selected_asset_list_path)
			OS.set_window_title('HLMWadEditor - ' + file_path)

func _on_SearchBar_text_entered(new_text='', expand=false):
	var searched = new_text.length() > 0 
	if searched: expand = true
	new_text = new_text.to_lower()
	asset_tree.reset()
	for file in base_wad.file_locations.keys():
		var style = AssetTree.Styles.None
#		if file.begins_with("Fonts"):
#			print("WAIT")
		if base_wad.new_files.has(file) or base_wad.changed_files.has(file):
			style |= AssetTree.Styles.Bold
		for p in base_wad.patchwad_list:
			if p.file_locations.has(file):
				style |= AssetTree.Styles.Bold
				break
		if not show_base_wad and style == AssetTree.Styles.None:
			continue
		if Config.settings.favorite_files.has(file):
			style |= AssetTree.Styles.Favorite
		if show_only_favorites and style == AssetTree.Styles.None:
			continue
		var file_lower = file.to_lower()
		if not searched or new_text in file_lower:
			add_asset_to_tree(file, style)
	var i = -1
	for f in advanced_stuff_filter.keys():
		i += 1
		if advanced_stuff_filter[f]:
			var b = base_wad.get_bin(f)
			if b == null: continue
			if not show_base_wad:
				var dumb = true
				for p in base_wad.patchwad_list:
					dumb = false
					if not(p.file_locations.has(f)):
						dumb = true
						break
				if dumb: continue
			if b:
				for n in b.data.keys():
					var style = AssetTree.Styles.None
					if base_wad.changed_files.has(f) or base_wad.new_files.has(f):
						style = AssetTree.Styes.Bold
					var file = f_prefixes[i] + n
					if Config.settings.favorite_files.has(file):
						style |= AssetTree.Styles.Favorite
					if show_only_favorites and style == AssetTree.Styles.None:
						continue
					if not searched or new_text in n.to_lower() or new_text in str(b.data[n]['id']):
						asset_tree.create_path(file, style)
		
	asset_tree.update()
	if expand: $Main/TopMenu/MenuItems.expandassetlist()

func add_asset_to_tree(file, style):
	# if .meta is different or if texture page is different, mark as bold
	if file.begins_with('Atlases/'):
		if file.ends_with('.meta') or file.ends_with('.gmeta'):
			asset_tree.create_path(file, style)
#		if file.ends_with('.png'):
#			asset_tree.create_path(file.replace('.png','.meta'), style)
	# hotline 1 :3
#				print(file)
	if file.begins_with('GL/') and file.ends_with('.phyre'):
		asset_tree.create_path(file, style)
	if file.begins_with('Fonts/'):
		if file.ends_with('.fnt'):
			asset_tree.create_path(file, style)
		elif file.ends_with("_0.png"):
			asset_tree.create_path(file.replace('_0.png','.fnt'), style)
	if file.begins_with('Sounds/'):
		asset_tree.create_path(file, style)
	if file.begins_with("Music/"):
		asset_tree.create_path(file, style)

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
			if base_wad.get_bin(SpritesBin).sprite_data.has(sprite):
#				if base_wad.get_bin(CollisionMasksBin.get_file_path()).mask_data.has(base_wad.get_bin(SpritesBin).sprite_data[sprite].id):
				var fc = meta.sprites.get_frame_count(sprite)
				var f = meta.sprites.get_frame(sprite, 0)
				base_wad.get_bin(CollisionMasksBin.get_file_path()).resize(base_wad.get_bin(SpritesBin).sprite_data[sprite]['id'], f.region.size.x, f.region.size.y, fc)
				for i in range(fc):
					f = meta.sprites.get_frame(sprite, i)
					var b_list = base_wad.get_bin(CollisionMasksBin.get_file_path()).compute_new_mask(base_wad.get_bin(SpritesBin).sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
					base_wad.get_bin(SpritesBin).sprite_data[sprite]['mask_x_bounds'] = b_list[0]
					base_wad.get_bin(SpritesBin).sprite_data[sprite]['mask_y_bounds'] = b_list[1]
					base_wad.changed_files[CollisionMasksBin.get_file_path()] = base_wad.get_bin(CollisionMasksBin.get_file_path())



var mutex = Mutex.new()

func _on_RecalculateSheetButton_pressed():
	var meta = selected_asset_data
	if selected_asset_data is WadFont:
		meta = selected_asset_data.meta
	if !(selected_asset_data is Meta):
		return
#	asset_tree.set_bold(selected_asset_treeitem)
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
	w.meta = meta_editor_node.meta
	w.sprite = meta_editor_node.current_sprite
	w.export_mode = 0
	#w.mode = FileDialog.MODE_SAVE_FILE
#	get_node("ImportantPopups").show()
#	w.popup()
#	w.invalidate()
#	w.deselect_items()
#	w.window_title = 'Export Sprite Strip to PNG'
#	w.filters = ['*.png']
#	w.current_file = ''
#	w.get_line_edit().text = ''
#	w.get_line_edit().text = meta_editor_node.current_sprite+'_strip.png'
#	w.current_file = meta_editor_node.current_sprite+'_strip.png'
#	w.get_line_edit().text = meta_editor_node.current_sprite+'_strip.png'
	
	var d = NativeDialog.popup_save_dialog(
		'Export Sprite Strip to PNG',
		['*.png ; PNG Image'],
		meta_editor_node.current_sprite + '_strip.png',
		w, '_on_ExportSpriteStripDialog_file_selected'
	)

func export_sprite_strips():
	var w :FileDialog= get_node("ImportantPopups/ExportSpriteStripDialog")
	var meta = meta_editor_node.meta
	w.meta = meta_editor_node.meta
	w.sprite = meta_editor_node.current_sprite
	w.export_mode = 1
	NativeDialog.popup_folder_dialog(
		"Select a Destination Folder to Save Sprites to",
		w, '_on_ExportSpriteStripDialog_dir_selected'
	)
#	w.mode = FileDialog.MODE_OPEN_DIR
#	w.window_title = 'Select a destination Folder'
#	w.filters = []
#	w.current_file = ''
#	w.get_line_edit().text = ''
#	get_node("ImportantPopups").show()
#	w.popup()
#	w.invalidate()

#func change_sprite_attr(sprite_name, attr, new_value):
#	pass

func _on_importSpriteStripButton_pressed():
	var w :FileDialog= get_node("ImportantPopups/ImportSpriteStripDialog")
	w.show_hidden_files = false
	var nw :WindowDialog= get_node("ImportantPopups/ImportSpriteStripSliceDialog")
	nw.meta = meta_editor_node.meta
	nw.sprite = meta_editor_node.current_sprite
	
	var dialog = NativeDialog.popup_open_dialog(
		w.window_title,
		['*.png ; PNG Images'],
		self, "_on_importSpriteStripFileSelected"
	)

func _on_importSpriteStripFileSelected(file):
	if !file: return
	var nw :WindowDialog= get_node("ImportantPopups/ImportSpriteStripSliceDialog")
	get_node("ImportantPopups").hide()
	nw._on_ImportSpriteStripDialog_file_selected(file)


# DEPRECATED
func _on_AddResourceDialog_file_selected(path):
	base_wad.add_file(path)
	_on_SearchBar_text_entered('')


func _on_OpenPatchDialog_file_selected(path):
	if !path: return
	open_patchwad(path)
	_on_SearchBar_text_entered('')
	current_open_patch_path = path
	if path in Config.settings.recent_patches:
		return
	Config.settings.recent_patches.push_front(path)
	if len(Config.settings.recent_patches) > 6:
		Config.settings.recent_patches.pop_back()
	recent_patches = Config.settings.recent_patches
	Config.save()


func _on_OpenWadDialog_file_selected(path):
	if !path: return
	if open_wad(path):
		Config.settings.base_wad_path = path
		base_wad_path = Config.settings.base_wad_path
		Config.save()
		$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Label.hide()


var wait_for_threads_to_resolve = false
var wait_for_threads_to_resolve_path = ''
func _on_SavePatchDialog_file_selected(path:String):
	if !path: return
	if !path.ends_with(".patchwad"): path += ".patchwad"
	var encrypt: bool = path.ends_with(".secure.patchwad")
	Log.log('"Saving to ' + path + '"...')
	var save_directory :Directory= Directory.new()
	var old_path = path
	if !save_directory.open(path.get_base_dir()):
		var i = 0
		while i < 10 and save_directory.file_exists(path):
			path += '_tmp'
		if i >= 10:
			return
	else:
		ErrorLog.show_user_error("Could not access folder: " + path.get_base_dir())
			
	wait_for_threads_to_resolve = false
	print(threads.keys())
	if len(threads.keys()) > 0:
		$WaitForThreadsDialog.popup()
		wait_for_threads_to_resolve_path = path
		return
	
	for fix_file in $ImportantPopups/ExportSettingsDialog.selected_fixes.keys():
		var fix = $ImportantPopups/ExportSettingsDialog.selected_fixes[fix_file]
		Log.log("Applying fix: " + fix_file)
		for delta in fix.Deltas:
			var new_val = fix.Deltas[delta]
			Log.log(delta +  "=" + str(new_val))
			var prop_path = Array(delta.split("."))
			for i in range(len(prop_path)):
				# detect indicies in prop path
				var prop = prop_path[i]
				if prop[0] >= '0' and prop[0] <= '9':
					prop_path[i] = int(prop)
			var target_bin: BinParser
			var asset_name = prop_path[0]
			var dest_prop = prop_path[prop_path.size() - 1]
			# parent null = -100
			# everything else = -1
#			match dest_prop:
#				"parent": if new_val.to_lower() == ""
			prop_path.remove(0)
			prop_path.remove(prop_path.size() - 1)
			var token = delta.left(3)
			var asset
			if token.begins_with("hlm"):
				for b in advanced_stuff_filter.keys():
					"GL/hlm2_sfs.bin".right(3)
					if b.right(3).begins_with(asset_name):
						target_bin = base_wad.get_bin(b)
						asset = target_bin
			else:
				if token.begins_with("obj"): target_bin = base_wad.get_bin(ObjectsBin)
				elif token.begins_with("rm"): target_bin = base_wad.get_bin(RoomsBin)
				elif token.begins_with("spr"): target_bin = base_wad.get_bin(SpritesBin)
				elif token.begins_with("tl"): target_bin = base_wad.get_bin(BackgroundsBin)
				else: continue
				if not(target_bin.data.has(asset_name)):
					ErrorLog.show_user_error("%s does not exist?\nDouble check %s in the \"fixes/\" folder located next to the Wad Editor application" % [asset_name, fix_file])
					continue
				asset = target_bin.get(asset_name)
			var current_sub_asset = asset
			for prop in prop_path:
				if typeof(prop) == TYPE_INT and prop >= len(current_sub_asset):
					# TODO: FIX THIS IS TOOO HACKY AND COULD BREAK SHIT
					# edge case: someone forgets to fill in a field
					current_sub_asset.append({})
				if typeof(current_sub_asset) == TYPE_ARRAY or typeof(current_sub_asset) == TYPE_DICTIONARY:
					current_sub_asset = current_sub_asset[prop]
				elif typeof(current_sub_asset) == TYPE_OBJECT:
					current_sub_asset = current_sub_asset.super_get(prop)
#			prints(dest_prop, new_val)
			current_sub_asset[dest_prop] = new_val
			base_wad.changed_files[target_bin.get_file_path()] = target_bin
	
#	var result = Wad.new()
	var files = {}
	for fp in base_wad.changed_files:
		print(fp, ':', base_wad.changed_files[fp])
		files[fp] = base_wad.changed_files[fp]
	for fp in base_wad.new_files:
		print(fp, ':', base_wad.new_files[fp])
		files[fp] = base_wad.new_files[fp]
	
	var f = File.new() # output file
	var fc = File.new() # file contents
	var header:StreamPeerBuffer = StreamPeerBuffer.new()
	if f.open(path, File.WRITE):
		print('could not open',path,'\nfile in use?')
		ErrorLog.show_user_error('could not open "' + path + '"\nfile in use?')
	if fc.open(path + ".content", File.WRITE_READ):
		print('could not open',path,'\nfile in use?')
		ErrorLog.show_user_error('could not open "' + path + '"\nfile in use?')
		return
	if base_wad.version != Wad.WAD_VERSION.HM1:
#		f.store_buffer(base_wad.identifier)
		header.put_data(base_wad.identifier)
	else:
#		f.store_32(0xFFffFFff)
		header.put_32(0xFFffFFff)


	var num_files = len(files.keys())
#	f.store_32(num_files)
	header.put_32(num_files)
	var current_offset = 0
	var comebackf = {}
	for k in files.keys():
		if base_wad.version == Wad.WAD_VERSION.HM1 and k.begins_with('GL/'):
			k = k.replace('hlm2','hotline')
		# metadata
#		f.store_32(len(k))
#		header.put_32(len(k))
#		f.store_buffer(PoolByteArray(k.to_ascii()))
#		header.put_data(PoolByteArray(k.to_ascii()))
#		comebackf[k] = f.get_position()
#		if base_wad.version == Wad.WAD_VERSION.HM1:
#			f.store_32(0x7fffffff)
#			f.store_32(0x7fffffff)
#			header.put_32(0x7fffffff)
#			header.put_32(0x7fffffff)
#		else:
#			f.store_64(0x7fffffffffffffff) # len
#			f.store_64(0x7fffffffffffffff) # offset
#			header.put_64(0x7fffffffffffffff)
#			header.put_64(0x7fffffffffffffff)
	
#	if base_wad.version != Wad.WAD_VERSION.HM1:
#		f.store_32(-1)
#		header.put_32(-1)
#		asset_tree.reset()
		# F this
#		for k in files.keys():
#			asset_tree.create_path(k)
#		var dd = asset_tree.directory_dict
#		print_dir(dd)
#		f.store_32(len(dirs.keys()))
#		for d in dirs.keys():
#			f.store_32(len(d))
#			f.store_string(d)
#			f.store_32(len(dirs[d]))
#			for e in dirs[d]:
#				f.store_32(len(e[0]))
#				f.store_string(e[0])
#				f.store_8(e[1])
#	var offset = f.get_position()
	
#	if base_wad.version == Wad.WAD_VERSION.HM1:
#		f.seek(0x0)
#		f.store_32(offset)
#		f.seek(offset)
	
#	if !base_wad.is_open():
#		if base_wad.open(base_wad.get_file_path(), File.READ):
#			$ErrorDialog.popup()
#			return
	Log.log('Writing contents to: "' + path + '.content"')
	for file in files.keys():
		var c = fc.get_position()
		header.put_32(len(file))
		header.put_data(PoolByteArray(file.to_ascii()))
		Log.log('Writing (0x%x) "%s"' % [c, file])
		var r = files[file]
		if r is Texture:
			fc.store_buffer(r.get_data().save_png_to_buffer())
		elif r is PhyreMeta:
			r.write(fc)
		elif r is Meta:
			r.write(fc)
		elif r is SpritesBin:
			if base_wad.goto(file) == null: 
				ErrorLog.log_error("base wad: \"" + base_wad_path + "\"" + "does not contain: \"" + file + "\"")
			else:
				var bw = base_wad
				for p in bw.patchwad_list:
					if p.exists(file):
						bw = p
						break
#				if bw == base_wad:
#					ErrorLog.show_user_error("no replacement for \"" + file + "\" found!")
#					return null
				bw.goto(file)
				r.write(bw, fc)
		elif r is CollisionMasksBin:
			if base_wad.goto(file) == null:
				ErrorLog.show_generic_error()
			else:
				var bw = base_wad
				for p in bw.patchwad_list:
					if p.exists(file):
						bw = p
						break
				bw.goto(file)
				r.write(bw, fc)
		elif r is BinParser:
			r.write(fc)
		elif r is WadSound:
			r.write(fc)
		elif r is WadFont:
			r.write(fc)
		else:
			ErrorLog.log_error('Uncaught resource: ' + str(r) + '(' + str(typeof(r)) + ')')
		var s = fc.get_position() - c
		if s <= 2 or s >= 0x7fffffffffffffff - 1:
			ErrorLog.show_generic_error()
			return
		var o = c# - offset
#		f.seek(comebackf[file])
		if base_wad.version == Wad.WAD_VERSION.HM1:
#			f.store_32(s)
#			f.store_32(o)
			header.put_32(s)
			header.put_32(o)
		else:
#			f.store_64(s)
#			f.store_64(o)
			header.put_64(s)
			header.put_64(o)
#		f.seek(c+s)
	header.put_32(0)
	# TODO!!
#	if encrypt: header = PatchWadEncrypter.encrypt(header)
	fc.flush()
	var content_size = fc.get_position()
	fc.seek(0)
	Log.log('Combining Header and Content...\n Content:%s.content\n Output: "%s"' % [path, path])
	f.store_buffer(header.data_array)
	f.store_buffer(fc.get_buffer(content_size))
	f.close()
	fc.close()
	Log.log('Finished writing to "%s!"' % [path])
	Log.log('Removing .content file: %s...' %[path + '.content'])
	if !save_directory.remove(path + '.content'):
		Log.log("Removed .content file!")
	else:
		Log.log("Error removing .content file: %s" % [path + '.content'])
	if path.ends_with('_tmp'):
		Log.log('removing destination file: "' + old_path + '"')
		if !save_directory.remove(old_path):
			if !save_directory.rename(path, old_path):
				Log.log('renaming temporary file from "%s" to "%s"' % [path, old_path])
			else:
				Log.log('Could not rename file: "' + path + '"')
		else:
			Log.log('Could not remove file: "' + old_path + '"')
		Log.log('Successfully overwrote: "' + old_path + '"')
		print('overwrite success!')
	if !path.ends_with('_tmp'):
		OS.set_window_title('HLMWadEditor - ' + path)
	Log.log('Save Successful!')


var dirs = {}
func print_dir(d, i=''):
	for l in d['contents'].keys():
		if d['contents'][l] is Dictionary:
			var s = i + '/' + l
			if i == '': s = l
			if s == '/': s == ''
			dirs[s] = []
			for k in d['contents'][l]['contents'].keys():
				if d['contents'][l]['contents'][k] is Dictionary:
					dirs[s].append([k,1])
				else:
					dirs[s].append([k,0])
			print_dir(d['contents'][l], s)


func _on_ImportSheetDialog_file_selected(path):
	if !path: return
	var image = Image.new()
	var texture = ImageTexture.new()
	var err = image.load(path)
	if err != OK:
		print('ouch couldnt load: ', path)
		return null
	texture.create_from_image(image, 0)
	if texture.get_size() != selected_asset_data.texture_page.get_size():
		if base_wad.version == Wad.WAD_VERSION.HM1:
			ErrorLog.show_user_error("Expected an image with dimensions of:" + str(selected_asset_data.texture_page.get_size()) + "\n Instead recieved: " + str(texture.get_size()), false)
			return
		elif !(selected_asset_data is WadFont):
			ErrorLog.show_user_error("Expected an image with dimensions of:" + str(selected_asset_data.texture_page.get_size()) + "\nInstead recieved: " + str(texture.get_size()) + "\nThis operation may cause visual distortions", false)
	selected_asset_data.texture_page.set_size_override(texture.get_size())
	selected_asset_data.texture_page.set_data(texture.get_data())
	#_recalc_collision()
	if selected_asset_data is WadFont:
		base_wad.changed_files[selected_asset_name.replace('.'+selected_asset_name.get_extension(),'_0.png')] = selected_asset_data.texture_page
	else:
		base_wad.changed_files[selected_asset_name.replace('.'+selected_asset_name.get_extension(),'.png')] = selected_asset_data.texture_page
	meta_editor_node.frametexturerect.update()


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
		if base_wad.get_bin(SpritesBin).sprite_data.has(sprite):
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
			if base_wad.get_bin(SpritesBin).sprite_data.has(sprite):
				base_wad.get_bin(SpritesBin).sprite_data[sprite]['size'] = new_size
				base_wad.get_bin(SpritesBin).sprite_data[sprite]['frame_count'] = nfc
				base_wad.changed_files[SpritesBin.get_file_path()] = base_wad.get_bin(SpritesBin)
				base_wad.get_bin(CollisionMasksBin.get_file_path()).resize(base_wad.get_bin(SpritesBin).sprite_data[sprite]['id'], new_size.x, new_size.y, fc)
				for i in range(nfc):
					var f = meta.sprites.get_frame(sprite, i)
					var b_list = base_wad.get_bin(CollisionMasksBin.get_file_path()).compute_new_mask(base_wad.get_bin(SpritesBin).sprite_data[sprite]['id'], i, f.atlas.get_data().get_rect(f.region)) # :D
					base_wad.get_bin(SpritesBin).sprite_data[sprite]['mask_x_bounds'] = b_list[0]
					base_wad.get_bin(SpritesBin).sprite_data[sprite]['mask_y_bounds'] = b_list[1]
					base_wad.changed_files[CollisionMasksBin.get_file_path()] = base_wad.get_bin(CollisionMasksBin.get_file_path())
			if old_size != new_size or fc != nfc:
				_on_RecalculateSheetButton_pressed()

func _on_ResizeSpriteSheetDialog_confirmed(w,h, recalc=false):
	var meta : Meta = selected_asset_data
	var src_tex : ImageTexture = meta.texture_page
	src_tex.set_size_override(Vector2(w,h))
#	var img = src_tex.get_data()
#	img.crop(w,h)
#	src_tex.set_data(img)
	if recalc: _on_RecalculateSheetButton_pressed()

func _on_Button_pressed():
	$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Button.hide()
	$Main/PanelContainer/HBoxContainer/TabContainer/Panel/Label.show()
	$OpenWadDialog.popup()


func _on_ImportWadFileDialog_confirmed():
	pass # Replace with function body.


func _on_ImportSoundDialog_file_selected(path : String):
	if !path: return
	if path.get_extension() != selected_asset_list_path.get_extension():
		var new_asset_path = selected_asset_list_path.get_basename() + '.' + path.get_extension()
		var new_asset_name = selected_asset_name.get_basename() + '.' + path.get_extension()
		base_wad.file_locations[new_asset_path] = base_wad.file_locations[selected_asset_list_path]
		base_wad.file_locations.erase(selected_asset_list_path)
		selected_asset_list_path = new_asset_path
		selected_asset_name = new_asset_name
	var sound = WadSound.new()
	var f = File.new()
	if f.open(path, File.READ):
		ErrorLog.show_user_error('ouch couldnt open: ' + path)
		return null
	sound.parse(f, f.get_len(), path)
	if sound.stream == null:
		ErrorLog.show_user_error('ouch couldnt open: ' + path)
		return null
#	selected_asset_data.texture_page.set_size_override(texture.get_size())
#	selected_asset_data.texture_page.set_data(texture.get_data())
	base_wad.changed_files[selected_asset_list_path] = sound
	sound_editor_node._on_PausePlayButton_toggled(false)
	sound_editor_node.set_sound(selected_asset_name)
#	sound_editor_node.update()


func _on_ExportSettingsDialog_confirmed() -> void:
	NativeDialog.popup_save_dialog(
		"Save Patchwad",
		["*.patchwad ; Patchwad Archive"],
		'mod.patchwad',
		self, '_on_SavePatchDialog_file_selected'
	)
