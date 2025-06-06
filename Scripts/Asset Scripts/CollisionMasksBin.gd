extends BinParser

class_name CollisionMasksBin



var version = 2
static func get_file_path():
	return 'GL/hlm2_collision_masks.bin'
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

#func resize(mask_id, width, height, frame_count=-1):
#	var mask = mask_data[mask_id]
#	if frame_count < 1:
#		if width == mask.width and height == mask.height:
#			return mask
#		frame_count = mask.frame_count
#	if width == mask.width and height == mask.height and frame_count == mask.frame_count:
#		return mask
#	mask.frame_count = frame_count
#	var row_size = mask.x * 8
#	var new_row_x = ceil(float(width)/8.0)
#	mask.x = new_row_x
#	mask.width = width
#	mask.height = height
#	mask.data.resize(mask.frame_count)
#	for f in range(mask.frame_count):
#		var frame = mask.data[f]
#		if frame == null:
#			mask.data[f] = []
#			frame = mask.data[f]
#		frame.resize(mask.height)
#		for r in range(len(frame)):
#			var row = frame[r]
#			if row == null:
#				frame[r] = []
#				row = frame[r]
#			row.resize(mask.x*8)
#			for b in range(len(row)):
#				if row[b] == null: row[b] = 0
#	return mask
#
#
#
#func compute_new_mask(mask_id, image_index, img:Image) -> Array:
#	# returns the new alpha rect
#	var x_bounds = Vector2(img.get_width(), 0)
#	var y_bounds = Vector2(img.get_height(),0)
#	img.lock()
#	if mask_data.has(mask_id):
#		var l = len(mask_data[mask_id].data)
#		if image_index >= l:
#			l = image_index + 1
#		var mask = resize(mask_id, img.get_width(), img.get_height(), l)
#		var f = mask.data[image_index]
#		for y in range(len(f)):
#			for x in range(len(f[y])):
#				f[y][x] = 0
#				if x < mask.width and y < mask.height:
#					f[y][x] = 0xFF * int(0<img.get_pixel(x,y).a)
#					if f[y][x]:
#						if x < x_bounds.x: x_bounds.x = x
#						if x > x_bounds.y: x_bounds.y = x
#						if y < y_bounds.x: y_bounds.x = y
#						if y > y_bounds.y: y_bounds.y = y
#	return [x_bounds, y_bounds]
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

#func parse(file_pointer):
#	var f :File= file_pointer
##	mask_indicies = parse_index_list(f)
##	masks = parse_struct_map(f, msk, 'id')
##	mask_names = parse_string_map(f)
##	var tf = File.new()
#	var start = f.get_position()
#	var mask_num = f.get_32()
#	for i in range(mask_num):
#		var p = f.get_position()
#		var mask = parse_struct(f, msk)
##		var data_len = mask.x * mask.height
#		for fi in range(mask.frame_count):
#			var fdata = []
#			for r in range(mask.height):
#				var buffer = f.get_buffer(mask.x)
#				var row = []
#				for byte in buffer:
#					for shift in range(8):
#						row.append(((byte >> shift) & 1)*0xFF)
#				fdata.append(row)
##				fdata += row
#			mask.data.append(fdata)
##			if mask.id >= 2387 and mask.id <= 2390:
##				var img = Image.new()
##				img.create_from_data(mask.x * 8, mask.height, false, Image.FORMAT_L8, fdata)
##				print('saved success yesyes??', mask.id, img.save_png('exported/collisionmasks/png/0'+str(mask.id)+'.png'))
##		mask.data.append(parse_simple_list(f, '32', int(data_len/4)))
##		if data_len % 4:
##			mask.data.append(parse_simple_list(f, '8', data_len % 4))
#		var s = mask.id
#		mask_data[s] = mask
#
#
#
#func write(file_pointer):
#	var f :File= file_pointer
##	mask_indicies = parse_index_list(f)
##	masks = parse_struct_map(f, msk, 'id')
##	mask_names = parse_string_map(f)
#	f.store_32(len(mask_data))
#	for m in mask_data.keys():
#		var mask = mask_data[m]
#		write_struct(f, msk, mask)
##		for fi in range(mask.frame_count):
##			f.store_buffer(mask.data[fi])
#		for fr in mask.data:
#			for r in fr:
#				for b in range(0,len(r), 8):
#					var byte = 0
#					for bi in range(8):
#						byte = byte | ((r[b+bi] & 1) << bi)
#					f.store_8(byte)


var image_cache = {}

class MaskEntry:
	var id:int
	var x:int
	var width:int = 1
	var height: int = 1
	var frame_count:int = 1
	var data : Array # [frame1[10][12], frame2[48][33]]
	var images : Array
	
	func resize(_width:int, _height:int, _frame_count:int=-1):
		if _frame_count < 1:
			if width == _width and height == _height:
				return self
			_frame_count = max(1, frame_count)
		if width == _width and height == _height and frame_count == _frame_count:
			return self
		frame_count = _frame_count
		width = _width
		height = _height
		x = ceil(float(width)/8.0)
		images.resize(frame_count)
		data.resize(frame_count)
		for f in range(frame_count):
			var frame = data[f]
			if frame == null:
				data[f] = []
				frame = data[f]
			frame.resize(height)
			for r in range(len(frame)):
				var row = frame[r]
				if row == null:
					frame[r] = []
					row = frame[r]
				row.resize(x*8)
				for b in range(len(row)):
					if row[b] == null: row[b] = 0
