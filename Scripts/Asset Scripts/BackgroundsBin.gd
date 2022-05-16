extends BinParser

class_name BackgroundsBin

var version = 2
static func get_file_path():
	return 'GL/hlm2_backgrounds.bin'
var background_data = {}
var background_indicies = []
var background_names = {}

var bg = {
	'id' : '32',
	'name_pos' : '32',
	'm2' : '32',
	'tile_size' : 'ivec2',
	'pre_slice' : '32',
	'size' : 'ivec2',
}

func parse(file_pointer):
	var f = file_pointer
	background_indicies = parse_index_list(f)
	var backgrounds = parse_struct_list(f, bg)
	background_names = parse_string_map(f)
	for background in backgrounds:
		var s = background_names[background['name_pos']]
		background_data[s] = background
	data = background_data
#	background_data['default'] = {
#		'id' : -1,
#		'dimesions' : [1,1],
#		'center' : Vector2(0,0),
#		'frame_count' : 1,
#	}

func write(f):
	write_simple_list(f, background_indicies)
#	background_data.erase('default')
	write_struct_list(f, bg, background_data.values())
	write_string_list(f, background_names.values())
