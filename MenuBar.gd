extends Control

onready var app = get_tree().get_nodes_in_group('App')[0]

var operations = {
	"FileButton" : [
		["Open Patch", [KEY_CONTROL, KEY_O], 'openpatch'],
		["Save Patch", [KEY_CONTROL,KEY_S,], 'savepatch'],
		["Save Patch as", [KEY_CONTROL, KEY_SHIFT, KEY_S], 'savepatchas'],
		["Recent Patches", [PopupMenu.new()], 'openrecentpatch'],
		[],
		["Import from Patch", [KEY_CONTROL, KEY_I], 'importpatch'],
		[],
		["Switch Base Wad", [KEY_CONTROL, KEY_SHIFT, KEY_O], 'openwad'],
		[],
		["Quit", [KEY_CONTROL, KEY_Q], 'quit'],
	],
	"ResourceButton" : [
		["Extract", [KEY_CONTROL, KEY_E], 'extract'],
#		["Replace", [KEY_CONTROL, KEY_R,], 'replace'],
		["Revert", [KEY_CONTROL, KEY_SHIFT, KEY_R], 'revert'],
#		[],
#		["Add", [KEY_CONTROL, KEY_SHIFT, KEY_A], 'add'],
#		["Merge", [KEY_CONTROL, KEY_M], 'merge'],
	],
	"ViewButton" : [
		["Show Only Modified Files", ['TOGGLE'], 'togglenewfileslist'],
		["Expand Asset List", [], 'expandassetlist'],
		[],
		["Toggle Asset List", [KEY_CONTROL, KEY_H], 'toggleassetlist'],
		["Advanced", [PopupMenu.new()], 'toggleadvanced'],
	],
	"1MetaButton" : [
		["Import Sprite Strip", [KEY_SHIFT, KEY_I], 'import_sprite_strip'],
		["Export Sprite Strip", [KEY_SHIFT, KEY_E], 'export_sprite_strip'],
		["Export Sprite to GIF", [], 'export_sprite_gif'],
		["Export All Sprites", [], 'export_sprite_strips'],
		[],
		["Toggle Gizmos", [KEY_SHIFT, KEY_G], 'togglemetagizmos'],
		[],
		["Resize Sprite", [], 'resize_sprite'],
#		["Extras", [PopupMenu.new(),[
#			["Convert to GMeta", [], 'convertmeta'],
#			["Add Sprite", [], 'convertmeta'],
#		]], ''],
	],
	"18SpriteSheetButton" : [
		["Import Texture Page", [], 'importspritesheet'],
		["Export Texture Page", [], 'exportspritesheet'],
		[],
		["Recalculate Texture Page", [], 'recalcspritesheet'],
	],
	"8FontButton" : [
		["Import Character", [], 'na'],
		["Export Character", [], 'na'],
	],
	"7SoundButton" : [
		["Import Sound", [], 'na'],
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
	if OS.get_name() == 'OSX':
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

func quit():
	get_tree().quit()

func openrecentpatch(id, popup):
	var a = get_tree().get_nodes_in_group('App')[0]
	a._on_OpenPatchDialog_file_selected(a.recent_patches[id])

func openpatch():
	var w :FileDialog= app.get_node("ImportantPopups/OpenPatchDialog")
	app.get_node("ImportantPopups").show()
	w.popup()

func savepatch():
	var w :FileDialog= app.get_node("ImportantPopups/SavePatchDialog")
	app.get_node("ImportantPopups").show()
	w.popup()
	
#func savepatchas():
#	pass
#
#func importpatch():
#	pass
	
func openwad():
	app.get_node("OpenWadDialog").popup()
	
func extract(resource_data=null):
	var w :FileDialog= app.get_node("ImportantPopups/ExtractResourceDialog")
	app.get_node("ImportantPopups").show()
	w.clear_filters()
	if !resource_data:
		resource_data = app.selected_asset_data
	w.r = resource_data
	if resource_data is BinParser:
		w.add_filter('*.bin')
	elif resource_data is Meta:
		w.add_filter('*.meta')
		w.add_filter('*.gmeta')
		if w.filename=='':w.filename = '.meta'
	elif resource_data is Texture:
		w.add_filter('*.png')
	else:
		app.get_node('NotImplementedYetDialog').popup()
	w.popup()

func add():
	var w :FileDialog= app.get_node("ImportantPopups/AddResourceDialog")
	app.get_node("ImportantPopups").show()
	w.popup()

#func replace():
#	pass
#
func revert():
	var f = app.selected_asset_list_path
	if app.selected_asset_data is Meta:
		app.base_wad.revert(f.replace('.'+f.get_extension(), '.png'))
	if app.selected_asset_data is WadFont:
		app.base_wad.revert(f.replace('.'+f.get_extension(), '_0.png'))
	app.base_wad.revert(f)
	app.open_asset(f)
#
#func merge():
#	pass

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
	app.meta_editor_node.gizmos_node.visible = !app.meta_editor_node.gizmos_node.visible
	app.meta_editor_node.frametexturerect.update()

func convertmeta():
	var nm = app.meta_editor_node.meta
	nm.convert_to_gmeta(app.base_wad.spritebin)
	var nfn = app.selected_asset_name.replace('.meta','.gmeta')
#	app.base_wad.changed_files[nfn] = nm
	app.base_wad.new_files[nfn] = nm
#	for p in app.base_wad.patchwad_list:
	app.base_wad.loaded_assets[nfn] = nm
	app.meta_editor_node.meta = app.base_wad.parse_orginal_meta(app.selected_asset_name)
#	app._on_SearchBar_text_entered('')
	app.asset_tree.create_path(nfn,1).select(0)

func export_sprite_gif():
	var w :FileDialog= app.get_node("ImportantPopups/SaveGIFDialog")
	var nw = app.get_node("ImportantPopups/SaveGIFDialog2")
	app.get_node("ImportantPopups").show()
	var meta :Meta= app.meta_editor_node.meta
	nw.meta = meta
	nw.sprite = app.meta_editor_node.current_sprite
	w.popup()

func export_sprite_strip():
	app._on_ExportSpriteStripButton_pressed()
func export_sprite_strips():
	app.export_sprite_strips()
func import_sprite_strip():
	app._on_importSpriteStripButton_pressed()

func recalcspritesheet():
	app._on_RecalculateSheetButton_pressed()

func exportspritesheet():
	extract(app.selected_asset_data.texture_page)
func importspritesheet():
	var w :FileDialog= app.get_node("ImportantPopups/ImportSheetDialog")
	app.get_node("ImportantPopups").show()
	w.popup()

func resize_sprite():
	var meta :Meta= app.meta_editor_node.meta
	if meta != app.selected_asset_data:
		return
	var w = app.get_node("ResizeSpriteDialog")
	app.get_node("ResizeSpriteDialog/VBoxContainer/SpriteNameLabel").text = app.meta_editor_node.current_sprite
	var f :MetaTexture= meta.sprites.get_frame(app.meta_editor_node.current_sprite, 0)
	app.get_node('ResizeSpriteDialog/VBoxContainer/GridContainer/WidthSpinBox').value = f.region.size.x
	app.get_node('ResizeSpriteDialog/VBoxContainer/GridContainer/HeightSpinBox').value = f.region.size.y
	app.get_node('ResizeSpriteDialog/VBoxContainer/GridContainer/FrameCountSpinBox').value = meta.sprites.get_frame_count(app.meta_editor_node.current_sprite)
	app.get_node('ResizeSpriteDialog/VBoxContainer/TextureRect/MarginContainer/TextureRect').texture = meta.sprites.get_frame(app.meta_editor_node.current_sprite, 0)
	w.popup()

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
