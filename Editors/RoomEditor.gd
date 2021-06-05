extends VBoxContainer


onready var app = get_tree().get_nodes_in_group('App')[0]
onready var room_tree = $TabContainer2/Advanced/RoomTree

var rooms = null
var room = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_room(room_name):
	room_tree.reset()
	rooms = app.base_wad.roombin
	room = rooms.room_data[room_name]
	room_tree.create_dict(room)
	$"TabContainer2/Room View/TextureRect/Control".room = room
	$"TabContainer2/Room View/TextureRect/Control".update()
	return rooms


func _on_RoomTree_item_edited(deleted=0):
	var ti :TreeItem= room_tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if int(s) or s == '0':
			s = int(s)
		p.push_front(s)
		ti = ti.get_parent()
	p.pop_front()
	var last_k = p.pop_back()
	var d = room
	for k in p:
		d = d[k]
	if deleted == 0:
		var value = room_tree.get_selected().get_text(1)
		if d[last_k] is Vector2:
			value.replace('(','')
			value.replace(')','')
			value = value.split(',')
			if int(value[0]) and int(value[1]):
				d[last_k] = Vector2(int(value[0]), int(value[1]))
		elif d[last_k] is int and int(value):
			d[last_k] = int(value)
		room_tree.get_selected().set_text(1, str(d[last_k]))
	elif deleted == 1:
		d.remove(last_k)
		room_tree.get_selected().free()
		print('kapow!')
	elif deleted == 2:
		pass

func change_order(_room, new_next, new_previous):
	rooms.room
