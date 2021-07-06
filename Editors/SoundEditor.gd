extends BinEditor

#onready var app = get_tree().get_nodes_in_group('App')[0]
onready var sound_tree = $TabContainer2/Advanced/SoundTree

var sounds = null
var sound = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	file = SoundsBin.file_path
	tree = sound_tree
	pass # Replace with function body.


func set_sound(sound_name):
	set_bin_asset(sound_name)
#	sound_tree.reset()
	sounds = bin #app.base_wad.soundbin
	sound = selected_struct #sounds.sound_data[sound_name]
#	sound_tree.create_dict(sound)
	return sounds

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
#		var sound_index = value
#		if bin.data.has(new_text_value):
#			sound_index = bin.data[new_text_value]['id']
#		if bin.names.has(can_be_int_fuck_you_godot(new_text_value)):
#			sound_index = can_be_int_fuck_you_godot(new_text_value)
#		return [sound_index, bin.names[sound_index]]
#	return [value, new_text_value]

func _on_SoundTree_item_edited(deleted=0):
	_on_Tree_item_edited(deleted)
	return


func change_order(_room, new_next, new_previous):
	sounds.sound

