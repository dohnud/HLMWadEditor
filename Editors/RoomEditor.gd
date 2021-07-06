extends BinEditor


#onready var app = get_tree().get_nodes_in_group('App')[0]
onready var room_tree = $TabContainer2/Advanced/RoomTree

var rooms = null
var room = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	file = RoomsBin.file_path
	tree = room_tree


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_room(room_name):
	set_bin_asset(room_name)
#	object_tree.reset()
	rooms = bin #app.base_wad.objectbin
	room = selected_struct #objects.object_data[object_name]
#	object_tree.create_dict(object)
	$"TabContainer2/Room View/TextureRect/Control".room = room
	$"TabContainer2/Room View/TextureRect/Control".rect_position = Vector2(10,10)
	$"TabContainer2/Room View/TextureRect/Control".create_room()
	return rooms

func _on_RoomTree_item_edited(deleted=0):
	var ti :TreeItem= room_tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if can_be_int_fuck_you_godot(s) or s == '0':
			s = can_be_int_fuck_you_godot(s)
		p.push_front(s)
		ti = ti.get_parent()
	p.pop_front()
	var last_k = p.pop_back()
	var d = room
	for k in p:
		d = d[k]
	if deleted == 0:
		var value = room_tree.get_selected().get_text(1)
		var v = d[last_k]
		if d[last_k] is Vector2:
			value.replace('(','')
			value.replace(')','')
			value = value.split(',')
			if can_be_int_fuck_you_godot(value[0]) and can_be_int_fuck_you_godot(value[1]):
				v = Vector2(can_be_int_fuck_you_godot(value[0]), can_be_int_fuck_you_godot(value[1]))
		elif d[last_k] is int and can_be_int_fuck_you_godot(value):
			v = can_be_int_fuck_you_godot(value)
		if v != d[last_k]:
			d[last_k] = v
			app.base_wad.changed_files[file] = bin
		room_tree.get_selected().set_text(1, str(d[last_k]))
	elif deleted == 1:
		d.remove(last_k)
		app.base_wad.changed_files[file] = bin
		room_tree.get_selected().free()
		print('kapow!')
	elif deleted == 2:
		pass

func can_be_int_fuck_you_godot(string:String):
	string = string.replace(' ', '')
	if string == '0': return 0
	if '+' in string:
		var l = string.split('+')
		var s = 0
		for i in l:
			s += can_be_int_fuck_you_godot(i)
		return s
	for c in string:
		if ord(c) > ord('A')-1 and ord(c) < ord('z')+1 or c == '/':
			return 0
	return int(string)
