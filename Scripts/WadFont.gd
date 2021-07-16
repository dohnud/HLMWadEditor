extends Node

class_name WadFont

var texture_page = null

var fnt = {
	'info': ['face', 'size', 'bold', 'italic', 'charset', 'unicode', 'stretchH', 'smooth', 'aa', 'padding', 'spacing', 'outline'],
	'common': ['lineHeight','base', 'scaleW', 'scaleH', 'pages', 'packed', 'alphaChnl', 'redChnl', 'greenChnl', 'blueChnl'],
	'page': ['id', 'file'],
	'chars': ['count'],
	'char': ['id', 'x', 'y', 'width', 'height', 'xoffset', 'yoffset', 'xadvance', 'page', 'chnl']
}

var data = {
	'info': ['face', 'size', 'bold', 'italic', 'charset', 'unicode', 'stretchH', 'smooth', 'aa', 'padding', 'spacing', 'outline'],
	'common': ['lineHeight','base', 'scaleW', 'scaleH', 'pages', 'packed', 'alphaChnl', 'redChnl', 'greenChnl', 'blueChnl'],
	'page': ['id', 'file'],
	'chars': ['count'],
	'char': ['id', 'x', 'y', 'width', 'height', 'xoffset', 'yoffset', 'xadvance', 'page', 'chnl']
}

func parse(f, size, tex):
	texture_page = tex
	var xmlparser = XMLParser.new()
	if xmlparser.open_buffer(f.get_buffer(size)):
		print('error opening font xml!')
		return null
	print(xmlparser.get_node_name())
	while !xmlparser.read():
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
	print(data)

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
	f.store_string('/>\n')
	
	
	t = 'char'
	for tag in data[t]:
		f.store_string('<'+t)
		for attr in tag.keys():
			f.store_string(' %s="%s"' % [attr, tag[attr]])
		f.store_string('/>\n')
	f.store_string('</chars>\n')
	f.store_string('</font\n>')
