extends Control

onready var app = get_tree().get_nodes_in_group('App')[0]

var room = null

func _draw():
	if room:
		for obj in room['objects']:
			draw_circle(obj['pos']*scale,2,Color(1,1,1,1))
		for obj in room['objects']:
			draw_string(get_font('font'), obj['pos']*scale, str(obj['id']))


var scale = 1
func _on_TextureRect_gui_input(e:InputEvent):
	print(e)
	if e is InputEventPanGesture:
		rect_position += e.delta * scale
		update()
	if e is InputEventMagnifyGesture:
		scale *= e.factor
		print(e.factor, ' ', scale)
		update()
