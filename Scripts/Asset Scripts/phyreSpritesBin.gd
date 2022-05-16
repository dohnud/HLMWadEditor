extends "res://Scripts/Asset Scripts/SpritesBin.gd"

class_name phyreSpritesBin

#const file_path = 'GL/hlm2_sprites.bin'
#const alt_file_path = 'GL/hotline_sprites.bin'
static func get_file_path():
	return 'GL/hotline_sprites.bin'
func _to_string():
	return 'GL/hotline_sprites.bin'

func _init():
	spr = {
	'id' : '32',
	'size' : 'ivec2',
	'center' : 'ivec2',
	'mask_x_bounds' : 'ivec2',
	'mask_y_bounds' : 'ivec2',
	'frame_count' : '32',
	'padding':[4*4]
}

#class SpriteEntry:
#	var id:int
#	var size : Vector2
#	var center : Vector2
#	var mask_x_bounds : Vector2
#	var mask_y_bounds : Vector2
#	var frame_count : int
#	var flags: Array #[0x10]
#	var name_pos : int
#	var padding : int

func get_sprite(sprite_index):
	return sprites[sprite_index]

func get_sprite_name(sprite_index):
	if sprite_index < 0 or !sprites.has(sprite_index): return 'NULL'
	return sprites[sprite_index]['name']

#var ref_start = 0
func parse(file_pointer):
	var f = file_pointer
#	ref_start = f.get_position()
#	sprite_indicies = parse_index_list(f)
	sprite_indicies = parse_simple_list(f)
	var sprite_num = f.get_32()
	for i in range(sprite_num):
		var sprite = parse_struct(f, spr)
		sprite['name'] = f.get_buffer(92).get_string_from_ascii()
		sprites[sprite['id']] = sprite
		
#	for sprite in sprites.values():
		var s = sprite['name'].get_file()
#		prints(sprite['id'], sprite['name'])
		sprite['name'] = s
		sprite_data[s] = sprite
	
#	var csv = File.new()
#	if !csv.open('./sprite_data.csv',File.WRITE):
#		csv.store_string('id, name, frame count, dimensions, anchor point')
#		for i in range(sprite_num):
#			if sprites.has(i):
#				var spr = sprites[i]
#				csv.store_string(
#					"%s, %s, %s, %s, %s\n" % [spr.id, spr.name, spr.frame_count, spr.size, spr.center]
#				)
	data = sprite_data
	names = sprite_names.values()

#var src_sprite_offsets = {}

#func parse(file_pointer:File):
#	reference_file = file_pointer
#	var f = file_pointer
#	var s = f.get_32()
#	f.seek(f.get_position() + s*4) # skip indicies
#	s = f.get_32()
#	for i in range(s):
#		var sprite :SpriteEntry= SpriteEntry.new()
#		sprite.id = f.get_32()
#		sprite.size = Vector2(f.get_32(), f.get_32())
#		sprite.center = Vector2(f.get_32(), f.get_32())
#		sprite.mask_x_bounds = Vector2(f.get_32(), f.get_32())
#		sprite.mask_y_bounds = Vector2(f.get_32(), f.get_32())
#		sprite.frame_count = f.get_32()
#		sprite.flags = f.get_buffer(0x10)
#		sprite.name_pos = f.get_32()
#		sprite.padding = f.get_32()
#		sprites[sprite.id] = sprite
#	sprite_names = parse_string_map(f)
#	for sprite in sprites.values():
#		var sprite_name = sprite_names[sprite.name_pos]
##		sprite['name'] = sprite_name
#		sprite_data[s] = sprite_name
#	data = sprite_data
#	names = sprite_names.values()

func write(ref_file, new_file):
	var nf :File= new_file
	var f :File= ref_file
#	f.seek(ref_start)
	write_simple_list(nf, parse_simple_list(f))
	var s = f.get_32()
	nf.store_32(s)
	for i in range(s):
		var id = f.get_32()
#		print(id)
		if sprites.has(id):
			write_struct(nf, spr, sprites[id])
			for j in range(92-len(sprites[id]['name'])):
				nf.store_8(0)
			f.seek(f.get_position()+148-0x04)
		else:
			nf.store_buffer(f.get_buffer(148-0x04))#4+4+4+4+4+4+4+4+4+0x10+4+4))
	write_string_list(nf, sprite_names.values())
