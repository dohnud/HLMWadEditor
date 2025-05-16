extends Tree

onready var app = get_tree().get_nodes_in_group('App')[0]

export(Texture) var folder_icon
export(Color) var folder_mod
export(Color) var subfolder_mod

onready var root = create_item()
onready var directory_dict = {'contents':{'':{'contents':{},'parent':root}},'parent':root}

#func _init():
#	var f = ImageTexture.new()
#	f.create_from_image(folder_icon)
#	folder_icon = f
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_hide_root(true)
#	create_path("Awesome/Poggerschamp/dumbledore/a")
#	create_path("Awesome/Poggerschamp/dumbledore/n").set_text(1, "value")
#	create_path("Awesome/Poggerschamp/dingodng/n")
#	create_dict({'a':{'a':[0,1,2],'b':-12},'b':10},'Stuff')

func reset():
	clear()
	root = create_item()
	directory_dict = {'contents':{'':{'contents':{},'parent':root}},'parent':root}
	set_hide_root(true)

func create_path(path:String, current_dir=directory_dict):
	var slice = path.find('/')
	if slice != -1:
		var folder = path.substr(0,slice)
		if !current_dir['contents'].has(folder):
			var treeitem :TreeItem = create_item(current_dir['parent'])
			if current_dir['parent'].get_text(0) != 'objects':
				treeitem.set_selectable(0, false)
				treeitem.set_selectable(1, false)
			treeitem.collapsed = true
			treeitem.set_text(0, folder)
			current_dir['contents'][folder] = {'parent':treeitem, 'contents':{}}
		return create_path(path.substr(slice+1),current_dir['contents'][folder])
	else:
		var text = path
		var treeitem :TreeItem = create_item(current_dir['parent'])
		treeitem.set_editable(0, false)
		treeitem.set_editable(1, true)
		treeitem.set_text(0, text)
		return treeitem

func create_array(array, path=''):
	var index = 0
	for i in array:
		if i is Dictionary:
			create_dict(i, path+'/'+str(index))
		elif i is Array or i is PoolByteArray:
			create_array(i, path+'/'+str(index))
		else:
			create_path(path+'/'+str(index)).set_text(1, str(i))
		index += 1

func create_dict(dict, path=''):
	for k in dict.keys():
		if dict[k] is Dictionary:
			create_dict(dict[k], path+'/'+k)
		elif dict[k] is Array or dict[k] is PoolByteArray:
			create_array(dict[k], path+'/'+k)
		else:
			var s = str(dict[k])
			if (k == 'object_id') and dict[k]>=0:
				s = app.base_wad.get_bin(ObjectsBin).names[dict[k]]
			create_path(path+'/'+k).set_text(1, s)

func create_struct(struct, path=''):
	if struct is Dictionary:
		create_dict(struct, path)
	elif struct is Array or struct is PoolByteArray:
		create_array(struct, path)
	create_path(path)

func _on_RoomTree_gui_input(event):
	if event.is_action_released("ui_delete"):
		emit_signal("item_edited", 1)
