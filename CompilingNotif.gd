extends PanelContainer

signal cancel_resolve
signal resolve_complete
var asset_name = ''
var asset :Meta= null



onready var app = get_tree().get_nodes_in_group('App')[0]

func _ready():
	$VBoxContainer/HBoxContainer/Label2.text = asset_name
	if !init_resolve():
		queue_free()

func _on_CancelResolveButton_pressed():
#	emit_signal("cancel_resolve", asset)
#	if asset and app and app.threads:
#		app.mutex.lock()
#		asset.terminate_resolve = true
#		app.mutex.unlock()
#		call_deferred('wait_for_thread', app.threads[asset][0])
	queue_free()

func resolve_complete(a):
#	emit_signal("resolve_complete", asset)
#	app._resolve_complete(asset)
	if asset and app and app.threads:
		call_deferred('wait_for_thread', app.threads[asset][0])
	else:
		queue_free()

func update_resolve_progress(v=0):
	$VBoxContainer/ProgressBar.value = v

func wait_for_thread(t:Thread):
	var r = t.wait_to_finish()
	if r == null:
		emit_signal("cancel_resolve", asset_name)
	else:
		emit_signal("resolve_complete", asset_name)
	queue_free()

var dest_image = Image.new()
var masq_image = Image.new()
var masq_square = Image.new()
var new_sprites = SpriteFrames.new()

var current_sprite = ''
var current_index = 0
var current_frame_index = 0

func _process(delta):
	var f_count = asset.sprites.get_frame_count(current_sprite)
	var l_as = len(asset.sprites.get_animation_names())
	if resolve(current_sprite, current_frame_index):
		current_frame_index += 1
		if current_frame_index >= f_count:
			current_frame_index = 0
			current_index += 1
			if current_index >= l_as:
				end_resolve()
				queue_free()
				return
			current_sprite = asset.sprites.get_animation_names()[current_index]
	var p1 = float(current_frame_index) / float(f_count)
	update_resolve_progress(float(current_index + p1)/float(l_as))#float(p)/float(len(animatedsprite.get_animation_names()))))

var image_width = 1
func init_resolve():
#	if !needs_recalc:
##		dest_image.create(image_width, spritesheet.get_height(), false, Image.FORMAT_RGBA8)
##		for s in animatedsprite.get_animation_names():
##			for i in animatedsprite.get_frame_count(s):
##				var f :AtlasTexture= animatedsprite.get_frame(s,i)
##				dest_image.blit_rect(f.atlas.get_data(), f.region, f.region.position)
#		mutex.lock()
#		emit_signal('resolve_progress', 2)
#		emit_signal('resolve_complete', self)
#		mutex.unlock()
#		return
	if !asset:return false
	var animatedsprite:SpriteFrames = asset.sprites
	var spritesheet:Texture = asset.texture_page
	image_width = spritesheet.get_width()
	# get image bigger image hegith..
	var a = animatedsprite.get_animation_names()
	for sprite_name in a:
		var f_count = animatedsprite.get_frame_count(sprite_name)
		for frame_index in range(f_count):
			if animatedsprite.get_frame(sprite_name, frame_index).region.size.x+1 > image_width:
				image_width = 1+animatedsprite.get_frame(sprite_name, frame_index).region.size.x

	var image_height = 1
	dest_image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	dest_image.lock()
	masq_image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	masq_image.lock()
	masq_square.create(1,1,false,Image.FORMAT_RGBA8)
	masq_square.fill(Color(1,0,0,1))
	new_sprites.remove_animation("default")
	current_sprite = asset.sprites.get_animation_names()[current_index]
	return true

var ty = 0
func resolve(sprite_name, frame_index):
#	var dest_size = Vector2(image_width, 1)
#	var new_sprites:SpriteFrames=SpriteFrames.new()
	
#	for sprite_name in a:
	if !new_sprites.has_animation(sprite_name):
		new_sprites.add_animation(sprite_name)
	
#	for ty in range(2048):
	if find_new_spot(sprite_name, frame_index, ty):
		return true
	ty += 1
	if ty >= 2048:
		return true # true = done
	return false
		
func find_new_spot(sprite_name, frame_index, ty):
	var animatedsprite:SpriteFrames = asset.sprites
	var spritesheet:Texture = asset.texture_page
#	var image_width = spritesheet.get_width()
	var f_count = animatedsprite.get_frame_count(sprite_name)
#	var p1 = 0
#	for frame_index in range(f_count):
#		p1 = float(frame_index) / float(f_count)
	var frame :MetaTexture= animatedsprite.get_frame(sprite_name, frame_index)
	var idx = frame.region.size.x
	var idy = frame.region.size.y
	assert(idx <= image_width)
	var found = false
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
			masq_square.crop(frame.region.size.x,frame.region.size.y)
			masq_square.fill(Color(1,0,0,1))
			masq_square.lock()
			masq_image.blit_rect(masq_square, Rect2(Vector2.ZERO,frame.region.size), Vector2(tx,ty))

			var new_frame:MetaTexture = MetaTexture.new()
			new_frame.uv = frame.uv
			new_frame.region = Rect2(int(tx),int(ty), int(idx),int(idy))
			new_frame.atlas = asset.texture_page
			new_sprites.add_frame(sprite_name, new_frame)
			found = true
			return true
		if found: break
	return false
#	if found: break
#	if terminate_resolve:
##				mutex.lock()
#		emit_signal('resolve_progress', 0)
#		emit_signal('resolve_complete', self)
##				mutex.unlock()
##				mutex.lock()
#		return null
#	emit_signal('resolve_progress', float(p + p1)/float(l_as))#float(p)/float(len(animatedsprite.get_animation_names())))
#		p += 1

func end_resolve():
	asset.texture_dimensions = dest_image.get_size()
	asset.sprites = new_sprites
	var a = asset.sprites.get_animation_names()	
	for sprite_name in a:
		var f_count = asset.sprites.get_frame_count(sprite_name)
		for frame_index in range(f_count):
			var f = asset.sprites.get_frame(sprite_name, frame_index)
			asset.sprites.get_frame(sprite_name, frame_index).uv = Rect2(
				float(f.region.position.x) / float(asset.texture_dimensions.x),
				float(f.region.position.y) / float(asset.texture_dimensions.y),
				float(f.region.size.x) / float(asset.texture_dimensions.x),
				float(f.region.size.y) / float(asset.texture_dimensions.y)
			)
#	dest_image.save_png('temp_sheet.png')
#	texture_dimensions = dest_image.get_size()
#	dest_image.crop(texture_dimensions)
#	texture_page.set_size_override(texture_dimensions)
#	texture_page.set_data(dest_image)
	asset.texture_page.create_from_image(dest_image, 0)
#	print(texture_dimensions)
#	mutex.lock()
#	emit_signal('resolve_progress', 2)
	emit_signal('resolve_complete', asset_name)
#	mutex.unlock()
#	print('PLEASE STOP PLEASE')
	return asset

