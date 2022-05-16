extends BinParser

class_name hotlineMeta

const file_path = ''

var pixel_data_global_offset = 0
var uvs = []
var texture = null
var order = []

func parse(file_pointer):
	var f :File= file_pointer
	var file_signature = f.get_buffer(0x04)    # RYHP
	var header_size = f.get_32()         # 54 00 00 00 (84)
	var next_size = f.get_32()           # b8 0b 00 00 (3000)
	var texture_signature = f.get_buffer(0x04) # LGCP
	var texture_type = f.get_32()        #
	var texture_header_size = f.get_32() # DING DING DING WINNER WINNER CHICKEN DINNER
	var texture_subimages = f.get_32()   #
	var texture_flags = f.get_32()       # 
	var texture_sprite_num = f.get_32()
	var texture_other1 = [f.get_32(), f.get_32(),f.get_32(),f.get_32()] # Always 00 00 00 01
	f.get_32()                            # Always 06
	var texture_offset = f.get_32()
	var header_info = f.get_buffer(header_size - f.get_position())
	
	pixel_data_global_offset = 0x80+100 + header_size + next_size + texture_offset + texture_header_size - 47
	
	# Header Data
	var header_data_signature = f.get_buffer(0x04) # 04 03 02 01
	var header_data_size = f.get_32()         # b8 0b 00 00 (3000)
	next_size = f.get_32()                # always 06 00
	var block1_data = f.get_buffer(header_data_size - 0x4 - 0x4)
	
	# Blocks
	var block_id = f.get_32()
	var block_size = f.get_32() # !=numsprites
	var some_offset = f.get_32()
	var another_offset = f.get_32()
	# another_offset = f.get_32() # accident
	f.get_32() # always 00
	var double_sprites = f.get_32() # always 2xnum_sprites (unless backgrounds: 1xnum_sprites)
	var bum_sprites = f.get_32() # always =numsprites (unless backgrounds: =0)
	f.get_32() # always 00

	var sub_block_id = f.get_32() # either 9 or 10
	var sub_block_size = f.get_32()# - 0x04
	var big_offset = f.get_32()
	var lil_offset = f.get_32() # uv data size
	var big_minus_lil_offset = f.get_32()
	f.get_32() # 00
	var num_images = f.get_32()
	var sub_block_data = f.get_buffer(block_size +80)

	# sub image uvs (6 floats, 2 zeros, top-left, width,height)!!!!!!!
	print('starting uv parsing! @',f.get_position())
	uvs = []
	for i in range(num_images):
		uvs.append([
			f.get_float(),f.get_float(),
			f.get_float(),f.get_float(),
			f.get_float(),f.get_float(),
		])
	print('end of uvs:', f.get_position())

	# strings of sub image names, null terminated
	var image_names = []
	var j = 0
	while j < num_images:
		var s = ''
		var c = f.get_8()
		while c != 0:
			s += char(c)
			c = f.get_8()
		if s == '': continue
		image_names.append(s)
		j += 1
	
	var texture_block_header = f.get_buffer(200)
	var rgba8_tag_index = 0
	while rgba8_tag_index<200 and texture_block_header.subarray(rgba8_tag_index,rgba8_tag_index+5).get_string_from_ascii() != 'RGBA8':
		rgba8_tag_index+=1
	if rgba8_tag_index < 1 or rgba8_tag_index >= 200:
		print('FUCK! @', f.get_position())
		return
	var texture_height = bytes_to_int(texture_block_header.subarray(rgba8_tag_index-36, rgba8_tag_index-33))
	var texture_width  = bytes_to_int(texture_block_header.subarray(rgba8_tag_index-40, rgba8_tag_index-37))
	

	f.seek(pixel_data_global_offset)
	var img = Image.new()
	img.create_from_data(texture_width, texture_height, false, Image.FORMAT_RGBA8, f.get_buffer(f.get_len()-pixel_data_global_offset))

	print('im tired',f.get_position())
	texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	
#	return img, uvs, image_names


var sprite_order = []


func get_frames(uv_index, num_frames):
	var frames = []
	for i in range(uv_index, uv_index+num_frames):
		var t = AtlasTexture.new()
		t.atlas = texture
		t.region = Rect2(
			uvs[i][2] * texture.get_width(),
			uvs[i][3] * texture.get_height(),
			uvs[i][4] * texture.get_width(),
			uvs[i][5] * texture.get_height()
		)
		frames.append(t)
	return frames

func bytes_to_int(bytes):
	var t = 0
	for i in range(len(bytes)):
		t += bytes[i] << (i*8)
	return t

func write(file_pointer):
	var f = file_pointer
	pass
