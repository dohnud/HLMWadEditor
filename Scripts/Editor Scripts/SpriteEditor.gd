extends VBoxContainer


onready var app = get_tree().get_nodes_in_group('App')[0]
onready var sprite_tree = $TabContainer2/Advanced/SpriteTree

var file = 'GL/hlm2_sprites.bin'
var bin = null
var sprites = null
var sprite = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_sprite(sprite_name):
	$Label.text = sprite_name
	sprite_tree.reset()
#	sprites = app.base_wad.spritebin
	sprites = app.base_wad.get_bin(SpritesBin.file_path)
	bin = sprites
	sprite = sprites.sprite_data[sprite_name]
	sprite_tree.create_dict(sprite)
	return sprites


func _on_SpriteTree_item_edited(deleted=0):
	var ti :TreeItem= sprite_tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if can_be_int_fuck_you_godot(s) != -1:
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
				if can_be_int_fuck_you_godot(value[0]) != -1 and can_be_int_fuck_you_godot(value[1]) != -1:
					v = Vector2(can_be_int_fuck_you_godot(value[0]), can_be_int_fuck_you_godot(value[1]))
#			print(v)
		elif d[last_k] is int and can_be_int_fuck_you_godot(value) != -1:
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

func can_be_int_fuck_you_godot(string:String):
	string = string.replace(' ', '')
	if string == '0': return 0
	if '+' in string:
		var l = string.split('+')
		var s = 0
		for i in l:
			var p = can_be_int_fuck_you_godot(i)
			if p != -1:
				s += p
		return s
	for c in string:
		if ord(c) > ord('A')-1 and ord(c) < ord('z')+1 or c == '/':
			return -1
	return int(string)
