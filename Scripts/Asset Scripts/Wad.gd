extends File

class_name Wad

#var file_list = []
var file_path = ''
var file_locations = {}
var patchwad_list = []
var content_offset = -1
var content_size
var version = WAD_VERSION.HM2

enum WAD_VERSION {
	HM1,
	HM2,
	HM2v2
}

var sprite_data = {}
var spritebin = null
var atlasbin = null
var object_data = {}
var objectbin = null
var max_object_index = -1
var roombin = null
var backgroundbin = null

var loaded_assets = {
	#"path/to/file.meta" : Meta()
}
var new_files = {
	#"path/to/file.meta" : Meta()
}
var changed_files = {
	#"path/file.meta": Meta()
}

var identifier = PoolByteArray()
var obselete_directory = PoolByteArray()

var audio_print=false

func opens(f,m):
	file_path = f
	return open(f,m)

func parse_header():
#	seek(0x10)
	seek(0)
	identifier = get_buffer(0x10)
	print(len(identifier.get_string_from_ascii()))
	version = WAD_VERSION.HM2v2
	if len(identifier.get_string_from_ascii()) < 5:
		version = WAD_VERSION.HM1
		seek(0)
		content_offset = get_32()
	
	# parse file locations
	var num_files = get_32()
	file_locations.clear()
	#file_list.clear()
	for _i in range(num_files):
		# metadata
		var file_name_l = get_32();
		var file_name = get_buffer(file_name_l).get_string_from_ascii()
		var file_len = 0
		var file_offset = 0
		if version != WAD_VERSION.HM1:
			file_len = get_64()
			file_offset = get_64()
		else:
			file_len = get_32()
			file_offset = get_32()
		if file_len >= 0xffffffffffffff or file_offset >= 0xffffffffffffff:
			ErrorLog.show_user_error("File: \"" + file_name + "\" is corrupted or missing, please contact a developer")
			print("File: \"" + file_name + "\" is corrupted or missing")
			printerr("File: \"" + file_name + "\" is corrupted or missing")
		else:
			# add to file locations
			file_locations[file_name] = [file_offset, file_len]
		#file_list.append(file_name)
		
	# parse directories (unused but maybe useful later?)
#	var debug = File.new()
#	debug.open('debug.txt', File.WRITE)
	if version == WAD_VERSION.HM2v2:
		var _num_dirs = get_32()
		for _i in range(_num_dirs):
			var _dir_name_l = get_32()
			var _dir_name = get_buffer(_dir_name_l).get_string_from_ascii()
	#		debug.store_string('+'+_dir_name+'\n')
			var _num_entries = get_32()
			for _j in range(_num_entries):
				var _entry_name_l = get_32()
				var _entry_name = get_buffer(_entry_name_l).get_string_from_ascii()
	#			debug.store_string(' '+_entry_name+' ')
				var _entry_type = get_8()
#			debug.store_string(str(_entry_type)+'\n')
	
	
	# raw file data starts here
	if version != WAD_VERSION.HM1:
		content_offset = get_position()
	
	patchwad_list = []#[get_script().new()]
	close()
	return 1


func add_file(file_path, dest_folder='Assets/'):
	var f = File.new()
	if !f.open(file_path, File.READ):
		if '.meta' in file_path or '.gmeta' in file_path:
			var folder = "Atlases/"
			var tex = add_file(file_path.replace('.'+file_path.get_extension(), '.png'), folder)
			if tex == null:
				tex = ImageTexture.new()
				tex.create(1,1,Image.FORMAT_RGBA8,0)
			var meta = Meta.new()
			f.seek_end()
			var s = f.get_position()
			f.seek(0)
			meta.parse(f, s, tex)
			new_files[folder + file_path.get_file()] = meta
			loaded_assets[folder + file_path.get_file()] = meta
			meta.is_gmeta = '.gmeta' in file_path
			return meta
		if '.png' in file_path:
#			var folder = "Atlases/"
			var image = Image.new()
			var texture = ImageTexture.new()
			var err = image.load(file_path)
			if err != OK:
				print('ouch couldnt load: ', file_path)
				return null
			texture.create_from_image(image, 0)
			new_files[dest_folder + file_path.get_file()] = texture
			loaded_assets[dest_folder + file_path.get_file()] = texture
			return texture
	return null
#func write_patch(file_pointer):
#
func add_file_data(file_path, file_data):
	new_files[file_path] = file_data

func exists(asset_name):
	return file_locations.has(asset_name)


func lazy_find(asset_name):
	for k in file_locations.keys():
		if asset_name == k.get_file():
			return k
	return asset_name

func goto(asset):
	if !is_open():
		if open(file_path, READ):
			return null
