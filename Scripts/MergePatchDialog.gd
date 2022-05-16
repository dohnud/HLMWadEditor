extends WindowDialog

onready var app = get_tree().get_nodes_in_group('App')[0]
export(NodePath) var select_patch_dialog_path
onready var select_patch_dialog = get_node(select_patch_dialog_path)

onready var src_patch = app.base_wad
onready var dest_patch = app.base_wad

func _ready():
	_on_Label2_item_selected(0)
	_on_Label4_item_selected(0)

var dif_files = {}
func _on_Button_pressed():
	var output_location = app.base_wad_path.get_basename() + '_modified.'  + Config.settings.base_wad_path.get_extension()
	if src_patch is String:
		var p = Wad.new()
		if !p.opens(src_patch, File.READ):
			p.parse_header()
		else:
			return
		src_patch = p
	if dest_patch is String:
		output_location = dest_patch.get_basename() + '_modified.'  + dest_patch.get_extension()
		var d = Wad.new()
		if !d.opens(src_patch, File.READ):
			d.parse_header()
		else:
			return
		dest_patch = d
	# user chose use current patch and current base wad
	if src_patch == dest_patch:
		dif_files = dest_patch.changed_files
	# user chose two different wads
	else:
		dif_files = src_patch.file_locations
		dest_patch.patchwad_list.append(src_patch)
	
	
	
	
	# do shit with dif_files key=file path value=object/filelocation
	var nf = File.new()
	if !nf.open(output_location, File.WRITE):
		var sizes = []
		var file_location_start = 0x10 + 4
		if dest_patch.version == Wad.WAD_VERSION.HM1:
			file_location_start = 0x04 + 4
			nf.store_32(dest_patch.content_offset)
		else:
			nf.store_buffer(dest_patch.identifier)
		nf.store_32(len(dest_patch.file_locations.keys()))
		for file in dest_patch.file_locations.keys():
			if dif_files.has(file.substr(3)):
				var fc = dif_files[file.substr(3)]
				var c = nf.get_position()
				if fc is Texture:
					nf.store_buffer(fc.get_data().save_png_to_buffer())
				elif fc is Meta:
					fc.write(nf)
				elif fc is SpritesBin:
					if dest_patch.goto(file) == null:
						$ErrorDialog.popup()
					else:
						var bw = dest_patch
						for p in bw.patchwad_list:
							if p.exists(file):
								bw = p
								break
						bw.goto(file)
						fc.write(bw, nf)
				elif fc is CollisionMasksBin:
					if dest_patch.goto(file) == null:
						$ErrorDialog.popup()
					else:
						var bw = dest_patch
						for p in bw.patchwad_list:
							if p.exists(file):
								bw = p
								break
						bw.goto(file)
						fc.write(bw, nf)
				elif fc is BinParser:
					print('writing a bin... hmmm i wonder')
					fc.write(nf)
				elif fc is WadSound:
					fc.write(nf)
				elif fc is WadFont:
					fc.write(nf)
				elif fc is Array:
					nf.store_buffer(src_patch.get(file))
				var s = nf.get_position() - c
				var o = c - dest_patch.content_offset
				sizes.append(s)
#				nf.seek(comebackf[file])
#				nf.store_64(s)
#				nf.store_64(o)
#				nf.seek(c+s)
			else:
				var c = nf.get_position()
				nf.store_buffer(dest_patch.get(file))
				var s = nf.get_position() - c
				sizes.append(s)
		nf.seek(file_location_start)
		var total = 0
		for i in range(len(dest_patch.file_locations.keys())):
			var file = dest_patch.file_locations.keys()[i]
			nf.store_32(len(file))
			nf.store_buffer(PoolByteArray(file.to_ascii()))
			if dest_patch.version == Wad.WAD_VERSION.HM1:
				nf.store_32(sizes[i]) # len
				nf.store_32(total) # offset
			else:
				nf.store_64(sizes[i]) # len
				nf.store_64(total) # offset
			total += sizes[i]
	hide()
	get_parent().hide()


var mode = 0

func _on_Label2_item_selected(index):
	mode = 0
	if index == 0:
		src_patch = app.base_wad
		$VBoxContainer/Control/Label2.text = "current open patch"
		return
	else:
		select_patch_dialog.popup()


func _on_Label4_item_selected(index):
	mode = 1
	if index == 0:
		dest_patch = app.base_wad
		$VBoxContainer/Control/Label4.text = Config.settings.base_wad_path.get_file()
		$VBoxContainer/Control/Label6.text = Config.settings.base_wad_path.get_basename() + '_modified.'  + Config.settings.base_wad_path.get_extension()
		return
	else:
		select_patch_dialog.popup()


func _on_OpenPatchDialog2_file_selected(path):
	$VBoxContainer/Control.show()
	if mode == 0:
		src_patch = path
		$VBoxContainer/Control/Label2.text = path.get_file()
		return
	dest_patch = path
	$VBoxContainer/Control/Label4.text = path.get_file()
	$VBoxContainer/Control/Label6.text = path.get_basename() + '_modified.'  + path.get_extension()
