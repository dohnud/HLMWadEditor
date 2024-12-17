extends ConfirmationDialog

onready var app = get_tree().get_nodes_in_group('App')[0]
var patchwad :Wad= null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_ok().text = "Import"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var file_dict = {}
func _on_ImportWadFileDialog_file_selected(path):
	if !path: return
	patchwad = null
	file_dict = {}
	get_parent().show()
	popup()
	var wad = Wad.new()
	file_dict = {}
	if !wad.opens(path, File.READ):
		if !wad.parse_header():
			# one or more files is corrupted
#			ErrorLog.show_generic_error()
			return
		patchwad = wad
		var tree_r :Tree = $MarginContainer/VBoxContainer/Resources
		tree_r.clear()
		var root_r = tree_r.create_item()
		tree_r.set_hide_root(true)
		for f in patchwad.file_locations.keys():
			# do not list texture files that have a .meta partner, same for fonts
			if f == CollisionMasksBin.get_file_path() or f == SpritesBin.get_file_path():
				continue
			if f.ends_with('.png') and (patchwad.file_locations.has(f.replace('.png', '.meta')) or patchwad.file_locations.has(f.replace('.png', '.fnt'))):
				continue
			file_dict[f] = false
			var child1 = tree_r.create_item(root_r)
			child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			child1.set_editable(0, true)
			child1.set_text(0, f)
#			child1.set_text_align(0, TreeItem.ALIGN_RIGHT)
#			child1.set_selectable(0, false)
			if f.ends_with('.meta') or f.ends_with('.png'):
				var m:Meta = null
				# create phantom meta so u can extract specific sprites
				if f.ends_with('.png'):
					m = app.base_wad.parse_orginal_meta(f.replace('.png', '.meta'))
					child1.set_text(0, f.replace('.png', '.meta'))
					file_dict[f.replace('.png', '.meta')] = {}
					file_dict.erase(f)
				else:
					m = patchwad.parse_meta(f)
					file_dict[f] = {}
				for sprite in m.sprites.get_animation_names():
					var child2 = tree_r.create_item(child1)
					child2.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
					child2.set_editable(0, true)
					child2.set_text(0, sprite)
					child1.collapsed = true
					file_dict[child1.get_text(0)][sprite] = false
		tree_r.grab_focus()


func _on_Resources_item_edited():
	var t :Tree = $MarginContainer/VBoxContainer/Resources
	var ti :TreeItem= t.get_selected()
	if ti != null:
		var checked = ti.is_checked(0)
		if ti.get_text(0).ends_with('.meta'):
#			file_dict[ti.get_text(0)] = {}
			for sprite in file_dict[ti.get_text(0)].keys():
				file_dict[ti.get_text(0)][sprite] = checked
			var sprite_ti :TreeItem= ti.get_children()
			while sprite_ti != null:
				sprite_ti.set_checked(0, checked)
				file_dict[ti.get_text(0)][sprite_ti.get_text(0)] = checked
				sprite_ti = sprite_ti.get_next()
		elif ti.get_parent().get_text(0).ends_with('.meta'):
			if checked:
				ti.get_parent().set_checked(0, true)
#			if !file_dict.has(ti.get_parent().get_text(0)) or !(file_dict[ti.get_parent().get_text(0)] is Dictionary):
#				file_dict[ti.get_parent().get_text(0)] = {}
			file_dict[ti.get_parent().get_text(0)][ti.get_text(0)] = checked
		else:
			file_dict[ti.get_text(0)] = checked



func _on_cancelButton_pressed():
	pass

var file_list = []
func _on_okButton_pressed():
	pass

func _on_SearchBar_text_entered(new_text=''):
	var t :Tree = $MarginContainer/VBoxContainer/Resources
	new_text = new_text.to_lower()
	t.clear()
	var root_r = t.create_item()
	t.set_hide_root(true)
	for f in file_dict.keys():
		# do not list texture files that have a .meta partner, same for fonts
		if f.ends_with('.png') and (file_dict.has(f.replace('.png', '.meta')) or file_dict.has(f.replace('_0.png', '.fnt'))):
			continue
#			file_list.append(f)
		if f.ends_with('.meta'):
			var do_it = false
			if new_text != '':
				for s in file_dict[f]:
					do_it = new_text in s.to_lower()
					if do_it:
						var child1 :TreeItem= t.create_item(root_r)
						child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
						child1.set_editable(0, true)
						child1.set_text(0, f)
						child1.collapsed = true
						for sprite in file_dict[f].keys():
							if new_text in sprite.to_lower() or new_text == '':
								var child2 = t.create_item(child1)
								child2.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
								child2.set_editable(0, true)
								child2.set_text(0, sprite)
				#					child2.set_text_align(0, TreeItem.ALIGN_RIGHT)
				#					child2.set_selectable(0, false)
								child1.collapsed = false
						break
			if (!do_it and new_text in f.to_lower()) or new_text == '':
				var child1 :TreeItem= t.create_item(root_r)
				child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
				child1.set_editable(0, true)
				child1.set_text(0, f)
				child1.collapsed = true
				child1.set_checked(0, (true in file_dict[f].values()))
				for sprite in file_dict[f]:
					var child2 = t.create_item(child1)
					child2.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
					child2.set_editable(0, true)
					child2.set_text(0, sprite)
					child2.set_checked(0,file_dict[f][sprite])
	#					child2.set_text_align(0, TreeItem.ALIGN_RIGHT)
	#					child2.set_selectable(0, false)
					child1.collapsed = true
		elif new_text in f.to_lower() or new_text == '':
			var child1 :TreeItem= t.create_item(root_r)
			child1.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			child1.set_editable(0, true)
			child1.set_text(0, f)
			child1.collapsed = true
			child1.set_checked(0, file_dict[f])
#	var ti_file :TreeItem= t.get_root().get_children()
#	while ti_file != null:
#		var import_file_path = file_list[index]
#		if !(new_text in ti_file.get_text(0)):
#			ti_file.get_next_visible()
#			var m :Meta= patchwad.open_asset(import_file_path)
#			# check if meta file has all sprites checked
#			var do_merge = false
#			var ti_sprite :TreeItem= ti_file.get_children()
#			while ti_sprite != null:
#				# if not do meta merge :P
#				if new_text in ti_sprite.get_text(0):


func _on_selectAllButton_pressed():
	var t :Tree = $MarginContainer/VBoxContainer/Resources
	var ti = t.get_root().get_children()
	while ti != null:
		ti.set_checked(0, true)
		var ti_c = ti.get_children()
		while ti_c != null:
			ti_c.set_checked(0, 1)
			ti_c = ti_c.get_next()
		ti = ti.get_next()
	for f in file_dict.keys():
		if file_dict[f] is Dictionary:
			for s in file_dict[f].keys():
				file_dict[f][s] = true
		else:
			file_dict[f] = true

var collision_toggle = false
func _on_CheckBox_toggled(button_pressed):
	collision_toggle = button_pressed


func _on_ImportPatchWindowDialog_popup_hide():
	hide()
	get_parent().hide()
