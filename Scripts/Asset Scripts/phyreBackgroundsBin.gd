extends "res://Scripts/Asset Scripts/BackgroundsBin.gd"

class_name phyreBackgroundsBin

static func get_file_path():
	return 'GL/hotline_backgrounds.bin'
func _to_string():
	return 'GL/hotline_backgrounds.bin'

#var background_data = {}
#var background_indicies = []
#var background_names = {}

func _init():
	bg = {
	'id' : '32',
	'name' : [48],
	'data' : [0x04 * 3]
}


func get_sprite_from_index(bg_index:int):
	return background_data[get_bg_name(bg_index)]

func get_sprite_from_name(bg_name:String):
	return background_data[bg_name]
	

func get_bg_name(bg_index):
	if bg_index < 0 or !background_names.has(bg_index): return 'NULL'
	return background_names[bg_index]

#var ref_start = 0
func parse(file_pointer):
	var f = file_pointer
	background_indicies = parse_index_list(f)
	
	var bg_num = f.get_32()
	for i in range(bg_num):
		var bg_entry = parse_struct(f, bg)
		
#	for sprite in sprites.values():
		var s = bg_entry['name'].get_string_from_ascii().get_file()
		background_names[bg_entry.id] = s
#		prints(sprite['id'], sprite['name'])
		bg_entry['name'] = s
		background_data[s] = bg_entry
	data = background_data
	names = background_names.values()

func write(new_file):
	var nf :File= new_file
#	f.seek(ref_start)
	write_simple_list(nf, background_indicies)
	write_struct_list(nf, bg, background_data.values())
