extends VBoxContainer

onready var app = get_tree().get_nodes_in_group('App')[0]

var selected_asset :WadFont= null
var selected_asset_name = ''

var text_scale = 1
var current_glyph = ""

onready var preview_label :Label= $VSplitContainer/FontPreviewPanel/MarginContainer/VBoxContainer/TextureRect/MarginContainer/LineEdit
onready var preview_label_edit = $VSplitContainer/FontPreviewPanel/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
onready var glyphlist_node = $VSplitContainer/GlyphListPanel/HBoxContainer/VBoxContainer/GlyphList
onready var frametexturerect = $VSplitContainer/GlyphListPanel/HBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect

func set_asset(path):
	$Label.text = path
	selected_asset = app.base_wad.parse_fnt(path)
#	selected_asset.meta.connect('resolve_complete', self, 'meta_recalc_resolved')
	selected_asset_name = path
#	preview_label.has_font_override()
	preview_label.add_font_override("font", selected_asset.to_godot_font())
	glyphlist_node.clear()
	for glyph_id in selected_asset.meta.sprites.get_animation_names():
		var glyph_char = char(int(glyph_id))
		glyphlist_node.add_item(glyph_char)
	glyphlist_node.select(0)
	_on_GlyphList_item_selected(0)
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


func _on_GlyphList_item_selected(index: int) -> void:
	var glyph_id = selected_asset.meta.sprites.get_animation_names()[index]
	var glyph_char = char(int(glyph_id))
	current_glyph = glyph_char
	
	var f: AtlasTexture = selected_asset.meta.sprites.get_frame(glyph_id, 0)
	frametexturerect.texture = f
