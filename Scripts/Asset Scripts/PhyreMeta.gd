extends BinParser

class_name PhyreMeta

#- .meta file identifier - 16 byte byte array
#- game (hm1 or hm2) -      4 byte integer
#- unused - 4 byte integer
#- repeat until end of file:
#  - sprite name len (L) - 1 byte integer
#  - sprite name -         L byte(s) string
#  - image count (N) -     4 byte integer
#  - repeat N times:
#	- width -  4 byte integer
#	- height - 4 byte integer
#	- x -      4 byte integer
#	- y -      4 byte integer
#	- uv -     4 4 byte floats (16 bytes total) (unused)


# load gif exporter module
const GIFExporter = preload("res://gdgifexporter/exporter.gd")
# load quantization module that you want to use
const MedianCutQuantization = preload("res://gdgifexporter/quantization/median_cut.gd")


func export_sprite_to_gif(file_path, sprite_name, speed=1, scale=1):
	# remember to use this image format when exporting
	var tf = sprites.get_frame(sprite_name,0)
	# initialize exporter object with width and height of gif canvas
	var exporter = GIFExporter.new(tf.region.size.x * scale, tf.region.size.y * scale)
	
	for i in sprites.get_frame_count(sprite_name):
		var f = sprites.get_frame(sprite_name, i)
		# write image using median cut quantization method and with one second animation delay
		var timg = f.atlas.get_data().get_rect(f.region)
		timg.resize(tf.region.size.x * scale, tf.region.size.y * scale, 0)
		exporter.add_frame(timg, speed, MedianCutQuantization)

	# when you have exported all frames of animation you, then you can save data into file
	var file: File = File.new()
	# open new file with write privlige
	file.open(file_path, File.WRITE)
	# save data stream into file
	file.store_buffer(exporter.export_file_data())
	# close the file
	file.close()

var sprites :SpriteFrames= SpriteFrames.new()
var texture_page :ImageTexture= null

signal resolve_progress
signal resolve_complete
var needs_recalc = false
var terminate_resolve = false

var is_gmeta = false
var is_hm1 = false
var center_norms = {}

var sprite_names_ordered = []
var texture_dimensions = Vector2.ZERO

var dumb_datas = []
var global_pixel_data_offset = 0
var uvs = []
var order = {}

