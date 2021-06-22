extends Control

class_name BinEditor

onready var app = get_tree().get_nodes_in_group('App')[0]
onready var tree = null#$TabContainer2/Advanced/Tree

var file = 'GL/hlm2_sprites.bin'
var bin :BinParser= null
var selected_struct = null
var selected_struct_id = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_bin_asset(asset):
	if tree:
		tree.reset()
		bin = app.base_wad.get_bin(file)
		selected_struct_id = asset
		selected_struct = bin.get(asset)
		tree.create_dict(selected_struct)
		return selected_struct
	return null


func parse_new_value(k,v,ntv):
	return [v,ntv]

func _on_Tree_item_edited(deleted=0):
	var ti :TreeItem= tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if int(s) or s == '0':
			s = int(s)
		p.push_front(s)
		ti = ti.get_parent()
	p.pop_front()
	var last_k = p.pop_back()
	var d = bin.data[selected_struct_id]
	var changed_d = bin.get(selected_struct_id).duplicate(true)
	for k in p:
		d = d[k]
	if deleted == 0:
		var value = tree.get_selected().get_text(1)
		var v = null
		var vs = null
		if d[last_k] is Vector2:
			value.replace('(','')
			value.replace(')','')
			value = value.split(',')
			if int(value[0]) and int(value[1]):
				v = Vector2(int(value[0]), int(value[1]))
				vs = str(v)
#		elif d[last_k] is int: # value is String implied
		else:
			var l = parse_new_value(last_k, d[last_k], value)
			v = l[0]
			vs = l[1]
		if d[last_k] is int and (vs == '0' or can_be_int_fuck_you_godot(vs)): # ex: depth
			print(vs,' ',int(vs))
			v = int(vs)
		if v != d[last_k]:
#			d[last_k] = v
			changed_d[last_k] = v
			bin.changed[selected_struct_id] = changed_d
			app.base_wad.changed_files[file] = bin
		tree.get_selected().set_text(1, vs)
	elif deleted == 1:
		d.remove(last_k)
		app.base_wad.changed_files[file] = bin
		tree.get_selected().free()
		print('kapow!')
	elif deleted == 2:
		pass

func can_be_int_fuck_you_godot(string:String):
	string = string.replace(' ', '')
	if string == '0': return 0
	for c in string:
		if ord(c) > ord('A')-1 and ord(c) < ord('z')+1:
			return 0
	return int(string)
#func change_order(_room, new_next, new_previous):
#	sprites.sprite
