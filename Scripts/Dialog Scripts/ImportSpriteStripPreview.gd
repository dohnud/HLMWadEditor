extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var f_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	if !texture:return
	var sprite_w = texture.get_width()
	var window_w = rect_size.x
	var sprite_h = texture.get_height()
	var window_h = rect_size.y
	
	var s = sprite_h / window_h
	var x = window_w/2 - sprite_w/(2*s)
	if x < 0:
		x = 0
		s = 1
		sprite_w = window_w
	if f_count > 0:
		var d = sprite_w / (f_count * s)
		for i in range(f_count-1):
			x += d
			draw_line(Vector2(x,0), Vector2(x,window_h), Color.red)


func _on_SpinBox_value_changed(value):
	f_count = int(value)
	update()
