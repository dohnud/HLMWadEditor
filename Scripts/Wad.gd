extends File

class_name Wad

#var file_list = []
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

var loaded_sheets = {}
var loaded_atlases = {}
var loaded_metas = {}
var loaded_simples = {}
var loaded_bins = {}

var new_files = {
	#"path/to/file.meta" : Meta()
}
var changed_files = {
	#"path/file.meta": Meta()
}

var loaded_audio = {}

var identifier = PoolByteArray()
var obselete_directory = PoolByteArray()

var audio_print=false

func parse_header():
#	seek(0x10)
	identifier = get_buffer(0x10)
	
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
	var come_back = get_position()
	var _num_dirs = get_32()
	for _i in range(_num_dirs):
		var _dir_name_l = get_32()
		var _dir_name = get_buffer(_dir_name_l)#.get_string_from_ascii()
		var _num_entries = get_32()
		for _j in range(_num_entries):
			var _entry_name_l = get_32()
			var _entry_name = get_buffer(_entry_name_l)
			var _entry_type = get_8()
	var _dir_end = get_position()
	seek(come_back)
	obselete_directory = get_buffer(_dir_end - come_back)
	
	# raw file data starts here
	content_offset = get_position()

func write_wad(file_pointer):
	var f = file_pointer
	# skip wad identifier for now
	f.store_buffer(identifier)
	
	# parse file locations
	var num_files = len(file_locations.keys())
	f.store_32(num_files)
	var current_offset = 0
	for k in file_locations.keys():
		# metadata
		f.store_32(len(k))
		f.store_buffer(PoolByteArray(k.to_ascii()))
		f.store_64(file_locations[k][1]) # len
		f.store_64(current_offset) # offset
		current_offset += file_locations[k][1]
	
	# fix so it recalculates directory dsoesnt matter but is nice
	f.store_buffer(obselete_directory)
	
	for k in file_locations.keys():
		if changed_files.has(k):
			k.save(f)
		f.store_buffer(get(k))
	

func add_file(file_path):
	var f = File.new()
	if !f.open(file_path, File.READ):
		if '.meta' in file_path or '.gmeta' in file_path:
			var folder = "Atlases/"
			var tex = add_file(file_path.replace('.gmeta', '.png'))
			var meta = Meta.new()
			f.seek_end()
			var s = f.get_position()
			f.seek(0)
			meta.parse(f, s, tex)
			new_files[folder + file_path.get_file()] = meta
			loaded_metas[folder + file_path.get_file()] = meta
			meta.is_gmeta = '.gmeta' in file_path
			return meta
		if '.png' in file_path:
			var folder = "Atlases/"
			var image = Image.new()
			var texture = ImageTexture.new()
			var err = image.load(file_path)
			if err != OK:
				print('ouch couldnt load: ', file_path)
				return null
			texture.create_from_image(image, 0)
			new_files[folder + file_path.get_file()] = texture
			loaded_sheets[folder + file_path.get_file()] = texture
			return texture
	return null
#func write_patch(file_pointer):
#

func exists(asset_name):
	return asset_name in file_locations.keys()

func lazy_find(asset_name):
	for k in file_locations.keys():
		if asset_name == k.get_file():
			return k
	return asset_name

func goto(asset):
	for p in patchwad_list:
		if p.exists(asset):
			return p.get(asset)
	var dim = file_locations[asset]
	seek(content_offset + dim[0])
	return dim[1]

func get(asset):
	return get_buffer(goto(asset))

func apply_patchwad(f):
	var patchwad = get_script().new()
	patchwad.open(f, File.READ)
	patchwad.parse_header()
	patchwad_list.append(patchwad)

func patch(wad):
	patchwad_list.append(wad)

func sprite_sheet(asset, lazy=0):
	if lazy:
		asset = lazy_find(asset)
	if asset in loaded_sheets.keys():
		return loaded_sheets[asset]
	for p in patchwad_list:
		if p.exists(asset):
			return p.sprite_sheet(asset)
	var img = Image.new()
	img.load_png_from_buffer(get(asset))
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	loaded_sheets[asset] = tex
	return tex

