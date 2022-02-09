extends File

class_name Wad

#var file_list = []
var file_path = ''
var file_locations = {}
var patchwad_list = []
var content_offset = -1
var content_size

var sprite_data = {}
var spritebin = null setget , spritebin_g
func spritebin_g():
	return get_bin(SpritesBin.file_path)
var object_data = {}
var objectbin = null setget , objectbin_g
func objectbin_g():
	return get_bin(ObjectsBin.file_path)
var max_object_index = -1
var roombin = null setget , roombin_g
func roombin_g():
	return get_bin(RoomsBin.file_path)
var backgroundbin = null setget , bgbin_g
func bgbin_g():
	return get_bin(BackgroundsBin.file_path)

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
	if len(identifier.get_string_from_ascii()) < 5:
		seek(0)
	
	# parse file locations
	var num_files = get_32()
	file_locations.clear()
	#file_list.clear()
	for _i in range(num_files):
		# metadata
		var file_name_l = get_32();
		var file_name = get_buffer(file_name_l).get_string_from_ascii()
		var file_len = get_64()
		var file_offset = get_64()
		# add to file locations
		file_locations[file_name] = [file_offset, file_len]
		#file_list.append(file_name)
		
	# parse directories (unused but maybe useful later?)
#	var debug = File.new()
#	debug.open('debug.txt', File.WRITE)
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
	content_offset = get_position()
	
	patchwad_list = [get_script().new()]
	close()

	

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
	var dim = file_locations[asset]
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

func open_asset(asset_path):
	if new_files.has(asset_path):
		return new_files[asset_path]
	if changed_files.has(asset_path):
		return changed_files[asset_path]
	if asset_path.ends_with('.meta'):
		return parse_meta(asset_path)
	if asset_path.ends_with('.gmeta'):
		return parse_meta(asset_path)
	if asset_path.ends_with('.png'):
		return sprite_sheet(asset_path)
	if asset_path.ends_with('.bin'):
		return get_bin(asset_path)
	return null

func apply_patchwad(f):
	var patchwad = get_script().new()
	patchwad.open(f, File.READ)
	patchwad.parse_header()
	patchwad_list.append(patchwad)

func patch(wad):
	patchwad_list.append(wad)
	for f in wad.file_locations.keys():
		changed_files[f] = wad.open_asset(f)

func reset():
	changed_files = {}
	new_files = {}
	loaded_assets = {}
	patchwad_list = []

func revert(asset):
	changed_files.erase(asset)
	new_files.erase(asset)
	loaded_assets.erase(asset)
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
	if asset in loaded_assets.keys():
		return loaded_assets[asset]
	
	if asset!=null:
		var sound = WadSound.new()
		var size = goto(asset)
		if size == null: return null
		sound.parse(self, size, asset)
		loaded_assets[asset] = sound
		return sound


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

func parse_sprite_data():
	var asset = 'GL/hlm2_sprites.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_sprite_data(asset)
	if !exists(asset):return null
	var size = goto(asset)
	if size == null: return null
	var r = SpritesBin.new()
	r.parse(self)
	spritebin = r
	sprite_data = r.sprite_data
	loaded_assets[asset] = r
	return r
	var sprite_num = get_32()
	#while get_position() < content_offset + dim[0] + dim[1]:
	# sprite data begin
#	seek(content_offset + dim[0] + 0x4440)
	var sprite_indices = {}
	var sprite_index = get_32()
	while sprite_index < sprite_num:
		var w = get_32()
		var h = get_32()
		var x = get_32()
		var y = get_32()
		var alx = get_32()
		var aux = get_32()
		var aly = get_32()
		var auy = get_32()
		var frame_count = get_32()
		var flags = get_buffer(0x10)
		var name_pos = get_32()
		get_32() # padding
		sprite_indices[sprite_index] = {
			'id' : sprite_index,
			'dimesions' : [w,h],
			'center' : Vector2(x,y),
			'frame_count' : frame_count,
		}
		#print(sprite_indices[sprite_index])
		sprite_index = get_32()
	for index in sprite_indices.keys():
		var s = ''
		var i = get_buffer(1)[0]
		while i != 0:
			s += char(i)
			i = get_buffer(1)[0]
		sprite_data[s] = sprite_indices[index]
	sprite_data['default'] = {
		'id' : -1,
		'dimesions' : [1,1],
		'center' : Vector2(0,0),
		'frame_count' : 1,
	}

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

func parse_objects():
	var asset = 'GL/hlm2_objects.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_objects(asset)
	var size = goto(asset)
	if size == null: return null
	var o = ObjectsBin.new()
	o.parse(self)
	objectbin = o
	loaded_assets[asset] = o
	return o

func get_object_data(object_name):
	return objectbin.object_data[object_name]

func parse_rooms():
	var asset = 'GL/hlm2_rooms.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_rooms(asset)
	if !exists(asset):return null
	var size = goto(asset)
	if size == null: return null
	var o = RoomsBin.new()
	o.parse(self)
	roombin = o
	loaded_assets[asset] = o
	return o

func parse_backgrounds():
	var asset = 'GL/hlm2_backgrounds.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_backgrounds(asset)
	var size = goto(asset)
	if size == null: return null
	var b = BackgroundsBin.new()
	b.parse(self)
	backgroundbin = b
	loaded_assets[asset] = b
	return b

func parse_atlases():
	var asset = 'GL/hlm2_atlases.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_backgrounds(asset)
	var size = goto(asset)
	if size == null: return null
	var b = AtlasesBin.new()
	b.parse(self)
	loaded_assets[asset] = b
	return b

func parse_sounds():
	var asset = 'GL/hlm2_sounds.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_sounds(asset)
	var size = goto(asset)
	if size == null: return null
	var b = SoundsBin.new()
	b.parse(self)
	loaded_assets[asset] = b
	return b

func parse_col_masks():
	var asset = CollisionMasksBin.file_path
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_col_masks(asset)
	var size = goto(asset)
	if size == null: return null
	var b = CollisionMasksBin.new()
	b.parse(self)
	loaded_assets[asset] = b
	return b

func get_bin(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.get_bin(asset)
	if loaded_assets.has(asset):
		return loaded_assets[asset]
	if new_files.has(asset):
		return new_files[asset]
	if changed_files.has(asset):
		return changed_files[asset]
	if !exists(asset):return null
	if !is_open(): open(file_path, READ)
	var r = null
	if asset == SpritesBin.file_path:
		r = parse_sprite_data()
	elif asset == ObjectsBin.file_path:
		r = parse_objects()
	elif asset == RoomsBin.file_path:
		r = parse_rooms()
	elif asset == BackgroundsBin.file_path:
		r = parse_backgrounds()
	elif asset == AtlasesBin.file_path:
		r = parse_atlases()
	elif asset == SoundsBin.file_path:
		r = parse_sounds()
	elif asset == CollisionMasksBin.file_path:
		r = parse_col_masks()
	close()
	loaded_assets[asset] = r
	return r

func parse_orginal_meta(asset, lazy=0):
	if !is_open(): open(file_path, READ)
	if lazy:
		asset = lazy_find(asset)
	var tex = sprite_sheet(asset.replace(".meta", ".png"))

	var meta = Meta.new()
	var size = goto(asset)
	if size == null: return null
	meta.parse(self, size, tex)
	loaded_assets[asset] = meta
	return meta