func parse(file_pointer, size, spritebin, atlasbin, bgbin, asset_path):
	var f :File= file_pointer
	var start = f.get_position()
	
	var file_name = asset_path.get_file().replace('.ags.phyre','')
	var target_atlas_id = atlasbin.atlas_names.find(file_name)
	
	 # file signature
	dumb_datas.append([
		f.get_buffer(4),
		f.get_32(),      # important (header size)
		f.get_32(),      # important (next size)
		f.get_buffer(4),
		f.get_32(),
		f.get_32(),      # important (texture_header_size)
		f.get_32(),
		f.get_32(),      # important (texture info size)
		f.get_32(),
		f.get_32(),f.get_32(),f.get_32(),f.get_32(),
		f.get_32(),
		f.get_32(),      # important (texture offset)
	])
	dumb_datas.append([f.get_buffer(dumb_datas[0][1] - (f.get_position()-start))])
	
	global_pixel_data_offset = start + 0x80+100 + dumb_datas[0][1] + dumb_datas[0][2] + dumb_datas[0][14] + dumb_datas[0][5] - 47
	
	dumb_datas.append([
		f.get_buffer(4),
		f.get_32(),      # important (data size)
		f.get_32(),      # important (next size)
	])
	dumb_datas.append([f.get_buffer(dumb_datas[2][1] - 0x4 - 0x4)])
	
	dumb_datas.append([
		f.get_32(),
		f.get_32(),      # important (block size)
		f.get_32(),
		f.get_32(),
		f.get_32(),      # padding
		f.get_32(),
		f.get_32(),
		f.get_32(),      # padding
		f.get_32(),
		f.get_32(),
		f.get_32(),
		f.get_32(),
		f.get_32(),
		f.get_32(),      # padding
		f.get_32(),      # important (num images)
	])
	dumb_datas.append([f.get_buffer(dumb_datas[4][1] + 80)])
	
	var num_images = dumb_datas[4][14]
	
	dumb_datas.append([])
	for i in range(num_images):
		var stuff = [f.get_float(), f.get_float(),f.get_float(),f.get_float(),f.get_float(),f.get_float()]
		uvs.append(Rect2(
			stuff[2],stuff[3],
			stuff[4],stuff[5]
		))
		dumb_datas[6].append_array(stuff)
	
	dumb_datas.append([[]])
	var image_names = []
	var j = 0
	while j < num_images:
		var s = ''
		var c = f.get_8()
		dumb_datas[7][0].append(c)
		while c != 0:
			s += char(c)
			c = f.get_8()
			dumb_datas[7][0].append(c)
		if s == '': continue
		image_names.append(s)
		j += 1
	
	var comeback = f.get_position()
	var texture_block_header = f.get_buffer(200)
	var rgba8_tag_index = 0
	while rgba8_tag_index<200 and texture_block_header.subarray(rgba8_tag_index,rgba8_tag_index+5).get_string_from_ascii() != 'RGBA8':
		rgba8_tag_index+=1
	if rgba8_tag_index < 1 or rgba8_tag_index >= 200:
		print('FUCK! @', f.get_position())
		return
	
	var comeonman = (19 - dumb_datas[0][7])
	global_pixel_data_offset = comeback + rgba8_tag_index + dumb_datas[0][5] + 37 - comeonman
	
	var texture_height = bytes_to_int(texture_block_header.subarray(rgba8_tag_index-36, rgba8_tag_index-33))
	var texture_width  = bytes_to_int(texture_block_header.subarray(rgba8_tag_index-40, rgba8_tag_index-37))
	
	# 
	f.seek(comeback)
	dumb_datas.append([f.get_buffer(global_pixel_data_offset - f.get_position())])

	
	
	f.seek(global_pixel_data_offset)
	var img = Image.new()
	img.create_from_data(texture_width, texture_height, false, Image.FORMAT_RGBA8, f.get_buffer(texture_width * texture_height * 4))
	texture_dimensions = Vector2(texture_width, texture_height)

	print('im tired',f.get_position())
	texture_page = ImageTexture.new()
	texture_page.create_from_image(img, 0)
	
	sprites = SpriteFrames.new()
	sprites.remove_animation('default')
	var sprite_order = {}
	var i = 0
	var t = 0
	# if there is no target atlas then the name of the file IS the sprite name and doesnt need an atlas lookup
	if file_name == 'background':
		# TODO: redo and fix phyreMeta parsing for backgrounds.ags.phyre
		for k in range(len(bgbin.background_data.values())):
			var bg = bgbin.background_data.values()[i]
			sprites.add_animation(str(bg.name))
			var mt = MetaTexture.new()
			mt.atlas = texture_page
			mt.uv = uvs[k]
			mt.region = Rect2(
				uvs[k].position.x * float(texture_page.get_width()),
				uvs[k].position.y * float(texture_page.get_height()),
				uvs[k].size.x * float(texture_page.get_width()),
				uvs[k].size.y * float(texture_page.get_height())
			)
			sprites.add_frame(str(bg.name), mt)
	elif target_atlas_id < 0:
		var spr
		if spritebin.sprite_data.has(file_name):
			spr = spritebin.sprite_data[file_name]
		sprites.add_animation(str(spr.name))
		for k in range(t, t + spr.frame_count):
			var mt = MetaTexture.new()
			mt.atlas = texture_page
			mt.uv = uvs[k]
			mt.region = Rect2(
				uvs[k].position.x * float(texture_page.get_width()),
				uvs[k].position.y * float(texture_page.get_height()),
				uvs[k].size.x * float(texture_page.get_width()),
				uvs[k].size.y * float(texture_page.get_height())
			)
			sprites.add_frame(str(spr.name), mt)
	else:
		for spr in spritebin.sprites.values():
			var a = atlasbin.atlas_sprites[spr.id]
	#		prints(spritebin.get_sprite_name(spr.id), a)
			if a == target_atlas_id:
				sprite_order[spr.id] = t
				sprites.add_animation(str(spr.name))
				for k in range(t, t + spr.frame_count):
					var mt = MetaTexture.new()
					mt.atlas = texture_page
					mt.uv = uvs[k]
					mt.region = Rect2(
						uvs[k].position.x * float(texture_page.get_width()),
						uvs[k].position.y * float(texture_page.get_height()),
						uvs[k].size.x * float(texture_page.get_width()),
						uvs[k].size.y * float(texture_page.get_height())
					)
					sprites.add_frame(str(spr.name), mt)
				t += spr.frame_count
				i += 1
	order = sprite_order