func audio_stream(asset, lazy=0 ,repeat=false):
	if lazy:
		asset = lazy_find(asset)
	if asset in loaded_audio.keys():
		return loaded_audio[asset]
	
	if asset!=null:
		var bytes = get(asset)
		var newstream = null
		# if File is wav
		if asset.ends_with(".wav"):
			newstream = AudioStreamSample.new()
			#---------------------------
			#parrrrseeeeee!!! :D
			var i = 0
			var riff_found = false
			var wave_found = false
			var fmt_found = false
			var data_found = false
			while i < len(bytes) and !(riff_found and wave_found and fmt_found and data_found):
				var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
				
				if those4bytes == "RIFF": 
					if audio_print:
						print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
					#RIP bytes 4-7 integer for now
					i += 8
					riff_found = true
					continue
				if those4bytes == "WAVE": 
					if audio_print:
						print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))
					i += 4
					wave_found = true
					continue

				if those4bytes == "fmt ":
					if audio_print:
						print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
					
					#get format subchunk size, 4 bytes next to "fmt " are an int32
					var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
					if audio_print:
						print ("Format subchunk size: " + str(formatsubchunksize))
					
					#using formatsubchunk index so it's easier to understand what's going on
					i += 8
					var fsc0 = i #fsc0 is byte 8 after start of "fmt "

					#get format code [Bytes 0-1]
					var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
					var format_name
					if format_code == 0: format_name = "8_BITS"
					elif format_code == 1: format_name = "16_BITS"
					elif format_code == 2: format_name = "IMA_ADPCM"
					if audio_print:
						print ("Format: " + str(format_code) + " " + format_name)
					#assign format to our AudioStreamSample
					newstream.format = format_code
					
					#get channel num [Bytes 2-3]
					var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
					if audio_print:
						print ("Number of channels: " + str(channel_num))
					#set our AudioStreamSample to stereo if needed
					if channel_num == 2: newstream.stereo = true
					
					#get sample rate [Bytes 4-7]
					var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
					if audio_print:
						print ("Sample rate: " + str(sample_rate))
					#set our AudioStreamSample mixrate
					newstream.mix_rate = sample_rate
					
					#get byte_rate [Bytes 8-11] because we can
					var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 24)
					if audio_print:
						print ("Byte rate: " + str(byte_rate))
					
					#same with bits*sample*channel [Bytes 12-13]
					var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
					if audio_print:
						print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
					#aaaand bits per sample [Bytes 14-15]
					var bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
					if audio_print:
						print ("Bits per sample: " + str(bits_per_sample))
					i += 16
					fmt_found = true
					continue
					
				if those4bytes == "data":
					var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
					if audio_print:
						print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

					i += 8
					var data_entry_point = i
					if audio_print:
						print ("Audio data starts at byte " + str(data_entry_point))
					
					newstream.data = bytes.subarray(data_entry_point, data_entry_point+audio_data_size-1)
					i += audio_data_size
					i += 4
					data_found = true
					continue
				i += 1
				# end of parsing
				#---------------------------

			#get samples and set loop end
			var samplenum = newstream.data.size() / 4
			newstream.loop_end = samplenum
			newstream.loop_mode = 0 #change to 0 or delete this line if you don't want loop, also check out modes 2 and 3 in the docs

		#if file is ogg
		elif asset.ends_with(".ogg"):
			newstream = AudioStreamOGGVorbis.new()
			newstream.loop = false #set to false or delete this line if you don't want to loop
			newstream.data = bytes

		#if file is mp3
	#	elif asset.ends_with(".mp3"):
	#		newstream = AudioStreamMP3.new()
	#		newstream.loop = true #set to false or delete this line if you don't want to loop
	#		newstream.data = bytes
	#		return newstream

		else:
			print ("ERROR: Wrong filetype or format")
			return null
		loaded_audio[asset] = newstream
		return loaded_audio[asset]

func byte_array_to_int(bytes):
		return ((bytes[3] & 0xFF) << 24) | ((bytes[2] & 0xFF) << 16) | ((bytes[1] & 0xFF) << 8) | ((bytes[0] & 0xFF) << 0)

# rename animated_sprite
func parse_meta(asset, lazy=0):
	if lazy:
		asset = lazy_find(asset)
	if asset in loaded_metas.keys():
		return loaded_metas[asset]
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_meta(asset)
	var tex = sprite_sheet(asset.replace(".meta", ".png"), lazy)

	var meta = Meta.new()
	var size = goto(asset)
	meta.parse(self, size, tex)
	loaded_metas[asset] = meta
	return meta

