extends BinParser

class_name CollisionMasksBin



const file_path = 'GL/hlm2_collision_masks.bin'
var mask_data = {}
var masks = {}
var mask_indicies = []
var mask_names = {}

var msk = {
	'id': '32',
	'x' : '32',
	'width': '32',
	'height': '32',
	'frame_count': '32',
	'data':['']
}

func resize(mask_id, width, height, frame_count=-1):
	var mask = mask_data[mask_id]
	if frame_count == -1:
		if width == mask.width and height == mask.height:
			return mask
		frame_count = mask.frame_count
	if width == mask.width and height == mask.height and frame_count == mask.frame_count:
		return mask
	mask.frame_count = frame_count
	var row_size = mask.x * 8
	var new_row_x = ceil(float(width)/8.0)
	mask.x = new_row_x
	mask.width = width
	mask.height = height
	mask.data.resize(mask.frame_count)
	for f in range(len(mask.data)):
		var frame = mask.data[f]
		if frame == null:
			mask.data[f] = []
			frame = mask.data[f]
		frame.resize(mask.height)
		for r in range(len(frame)):
			var row = frame[r]
			if row == null:
				frame[r] = []
				row = frame[r]
			row.resize(mask.x*8)
			for b in range(len(row)):
				if row[b] == null: row[b] = 0
	return mask


func compute_new_mask(mask_id, image_index, img:Image):
#	var i = img.get_rect(Rect2(0,0,img.get_width(),img.get_height()))
	
#	img.convert(Image.FORMAT_L8)
	img.lock()
	var mask = resize(mask_id, img.get_width(), img.get_height())
	var f = mask.data[image_index]
	for y in range(len(f)):
		for x in range(len(f[y])):
			f[y][x] = 0
			if x < mask.width and y < mask.height:
				f[y][x] = 0xFF * int(0<img.get_pixel(x,y).a)
#	mask_data[mask_id].data[image_index] = i.convert(Image.FORMAT_L8)

func byte_array_to_int(bytes):
#	var t = 0
##	var o = 8*len(bytes)
#	for i in range(len(bytes)-1,0, -1):
#		var f = (bytes[i] & 0xFF)
#		var ii = i*8
#		if ii:
#			t = t | ( f << ii)
#	return t
	return ((bytes[3] & 0xFF) << 24) | ((bytes[2] & 0xFF) << 16) | ((bytes[1] & 0xFF) << 8) | ((bytes[0] & 0xFF) << 0)

func parse(file_pointer):
	var f :File= file_pointer
#	mask_indicies = parse_index_list(f)
#	masks = parse_struct_map(f, msk, 'id')
#	mask_names = parse_string_map(f)
#	var tf = File.new()
	var start = f.get_position()
	var mask_num = f.get_32()
	for i in range(mask_num):
		var p = f.get_position()
		var mask = parse_struct(f, msk)
#		var data_len = mask.x * mask.height
		for fi in range(mask.frame_count):
			var fdata = []
			for r in range(mask.height):
				var buffer = f.get_buffer(mask.x)
				var row = []
				for byte in buffer:
					for shift in range(8):
						row.append(((byte >> shift) & 1)*0xFF)
				fdata.append(row)
#				fdata += row
			mask.data.append(fdata)
#			if mask.id == 2388:
#				var img = Image.new()
#				img.create_from_data(mask.x * 8, mask.height, false, Image.FORMAT_L8, fdata)
#				img.save_png('exported/collision_masks/png/0sprMagnum.png')
#		mask.data.append(parse_simple_list(f, '32', int(data_len/4)))
#		if data_len % 4:
#			mask.data.append(parse_simple_list(f, '8', data_len % 4))
		var s = mask.id
#		mask['name'] = s
#		Log.log('location: '+ "0x%x" % (f.get_position()-start))
#		Log.log('bin index : '+ str(i))
#		Log.log('mask_index : '+ str(mask.id))
#		Log.log('x : '+ str(mask.x))
#		Log.log('width : '+ str(mask.width))
#		Log.log('height : '+ str(mask.height))
#		Log.log('frame_count : '+ str(mask.frame_count))
##		Log.log('data size : '+ str(data_len))
#		Log.log('data : '+ str(mask.data))
#		Log.log('----------------------')
#		tf = File.new()
#		tf.open('exported/collision_masks/'+str(s)+'.bin', File.WRITE)
#		write_struct(tf, msk, mask)
#		write_simple_list(tf, mask.data[0], '32', 0, false)
#		if data_len % 4:
#			write_simple_list(tf, mask.data[1], '8', 0, false)
#		tf.close()
		mask_data[s] = mask

func write(file_pointer):
	var f :File= file_pointer
#	mask_indicies = parse_index_list(f)
#	masks = parse_struct_map(f, msk, 'id')
#	mask_names = parse_string_map(f)
	f.store_32(len(mask_data))
	for m in mask_data.keys():
		var mask = mask_data[m]
		write_struct(f, msk, mask)
#		for fi in range(mask.frame_count):
#			f.store_buffer(mask.data[fi])
		for fr in mask.data:
			for r in fr:
				for b in range(0,len(r), 8):
					var byte = 0
					for bi in range(8):
						byte = byte | ((r[b+bi] & 1) << bi)
					f.store_8(byte)
