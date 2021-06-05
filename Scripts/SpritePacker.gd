var thread

class_name SpritePacker

func resolve(animatedsprite:SpriteFrames, spritesheet:Texture):
	var image_width = spritesheet.get_width()
	var image_height = 1
	var dest_image :Image = Image.new()
	var masq_image :Image = Image.new()
	var new_spritesheet = ImageTexture.new()
	dest_image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	masq_image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	var dest_size = Vector2(image_width, 1)
	
	for sprite_name in animatedsprite.animations:
		for frame_index in range(animatedsprite.get_frame_count(sprite_name)):
			var frame :AtlasTexture= animatedsprite.get_frame(sprite_name, frame_index)
			var idx = frame.region.size.x
			var idy = frame.region.size.y
			assert(idx <= image_width)
			
			var found = false
			for ty in range(2048):
				if ty + idy > dest_image.get_height():
					dest_image.crop(image_width, ty + idy)
					masq_image.crop(image_width, ty + idy)
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
						for ity in range(idy):
							for itx in range(idx):
								masq_image.set_pixel(tx + itx, ty + ity, Color(1,0,0,1))
						print('moving', sprite_name, frame_index, ': ', frame.region.position, ' -> ', Vector2(tx,ty))
						frame.region.position = Vector2(tx,ty)
						frame.atlas = new_spritesheet
#						frame.region.size = Vector2(idx,idy) # implied
						found = true
					if found: break
				if found: break
	dest_image.save_png('temp_sheet.png')
	new_spritesheet.set_data(dest_image)
