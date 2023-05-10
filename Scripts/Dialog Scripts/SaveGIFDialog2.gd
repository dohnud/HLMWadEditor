extends WindowDialog

onready var app = get_tree().get_nodes_in_group('App')[0]
var meta :Meta= null
var sprite = ''
var path = ''

func _on_Button_pressed():
	if meta and sprite and path:
		meta.export_sprite_to_gif(path, sprite, 1/$VBoxContainer/HBoxContainer/Label2.value, $VBoxContainer/HBoxContainer2/Label2.value)
	path = ''
	sprite = ''
	hide()
	get_parent().hide()


func _on_SaveGIFDialog_file_selected(_path):
	if !_path:return
	path = _path
	popup()