#	for p in patchwad_list:
#		if p.exists(asset):
#			return p.goto(asset)
	if !file_locations.has(asset):
		return null
	var dim = file_locations[asset]
	if dim[0] >= 0xffffffffffffff or dim[1] >= 0xffffffffffffff:
		Log.log("File: " + asset + "is corrupted or missing, please contact a developer")
		print("File:" + asset + "is corrupted or missing")
		printerr("File:" + asset + "is corrupted or missing")
		return null
	seek(content_offset + dim[0])
	return dim[1]

func get(asset):
	if new_files.has(asset):
		return new_files[asset]
	if changed_files.has(asset):
		return changed_files[asset]
	var size = goto(asset)
	if size == null: return null
	var r = get_buffer(size)
	close()
	return r

func open_asset(asset_path, base_wad=null):
	if new_files.has(asset_path):
		return new_files[asset_path]
	if changed_files.has(asset_path):
		return changed_files[asset_path]
	if asset_path.ends_with('.ags.phyre'):
		return parse_phyremeta(asset_path, base_wad)
	if asset_path.ends_with('.meta'):
		return parse_meta(asset_path)
	if asset_path.ends_with('.gmeta'):
		return parse_meta(asset_path)
	if asset_path.ends_with('.png'):
		return sprite_sheet(asset_path)
	if asset_path.ends_with('.bin'):
		return get_bin(asset_path)
	if asset_path.ends_with('.mp3') or \
		asset_path.ends_with('.wav') or \
		asset_path.ends_with('.ogg') :
		return audio_stream(asset_path)
	return null

#func apply_patchwad(f):
#	var patchwad = get_script().new()
#	patchwad.open(f, File.READ)
#	patchwad.parse_header()
#	patchwad_list.append(patchwad)

func patch(wad):
	patchwad_list.append(wad)
	for f in wad.file_locations.keys():
		changed_files[f] = wad.open_asset(f, self)

func reset():
	changed_files = {}
	new_files = {}
	loaded_assets = {}
	patchwad_list = []

func revert(asset):
	changed_files.erase(asset)
	new_files.erase(asset)
	loaded_assets.erase(asset)
#	file_locations.erase(asset) # leave commented
	for p in patchwad_list:
		p.revert(asset)
		p.file_locations.erase(asset)

func sprite_sheet(asset, lazy=0):
	if lazy:
		asset = lazy_find(asset)
	for p in patchwad_list:
		if p.exists(asset):
			return p.sprite_sheet(asset)
	if asset in loaded_assets.keys():
		return loaded_assets[asset]
	if !is_open(): open(file_path, READ)
	var img = Image.new()
	var data = get(asset)
	if !(data is PoolByteArray):
		return data
	img.load_png_from_buffer(data)
#	img.convert(fmt)
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	loaded_assets[asset] = tex
	close()
	return tex

func audio_stream(asset, lazy=0 ,repeat=false):
	if lazy:
		asset = lazy_find(asset)
	if changed_files.has(asset):
		return changed_files[asset]
	if asset in loaded_assets.keys():
		return loaded_assets[asset]
	
	if asset!=null:
		var sound = WadSound.new()
		var size = goto(asset)
		if size == null: 
			ErrorLog.show_user_error("couldnt find file: " + asset)
			return null
		sound.parse(self, size, asset)
		loaded_assets[asset] = sound
		return sound
	ErrorLog.show_user_error("couldnt find file: " + asset)
	return null


func byte_array_to_int(bytes):
		return ((bytes[3] & 0xFF) << 24) | ((bytes[2] & 0xFF) << 16) | ((bytes[1] & 0xFF) << 8) | ((bytes[0] & 0xFF) << 0)

# rename animated_sprite
func parse_meta(asset, lazy=0):
	if lazy:
		asset = lazy_find(asset)
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_meta(asset)
	if new_files.has(asset):
		return new_files[asset]
	if changed_files.has(asset):
		return changed_files[asset]
	var tex = null
	if ".meta" in asset:
		tex = sprite_sheet(asset.replace(".meta", ".png"))
	elif '.gmeta' in asset:
		tex = sprite_sheet(asset.replace(".gmeta", ".png"))
#	if new_files.has(asset):
#		return new_files[asset]
#	if changed_files.has(asset):
#		return changed_files[asset]
	if asset in loaded_assets.keys():
#		loaded_assets[asset].texture_page.set_size_override(tex.get_size())
#		loaded_assets[asset].texture_page.set_data(tex.get_data())
		return loaded_assets[asset]

	var meta = Meta.new()
	var size = goto(asset)
	if size == null: return null
	meta.parse(self, size, tex)
	loaded_assets[asset] = meta
	return meta
	
