extends Node

class_name BinParser

var data = {}
var names = {}
var changed = {}
var size = 0

# OTHER
func get(asset_id) -> Dictionary:
	if changed.has(asset_id):
		return changed[asset_id]
	return data[asset_id]

# READ
func parse_simple_list(f, type='32',n=0):
	if !n:
		n = parse_type(f, type)
	var index_list = []
	for i in range(n):
		index_list.append(parse_type(f, type))
	return index_list

func parse_index_list(f):
	return parse_simple_list(f)

func parse_string_list(f):
	var size = f.get_32()
	var start = f.get_position()
	var l = []
	while f.get_position() < start + size:
		var s = ''
		var i = f.get_buffer(1)[0]
		while i != 0:
			s += char(i)
			i = f.get_buffer(1)[0]
		l.append(s)
	return l

func parse_string_map(f):
	var size = f.get_32()
	var start = f.get_position()
	var d = {}
	while f.get_position() < start + size:
		var s = ''
		var i = f.get_buffer(1)[0]
		while i != 0:
			s += char(i)
			i = f.get_buffer(1)[0]
		d[f.get_position()-start-len(s)-1] = s
	return d

func get_s32(f):
	var n = f.get_32()
	if n > 0x7FffFFff:
		return n - 0xFFffFFff - 1
	return n

func parse_type(f, type):
	if type is Array:
		if type[0] is String:
			if len(type) > 1:
				if type[1] is Array:
					return parse_simple_list(f, type[0], type[1][0])
				return parse_struct_list(f, type[1], type[0])
			return parse_simple_list(f, type[0])
		# type[0] is a number, static array size
		if type[0] is int:
			if len(type) > 1:
				if type[1] is String:
					return parse_simple_list(f, type[1], type[0])
				return parse_struct_list(f, type[1], '', type[0])
		return f.get_buffer(type[0])
	if type is Dictionary:
		return parse_struct(f, type)
	elif type == '16':
		return f.get_16()
	if type == '32':
		var v = f.get_32()
		if v == 1447:
			var stop = true
		return v
	if type == '64':
		return f.get_64()
	elif type == 's32':
		return get_s32(f)
	elif type == 'ivec2':
		return Vector2(f.get_32(), f.get_32())
	elif type == 'i16vec2':
		return Vector2(f.get_16(), f.get_16())
	return -1

func parse_struct(f, struct):
	var n = {}
	for member in struct.keys():
		n[member] = parse_type(f, struct[member])
	return n

func parse_struct_list(f, struct, ntype='32', n=0):
	if !n:
		n = parse_type(f, ntype)
	var l = []
	for i in range(n):
		l.append(parse_struct(f, struct))
	return l

func parse_struct_map(f, struct, key_str, ntype='32', n=0):
	if !n:
		n = parse_type(f, ntype)
	var l = {}
	for i in range(n):
		var v = parse_struct(f, struct)
		l[v[key_str]] = v
	return l


# WRITE
func write_simple_list(f, list, ntype='32', n=0):
	if !n:
		n = len(list)
	write_type(f, ntype, n)
	for i in range(n):
		write_type(f, ntype, list[i])

func write_string_list(f, list):
	var start = f.get_position()
	var size = len(list) # preadds all null characters
	f.store_32(0)
	for i in list:
		f.store_buffer(PoolByteArray(i.to_ascii()))
		f.store_8(0)
		size += len(i)
	f.seek(start)
	f.store_32(size)

func write_type(f, type, value):
	if type is Array:
		if type[0] is String:
			if len(type) > 1:
				if type[1] is Array:
					return write_simple_list(f, value, type[0], type[1][0])
				return write_struct_list(f, type[1], value, type[0])
			return write_simple_list(f, type[0])
		# type[0] is a number, static array size
		if type[0] is int:
			if len(type) > 1:
				if type[1] is String:
					return write_simple_list(f, value, type[1], type[0])
				return write_struct_list(f, type[1], value, '', type[0])
		return f.store_buffer(value)
	elif type is Dictionary:
		write_struct(f, type, value)
	elif type == '16':
		f.store_16(value)
	elif type == '32' or type == 's32':
		f.store_32(value)
	elif type == '64':
		f.store_64(value)
	elif type == 'ivec2':
		f.store_32(value.x)
		f.store_32(value.y)
	elif type == 'i16vec2':
		f.store_16(value.x)
		f.store_16(value.y)

func write_struct(f, struct, filled_struct):
	for member in struct.keys():
		write_type(f, struct[member], filled_struct[member])

func write_struct_list(f, struct, filled_struct_list, ntype='32', n=0):
	if !n:
		n = len(filled_struct_list)
	write_type(f, ntype, n)
	for i in range(n):
		write_struct(f, struct, filled_struct_list[i])
