extends Control

onready var app = get_tree().get_nodes_in_group('App')[0]

var operations = {
	"FileButton" : [
		["Open Patch", [KEY_CONTROL, KEY_O], 'openpatch'],
		["Save Patch", [KEY_CONTROL,KEY_S,], 'savepatch'],
		["Recent Patches", [PopupMenu.new()], 'openrecentpatch'],
		[],
		["Import from Patch", [KEY_CONTROL, KEY_I], 'importpatch'],
		["Merge into WAD", [], 'mergepatch'],
		[],
		["Switch Base WAD", [KEY_CONTROL, KEY_SHIFT, KEY_O], 'openwad'],
		["Quit", [KEY_CONTROL, KEY_Q], 'quit'],
	],
	"ResourceButton" : [
		["Extract", [KEY_CONTROL, KEY_E], 'extract'],
		[],
		["Replace", [KEY_CONTROL, KEY_R,], 'replace'],
		["Revert", [KEY_CONTROL, KEY_SHIFT, KEY_R], 'revert'],
#		[],
#		["Add", [KEY_CONTROL, KEY_SHIFT, KEY_A], 'add'],
#		["Merge", [KEY_CONTROL, KEY_M], 'merge'],
	],
	"ViewButton" : [
		["Expand Asset List", [], 'expandassetlist'],
		["Show Only Modified Files", ['TOGGLE'], 'togglenewfileslist'],
		["Advanced", [PopupMenu.new()], 'toggleadvanced'],
		[],
		["Hide Asset List", [KEY_CONTROL, KEY_H], 'toggleassetlist'],
	],
	"1MetaButton" : [
		["Import Sprite from Strip", [KEY_SHIFT, KEY_I], 'import_sprite_strip'],
		[],
		["Export Sprite to Strip", [KEY_SHIFT, KEY_E], 'export_sprite_strip'],
		["Export Sprite to GIF", [], 'export_sprite_gif'],
		["Export All Sprites", [], 'export_sprite_strips'],
		[],
		["Transform Sprite", [KEY_SHIFT, KEY_T], 'resize_sprite'],
		["Revert Sprite", [KEY_SHIFT, KEY_R], 'revert_sprite'],
		["Recalculate Sprite Sheet", [], 'recalcspritesheet'],
		["Recalculate All Collision Masks", [], 'recalccollisionmasks'],
		[],
		["Toggle Gizmos", [KEY_SHIFT, KEY_G], 'togglemetagizmos'],
		["Show Collision", [], 'togglecollisiongizmo'],
#		["Extras", [PopupMenu.new(),[
#			["Convert to GMeta", [], 'convertmeta'],
#			["Add Sprite", [], 'convertmeta'],
#		]], ''],
	],
	"9AGSButton" : [
		["Import Sprite from Strip", [KEY_SHIFT, KEY_I], 'import_sprite_strip'],
		[],
		["Export Sprite to Strip", [KEY_SHIFT, KEY_E], 'export_sprite_strip'],
		["Export Sprite to GIF", [], 'export_sprite_gif'],
		["Export All Sprites", [], 'export_sprite_strips'],
#		[],
#		["Transform Sprite", [KEY_SHIFT, KEY_T], 'resize_sprite'],
#		["Compile All Sprites", [], 'recalcspritesheet'],
		[],
		["Toggle Gizmos", [KEY_SHIFT, KEY_G], 'togglemetagizmos'],
#		["Extras", [PopupMenu.new(),[
#			["Convert to GMeta", [], 'convertmeta'],
#			["Add Sprite", [], 'convertmeta'],
#		]], ''],
	],
	"18SpriteSheetButton" : [
		["Import Texture Page", [], 'importspritesheet'],
#		["Resize Texture Page", [], 'resize_spritesheet'],
		[],
		["Export Texture Page", [], 'exportspritesheet'],
	],
	"8FontButton" : [
		["Import Character", [], 'na'],
		[],
		["Export Character", [], 'na'],
	],
	"7SoundButton" : [
		["Import Sound", [KEY_SHIFT, KEY_I], 'importsound'],
	],
	"2RoomButton" : [
		["Add Generic Object to Room", [], 'room_add_object'],
	],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for op in operations.keys():
		var i = 0
		var p = null
#		if op[0] >= '0' and op[0] <= '9':
#			p = get_node(op.substr(1))
#			p.visible = false
#			var g = p.get_index()
#			get_child(g+1).visible = false
		
		var num_n = 0
		while op[num_n] >= '0' and op[num_n] <= '9':
			num_n += 1
		if num_n:
			p = get_node(op.substr(num_n))
			p.visible = false
			var g = p.get_index()
			get_child(g+1).visible = false
		else:
			p = get_node(op)
		p = p.get_popup()
		p.connect('id_pressed', self, "doop", [op, p])
		for item in operations[op]:
			if len(item) == 0:
				p.add_separator('')
			elif len(item[1]) > 0:
				if item[1][0] is PopupMenu:
					var s = item[0]
					var np = item[1][0]
					np.set_name(s)
					np.connect('id_pressed', self, item[2], [np])
					if s == 'Advanced':
						for f in get_tree().get_nodes_in_group('App')[0].f_prefixes:
							np.add_check_item('Show ' + f.substr(0,len(f)-1))
					elif len(item[1]) > 1:
						np.set_name(s)
						np.connect('id_pressed', self, item[2], [np])
#						np.connect('id_pressed', self, "doop", [op, p])
						for o in item[1][1]:
							np.add_item(o[0])
					else:
						for recent in get_tree().get_nodes_in_group('App')[0].recent_patches:
							np.add_item('.../' + recent.get_file())
					p.add_child(np)
					p.add_submenu_item(item[0], s)
				elif item[1][0] is String and item[1][0] == 'TOGGLE':
					p.add_item(item[0], i)
					p.set_item_as_checkable(i, true)
				else:
					p.add_item(item[0], i)
					p.set_item_shortcut(i, set_shortcut(item[1]))
			else:
				p.add_item(item[0], i)
				
			i += 1

# Function that makes a shortcut
func set_shortcut(keys):
	if len(keys) == 0:
		return null
	# Creates ShortCut and InputKeyEvent
	var shortcut = ShortCut.new()
	var inputeventkey = InputEventKey.new()
	# Sets the scanned key and uses control as the preceding command
	inputeventkey.set_scancode(keys[len(keys)-1])
	if OS.get_name() == 'OSX' and !(KEY_H in keys):
		inputeventkey.command = KEY_CONTROL in keys
	else:
		inputeventkey.control = KEY_CONTROL in keys
	inputeventkey.shift = KEY_SHIFT in keys
	# Makes the final shortcut and returns it
	shortcut.set_shortcut(inputeventkey)
	return shortcut

func doop(id, op, p:PopupMenu):
	var num_n = 0
	while op[num_n] >= '0' and op[num_n] <= '9':
		num_n += 1
	if num_n and !get_node(op.substr(num_n)).visible: return
	if has_method(operations[op][id][2]):
		call(operations[op][id][2])
	else:
		app.get_node('NotImplementedYetDialog').popup()
	if len(operations[op][id][1]) == 1 and operations[op][id][1][0] == 'TOGGLE':
		p.set_item_checked(id, !p.is_item_checked(id))
	if app.editor_tabs.get_current_tab_control():
		app.editor_tabs.get_current_tab_control().grab_focus()

func quit():
	get_tree().quit()

func openrecentpatch(id, popup):
	var a = get_tree().get_nodes_in_group('App')[0]
	a._on_OpenPatchDialog_file_selected(a.recent_patches[id])



func openpatch():
#	var w :FileDialog= app.get_node("ImportantPopups/OpenPatchDialog")
#	app.get_node("ImportantPopups").show()
#	w.popup()
#	w.invalidate()
	NativeDialog.popup_open_dialog("Open A Patchwad", ["*.patchwad ; Patchwad Archive"], app, '_on_OpenPatchDialog_file_selected')

func savepatch():
#	var w :FileDialog= app.get_node("ImportantPopups/SavePatchDialog")
#	app.get_node("ImportantPopups").show()
#	w.popup()
#	w.invalidate()
	NativeDialog.popup_save_dialog(
		"Save Patchwad",
		["*.patchwad ; Patchwad Archive"],
		'mod.patchwad',
		app, '_on_SavePatchDialog_file_selected'
	)
	
#func savepatchas():
#	pass
#
func importpatch():
	#app.get_node("ImportWadFileDialog").popup()
	var w = app.get_node("ImportantPopups/ImportPatchWindowDialog")
	NativeDialog.popup_open_dialog(
		"Open Patchwad to Import from",
		["*.patchwad ; Patchwad Archive", "*.wad ; WAD Archive"],
		w, '_on_ImportWadFileDialog_file_selected'
	)

func mergepatch():
	app.get_node("ImportantPopups").show()
	var nw = app.get_node("ImportantPopups/MergePatchDialog")
	nw.src_patch = app.base_wad
	nw.dest_patch = app.base_wad
	nw._on_Label2_item_selected(0)
	nw._on_Label4_item_selected(0)
	nw.popup()

func openwad():
#	var w = app.get_node("OpenWadDialog")
#	w.popup()
#	w.invalidate()
	NativeDialog.popup_open_dialog(
		"Select a Base WAD to reference",
		["*.wad ; WAD Archive"],
		app, '_on_OpenWadDialog_file_selected'
	)
	
func extract(resource_data=null):
	var w :FileDialog= app.get_node("ImportantPopups/ExtractResourceDialog")
	w.current_file = app.selected_asset_name.get_file()
	var d = NativeDialog.popup_save_dialog(
		"Save HLM2 Resource to a file",
		['* ; Any File'],
		app.selected_asset_name.get_file(),
		w,'_on_ExtractResourceDialog_file_selected',
		false
	)
	if !resource_data:
		resource_data = app.selected_asset_data
	w.r = resource_data
	if resource_data is BinParser:
		d.add_filter('*.bin ; Binary File')
	elif resource_data is Meta:
		d.add_filter('*.meta ; Meta Sprite Atlas')
		if w.current_file=='':w.current_file = '.meta'
	elif resource_data is Texture:
		d.add_filter('*.png ; Image File')
		d.initial_path = d.initial_path.replace('.meta', '.png')
	elif resource_data is WadSound:
		d.add_filter('*.' + app.selected_asset_name.get_extension() + ' ; Audio File')
	else:
		app.get_node('NotImplementedYetDialog').popup()
	d.show()

func room_add_object():
	app.room_editor_node.add_generic_object()

func add():
	# TODO: DEPRECATED
	var w :FileDialog= app.get_node("ImportantPopups/AddResourceDialog")
	app.get_node("ImportantPopups").show()
	w.popup()
	w.invalidate()

func replace():
	var w :FileDialog= app.get_node("ImportantPopups/ReplaceResourceDialog")
	var d = NativeDialog.popup_open_dialog(
		"Save HLM2 Resource to a file",
		['* ; Any File'],
		w,'_on_ReplaceResourceDialog_file_selected',
		false
	)
	var resource_data = app.selected_asset_data
	if resource_data is BinParser:
		d.add_filter('*.bin ; Binary File')
	elif resource_data is Meta:
		d.add_filter('*.meta ; Meta Sprite Atlas')
		if w.current_file=='':w.current_file = '.meta'
	elif resource_data is Texture:
		d.add_filter('*.png ; Image File')
	elif resource_data is WadSound:
		d.add_filter('*.' + app.selected_asset_name.get_extension() + ' ; Audio File')
	else:
		app.get_node('NotImplementedYetDialog').popup()
	w.r = app.selected_asset_data
	d.show()

func revert():
	var f = app.selected_asset_list_path
	if app.selected_asset_data is Meta:
		app.base_wad.revert(f.replace('.'+f.get_extension(), '.png'))
	if app.selected_asset_data is WadFont:
		app.base_wad.revert(f.replace('.'+f.get_extension(), '_0.png'))
	app.base_wad.revert(f)
	app.open_asset(f)

func revertsprite():
	var spr : String = app.meta_editor_node.current_sprite
	var dst_m : Meta = app.selected_asset_data
	var src_m : Meta = app.base_wad.parse_orginal_meta(app.selected_asset_name)
	var dst_fc : int = dst_m.sprites.get_frame_count(spr)
	var src_fc : int = src_m.sprites.get_frame_count(spr)
	var recalc_needed = src_fc > dst_fc
	if recalc_needed:
		var yes = yield(ErrorLog.show_user_confirmation("Original Sprite contains more frames than the current Sprite.\nDo you want to recalculate the sprite sheet or abort this operation?"), "choice_made")
		if not yes: return
	# blit original sprite onto current sprite sheet
	if not recalc_needed:
		# remove extra sprites from dest sprite if its bigger than original
		for i in range(dst_fc - src_fc):
			dst_m.sprites.remove_frame(spr, 0)
		for i in range(src_fc):
			var src_f : MetaTexture = src_m.sprites.get_frame(spr, i)
			var dst_f : MetaTexture = dst_m.sprites.get_frame(spr, i)
			dst_m.texture_page.get_data().blit_rect(src_f.get_data(), src_f.region, dst_f.region.position)
	# else recalculate spritesheet
	else:
		for i in range(dst_fc):
			dst_m.sprites.remove_frame(spr, 0)
		for i in range(src_fc):
			dst_m.sprites.add_frame(spr, src_m.sprites.get_frame(spr, i))
		app._on_RecalculateSheetButton_pressed()
	# change dst_meta sprite's frames to match original
	# reset sprite entry in sprites bin if sprites bin changed

func toggleassetlist():
	app.asset_tree_container.visible = !app.asset_tree_container.visible
func expandassetlist(t:TreeItem=null):
	if t == null:
		t = app.asset_tree.root
	t.collapsed = false
	var tc = t.get_children()
	while tc != null:
		expandassetlist(tc)
		tc = tc.get_next()

func togglenewfileslist():
	app.show_base_wad = !app.show_base_wad
	app._on_SearchBar_text_entered('')

func toggleadvanced(id, popup:PopupMenu):
	app.advanced_stuff_filter[app.advanced_stuff_filter.keys()[id]] = !app.advanced_stuff_filter[app.advanced_stuff_filter.keys()[id]]
	popup.set_item_checked(id, app.advanced_stuff_filter[app.advanced_stuff_filter.keys()[id]])
	app._on_SearchBar_text_entered('')

func togglemetagizmos():
	if app.editor_tabs.current_tab != 9:
		app.meta_editor_node.gizmos_node.visible = !app.meta_editor_node.gizmos_node.visible
		app.meta_editor_node.frametexturerect.update()
		return
		
	app.ags_editor_node.gizmos_node.visible = !app.ags_editor_node.gizmos_node.visible
	app.ags_editor_node.frametexturerect.update()

func togglecollisiongizmo():
	if app.editor_tabs.current_tab != 9:
		app.meta_editor_node.show_collision_mask = !app.meta_editor_node.show_collision_mask
		app.meta_editor_node.frametexturerect.update()
		app.meta_editor_node.timeline.update_pos(app.meta_editor_node.timeline.current_time)
		return

func convertmeta():
	var nm = app.meta_editor_node.meta
	nm.convert_to_gmeta(app.base_wad.get_bin(SpritesBin))
	var nfn = app.selected_asset_name.replace('.meta','.gmeta')
#	app.base_wad.changed_files[nfn] = nm
	app.base_wad.new_files[nfn] = nm
#	for p in app.base_wad.patchwad_list:
	app.base_wad.loaded_assets[nfn] = nm
	app.meta_editor_node.meta = app.base_wad.parse_orginal_meta(app.selected_asset_name)
#	app._on_SearchBar_text_entered('')
	app.asset_tree.create_path(nfn,1).select(0)
	app.asset_tree.update()

func export_sprite_gif():
	var w :FileDialog= app.get_node("ImportantPopups/SaveGIFDialog")
	var nw = app.get_node("ImportantPopups/SaveGIFDialog2")
	var meta = app.meta_editor_node.meta
	nw.meta = meta
	nw.sprite = app.meta_editor_node.current_sprite
	
#	w.get_line_edit().text = app.meta_editor_node.current_sprite+'.gif'
	NativeDialog.popup_save_dialog(
		"Save Sprite to GIF",
		['*.gif ; GIF Animation'],
		app.meta_editor_node.current_sprite+'.gif',
		nw, '_on_SaveGIFDialog_file_selected'
	)

func export_sprite_strip():
	app._on_ExportSpriteStripButton_pressed()
func export_sprite_strips():
	app.export_sprite_strips()
func import_sprite_strip():
	app._on_importSpriteStripButton_pressed()

func recalcspritesheet():
	app._on_RecalculateSheetButton_pressed()

func recalccollisionmasks():
	if app.selected_asset_data is Meta:
		app._recalc_collision()
		

func exportspritesheet():
	extract(app.selected_asset_data.texture_page)
func importspritesheet():
	var w :FileDialog= app.get_node("ImportantPopups/ImportSheetDialog")
	app.get_node("ImportantPopups").show()
	w.popup()
	w.invalidate()

func resize_sprite():
	var meta :Meta= app.meta_editor_node.meta
	if meta != app.selected_asset_data:
		return
	var w = app.get_node("ResizeSpriteDialog")
	w.current_tex_dim = meta.texture_page.get_size()
	app.get_node("ResizeSpriteDialog/VBoxContainer/SpriteNameLabel").text = app.meta_editor_node.current_sprite
	var f :MetaTexture= meta.sprites.get_frame(app.meta_editor_node.current_sprite, 0)
	app.get_node('ResizeSpriteDialog/VBoxContainer/GridContainer/WidthSpinBox').value = f.region.size.x
	app.get_node('ResizeSpriteDialog/VBoxContainer/GridContainer/HeightSpinBox').value = f.region.size.y
	app.get_node('ResizeSpriteDialog/VBoxContainer/GridContainer/FrameCountSpinBox').value = meta.sprites.get_frame_count(app.meta_editor_node.current_sprite)
	app.get_node('ResizeSpriteDialog/VBoxContainer/TextureRect/MarginContainer/TextureRect').texture = meta.sprites.get_frame(app.meta_editor_node.current_sprite, 0)
	w.popup()

func resize_spritesheet():
	var meta :Meta= app.meta_editor_node.meta
	if meta != app.selected_asset_data:
		return
	var w = app.get_node("ResizeSpriteSheetDialog")
	w.current_tex_dim = meta.texture_page.get_size()
	app.get_node("ResizeSpriteSheetDialog/VBoxContainer/SpriteNameLabel").text = app.selected_asset_name.replace('.meta', '.png')
	app.get_node('ResizeSpriteSheetDialog/VBoxContainer/GridContainer/WidthSpinBox').value = w.current_tex_dim.x
	app.get_node('ResizeSpriteSheetDialog/VBoxContainer/GridContainer/HeightSpinBox').value = w.current_tex_dim.y
	app.get_node('ResizeSpriteSheetDialog/VBoxContainer/TextureRect/MarginContainer/TextureRect').texture = meta.texture_page
	w.popup()

func importsound():
	var mode = "*.*"
	if app.sound_editor_node.sound.stream is AudioStreamSample:
		mode = "*.wav ; WAV Audio files"
	elif app.sound_editor_node.sound.stream is AudioStreamMP3:
		mode = "*.mp3 ; MP3 Audio files"
	elif app.sound_editor_node.sound.stream is AudioStreamOGGVorbis:
		mode = "*.ogg ; OGG Audio files"
	var w :FileDialog= app.get_node("ImportantPopups/ImportSoundDialog")
	w.clear_filters()
	w.add_filter(mode)
	app.get_node("ImportantPopups").show()
	w.popup()
	w.invalidate()

func _on_TabContainer_tab_changed(tab):
	var i = 2
	for op in operations.keys():
		var num_n = 0
		while op[num_n] >= '0' and op[num_n] <= '9':
			num_n += 1
		if num_n:
#			get_node(op.substr(num_n)).visible = false
#			get_node('Divider'+str(i)).visible = false
			var p = get_node(op.substr(num_n))
			var g = p.get_index()
			p.visible = false
			get_child(g+1).visible = false
		for j in range(num_n):
			if op[j] == str(tab):
				var p = get_node(op.substr(num_n))
				var g = p.get_index()
				p.visible = true
				get_child(g+1).visible = true
		i += 1


func _on_exportbutton_pressed():
	exportspritesheet()

func _on_importbutton_pressed():
	importspritesheet()
