extends TextureRect

export(Color) var old_bounds_color
export(Color) var new_bounds_color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var sprite_w = 0
var sprite_h = 0


func _draw():
	if !texture:return
	draw_(texture.get_width(), texture.get_height(), old_bounds_color)
	draw_(sprite_w, sprite_h, new_bounds_color, texture.get_width(), texture.get_height())
#	var _sprite_w = texture.get_width()
#	var _sprite_h = texture.get_height()
#	var window_w = rect_size.x
##	var sprite_h = texture.get_height()
#	var window_h = rect_size.y
#	var sx = _sprite_h / window_h
#	var sy = _sprite_w / window_w
#	var x = window_w/2 - _sprite_w/(2*sx)
#	if x < 0:
#		x = 0
#		sx = 1
#		_sprite_w = window_w
#	var y = window_h/2 - _sprite_h/(2*sy)
#	if y < 0:
#		y = 0
#		sy = 1
#		_sprite_h = window_h
#	if sx <= 0: sx = 1
#	if sy <= 0: sy = 1
#	var dx = sprite_w / (sx)
#	var dy = sprite_h / (sy)
#	draw_rect(Rect2(x,y,dx,dy), new_bounds_color, false, 1)

func draw_(_sprite_w, _sprite_h, color, modulate_w=-1, modulate_h=-1):
	if modulate_w < 0:
		modulate_w = _sprite_w
	if modulate_h < 0:
		modulate_h = _sprite_h
#	if !texture:return
#	var sprite_w = texture.get_width()
	var window_w = rect_size.x
#	var sprite_h = texture.get_height()
	var window_h = rect_size.y
	var sx = modulate_h / window_h
	var sy = modulate_w / window_w
	var x = window_w/2 - modulate_w/(2*sx)
	var dx = modulate_w / (sx)
	var dy = modulate_h / (sy)
	if x < 0:
		x = 0
		sx = 1
		dx = window_w
	var y = window_h/2 - modulate_h/(2*sy)
	if y < 0:
		y = 0
		sy = 1
		dy = window_h
	if sx <= 0: sx = 1
	if sy <= 0: sy = 1
	draw_rect(Rect2(x,y,float(_sprite_w)/float(modulate_w) * dx, float(_sprite_h)/float(modulate_h) * dy), color, false, 1)

func _on_WidthSpinBox_value_changed(value):
	sprite_w = int(value)
	update()


func _on_HeightSpinBox_value_changed(value):
	sprite_h = int(value)
	update()
