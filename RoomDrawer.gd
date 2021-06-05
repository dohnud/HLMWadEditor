extends Control

onready var app = get_tree().get_nodes_in_group('App')[0]

var room = null

func _draw():
	if room:
		for obj in room['objects']:
			draw_circle(obj['pos'],2,Color(1,1,1,1))
