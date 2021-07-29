extends Node

class SpriteEntry:
	var id:int
	var size : Vector2
	var center : Vector2
	var mask_x_bounds : Vector2
	var mask_y_bounds : Vector2
	var frame_count : int
	var flags: Array #[0x10]
	var name_pos : int
	var padding : int
	const types = {
		'id' : '32',
		'size' : 'ivec2',
		'center' : 'ivec2',
		'mask_x_bounds' : 'ivec2',
		'mask_y_bounds' : 'ivec2',
		'frame_count' : '32',
		'flags': [0x10],
		'name_pos' : '32',
		'padding' : '32'
	}
	
	func resize(width:int, height:int):
		size = Vector2(width, height)
	
	func parse(file_pointer:File):
		pass
	
func _init():
	var s = SpriteEntry.new()
	print(s.id)
	print(s.size)
	for p in s.get_property_list():
		print(p.name)
