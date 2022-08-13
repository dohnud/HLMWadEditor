extends Resource

class_name WadFont

var texture_page = null
var meta :Meta= null

var fnt = {
	'info': ['face', 'size', 'bold', 'italic', 'charset', 'unicode', 'stretchH', 'smooth', 'aa', 'padding', 'spacing', 'outline'],
	'common': ['lineHeight','base', 'scaleW', 'scaleH', 'pages', 'packed', 'alphaChnl', 'redChnl', 'greenChnl', 'blueChnl'],
	'page': ['id', 'file'],
	'chars': ['count'],
	'char': ['id', 'x', 'y', 'width', 'height', 'xoffset', 'yoffset', 'xadvance', 'page', 'chnl']
}

var data = {
#	'info': ['face', 'size', 'bold', 'italic', 'charset', 'unicode', 'stretchH', 'smooth', 'aa', 'padding', 'spacing', 'outline'],
#	'common': ['lineHeight','base', 'scaleW', 'scaleH', 'pages', 'packed', 'alphaChnl', 'redChnl', 'greenChnl', 'blueChnl'],
#	'page': ['id', 'file'],
#	'chars': ['count'],
#	'char': ['id', 'x', 'y', 'width', 'height', 'xoffset', 'yoffset', 'xadvance', 'page', 'chnl']
}

func parse(f, size, tex):
	texture_page = tex
	var xmlparser = XMLParser.new()
	if xmlparser.open_buffer(f.get_buffer(size)):
		print('error opening font xml!')
		return null
#	print(xmlparser.get_node_name())
	while !xmlparser.read():
		if xmlparser.get_node_type() == XMLParser.NODE_TEXT:
			continue
		var k = xmlparser.get_node_name()
		if fnt.has(k):
			var tag = {}
			for i in range(xmlparser.get_attribute_count()):
				var attr = xmlparser.get_attribute_name(i)
				if fnt[k].has(attr):
					tag[attr] = xmlparser.get_attribute_value(i)
			if data.has(k):
				if data[k] is Dictionary:
					data[k] = [data[k]]
				data[k].append(tag)
			else:
				data[k] = tag
	meta = Meta.new()
	meta.texture_page = texture_page
	for ch in data.char:
		var t = AtlasTexture.new()
		t.region = Rect2(ch.x, ch.y, ch.width, ch.height)
		t.atlas = texture_page
		meta.sprites.add_animation(ch.id)
		meta.sprites.add_frame(ch.id, t)
	return self


func write(f):
	f.store_string('<?xml version="1.0"?>\n<font>\n')
	f.store_string('<font>\n')
	var t = 'info'
	f.store_string('<'+t)
	for attr in data[t]:
		f.store_string(' %s="%s"' % [attr, data[t][attr]])
	f.store_string('/>\n')

	t = 'common'
	f.store_string('<'+t)
	for attr in data[t]:
		f.store_string(' %s="%s"' % [attr, data[t][attr]])
	f.store_string('/>\n')

	f.store_string('<pages>\n')
	t = 'page'
	f.store_string('<'+t)
	for attr in data[t]:
		f.store_string(' %s="%s"' % [attr, data[t][attr]])
	f.store_string('/>\n')
	f.store_string('</pages>\n')

	t = 'chars'
	f.store_string('<'+t)
	for attr in data[t][0]:
		f.store_string(' %s="%s"' % [attr, data[t][attr]])
	f.store_string('>\n')

	t = 'char'
	for tag in data[t]:
		f.store_string('<'+t)
		var frame :AtlasTexture= meta.sprites.get_frame(tag.id,0);
		tag.x = frame.region.position.x
		tag.y = frame.region.position.y
		tag.width = frame.region.size.x
		tag.width = frame.region.size.y
		for attr in tag.keys():
			f.store_string(' %s="%s"' % [attr, tag[attr]])
		f.store_string('/>\n')
	f.store_string('</chars>\n')
	f.store_string('</font\n>')

func to_godot_font():
	var region : Rect2
	var btmfont = BitmapFont.new()
	btmfont.add_texture(texture_page)
	for ch in data.char:
		var frame :AtlasTexture= meta.sprites.get_frame(ch.id,0);
		btmfont.add_char(int(ch.id), 0, frame.region, Vector2(int(ch.xoffset), int(ch.yoffset)), int(ch.xadvance))
	return btmfont
