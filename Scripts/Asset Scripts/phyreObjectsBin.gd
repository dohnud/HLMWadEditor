extends "res://Scripts/Asset Scripts/ObjectsBin.gd"

class_name phyreObjectsBin

#const file_path = 'GL/hlm2_sprites.bin'
#const alt_file_path = 'GL/hotline_sprites.bin'
static func get_file_path():
	return 'GL/hotline_objects.bin'
func _to_string():
	return 'GL/hotline_objects.bin'

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _init() :
	obj = {
	#			'nameindex' : object_name_indicies[id],
		'id' : '32',
		'sprite_index' : 's32',
		'depth' : 's32',
		'parent' : 's32',
		'mask_sprite' : 's32',
		'solid' : '32',
		'visible' : '32',
		'persistent' : '32',
		'priority' : '64',
	#			'extra flags' : [f.get_32(), f.get_32()],
#		'name_pos' : '32'
	}


func get_objects():
	return object_data.keys()

func parse(f):
	var t_pos = f.get_position()
	name_indicies = parse_index_list(f)
	var objects = parse_struct_list(f, obj)
#	var name_positions = parse_string_map(f)
	for object in objects:
#		var s = name_positions[object['name_pos']]
		var s = str(object['id'])
		object_data[s] = object
		object_names[object['id']] = s
	data = object_data
	names = object_names
	file_size = f.get_position() - t_pos


func write(f):
	write_simple_list(f, name_indicies)
	var t = {}
	for k in object_data.keys():
		t[k] = object_data[k]
		if changed.has(k):
			t[k] = changed[k]
	write_struct_list(f, obj, t.values())
