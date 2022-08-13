extends Resource

class_name Meta

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

func parse(file_pointer, size, _texture_page=null) -> SpriteFrames:
	texture_page = _texture_page
	var f = file_pointer
	var start = f.get_position()
	# skip id, gameid, unusedid
	f.seek(start + 0x10 + 0x04 + 0x04)
	
	while f.get_position() < start + size:
		# parse sprite name
		var sprite_name_l = f.get_8()
		var sprite_name = f.get_buffer(sprite_name_l).get_string_from_ascii()
		sprites.add_animation(sprite_name)
		sprite_names_ordered.append(sprite_name)
		
		# parse sprite frame
		var image_count = f.get_32()
		for i in range(image_count):
			f.get_32() #4 bytes of padding for some reason
			var img = MetaTexture.new()
			var w = f.get_32()
			var h = f.get_32()
			var x = f.get_32()
			var y = f.get_32()
			img.region = Rect2(x,y,w,h);
#			img.position = Vector2(x,y)
#			img.meta_position = Vector2(x,y)
			img.atlas = texture_page
			# skip uv coords
			# top left
			var p = Vector2(f.get_float(), f.get_float())
			# bottom right
			var c =  Vector2(f.get_float(), f.get_float())
			img.uv = Rect2(p, c-p)
			if !center_norms.has(sprite_name):
				center_norms[sprite_name] = c
			sprites.add_frame(sprite_name, img)
			sprites.set_animation_speed(sprite_name, 60)
	f.seek(start + size)
	sprites.remove_animation("default")
	return sprites

func write(file_pointer) -> int:
	texture_dimensions = texture_page.get_size()
	print(texture_dimensions)
	var f = file_pointer
	var start = f.get_position()
	f.store_8(15)
	f.store_buffer(PoolByteArray('AGTEXTUREPACKER'.to_ascii()))
	f.store_32(0x02) # gameid 1 = hm1 2 = hm2
	f.store_32(0x01) # unused for hm2
	
	for spr_name in sprite_names_ordered:
		if !sprites.has_animation(spr_name):
			continue
		f.store_8(len(spr_name))
		f.store_buffer(spr_name.to_ascii())
		var image_count = sprites.get_frame_count(spr_name)
		f.store_32(image_count)
		for i in range(image_count):
			f.store_buffer(PoolByteArray('dump'.to_ascii()))
			#f.store_32(0)
			# all frames are atlastextures
			var frame = sprites.get_frame(spr_name, i)
			f.store_32(frame.region.size.x)
			f.store_32(frame.region.size.y)
			f.store_32(frame.region.position.x)
			f.store_32(frame.region.position.y)
#			if texture_dimensions == Vector2.ZERO:
#				f.store_32(0)
#				f.store_32(0)
#				f.store_32(0)
#				f.store_32(0)
#			else:
			if is_gmeta:
				f.store_float(0)
				f.store_float(0)
				f.store_float(center_norms[spr_name].x)
				f.store_float(center_norms[spr_name].y)
			else:
				var w  = frame.region.size.x
				var h  = frame.region.size.y
				f.store_float(frame.region.position.x / texture_dimensions.x)
				f.store_float(frame.region.position.y / texture_dimensions.y)
				f.store_float(float(frame.region.position.x+w) / texture_dimensions.x)
				f.store_float(float(frame.region.position.y+h) / texture_dimensions.y)
		
	for spr_name in sprites.get_animation_names():
		if spr_name in sprite_names_ordered:
			continue
		f.store_8(len(spr_name))
		f.store_buffer(spr_name.to_ascii())
		var image_count = sprites.get_frame_count(spr_name)
		f.store_32(image_count)
		for i in range(image_count):
			f.store_buffer(PoolByteArray('dump'.to_ascii()))
			# all frames are atlastextures
			var frame = sprites.get_frame(spr_name, i)
			f.store_32(frame.region.size.x)
			f.store_32(frame.region.size.y)
			f.store_32(frame.region.position.x)
			f.store_32(frame.region.position.y)
#			if texture_dimensions == Vector2.ZERO:
#				f.store_32(0)
#				f.store_32(0)
#				f.store_32(0)
#				f.store_32(0)
#			else:
			if is_gmeta:
				f.store_float(0)
				f.store_float(0)
				f.store_float(center_norms[spr_name].x)
				f.store_float(center_norms[spr_name].y)
			else:
				var w  = frame.region.size.x
				var h  = frame.region.size.y
				f.store_float(frame.region.position.x / texture_dimensions.x)
				f.store_float(frame.region.position.y / texture_dimensions.y)
				f.store_float((frame.region.position.x+w) / texture_dimensions.x)
				f.store_float((frame.region.position.y+h) / texture_dimensions.y)
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
