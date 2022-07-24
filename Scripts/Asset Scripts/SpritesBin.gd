extends BinParser

class_name SpritesBin

#const file_path = 'GL/hlm2_sprites.bin'
#const alt_file_path = 'GL/hotline_sprites.bin'
static func get_file_path():
	return 'GL/hlm2_sprites.bin'
func _to_string():
	return 'GL/hlm2_sprites.bin'
var version = 2
var sprite_data = {}
var sprites = {}
var sprite_indicies = []
var sprite_names = {}

var spr = {
	'id' : '32',
	'size' : 'ivec2',
	'center' : 'ivec2',
	'mask_x_bounds' : 'ivec2',
	'mask_y_bounds' : 'ivec2',
	'frame_count' : '32',
	'flags': [0x10],
	'name_pos' : '32',
	'padding' : '32'
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
	return sprite_names[sprites[sprite_index].name_pos]

var ref_start = 0
func parse(file_pointer):
	var f = file_pointer
#	ref_start = f.get_position()
#	sprite_indicies = parse_index_list(f)
	f.seek(f.get_position() + f.get_32()*4 + 4) # skip indicies
	sprites = parse_struct_map(f, spr, 'id')
	sprite_names = parse_string_map(f)
	for sprite in sprites.values():
		var s = sprite_names[sprite['name_pos']]
		sprite['name'] = s
		sprite_data[s] = sprite
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
			f.seek(f.get_position()+60)
		else:
#			write_struct(nf, spr, ts)
#			var sprite :SpriteEntry= sprites[id]
#			nf.store_32(id)
#			nf.store_32(sprite.size.x)
#			nf.store_32(sprite.size.y)
#			nf.store_32(sprite.center.x)
#			nf.store_32(sprite.center.y)
#			nf.store_32(sprite.mask_x_bounds.x)
#			nf.store_32(sprite.mask_x_bounds.y)
#			nf.store_32(sprite.mask_y_bounds.x)
#			nf.store_32(sprite.mask_y_bounds.y)
#			nf.store_32(sprite.frame_count)
#			nf.store_buffer(f.flags)
#			nf.store_32(sprite.name_pos)
#			nf.store_32(sprite.padding)
			nf.store_32(id)
			nf.store_buffer(f.get_buffer(60))#4+4+4+4+4+4+4+4+4+0x10+4+4))
	write_string_list(nf, sprite_names.values())