func bytes_to_int(bytes):
	var t = 0
	for i in range(len(bytes)):
		t += bytes[i] << (i*8)
	return t


func write(file_pointer) -> int:
	var f = file_pointer
	var start = f.get_position()
	for data in dumb_datas:
		for field in data:
			if field is Array or field is PoolByteArray:
				f.store_buffer(field)
			elif field is float:
				f.store_float(field)
			else:
				f.store_32(field)
	f.store_buffer(texture_page.get_data().get_data())
	return f.get_position() - start
#
#func writeg(file_pointer):
#	var f = file_pointer
#	var start = f.get_position()
#	f.store_8(15)
#	f.store_buffer(PoolByteArray('AGTEXTUREPACKER'.to_ascii()))
#	f.store_32(0x02) # gameid 1 = hm1 2 = hm2
#	f.store_32(0x01) # unused for hm2
#
#	for spr_name in sprite_names_ordered:
#		if !sprites.has_animation(spr_name):
#			continue
#		f.store_8(len(spr_name))
#		f.store_buffer(spr_name.to_ascii())
#		var image_count = sprites.get_frame_count(spr_name)
#		f.store_32(image_count)
#		for i in range(image_count):
#			f.store_buffer(PoolByteArray('dump'.to_ascii()))
#			#f.store_32(0)
#			# all frames are atlastextures
#			var frame = sprites.get_frame(spr_name, i)
#			f.store_32(frame.region.size.x)
#			f.store_32(frame.region.size.y)
#			f.store_32(frame.region.position.x)
#			f.store_32(frame.region.position.y)
#			if spritebin_ref == null:
#				f.store_float(0)
#				f.store_float(0)
#				f.store_float(0)
#				f.store_float(0)
#			else:
#				var w  = frame.region.size.x
#				var h  = frame.region.size.y
##				f.store_float(frame.region.position.x / texture_dimensions.x)
##				f.store_float(frame.region.position.y / texture_dimensions.y)
#				f.store_float(0)
#				f.store_float(0)
#				if is_gmeta:
#					f.store_float(center_norms[spr_name].x)
#					f.store_float(center_norms[spr_name].y)
#				else:
#					f.store_float(clamp(spritebin_ref[spr_name]['center'].x / w,0,1))
#					f.store_float(clamp(spritebin_ref[spr_name]['center'].y / h,0,1))
#
#	for spr_name in sprites.get_animation_names():
#		if spr_name in sprite_names_ordered:
#			continue
#		f.store_8(len(spr_name))
#		f.store_buffer(spr_name.to_ascii())
#		var image_count = sprites.get_frame_count(spr_name)
#		f.store_32(image_count)
#		for i in range(image_count):
#			f.store_buffer(PoolByteArray('dump'.to_ascii()))
#			# all frames are atlastextures
#			var frame = sprites.get_frame(spr_name, i)
#			f.store_32(frame.region.size.x)
#			f.store_32(frame.region.size.y)
#			f.store_32(frame.region.position.x)
#			f.store_32(frame.region.position.y)
#			if spritebin_ref == null:
#				f.store_float(0)
#				f.store_float(0)
#				f.store_float(0)
#				f.store_float(0)
#			else:
#				var w  = frame.region.size.x
#				var h  = frame.region.size.y
##				f.store_float(frame.region.position.x / texture_dimensions.x)
##				f.store_float(frame.region.position.y / texture_dimensions.y)
#				f.store_float(0)
#				f.store_float(0)
#				if is_gmeta:
#					f.store_float(center_norms[spr_name].x)
#					f.store_float(center_norms[spr_name].y)
#	return f.get_position() - start

