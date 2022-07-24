extends BinParser

class_name RoomsBin

var version = 2
static func get_file_path():
	return 'GL/hlm2_rooms.bin'

func _to_string():
	return 'GL/hlm2_rooms.bin'

var file_size = 0
var name_indices = []
var room_data = {}
var room_names = {}
var room_order = []

var rm = {
	'id': '16',
		
#		var room_order_i = room_order.find(id)
#		if room_order_i > 0:
#			room['previous_room'] = room_order[room_order_i-1]
#		if room_order_i < len(room_order)-1:
#			room['next_room'] = room_order[room_order_i+1]
	'header' : {
		'size':'i16vec2',
		'framerate':'16',
		'm1':'32',
		'm2':'i16vec2',
		'm3':'32'
	},
	'viewports':[8, {
		'enabled':'16',
		'm1':'16', 'm2':'16',
		'size':'i16vec2',
		'position' : 'i16vec2',
		'bounds' : 'i16vec2',
		'extra' : 'i16vec2',
		'filler': [3 * 2]
	}],
	'tiles' : ['32', {
		'world_pos': 'i16vec2',
		'id' : '16',
		'tilesheet_pos': 'i16vec2',
		'tilesheet_size':'i16vec2',
		'depth' : '16',
	}],
	'objects' : ['32', {
		'instance_id' : '16',
		'mystery1' : '16',
		'mystery2' : '16',
		'object_id' : '16',
		'position': 'i16vec2',
	}],
	'footers' : ['16', {'bytes':[20]}],
	'end_bytes' : [2],
	'name_pos': '32'
}

func parse(file_pointer):
	var f = file_pointer
	var file_start = f.get_position()
	
	# parse silly header :P
	name_indices = parse_index_list(f)
		
	# parse room order :o
	room_order = parse_simple_list(f)
	
	# parse rooms :D
	var rooms = parse_struct_map(f, rm, 'id')
	
	# parse room names :S
	room_names = parse_string_map(f)
#	for room_id in room_order:
	for room_id in rooms.keys():
		var r = rooms[room_id]
		var s = room_names[r['name_pos']]
		room_data[s] = r
	data = room_data
	names = room_names.values()
	file_size = f.get_position() - file_start

func write(file_pointer):
	var f = file_pointer
	
	write_simple_list(f, name_indices)
		
	# write room order :o
	write_simple_list(f, room_order)
	
	write_struct_list(f, rm, room_data.values())
	write_string_list(f, room_names.values())
