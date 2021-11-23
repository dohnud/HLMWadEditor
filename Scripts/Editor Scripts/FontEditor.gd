extends VBoxContainer

onready var app = get_tree().get_nodes_in_group('App')[0]

var selected_asset :WadFont= null
var selected_asset_name = ''

var text_scale = 1

onready var preview_label :Label= $FontPreviewPanel/MarginContainer/VBoxContainer/TextureRect/MarginContainer/LineEdit
onready var preview_label_edit = $FontPreviewPanel/MarginContainer/VBoxContainer/HBoxContainer/LineEdit

func set_asset(path):
	$Label.text = path
	selected_asset = app.base_wad.parse_fnt(path)
	selected_asset.meta.connect('resolve_complete', self, 'meta_recalc_resolved')
	selected_asset_name = path
#	preview_label.has_font_override()
	preview_label.add_font_override("font", selected_asset.to_godot_font())
	return selected_asset

func _on_HSlider_value_changed(value=text_scale):
	text_scale = value
	preview_label.rect_scale = Vector2(text_scale, text_scale)
#	preview_label.rect_size = Vector2(preview_label.get_font('font').get_string_size(preview_label_edit.text).x * value,  preview_label.rect_size.y)

func meta_recalc_resolved():
	preview_label.add_font_override("font", selected_asset.to_godot_font())


func _on_LineEdit_text_changed(new_text):
	preview_label.text = new_text
	_on_HSlider_value_changed()


func _on_uppercasetogglebutton_toggled(button_pressed):
	preview_label.uppercase = button_pressed
	_on_HSlider_value_changed()
