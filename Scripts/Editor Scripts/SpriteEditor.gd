extends BinEditor

onready var sprite_tree = $TabContainer2/Advanced/SpriteTree

var sprites = null
var sprite = {}
var sprite_name = ""


onready var room_tree = $TabContainer2/Advanced/RoomTree

var rooms = null
var room_name = ""
var room = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	filetype = SpritesBin
	file = SpritesBin
	tree = sprite_tree

func set_sprite(_sprite_name):
	set_bin_asset(_sprite_name)
	sprite_name = _sprite_name
	$Label.text = sprite_name
	sprites = bin
	sprite = selected_struct
	return sprites


func _on_SpriteTree_item_edited(deleted=0):
	_on_Tree_item_edited(deleted)
	return
	var ti :TreeItem= sprite_tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if can_be_int_fuck_you_godot(s) != null:
			s = can_be_int_fuck_you_godot(s)
		p.push_front(s)
		ti = ti.get_parent()
	p.pop_front()
	var last_k = p.pop_back()
	var d = sprite
	for k in p:
		d = d[k]
	if deleted == 0:
		var value = sprite_tree.get_selected().get_text(1)
		var v = d[last_k]
		if d[last_k] is Vector2:
			value = value.replace('(','')
			value = value.replace(')','')
			value = value.split(',')
			if len(value) < 2:
				value = value.split(' ')
			if (len(value) > 1 and len(value) < 3):
#			print(value)
				if can_be_int_fuck_you_godot(value[0]) != null and can_be_int_fuck_you_godot(value[1]) != null:
					v = Vector2(can_be_int_fuck_you_godot(value[0]), can_be_int_fuck_you_godot(value[1]))
#			print(v)
		elif d[last_k] is int and can_be_int_fuck_you_godot(value) != null:
			v = can_be_int_fuck_you_godot(value)
		if v != d[last_k]:
#			print(v)
			d[last_k] = v
			app.base_wad.changed_files[file] = bin
		sprite_tree.get_selected().set_text(1, str(d[last_k]))
	elif deleted == 1:
		d.remove(last_k)
		app.base_wad.changed_files[file] = bin
		sprite_tree.get_selected().free()
		print('kapow!')
	elif deleted == 2:
		pass

