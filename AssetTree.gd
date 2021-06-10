tool
extends Tree

onready var app = get_tree().get_nodes_in_group('App')[0]

export(Texture) var folder_icon
export(Color) var folder_mod
export(Color) var subfolder_mod
export(Font) var bold_font

onready var root = create_item()
onready var directory_dict = {'contents':{},'parent':root}

var bolds = {}
#func _init():
#	var f = ImageTexture.new()
#	f.create_from_image(folder_icon)
#	folder_icon = f
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_hide_root(true)
#	create_path("Awesome/Poggerschamp/dumbledore/a")
#	create_path("Awesome/Poggerschamp/dumbledore/n")
#	create_path("Awesome/Poggerschamp/dingodng/n")
#
#func create_path(path:String):
#	var slice = path.find('/')
#	var pos :TreeItem= root
#	while slice != -1:
#		if !directory_dict.has(path.substr(0,slice)):
#			var child1 = create_item(pos)
#			child1.set_text(0, path.substr(0,slice))
#			child1.set_icon(0, folder_icon)
#			if pos == root:
#				child1.set_icon_modulate(0, folder_mod)
#				child1.set_icon_max_width(0, 16)
#			else:
#				child1.set_icon_modulate(0, subfolder_mod)
#				child1.set_icon_max_width(0, 14)
#			child1.collapsed = true
#			child1.set_selectable(0, false)
#			directory_dict[path.substr(0,slice)] = child1
#		pos = directory_dict[path.substr(0,slice)]
#		path = path.substr(slice+1)
#		slice = path.find('/')
#	var child1 = create_item(pos)
#	child1.set_text(0, path)
#	directory_dict[path] = child1
#	return child1
func reset():
	clear()
	root = create_item()
	directory_dict = {'contents':{},'parent':root}
	bolds = {}
	set_hide_root(true)


func create_path(path:String, bold=false, current_dir=directory_dict):
	var slice = path.find('/')
	if slice != -1:
		var folder = path.substr(0,slice)
		if !current_dir['contents'].has(folder):
			var treeitem :TreeItem = create_item(current_dir['parent'])
			treeitem.set_selectable(0, false)
			treeitem.collapsed = true
			treeitem.set_icon(0, folder_icon)
			if current_dir['parent'] == root:
				treeitem.set_icon_modulate(0, folder_mod)
				treeitem.set_icon_max_width(0, 16)
			else:
				treeitem.set_icon_modulate(0, subfolder_mod)
				treeitem.set_icon_max_width(0, 14)
			treeitem.set_text(0, folder)
			current_dir['contents'][folder] = {'parent':treeitem, 'contents':{}}
		return create_path(path.substr(slice+1), bold, current_dir['contents'][folder])
	else:
		var text = path
		var treeitem : TreeItem = null
		if current_dir['contents'].has(path):
			treeitem = current_dir['contents'][path]
		else:
			treeitem = create_item(current_dir['parent'])
		if bold:
			treeitem.set_cell_mode(0,TreeItem.CELL_MODE_CUSTOM)
#			treeitem.set_text(0, text)
			treeitem.set_custom_draw(0, self, "bold_treeitem_draw")
			bolds[treeitem] = text
#			treeitem.set_custom_font(0, bold_font)
		else:
			treeitem.set_text(0, text)
		treeitem.set_editable(0, false)
		current_dir['contents'][path] = treeitem
		return treeitem

func bold_treeitem_draw(treeitem:TreeItem, rect:Rect2):
	draw_string(bold_font,rect.position + Vector2(0,rect.size.y+bold_font.size/2)/2, bolds[treeitem])
#	draw_string(bold_font,rect.position+Vector2(0,rect.size.y), treeitem.get_text(0))

func _on_Tree_item_selected():
	var treeitem = get_selected()
#	var asset = '/' + treeitem.get_text(0)
#	treeitem = treeitem.get_parent()
	var asset = ''
	while treeitem.get_text(0) != '' or bolds.has(treeitem):
		if bolds.has(treeitem):
			asset = '/' + bolds[treeitem] + asset
		else:
			asset = '/' + treeitem.get_text(0) + asset
		treeitem = treeitem.get_parent()
	asset = asset.substr(1)
	app.open_asset(asset)