func convert_to_gmeta(spritebin_ref):
	is_gmeta = true
	for sprite in sprites.get_animation_names():
		var frame = sprites.get_frame(sprite, 0)
		var w  = frame.region.size.x
		var h  = frame.region.size.y
		center_norms[sprite] = Vector2(clamp(spritebin_ref.sprite_data[sprite]['center'].x / w,0,1), clamp(spritebin_ref.sprite_data[sprite]['center'].y / h,0,1))

#func resolve(animatedsprite:SpriteFrames, spritesheet:Texture):
func resolve(userdata):
#	if userdata == null: return null
	var mutex = userdata[2]
	if !needs_recalc:
#		dest_image.create(image_width, spritesheet.get_height(), false, Image.FORMAT_RGBA8)
#		for s in animatedsprite.get_animation_names():
#			for i in animatedsprite.get_frame_count(s):
#				var f :AtlasTexture= animatedsprite.get_frame(s,i)
#				dest_image.blit_rect(f.atlas.get_data(), f.region, f.region.position)
		mutex.lock()
		emit_signal('resolve_progress', 2)
		emit_signal('resolve_complete', self)
		mutex.unlock()
		return
	var animatedsprite:SpriteFrames = userdata[0]
	var spritesheet:Texture = userdata[1]
	var image_width = spritesheet.get_width()
	# get image bigger image hegith..
	var a = animatedsprite.get_animation_names()
	for sprite_name in a:
		var f_count = animatedsprite.get_frame_count(sprite_name)
		for frame_index in range(f_count):
			if animatedsprite.get_frame(sprite_name, frame_index).region.size.x+1 > image_width:
				image_width = 1+animatedsprite.get_frame(sprite_name, frame_index).region.size.x
	var image_height = 1
	var dest_image :Image = Image.new()
	
	var p = 0
	var l_as = len(a)
	
	var rs = []
	dest_image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	dest_image.lock()
	var masq_image :Image = Image.new()
	masq_image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	masq_image.lock()
	var new_spritesheet = ImageTexture.new()
	var masq_square = Image.new()
	masq_square.create(1,1,false,Image.FORMAT_RGBA8)
	masq_square.fill(Color(1,0,0,1))
#	var dest_size = Vector2(image_width, 1)
	
	var new_sprites:SpriteFrames=SpriteFrames.new()
	new_sprites.remove_animation("default")
	for sprite_name in a:
		new_sprites.add_animation(sprite_name)
		var f_count = animatedsprite.get_frame_count(sprite_name)
		var p1 = 0
		for frame_index in range(f_count):
			p1 = float(frame_index) / float(f_count)
			var frame :MetaTexture= animatedsprite.get_frame(sprite_name, frame_index)
			var idx = frame.region.size.x
			var idy = frame.region.size.y
			assert(idx <= image_width)
			
			var found = false
			for ty in range(2048):
				if ty + idy > dest_image.get_height():
					masq_image.unlock()
					dest_image.unlock()
					dest_image.crop(image_width, ty + idy)
