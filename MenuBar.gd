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
	],
	"ResourceButton" : [
		["Extract", [KEY_CONTROL, KEY_E], 'extract'],
		["Replace", [KEY_CONTROL, KEY_R,], 'replace'],
		["Revert", [KEY_CONTROL, KEY_SHIFT, KEY_R], 'revert'],
		[],
		["Add", [KEY_CONTROL, KEY_SHIFT, KEY_A], 'add'],
#		["Merge", [KEY_CONTROL, KEY_M], 'merge'],
	],
	"ViewButton" : [
		["Toggle Asset List", [KEY_CONTROL, KEY_H], 'toggleassetlist'],
		["Show Modified Files", ['TOGGLE'], 'togglenewfileslist'],
	],
#	"MetaButton" : [
#		["Toggle Bounding Box", [], 'togglemetaboundingbox'],
#		["Toggle Origin Gizmo", [], 'togglemetaorigingizmo'],
#	]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for op in operations.keys():
		var i = 0
		var p :PopupMenu= get_node(op).get_popup()
		p.connect('id_pressed', self, "doop", [op])
		for item in operations[op]:
			if len(item) == 0:
				p.add_separator('')
			elif len(item[1]) > 0:
				if item[1][0] is PopupMenu:
					var s = item[0]
					var np = item[1][0]
					np.set_name(s)
					np.connect('id_pressed', self, item[2])
					for recent in get_tree().get_nodes_in_group('App')[0].recent_patches:
						np.add_item('.../' + recent.get_file())
					p.add_child(np)
					p.add_submenu_item(item[0], s)
				elif item[1][0] is String and item[1][0] == 'TOGGLE':
					p.add_item(item[0], i)
					p.set_item_as_checkable(i, false)
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
	inputeventkey.control = KEY_CONTROL in keys
	inputeventkey.shift = KEY_SHIFT in keys
	# Makes the final shortcut and returns it
	shortcut.set_shortcut(inputeventkey)
	return shortcut

func doop(id, op):
	call(operations[op][id][2])
	print(id)

func openrecentpatch(id):
#	get_tree().get_nodes_in_group('App')[0].recent_patches
	print(id)

func openpatch():
	var w :FileDialog= app.get_node("ImportantPopups/OpenPatchDialog")
	app.get_node("ImportantPopups").show()
	w.popup()
	
func savepatch():
	pass
	
func savepatchas():
	pass
	
func openwad():
	pass
	
func extract():
	var w :FileDialog= app.get_node("ImportantPopups/ExtractResourceDialog")
	app.get_node("ImportantPopups").show()
	w.clear_filters()
	w.popup()
	if app.selected_asset_data is BinParser:
		w.add_filter('*.bin')
	elif app.selected_asset_data is Meta:
		w.add_filter('*.meta')
		w.add_filter('*.gmeta')

func add():
	var w :FileDialog= app.get_node("ImportantPopups/AddResourceDialog")
	app.get_node("ImportantPopups").show()
	w.popup()

func replace():
	pass
	
func revert():
	pass
	
func merge():
	pass

func toggleassetlist():
	app.asset_tree_container.visible = !app.asset_tree_container.visible

func togglenewfileslist():
	app.show_base_wad = !app.show_base_wad
	app._on_SearchBar_text_entered('')