#		if width >0:
#			print('fasdf')
		return self
	
	
	func compute_mask_from_image(image_index, img:Image) -> Array:
		# returns the new alpha rect
		var x_bounds = Vector2(img.get_width(), 0)
		var y_bounds = Vector2(img.get_height(),0)
		img.lock()
#		var l = len(data)
#		if image_index >= l:
#			l = image_index + 1
		resize(x_bounds.x, y_bounds.x, image_index+1)
		var f = data[image_index]
		var bytes = []
#		bytes.resize(len(f) * len(f[0]))
		for y in range(len(f)):
			for x in range(len(f[y])):
				f[y][x] = 0
				if x < width and y < height:
					f[y][x] = 0xFF * int(0<img.get_pixel(x,y).a)
					if f[y][x]:
						if x < x_bounds.x: x_bounds.x = x
						if x > x_bounds.y: x_bounds.y = x
						if y < y_bounds.x: y_bounds.x = y
						if y > y_bounds.y: y_bounds.y = y
					bytes.append(f[y][x])
		var tex = ImageTexture.new()
		var img1 = Image.new()
		img1.create_from_data(width, height, 0, Image.FORMAT_L8, bytes)
		tex.create_from_image(img1, 0)
		images[image_index] = tex
		return [x_bounds, y_bounds]

#var masks = {}

func resize(mask_id, width, height, frame_count:int=-1):
	var mask :MaskEntry = null
	if masks.has(mask_id):
		mask = masks[mask_id]
	if mask == null:
		mask = MaskEntry.new()
		mask.id = mask_id
		masks[mask_id] = mask
	mask.resize(width, height, frame_count)
	return mask


func compute_new_mask(mask_id, image_index, img:Image) -> Array:
	var mask :MaskEntry = null
	if masks.has(mask_id):
		mask = masks[mask_id]
	if mask == null:
		mask = MaskEntry.new()
		mask.id = mask_id
		masks[mask_id] = mask
	var m = mask.compute_mask_from_image(image_index, img)
	return m
	

var ref_start = 0
func parse(file_pointer:File):
	var f :File= file_pointer
#	mask_indicies = parse_index_list(f)
#	masks = parse_struct_map(f, msk, 'id')
#	mask_names = parse_string_map(f)
#	var tf = File.new()
#	ref_start = f.get_position()
	var mask_num = f.get_32()

func write(ref_file, new_file):
	var nf :File= new_file
	var f :File= ref_file
#	f.seek(ref_start)
	var mask_num = f.get_32()
	nf.store_32(mask_num)
#	fn.store_32(len(mask_data))
	for i in range(mask_num):
		var id = f.get_32()
		var x = f.get_32()
		var w = f.get_32()
		var h = f.get_32()
		var fc = f.get_32()
		nf.store_32(id)
		if masks.has(id):
			var mask = masks[id]
			nf.store_32(mask.x)
			nf.store_32(mask.width)
			nf.store_32(mask.height)
			nf.store_32(mask.frame_count)
			
			for fr in mask.data:
				for r in fr:
					for b in range(0,len(r), 8):
						var byte = 0
						for bi in range(8):
							byte = byte | ((r[b+bi] & 1) << bi)
						nf.store_8(byte)
			f.seek(f.get_position() + x * h * fc)
		else:
			nf.store_32(x)
			nf.store_32(w)
			nf.store_32(h)
			nf.store_32(fc)
			nf.store_buffer(f.get_buffer(x * h * fc))


var f_cache = {}

func find(mask_id, ref_file):
	if masks.has(mask_id): return masks[mask_id]
	if !ref_file: return null
	var f = ref_file
	var mask_num = 1
	if f_cache.has(ref_file):
		if f_cache[ref_file].has(mask_id):
			f.seek(f_cache[ref_file][mask_id])
		else:
			mask_num = f.get_32()
	else:
		mask_num = f.get_32()
		f_cache[ref_file] = {}
#	fn.store_32(len(mask_data))
	var id = f.get_32()
	f_cache[ref_file][id] = f.get_position() - 0x04
	var x = f.get_32()
	var w = f.get_32()
	var h = f.get_32()
	var fc = f.get_32()
	for i in range(mask_num):
		if mask_id == id:
			var mask = MaskEntry.new()
			mask.x = x
			mask.width = w
			mask.height = h
			mask.frame_count = fc
			mask.data = []
			var data_len = mask.x * mask.height
			for fi in range(fc):
				var p_data = []
				var fdata = []
				for r in range(h):
					var buffer = f.get_buffer(x)
					var row = []
					for byte in buffer:
						for shift in range(8):
							row.append(((byte >> shift) & 1)*0xFF)
					fdata.append(row)
					p_data.append_array(row)
	#				fdata += row
				mask.data.append(fdata)
				var tex = ImageTexture.new()
				var img1 = Image.new()
#				img1.create_from_data(w, h, 0, Image.FORMAT_L8, f)
				img1.create_from_data(x*8, h,0, Image.FORMAT_L8, p_data)
#				img1.save_png("HELP_"+str(id)+'_' +str(fi)+ ".png")
				tex.create_from_image(img1, 0)
				mask.images.append(tex)
			return mask
		else:
#			nf.store_buffer(f.get_buffer(x * h * fc))
			f.seek(f.get_position() + x * h * fc)
		id = f.get_32()
		f_cache[ref_file][id] = f.get_position() - 0x04
		x = f.get_32()
		w = f.get_32()
		h = f.get_32()
		fc = f.get_32()
	return null

