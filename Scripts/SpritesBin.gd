extends BinParser

class_name SpritesBin

const file_path = 'GL/hlm2_sprites.bin'
var sprite_data = {}
var sprites = {}
var sprite_indicies = []
var sprite_names = {}

var spr = {
	'id' : '32',
	'size' : 'ivec2',
	'center' : 'ivec2',
	'mask_x_bounds' : 'ivec2',
	'mask_y_bounds' : 'ivec2',
	'frame_count' : '32',
	'flags': [0x10],
	'name_pos' : '32',
	'padding' : '32'
}

func parse(file_pointer):
	var f = file_pointer
	sprite_indicies = parse_index_list(f)
	sprites = parse_struct_map(f, spr, 'id')
	sprite_names = parse_string_map(f)
	for sprite in sprites.values():
		var s = sprite_names[sprite['name_pos']]
		sprite['name'] = s
		sprite_data[s] = sprite
	data = sprite_data
	names = sprite_names.values()
#	sprite_data['default'] = {
#		'id' : -1,
#		'dimesions' : [1,1],
#		'center' : Vector2(0,0),
#		'frame_count' : 1,
#	}

func write(f):
	write_simple_list(f, sprite_indicies)
#	sprite_data.erase('default')
	write_struct_list(f, spr, sprite_data.values())
	write_string_list(f, sprite_names.values())