#						print(sprite_name,' ', frame_index,': ',image_width,' x ', ty + idy)
					masq_image.crop(image_width, ty + idy)
					dest_image.lock()
					masq_image.lock()
				for tx in range(image_width - idx):
					var valid = !(masq_image.get_pixel(tx,ty).r8 ||
						masq_image.get_pixel(tx, ty + idy-1).r8 ||
						masq_image.get_pixel(tx + idx-1, ty).r8 ||
						masq_image.get_pixel(tx + idx-1, ty + idy-1).r8)
					if valid:
						for ity in range(idy):
							for itx in range(idx):
								valid = !masq_image.get_pixel(tx + itx, ty + ity).r8
								if !valid: break
							if !valid: break
					if valid:
						dest_image.blit_rect(frame.atlas.get_data(), frame.region, Vector2(tx,ty))
						masq_square.unlock()
#						masq_square.resize(frame.region.size.x, frame.region.size.y, Image.INTERPOLATE_NEAREST)
						masq_square.crop(frame.region.size.x,frame.region.size.y)
						masq_square.fill(Color(1,0,0,1))
						masq_square.lock()
						masq_image.blit_rect(masq_square, Rect2(Vector2.ZERO,frame.region.size), Vector2(tx,ty))
#						for ity in range(idy):
#							for itx in range(idx):
#								masq_image.set_pixel(tx + itx, ty + ity, Color(1,0,0,1))
#						print('moving ', sprite_name, frame_index, ': ', frame.region.position, ' -> ', Vector2(tx,ty))
#							rs.append(Rect2(int(tx),int(ty), int(idx),int(idy)))

						var new_frame:MetaTexture = MetaTexture.new()
						new_frame.uv = frame.uv
						new_frame.region = Rect2(int(tx),int(ty), int(idx),int(idy))
#						if int(ty)+int(idy) > dest_size.y:
#							dest_size = Vector2(image_width, ty + idy)
						new_frame.atlas = texture_page
						new_sprites.add_frame(sprite_name, new_frame)
						found = true
					if found: break
				if found: break
			if terminate_resolve:
#				mutex.lock()
				emit_signal('resolve_progress', 0)
				emit_signal('resolve_complete', self)
#				mutex.unlock()
#				mutex.lock()
				return null
			emit_signal('resolve_progress', float(p + p1)/float(l_as))#float(p)/float(len(animatedsprite.get_animation_names())))
		p += 1
#		var i = 0
#		for sprite_name in a:
#			new_sprites.add_animation(sprite_name)
#			var f_count = animatedsprite.get_frame_count(sprite_name)
#			for frame_index in range(f_count):
#				var f :AtlasTexture = AtlasTexture.new()
#				f.atlas = texture_page
#				f.region = rs[i]
#				new_sprites.add_frame(sprite_name, f)
#				i += 1
#	dest_image.crop(dest_size.x, dest_size.y)
	texture_dimensions = dest_image.get_size()
	sprites = new_sprites
	for sprite_name in a:
		var f_count = sprites.get_frame_count(sprite_name)
		for frame_index in range(f_count):
			var f = sprites.get_frame(sprite_name, frame_index)
			sprites.get_frame(sprite_name, frame_index).uv = Rect2(
				float(f.region.position.x) / float(texture_dimensions.x),
				float(f.region.position.y) / float(texture_dimensions.y),
				float(f.region.size.x) / float(texture_dimensions.x),
				float(f.region.size.y) / float(texture_dimensions.y)
			)
#	dest_image.save_png('temp_sheet.png')
#	texture_dimensions = dest_image.get_size()
#	dest_image.crop(texture_dimensions)
#	texture_page.set_size_override(texture_dimensions)
#	texture_page.set_data(dest_image)
	texture_page.create_from_image(dest_image, 0)
#	print(texture_dimensions)
	mutex.lock()
	emit_signal('resolve_progress', 2)
	emit_signal('resolve_complete', self)
	mutex.unlock()
	print('PLEASE STOP PLEASE')
	return self
