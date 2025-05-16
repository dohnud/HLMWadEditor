extends ConfirmationDialog


onready var tree: Tree = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Tree
var root: TreeItem = null

var fixes = {}

var selected_fixes = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree.set_hide_root(true)
	reset()

func reset():
	tree.clear()
	root = tree.create_item()
	
	fixes.clear()
	parse_fix_dir(Log.log_directory + "fixes")
	parse_fix_dir("res://fixes")
	

func parse_fix_dir(fix_path):
	var fix_dir = Directory.new()
	if fix_dir.open(fix_path):
		ErrorLog.show_user_error("No path \"fixes/\" found in the Wad Editor's installed directory.\nPlease make sure this folder exists if you want to add community fixes to your mod")
		emit_signal("confirmed")
		hide()
	
	fix_dir.list_dir_begin()
	var fix_file_name = fix_dir.get_next()
	while fix_file_name != "":
		if fix_file_name.ends_with(".cfg"):
			var cfg = ConfigFile.new()
			if OK != cfg.load(fix_path + "/" + fix_file_name):
				printerr("Could not parse " + fix_file_name + " as valid .CFG")
				fix_file_name = fix_dir.get_next()
				continue
			var fix = cfg_to_fixdict(cfg)
			if fixes.has(fix_file_name):
				fix_file_name = fix_dir.get_next()
				continue
			fixes[fix_file_name] = fix
			add_fix_to_tree(fix_file_name, fix.Title, fix.Description, fix.Category)

		fix_file_name = fix_dir.get_next()

func cfg_to_fixdict(cfg) -> Dictionary:
	var req_info = ["Title", "Description", "Category"]
	var fix = {}
	for req in req_info:
		fix[req] = cfg.get_value("Info", req)
	fix['Deltas'] = {}
	for delta in cfg.get_section_keys("Deltas"):
		var delta_string = cfg.get_value("Deltas", delta)
		if delta_string == null: continue
		fix['Deltas'][delta] = delta_string
	return fix

func add_fix_to_tree(file_name, fix_name, description="No Description", category="Uncategorized"):
	var cat: TreeItem = root.get_children()
	while cat != null and cat.get_text(0) != category:
		cat = cat.get_next()
	if cat == null:
		cat = tree.create_item(root)
		cat.collapsed = true
		cat.set_editable(0, false)
		cat.set_selectable(0, false)
		cat.set_text(0, category)
	var fix: TreeItem = tree.create_item(cat)
	fix.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	fix.set_editable(0, true)
#	fix.set_selectable(0, false)
	fix.set_text(0, fix_name)
	fix.set_tooltip(0, description)
	fix.set_metadata(0, file_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func detect_fixes():
	for fix in fixes:
		for prop in fix.Deltas.keys():
			var new_val = fix.Deltas[prop]
			

func _on_Tree_cell_selected() -> void:
	var ti: TreeItem = tree.get_selected()
	var fix_file_name = ti.get_metadata(0)
	var fix = fixes[fix_file_name]
	var fl = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/FileLabel
	var tl = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/HBoxContainer/TitleLabel
	var cl = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/HBoxContainer/CatLabel
	var dl = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/DescLabel
	var kc = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/ScrollContainer/HSplitContainer/HBoxContainer/VBoxContainer
	var vc = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/ScrollContainer/HSplitContainer/VBoxContainer2
	for i in range(1, kc.get_child_count()): kc.get_child(i).queue_free()
	for i in range(1, vc.get_child_count()): vc.get_child(i).queue_free()
	fl.text = fix_file_name
	tl.text = fix.Title
	dl.text = fix.Description
	cl.text = "[ " + fix.Category + " ]"
	
	for k in fix.Deltas:
		var kl = Label.new()
		var vl = Label.new()
		kl.text = k
		vl.text = str(fix.Deltas[k])
		kl.add_color_override("font_color", Color(1, 1, 1, 0.6))
		vl.add_color_override("font_color", Color(1, 1, 1, 0.6))
		kc.add_child(kl)
		vc.add_child(vl)


func _on_Resources_item_edited() -> void:
	var ti: TreeItem = tree.get_selected()
	var fix_file_name = ti.get_metadata(0)
	if ti.is_checked(0):
		var fix = fixes[fix_file_name]
		selected_fixes[fix_file_name] = fix
	else:
		selected_fixes.erase(fix_file_name)
	
#	for fix in selected_fixes.values():
#		for delta in fix.Deltas:
#			var new_val = fix.Deltas[delta]
#			prints(delta, "=", new_val)


func _on_Button_pressed() -> void:
	reset()
