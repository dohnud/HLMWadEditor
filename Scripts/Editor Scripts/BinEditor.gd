extends Control

class_name BinEditor

onready var app = get_tree().get_nodes_in_group('App')[0]
onready var tree = null#$TabContainer2/Advanced/Tree

var filetype = SpritesBin
var file = ''
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
	bin = app.base_wad.get_bin(filetype)
	file = filetype.get_file_path()
	if bin == null: return null
	selected_struct_id = asset
	selected_struct = bin.get(asset)
	if tree:
		tree.reset()
		tree.create_struct(selected_struct)
	return selected_struct


func parse_new_value(k,v,ntv):
	return [v, ntv]

func _on_Tree_item_edited(deleted=0):
	# using the treeitem, backtrack up the treeitems parents
	# determining which aspect of the room data was just modified
	# the tree is a 1:1 representation of the data
	var ti :TreeItem= tree.get_selected()
	var p = []
	while ti != null:
		var s = ti.get_text(0)
		if can_be_int_fuck_you_godot(s) != null or s == '0':
			s = int(s)
		p.push_front(s)
		ti = ti.get_parent()
	# remove the root as its redundant (first element)
	p.pop_front()
	# d and last_k represent the exact field we are modifying
	# changed_d 
	var last_k = p.pop_back()
	var d = bin.data[selected_struct_id]
	var new_d = bin.get(selected_struct_id).duplicate(true)
	var changed_d = new_d
	# build delta string for diff tweaks
#	var delta_string = file.right(3) + "." + selected_struct_id + "."
	var delta_string = selected_struct_id + "."
	for k in p:
		delta_string += str(k) + "."
		d = d[k]
		changed_d = changed_d[k]
	delta_string += str(last_k) + " = "
	if deleted == 0:
		var value = tree.get_selected().get_text(1)
		delta_string += value
		var v = d[last_k]
		var vs = null
		if d[last_k] is Vector2:
			value = value.replace('(','')
			value = value.replace(')','')
			value = value.split(',')
			if len(value) > 1 and int(value[0]) and int(value[1]):
				v = Vector2(int(value[0]), int(value[1]))
			vs = str(v)
#		elif d[last_k] is int: # value is String implied
		else:
			var l = parse_new_value(last_k, d[last_k], value)
			v = l[0]
			vs = l[1]
		if d[last_k] is int and (vs == '0' or can_be_int_fuck_you_godot(vs)): # ex: depth
#			print(vs,' ',int(vs))
			v = int(vs)
		# CHANGE DETECTED !!!!!
		if v != d[last_k]:
#			d[last_k] = v
			changed_d[last_k] = v
			bin.changed[selected_struct_id] = new_d
			app.base_wad.changed_files[file] = bin
			print(delta_string)
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
#func change_order(_room, new_next, new_previous):
#	sprites.sprite
