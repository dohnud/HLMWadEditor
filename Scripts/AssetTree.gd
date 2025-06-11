class_name AssetTree
extends Tree


onready var app = get_tree().get_nodes_in_group('App')[0]

export(Texture) var folder_icon
export(Texture) var favorite_icon
export(Color) var favorite_mod
export(Color) var folder_mod
export(Color) var subfolder_mod
export(Font) var bold_font

onready var root = create_item()
onready var directory_dict = {'contents':{},'parent':root}

var bolds = {}

enum Styles {
	None     = 0b0000,
	Bold     = 0b0001,
	Favorite = 0b0010,
}
#func _init():
#	var f = ImageTexture.new()
#	f.create_from_image(folder_icon)
#	folder_icon = f
	
# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
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
	root.set_text(0,'/')
	directory_dict = {'contents':{},'parent':root}
	bolds = {}
	set_hide_root(true)


func create_path(path:String, style=Styles.None, current_dir=directory_dict):
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
		return create_path(path.substr(slice+1), style, current_dir['contents'][folder])
	else:
		var text = path
		var treeitem : TreeItem = null
		if current_dir['contents'].has(path):
			if !current_dir['contents'][path] is TreeItem:
#				print(path)
				return null
			treeitem = current_dir['contents'][path]
		else:
			treeitem = create_item(current_dir['parent'])
		if style & Styles.Bold:
			treeitem.set_cell_mode(0,TreeItem.CELL_MODE_CUSTOM)
#			treeitem.set_text(0, text)
			treeitem.set_custom_draw(0, self, "bold_treeitem_draw")
			bolds[treeitem] = text
#			treeitem.set_custom_font(0, bold_font)
		if style & Styles.Favorite:
			treeitem.set_icon(0, favorite_icon)
			treeitem.set_icon_modulate(0, favorite_mod)
			treeitem.set_icon_max_width(0, 16)
			treeitem.set_text(0, text)
		if style == Styles.None:
			treeitem.set_text(0, text)
			treeitem.set_icon(0, null)
			treeitem.set_icon_max_width(0, 0)
		treeitem.set_editable(0, false)
		current_dir['contents'][path] = treeitem
		return treeitem

func bold_treeitem_draw(treeitem:TreeItem, rect:Rect2):
	draw_string(bold_font,rect.position + Vector2(0,rect.size.y+bold_font.size/2)/2, bolds[treeitem])
#	draw_string(bold_font,rect.position+Vector2(0,rect.size.y), treeitem.get_text(0))

func set_bold(treeitem, bold=true):
	if treeitem == null: return
	if bold:
		bolds[treeitem] = treeitem.get_text(0)
		treeitem.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
		treeitem.set_custom_draw(0, self, "bold_treeitem_draw")
		treeitem.set_text(0, '')
	elif bolds.has(treeitem):
#		bolds[treeitem] = treeitem.get_text(0)
		treeitem.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
#		treeitem.set_custom_draw(0, self, "bold_treeitem_draw")
		treeitem.set_text(0, bolds[treeitem])

func _on_Tree_item_selected():
	var treeitem = get_selected()
#	var asset = '/' + treeitem.get_text(0)
#	treeitem = treeitem.get_parent()
	var asset = ''
	while treeitem and (treeitem.get_text(0) != '' or bolds.has(treeitem)):
		if treeitem == root: break
		if bolds.has(treeitem):
			asset = '/' + bolds[treeitem] + asset
		else:
			asset = '/' + treeitem.get_text(0) + asset
		treeitem = treeitem.get_parent()
	asset = asset.substr(1)
	app.open_asset(asset)
	app.selected_asset_treeitem = treeitem



func _on_AssetTree_item_rmb_selected(position: Vector2) -> void:
	var treeitem = get_selected()
	var asset = ''
	while treeitem and (treeitem.get_text(0) != '' or bolds.has(treeitem)):
		if treeitem == root: break
		if bolds.has(treeitem):
			asset = '/' + bolds[treeitem] + asset
		else:
			asset = '/' + treeitem.get_text(0) + asset
		treeitem = treeitem.get_parent()
	asset = asset.substr(1)
	print("favoriting: ", asset)
	var favorited = Config.settings.favorite_files.has(asset)
	var style = Styles.Favorite
	if favorited:
		style = Styles.None
		Config.settings.favorite_files.erase(asset)
	else:
		Config.settings.favorite_files[asset] = true
	create_path(asset, style)
