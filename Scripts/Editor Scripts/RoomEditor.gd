extends BinEditor


#onready var app = get_tree().get_nodes_in_group('App')[0]
onready var room_tree = $TabContainer2/Advanced/RoomTree

var rooms = null
var room_name = ""
var room = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	filetype = RoomsBin
	tree = room_tree


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func add_generic_object():
	var new_obj;
	if bin is phyreRoomsBin:
		new_obj = {
			'instance_id': 0,
			'object_id' : 7,
			'position': Vector2(0,0),
			'm' : 0
		}
	else:
		new_obj = {
			'instance_id' : 1,
			'mystery1' : 1,
			'mystery2' : 1,
			'object_id' : 2342,
			'position': Vector2(0,0),
		}
	var objecttreeitem = room_tree.get_root().get_children().get_next().get_next().get_next()
	var new_objecttreeitem = room_tree.create_item(objecttreeitem)
	new_objecttreeitem.set_text(0,str(len(room['objects'])))
	for k in new_obj.keys():
		var fieldtreeitem = room_tree.create_item(new_objecttreeitem)
		fieldtreeitem.set_editable(0, false)
		fieldtreeitem.set_editable(1, true)
		fieldtreeitem.set_text(0, k)
		fieldtreeitem.set_text(1, str(new_obj[k]))
	room['objects'].append(new_obj)
	

func set_room(room_name):
	set_bin_asset(room_name)
	
	$Label.text = room_name
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
		if can_be_int_fuck_you_godot(s) != null or s == '0':
			s = can_be_int_fuck_you_godot(s)
		p.push_front(s)
		ti = ti.get_parent()
	p.pop_front()
	var last_k = p.pop_back()
	var d = room
	var type_d = rooms.rm
	for k in p:
		if not(k is int):
			type_d = type_d[k]
		else:
			type_d = type_d[1]
		d = d[k]
	if deleted == 0:
		var value = room_tree.get_selected().get_text(1)
		var v = d[last_k]
		if d[last_k] is Vector2:
			value = value.replace('(','')
			value = value.replace(')','')
			value = value.split(',')
			if len(value) < 2:
				value = value.split(' ')
			if (len(value) > 1 and len(value) < 3):
				var r1 = can_be_int_fuck_you_godot(value[0])
				var r2 = can_be_int_fuck_you_godot(value[1])
				if r1 != null and r2 != null:
					v = Vector2(r1, r2)
		elif d[last_k] is int and (can_be_int_fuck_you_godot(value) != null or value == '0'):
			v = can_be_int_fuck_you_godot(value)
			var limit = (1<<int(type_d[last_k])) - 1
			v = clamp(v, 0, limit)
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
			var r = can_be_int_fuck_you_godot(i)
			if r != null:
				s += r
		return s
	for c in string:
#		if ord(c) > ord('A')-1 and ord(c) < ord('z')+1 or c == '/':
		if ord(c) < ord('0') or ord(c) > ord('9'):
			return null
	return int(string)
