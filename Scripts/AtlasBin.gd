extends BinParser

class_name AtlasesBin

const file_path = 'GL/hlm2_atlases.bin'
var atlas_data = {}
var atlases_backgrounds = {}
var atlas_sprites = {}
var name_indicies = []
var atlas_names = {}

var atl = {
	'id': '32',
	'atlas_id':'32'
}

func parse(file_pointer):
	var f = file_pointer
	name_indicies = parse_index_list(f)
	atlas_names = parse_string_map(f)
	# sprite bin data is the same size as this :0
	atlas_sprites = parse_struct_list(f, atl)
	atlases_backgrounds = parse_struct_list(f, atl)
	for atlas in atlas_sprites + atlases_backgrounds:
		var id = atlas['id']
		var s = atlas_names.values()[id]
		var v = atlas
		if atlas_data.has(s):
			if atlas_data[s] is Array:
				atlas_data[s].append(v)
			else:
				atlas_data[s] = [atlas_data[s], v]
		else:
			atlas_data[s] = v
	data = atlas_data
	names = atlas_names

func write(f):
	write_simple_list(f, name_indicies)
	write_string_list(f, atlas_names.values())
	write_struct_list(f, atl, atlas_sprites.values())
	write_struct_list(f, atl, atlases_backgrounds.values())
