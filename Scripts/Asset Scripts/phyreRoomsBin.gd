extends "res://Scripts/Asset Scripts/RoomsBin.gd"

class_name phyreRoomsBin

#const file_path = 'GL/hlm2_sprites.bin'
#const alt_file_path = 'GL/hotline_sprites.bin'
static func get_file_path():
	return 'GL/hotline_rooms.bin'
func _to_string():
	return 'GL/hotline_rooms.bin'

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _init():
	rm = {
	'id': '32',
		
#		var room_order_i = room_order.find(id)
#		if room_order_i > 0:
#			room['previous_room'] = room_order[room_order_i-1]
#		if room_order_i < len(room_order)-1:
#			room['next_room'] = room_order[room_order_i+1]
	'header' : {
		'size':'ivec2',
#		'framerate':'16',
		'm1':'32',
#		'm2':'i16vec2',
#		'm3':'32'
	},
	'viewports':[8, {
		'enabled':'32',
		'm1':'32', 'm2':'32',
		'size':'ivec2',
		'position' : 'ivec2',
		'port' : 'ivec2',
		'extra' : 'ivec2',
		'filler': [3 * 4]
	}],
	'tiles' : ['32', {
		'depth' : 's32',
		'world_pos': 'ivec2',
		'tilesheet_pos': 'ivec2',
		'm':'32',
		'tilesheet_size':'ivec2',
	}],
	'objects' : ['32', {
		'instance_id': '32',
		'object_id' : '32',
		'position': 'ivec2',
		'm' : '32'
	}],
	'footers' : ['32', {'bytes':[40]}],
#	'end_bytes' : [2],
#	'name_pos': '32'
}

func parse(file_pointer):
	var f = file_pointer
	var file_start = f.get_position()
	
	# parse silly header :P
	name_indices = parse_index_list(f)
		
	# parse room order :o
	room_order = parse_simple_list(f)
	
	# parse rooms :D
	var rooms = parse_struct_map(f, rm, 'object_id')
	
	# parse room names :S
	#room_names = parse_string_map(f)
#	for room_id in room_order:
	var i_s = {}
	for room_id in rooms.keys():
		var r = rooms[room_id]
		var s = room_id#room_names[r['name_pos']]
		print('room: ', s)
		for i in range(len(r['objects'])):
			var n = r['objects'][i]['instance']
			if i_s.has(n):
#				print(i_s[n], n)
				i_s[n].append(r['objects'][i]['object_id'])
			else:
				i_s[n] = [r['objects'][i]['object_id']]
#			var fm = (n>>14) & 0b111111111111111111
#			if r['objects'][i]['id'] == 156:
#			if n / 1000 == int(n/1000):
#				print(r['objects'][i-1]['instance'])
#				print(n)
#				print(r['objects'][i+1]['instance'])
#				printraw(' ',str(n & 0b11111111111111),' ')
#				for bi in range(13):
#					printraw((fm>>bi)&1)
#				print()
		room_data[str(s)] = r
	for k in i_s.keys():
		print(k,': ',i_s[k])
	data = room_data
	names = room_names.values()
	file_size = f.get_position() - file_start

func write(file_pointer):
	var f = file_pointer
	
	write_simple_list(f, name_indices)
		
	# write room order :o
	write_simple_list(f, room_order)
	
	write_struct_list(f, rm, room_data.values())
