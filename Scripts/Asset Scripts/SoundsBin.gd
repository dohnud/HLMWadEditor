extends BinParser

class_name SoundsBin

var version = 2
static func get_file_path():
	return 'GL/hlm2_sounds.bin'
func _to_string():
	return 'GL/hlm2_sounds.bin'
var snd = {
	'id' : '32',
	'mystery' : '32',
	'name_pos' : '32',
	'big_number' : '32',
	'flag 1' : '32',
	'flag 2' : '32',
}
var index_list = []
var sound_data = {}
var sound_names = {}
var file_size = 0


func change_sound_prop(sound_name, key, value):
	if changed.has(sound_name):
		changed[sound_name][key] = value
	else:
		changed[sound_name] = {key : value}

func get_sounds():
	return sound_data.keys()

func parse(f):
	var t_pos = f.get_position()
	index_list = parse_index_list(f)
	var sounds = parse_struct_list(f, snd)
	var name_positions = parse_string_map(f)
	for sound in sounds:
		var s = name_positions[sound['name_pos']]
		sound_data[s] = sound
		sound_names[sound['id']] = s
	data = sound_data
	names = sound_names
	file_size = f.get_position() - t_pos


func write(f):
	write_simple_list(f, index_list)
	var t = {}
	for k in sound_data.keys():
		t[k] = sound_data[k]
		if changed.has(k):
			t[k] = changed[k]
	write_struct_list(f, snd, t.values())
	write_string_list(f, sound_names.values())
