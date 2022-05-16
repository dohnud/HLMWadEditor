extends "res://Scripts/Asset Scripts/AtlasesBin.gd"

class_name phyreAtlasesBin

#const file_path = 'GL/hlm2_sprites.bin'
#const alt_file_path = 'GL/hotline_sprites.bin'
static func get_file_path():
	return "GL/hotline_atlases.bin"

func to_string():
	return "GL/hotline_atlases.bin"

#var atl = {
#	'id': '32',
#	'atlas_id':'32'
#}

func parse(file_pointer):
	var f = file_pointer
#	name_indicies = parse_index_list(f)
#	atlas_names = parse_string_map(f)
	# sprite bin data is the same size as this :0
	atlas_names = []
	var atlas_num = f.get_32()
	for i in range(atlas_num):
#		atlas_names.append("AssetScripts/"+f.get_buffer(88).get_string_from_ascii())
#		"f/furniture.ags.phyre"
		atlas_names.append(f.get_buffer(88).get_string_from_ascii().substr(2))
	atlas_sprites = parse_simple_list(f)
#	print(atlases_backgrounds)
	for i in range(len(atlas_sprites)):
		var id = i
		var v = atlas_sprites[i]
		var s = str(atlas_names[v])
		if atlas_data.has(id):
			if atlas_data[id] is Array:
				atlas_data[id].append(id)
			else:
				atlas_data[id] = [atlas_data[id], v]
		else:
			atlas_data[id] = v
#		print(id, ' ',v ,' ', s)
#	for k in atlas_data.keys():
#		print(k,' ', atlas_data[k])
	data = atlas_data
	names = atlas_names

func write(f):
#	write_simple_list(f, name_indicies)
	f.store_32(len(atlas_names))
	for _name in atlas_names:
		f.store_string(_name)
		for i in range(88-len(_name)):
			f.store_8(0)
	write_simple_list(f, atlas_sprites)
