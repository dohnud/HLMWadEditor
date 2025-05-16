extends BinParser

class_name ObjectsBin

var version = 2
static func get_file_path():
	return 'GL/hlm2_objects.bin'
func _to_string():
	return 'GL/hlm2_objects.bin'
var obj = {
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
	'name_pos' : '32'
}
var name_indicies = []
var object_data = {}
var object_names = {}
var file_size = 0

func add_object(object_name, sprite, depth, parent, masksprite, solid, visible, persistent):
	var object_index = len(object_names.keys())
	
	var last_name = object_names.keys()[len(object_names.keys())-1]
	var name_pos = last_name + len(object_name)
	var object = {
		'id' : object_index,
		'sprite' : sprite,
		'depth' : depth,
		'parent' : parent,
		'mask_sprite' : masksprite,
		'solid' : solid,
		'visible' : visible,
		'persistent' : persistent,
		'priority' : 0x10000000,
		'name_pos': name_pos
	}
	object_data[object_name] = object
	
	object_names[name_pos] = object_name
	changed[object_name] = object_name
	name_indicies.append(object_index)

# name:object_data dependancy created!
func get_object(object_name):
	if changed.has(object_name):
		return changed[object_name]
	return object_data[object_name]
#	var i = object_names.values().find(object_name)
#	if i != -1:
#		return objects[i]

func change_object_prop(object_name, key, value):
	if changed.has(object_name):
		changed[object_name][key] = value
	else:
		changed[object_name] = {key : value}

func get_objects():
	return object_data.keys()

func parse(f):
	var t_pos = f.get_position()
	name_indicies = parse_index_list(f)
	var objects = parse_struct_list(f, obj)
	var name_positions = parse_string_map(f)
	for object in objects:
		var s = name_positions[object['name_pos']]
		object_data[s] = object
		object_names[object['id']] = s
	data = object_data
	names = object_names
	file_size = f.get_position() - t_pos


func write(f):
	write_simple_list(f, name_indicies)
	var t = {}
	for k in object_data.keys():
		t[k] = get_object(k)
	write_struct_list(f, obj, t.values())
	write_string_list(f, object_names.values())
