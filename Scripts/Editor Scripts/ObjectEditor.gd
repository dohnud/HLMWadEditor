extends BinEditor

#onready var app = get_tree().get_nodes_in_group('App')[0]
onready var object_tree = $TabContainer2/Advanced/ObjectTree

var objects = null
var object = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	file = ObjectsBin
	filetype = ObjectsBin
	tree = object_tree
	pass # Replace with function body.


func set_object(object_name):
	set_bin_asset(object_name)
	$Label.text = object_name
#	object_tree.reset()
	objects = bin #app.base_wad.objectbin
	object = selected_struct #objects.object_data[object_name]
#	object_tree.create_dict(object)
	return objects


func parse_new_value(key, value, new_text_value):
	if key == 'sprite_index' or key == 'mask_sprite':
		var sprite_index = value
		if int(new_text_value) == -1 or new_text_value=='Null':
			return [-1, 'Null']
		# sets sprite index from name
		if app.base_wad.get_bin(SpritesBin).sprite_data.has(new_text_value):
			sprite_index = app.base_wad.get_bin(SpritesBin).sprite_data[new_text_value]['id']
		# sets sprite index from index
		elif (int(new_text_value) or new_text_value=='0') and app.base_wad.get_bin(SpritesBin).sprites.has(int(new_text_value)):
			sprite_index = int(new_text_value)
		if app.base_wad.get_bin(SpritesBin).sprites.has(sprite_index):
			return [sprite_index, app.base_wad.get_bin(SpritesBin).sprites[sprite_index]['name']]
	if key == 'parent':
		var object_index = value
		if bin.data.has(new_text_value):
			object_index = bin.data[new_text_value]['id']
		if can_be_int_fuck_you_godot(new_text_value) != null and bin.names.has(can_be_int_fuck_you_godot(new_text_value)):
			object_index = can_be_int_fuck_you_godot(new_text_value)
		return [object_index, bin.names[object_index]]
	return [value, new_text_value]

func _on_ObjectTree_item_edited(deleted=0):
	_on_Tree_item_edited(deleted)
	return


func change_order(_room, new_next, new_previous):
	objects.object
