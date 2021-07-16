extends VBoxContainer


onready var app = get_tree().get_nodes_in_group('App')[0]
onready var background_tree = $TabContainer2/Advanced/BackgroundTree

var backgrounds = null
var background = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_background(background_name):
	background_tree.reset()
	backgrounds = app.base_wad.backgroundbin
	background = backgrounds.background_data[background_name]
	background_tree.create_dict(background)
	return backgrounds


func _on_BackgroundTree_item_edited(deleted=0):
	var ti :TreeItem= background_tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if (int(s) or s == '0') and !('m' in s):
			s = int(s)
		p.push_front(s)
		ti = ti.get_parent()
	p.pop_front()
	var last_k = p.pop_back()
	var d = background
	for k in p:
		d = d[k]
	if deleted == 0:
		var value = background_tree.get_selected().get_text(1)
		if d[last_k] is Vector2:
			value = value.replace('(','')
			value = value.replace(')','')
			value = value.split(',')
			if int(value[0]) and int(value[1]):
				d[last_k] = Vector2(int(value[0]), int(value[1]))
		elif d[last_k] is int and int(value):
			d[last_k] = int(value)
		background_tree.get_selected().set_text(1, str(d[last_k]))
	elif deleted == 1:
		d.remove(last_k)
		background_tree.get_selected().free()
		print('kapow!')
	elif deleted == 2:
		pass

func change_order(_room, new_next, new_previous):
	backgrounds.background