func parse_phyremeta(asset, base_wad=null, lazy=0):
	if lazy:
		asset = lazy_find(asset)
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_phyremeta(asset)
	if new_files.has(asset):
		return new_files[asset]
	if changed_files.has(asset):
		return changed_files[asset]
	if asset in loaded_assets.keys():
#		loaded_assets[asset].texture_page.set_size_override(tex.get_size())
#		loaded_assets[asset].texture_page.set_data(tex.get_data())
		return loaded_assets[asset]
	
	var from = self
	if base_wad != null:
		from = base_wad
	var a = from.get_bin(phyreAtlasesBin)
	var s = from.get_bin(phyreSpritesBin)
	var b = from.get_bin(phyreBackgroundsBin)
		
	var size = goto(asset)
	if size == null: return null
	var ags = PhyreMeta.new()
	ags.parse(self, size, s, a, b, asset)
	close()
	loaded_assets[asset] = ags
	return ags


func sprite_id_to_atlas_id(sprite_id):
	return atlasbin.atlas_sprites[sprite_id]

func sprite_id_to_atlas_name(sprite_id):
	return atlasbin.atlas_names[sprite_id_to_atlas_id(sprite_id)]

func sprite_id_to_sprite_name(sprite_id):
	return spritebin.get_sprite_name(sprite_id)

func sprite_id_to_uv_index(sprite_id):
	return atlasbin.atlas_data[sprite_id]

var meta_cache = {}

func get_frames(sprite_id):
	var target_atlas_id = sprite_id_to_atlas_id(sprite_id)
	if target_atlas_id >= 4294967295 - 10:
		return []
	var frames = []
	var ags = null
	if meta_cache.has(target_atlas_id):
		ags = meta_cache[target_atlas_id]
		frames = ags.get_frames(ags.order[sprite_id], spritebin.sprites[sprite_id].frame_count)
	else:
		ags = parse_phyremeta(sprite_id_to_atlas_name(sprite_id))
		if ags == null:
			return []
		var sprite_order = {}
		var i = 0
		var t = 0
		for spr in spritebin.sprites.values():
			var a = sprite_id_to_atlas_id(spr.id)
			if spr.id == sprite_id:
				frames = ags.get_frames(i, spr.frame_count)
			if a == target_atlas_id:
				sprite_order[spr.id] = t
				t += spr.frame_count
				i += 1
		meta_cache[target_atlas_id] = ags
		ags.order = sprite_order
#	if len(frames) and ags:
#		var spr = spritebin.sprites[sprite_id]
#		var img = Image.new()
#		img.create(spr.frame_count * spr.size.x, spr.size.y, false, Image.FORMAT_RGBA8)
#		for j in range(len(frames)):
#			img.blit_rect(ags.texture.get_data(), frames[j].region, Vector2(j*spr.size.x, 0))
#		img.save_png("res://Scripts/Asset Scripts/parsed ags files/strips/%s.png" % [sprite_id_to_sprite_name(sprite_id)])
	return frames

func parse_fnt(asset, lazy=0):
	if lazy:
		asset = lazy_find(asset)
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_fnt(asset)
	var tex = null
	if ".fnt" in asset:
		tex = sprite_sheet(asset.replace(".fnt", "_0.png"))
#	if new_files.has(asset):
#		return new_files[asset]
#	if changed_files.has(asset):
#		return changed_files[asset]
	if asset in loaded_assets.keys():
#		loaded_assets[asset].texture_page.set_size_override(tex.get_size())
#		loaded_assets[asset].texture_page.set_data(tex.get_data())
		return loaded_assets[asset]

	var meta = WadFont.new()
	var size = goto(asset)
	if size == null: return null
	meta.parse(self, size, tex)
	loaded_assets[asset] = meta
	return meta

