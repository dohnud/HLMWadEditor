extends WindowDialog

onready var app = get_tree().get_nodes_in_group('App')[0]
var meta :Meta= null
var sprite = ''
var path = ''
var fps = 1
var pixel_scale = 1

func _on_Button_pressed():
	pixel_scale = $VBoxContainer/HBoxContainer2/Label2.value
	fps = $VBoxContainer/HBoxContainer/Label2.value
	NativeDialog.popup_save_dialog(
		"Save Sprite to GIF",
		['*.gif ; GIF Animation'],
		sprite + '.gif',
		self, '_on_SaveGIFDialog_file_selected'
	)
	hide()
	get_parent().hide()


func _on_X_Button_pressed():
	path = ''
	sprite = ''
	hide()
	get_parent().hide()


func _on_SaveGIFDialog_file_selected(_path):
	if !_path:return
	path = _path
	if meta and sprite and path:
		meta.export_sprite_to_gif(path, sprite, 1/fps, pixel_scale)
	path = ''
	sprite = ''
