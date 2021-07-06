extends BinEditor

#onready var app = get_tree().get_nodes_in_group('App')[0]
onready var atlas_tree = $TabContainer2/Advanced/AtlasTree

var atlases = null
var atlas = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	file = AtlasesBin.file_path
	tree = atlas_tree
	pass # Replace with function body.


func set_atlas(atlas_name):
	set_bin_asset(atlas_name)
#	atlas_tree.reset()
	atlases = bin #app.base_wad.atlasbin
	atlas = selected_struct #atlass.atlas_data[atlas_name]
#	atlas_tree.create_dict(atlas)
	return atlases

#
#func parse_new_value(key, value, new_text_value):
#	if key == 'sprite_index' or key == 'mask_sprite':
#		var sprite_index = value
#		if int(new_text_value) == -1 or new_text_value=='Null':
#			return [-1, 'Null']
#		# sets sprite index from name
#		if app.base_wad.spritebin.sprite_data.has(new_text_value):
#			sprite_index = app.base_wad.spritebin.sprite_data[new_text_value]['id']
#		# sets sprite index from index
#		elif (int(new_text_value) or new_text_value=='0') and app.base_wad.spritebin.sprites.has(int(new_text_value)):
#			sprite_index = int(new_text_value)
#		if app.base_wad.spritebin.sprites.has(sprite_index):
#			return [sprite_index, app.base_wad.spritebin.sprites[sprite_index]['name']]
#	if key == 'parent':
#		var atlas_index = value
#		if bin.data.has(new_text_value):
#			atlas_index = bin.data[new_text_value]['id']
#		if bin.names.has(can_be_int_fuck_you_godot(new_text_value)):
#			atlas_index = can_be_int_fuck_you_godot(new_text_value)
#		return [atlas_index, bin.names[atlas_index]]
#	return [value, new_text_value]

func _on_AtlasTree_item_edited(deleted=0):
	_on_Tree_item_edited(deleted)
	return


func change_order(_room, new_next, new_previous):
	atlases.atlas