func parse_sprite_data(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_sprite_data(asset)
	if !exists(asset):return null
	var size = goto(asset)
	if size == null: return null
	var r = SpritesBin.new()
	if version == WAD_VERSION.HM1:
		r = phyreSpritesBin.new()
	r.parse(self)
	spritebin = r
	sprite_data = r.sprite_data
	loaded_assets[asset] = r
	return r
	

func get_sprite_data(sprite_name):
	return spritebin.sprite_data[sprite_name]

func get_s32():
	var n = get_32()
	if n > 0x7FffFFff:
		return n - 0xFFffFFff - 1
	return n
#func store_s32(n):
#	if n > 0x7FffFFff:
#		return n - 0xFFffFFff - 1
#	return n

func parse_objects(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_objects(asset)
	var size = goto(asset)
	if size == null: return null
	var o = ObjectsBin.new()
	if version == WAD_VERSION.HM1:
		o = phyreObjectsBin.new()
	o.parse(self)
	objectbin = o
	loaded_assets[asset] = o
	return o

func get_object_data(object_name):
	return objectbin.object_data[object_name]

func parse_rooms(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_rooms(asset)
	if !exists(asset):return null
	var size = goto(asset)
	if size == null: return null
	var o = RoomsBin.new()
	if version == WAD_VERSION.HM1:
		o = phyreRoomsBin.new()
	o.parse(self)
	roombin = o
	loaded_assets[asset] = o
	return o

func parse_backgrounds(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_backgrounds(asset)
	var size = goto(asset)
	if size == null: return null
	var b = BackgroundsBin.new()
	if version == WAD_VERSION.HM1:
		b = phyreBackgroundsBin.new()
	b.parse(self)
	backgroundbin = b
	loaded_assets[asset] = b
	return b

func parse_atlases(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_backgrounds(asset)
	var size = goto(asset)
	if size == null: return null
	var b = AtlasesBin.new()
	if version == WAD_VERSION.HM1:
		b = phyreAtlasesBin.new()
	b.parse(self)
	loaded_assets[asset] = b
	return b

func parse_sounds(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_sounds(asset)
	var size = goto(asset)
	if size == null: return null
	var b = SoundsBin.new()
	if version == WAD_VERSION.HM1:
		b = phyreSoundsBin.new()
	b.parse(self)
	loaded_assets[asset] = b
	return b

func parse_col_masks(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_col_masks(asset)
	var size = goto(asset)
	if size == null: return null
	var b = CollisionMasksBin.new()
	if version == WAD_VERSION.HM1:
		b = phyreCollisionMasksBin.new()
	b.parse(self)
	loaded_assets[asset] = b
	return b

func get_from_cache(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.get_bin(asset)
	if loaded_assets.has(asset):
		return loaded_assets[asset]
	if new_files.has(asset):
		return new_files[asset]
	if changed_files.has(asset):
		return changed_files[asset]
	return null

func get_bin(bintype):
	var asset = bintype
	if !(bintype is String):
		asset = bintype.get_file_path() # by default will be hm2
	if !is_open(): open(file_path, READ)
	var r = null
	if asset.ends_with('sprites.bin'):
		if version == WAD_VERSION.HM1:
			asset = phyreSpritesBin.get_file_path()
		r = get_from_cache(asset)
		if !r:
			r = parse_sprite_data(asset)
	elif asset.ends_with('objects.bin'):
		if version == WAD_VERSION.HM1:
			asset = phyreObjectsBin.get_file_path()
		r = get_from_cache(asset)
		if !r:
			r = parse_objects(asset)
	elif asset.ends_with('rooms.bin'):
		if version == WAD_VERSION.HM1:
			asset = phyreRoomsBin.get_file_path()
		r = get_from_cache(asset)
		if !r:
			r = parse_rooms(asset)
	elif asset.ends_with('backgrounds.bin'):
		if version == WAD_VERSION.HM1:
			asset = phyreBackgroundsBin.get_file_path()
		r = get_from_cache(asset)
		if !r:
			r = parse_backgrounds(asset)
	elif asset.ends_with('atlases.bin'):
		if version == WAD_VERSION.HM1:
			asset = phyreAtlasesBin.get_file_path()
		r = get_from_cache(asset)
		if !r:
			r = parse_atlases(asset)
	elif asset.ends_with('sounds.bin'):
		if version == WAD_VERSION.HM1:
			asset = phyreSoundsBin.get_file_path()
		r = get_from_cache(asset)
		if !r:
			r = parse_sounds(asset)
	elif asset.ends_with('masks.bin'):
		if version == WAD_VERSION.HM1:
			asset = phyreCollisionMasksBin.get_file_path()
		r = get_from_cache(asset)
		if !r:
			r = parse_col_masks(asset)
	close()
	return r
	if !exists(asset):return null

func parse_original_sprite_sheet(asset, lazy=0):
	if lazy:
		asset = lazy_find(asset)
	if !is_open(): open(file_path, READ)
	var img = Image.new()
	var size = goto(asset)
	var data = get_buffer(size)
	if !(data is PoolByteArray):
		return data
	img.load_png_from_buffer(data)
#	img.convert(fmt)
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	close()
	return tex

func parse_orginal_meta(asset, lazy=0, tex=null):
	if !is_open(): open(file_path, READ)
	if lazy:
		asset = lazy_find(asset)
	if tex == null:
		tex = sprite_sheet(asset.replace(".meta", ".png"))

	var meta = Meta.new()
	var size = goto(asset)
	if size == null: return null
	meta.parse(self, size, tex)
	loaded_assets[asset] = meta
	return meta
