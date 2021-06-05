extends Control

var operations = {
	"FileButton" : [
		["Open Patch", [KEY_CONTROL, KEY_O]],
		["Save Patch", [KEY_CONTROL,KEY_S,]],
		["Save Patch as", [KEY_CONTROL, KEY_SHIFT, KEY_S]],
		["Recent Patches", []],
#		[],
#		["Import Patch", [KEY_CONTROL,'i']],
		[],
		["Switch Base Wad", [KEY_CONTROL, KEY_SHIFT, KEY_O]],
	],
	"ResourceButton" : [
		["Extract", [KEY_CONTROL, KEY_E]],
		["Replace", [KEY_CONTROL, KEY_R,]],
		["Revert", [KEY_CONTROL, KEY_SHIFT, KEY_R]],
		[],
		["Merge", [KEY_CONTROL, KEY_M]],
	]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for op in operations.keys():
		var i = 0
		var p :PopupMenu= get_node(op).get_popup()
		for item in operations[op]:
			if len(item) == 0:
				p.add_separator('')
			elif len(item[1]) == 0:
				p.add_submenu_item(item[0], item[0])
			else:
				p.add_item(item[0], i)
				p.set_item_shortcut(i, set_shortcut(item[1]))
			i += 1

# Function that makes a shortcut
func set_shortcut(keys):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