func parse_sprite_data():
	var asset = 'GL/hlm2_sprites.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_sprite_data(asset)
	var size = goto(asset)
	var r = SpritesBin.new()
	r.parse(self)
	spritebin = r
	sprite_data = r.sprite_data
	loaded_bins[asset] = r
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
	var o = ObjectsBin.new()
	o.parse(self)
	objectbin = o
	loaded_bins[asset] = o
	return o
	var start = get_position()
	
	var num_objects = get_32()
	# parse silly header
	var dumb_header = []
	var n = 0
	while n <= num_objects:
		var num = get_32()
		if num == 0xFFffFFff:
			num_objects -= 1
			continue
		n += 1
		dumb_header.append(num)
	# parse objects :D
	var objects = {}
	for i in range(num_objects):
		var id = get_32()
		if id > max_object_index:
			max_object_index = id
		objects[id] = {
			'id' : id,
			'sprite' : get_s32(),
			'depth' : get_s32(),
			'parent' : get_s32(),
			'masksprite' : get_s32(),
			'solid' : get_32(),
			'visible' : get_32(),
			'persistent' : get_32(),
			'priority' : get_64(),
#			'extra flags' : [get_32(), get_32()],
			'sprite name pos' : get_32()
		}
#	var s = 0
#	for i in objects.values():
#		print(i)
#		if s > 100: break
#		s += 1
	var object_name_list_size = get_32()
	var object_name_list_start = get_position()
	# there will always be a congruence with the object name list and object count
	for index in objects.keys():
		var s = ''
		var i = get_buffer(1)[0]
		while i != 0:
			s += char(i)
			i = get_buffer(1)[0]
		object_data[s] = objects[index]

func get_object_data(object_name):
	return objectbin.object_data[object_name]

func parse_rooms():
	var asset = 'GL/hlm2_rooms.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_rooms(asset)
	var size = goto(asset)
	var o = RoomsBin.new()
	o.parse(self)
	roombin = o
	loaded_bins[asset] = o
	return o

func parse_backgrounds():
	var asset = 'GL/hlm2_backgrounds.bin'
	for p in patchwad_list:
		if p.exists(asset):
			return p.parse_backgrounds(asset)
	var size = goto(asset)
	var b = BackgroundsBin.new()
	b.parse(self)
	backgroundbin = b
	loaded_bins[asset] = b
	return b

func get_bin(asset):
	if loaded_bins.has(asset):
		return loaded_bins[asset]
	for p in patchwad_list:
		if p.exists(asset):
			return p.get_bin(asset)
	if asset == SpritesBin.file_path:
		return parse_sprite_data()
	elif asset == ObjectsBin.file_path:
		return parse_objects()
	elif asset == RoomsBin.file_path:
		return parse_rooms()
	elif asset == BackgroundsBin.file_path:
		return parse_backgrounds()
	return null

func write_objects():
	var file_start = get_position()
	var num_objects = max_object_index+1
	var actual_num_objects = len(object_data.keys())
	store_32(num_objects)
	# write silly header
	for i in range(num_objects):
		if i < actual_num_objects:
			store_32(i)
		else:
			store_32(0xFFffFFff)
	# write objects :D
	for k in object_data.keys():
		store_32(object_data[k]['id'])
		store_32(object_data[k]['sprite'])# : get_s32(),
		store_32(object_data[k]['depth'])# : get_s32(),
		store_32(object_data[k]['parent'])# : get_s32(),
		store_32(object_data[k]['masksprite'])# : get_s32(),
		store_32(object_data[k]['solid'])# : get_32(),
		store_32(object_data[k]['visible'])# : get_32(),
		store_32(object_data[k]['persistent'])# : get_32(),
		store_64(object_data[k]['priority'])# : get_64(),
		store_32(object_data[k]['sprite name pos'])# : get_32()
	var object_name_list_start = get_position()
	store_32(0)
	var object_name_list_size = actual_num_objects
	for k in object_data.keys():
		store_buffer(PoolByteArray(k.to_ascii()))
		object_name_list_size += len(k)
	seek(object_name_list_start)
	store_32(object_name_list_size)
	
	var file_end = get_position()
