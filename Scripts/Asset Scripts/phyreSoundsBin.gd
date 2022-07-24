extends SoundsBin

class_name phyreSoundsBin

static func get_file_path():
	return 'GL/hotline_sounds.bin'
func _to_string():
	return 'GL/hotline_objects.bin'

func _init():
	snd = {
		'id' : '64',
		'name_buffer' : [40],
		'mystery' : '32',
		'flag 2' : '32',
	}

func parse(f):
	sound_data = parse_struct_list(f, snd)
	
	data = sound_data
	names = sound_names
