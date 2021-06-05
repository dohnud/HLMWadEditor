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
	sprite_tree.reset()
	sprites = app.base_wad.spritebin
	bin = sprites
	sprite = sprites.sprite_data[sprite_name]
	sprite_tree.create_dict(sprite)
	return sprites


func _on_SpriteTree_item_edited(deleted=0):
	var ti :TreeItem= sprite_tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if int(s) or s == '0':
			s = int(s)
		p.push_front(s)
		ti = ti.get_parent()
	p.pop_front()
	var last_k = p.pop_back()
	var d = sprite
	for k in p:
		d = d[k]
	if deleted == 0:
		var value = sprite_tree.get_selected().get_text(1)
		var v = null
		if d[last_k] is Vector2:
			value.replace('(','')
			value.replace(')','')
			value = value.split(',')
			if int(value[0]) and int(value[1]):
				v = Vector2(int(value[0]), int(value[1]))
		elif d[last_k] is int and int(value):
			v = int(value)
		if v != d[last_k]:
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

func change_order(_room, new_next, new_previous):
	sprites.sprite
