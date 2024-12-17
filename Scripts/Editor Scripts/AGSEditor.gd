extends VBoxContainer

onready var app = get_tree().get_nodes_in_group('App')[0]

onready var asset_label_node = $HBoxContainer/Label
onready var sprite_sheet_icon_node = $HSplitContainer/VBoxContainer/Panel/HBoxContainer/TexturePageRect
onready var spritelist_node = $HSplitContainer/VBoxContainer/SpriteList
onready var frametexturerect = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect
#onready var d = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect
onready var frame_number_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/VBoxContainer/HBoxContainer2/FrameNumber2
onready var tex_dimensions_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/VBoxContainer/HBoxContainer/FrameNumber
onready var frame_tex_offset_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/VBoxContainer2/HBoxContainer3/OffsetLabel
onready var frame_tex_uv_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/VBoxContainer2/HBoxContainer3/UVLabel
onready var gizmos_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos
onready var origin_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/VBoxContainer2/Panel
onready var xorigin_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/VBoxContainer2/Panel/HBoxContainer/XOriginInput
onready var yorigin_node = $HSplitContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/VBoxContainer2/Panel/HBoxContainer/YOriginInput
#onready var fps_node = $HSplitContainer/Preview/VBoxContainer/TimelineControls/HBoxContainer/Left/FpsSpinBox
onready var fps_node = $HSplitContainer/Preview/VBoxContainer/TimelineControls/HBoxContainer/Left/PanelContainer/HBoxContainer/FpsSpinBox
onready var timeline = $HSplitContainer/Preview/VBoxContainer/Timeline/TimelineSlider
onready var pause_button_node = $HSplitContainer/Preview/VBoxContainer/TimelineControls/HBoxContainer/Middle/PausePlayButton


var meta : PhyreMeta = null
var current_sprite = ''
var current_sprite_list_index = 0
var mode = 0

var thread = null
var resolve_progress = 0
var show_collision_mask = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_asset(asset_path):
	meta = app.base_wad.parse_phyremeta(asset_path)
	asset_label_node.text = asset_path.get_file()
	sprite_sheet_icon_node.texture = meta.texture_page
	spritelist_node.clear()
	for sprite_name in meta.sprites.get_animation_names():
		spritelist_node.add_item(sprite_name)
	spritelist_node.select(0)
	_on_SpriteList_item_selected(0)
	return meta
#	if !app.base_wad.sprite_data.has(sprite_name):
#		mode = 1
#	animatedsprite_node.frames = meta.sprites
#	current_sprite = meta.sprites.get_animation_names()[0]
#	frametexturerect.texture = meta.sprites.get_frame(current_sprite, 0)
#	if mode == 0:
#		xorigin_node.value = app.base_wad.sprite_data[current_sprite]['center'].x
#		xorigin_node.max_value = meta.sprites.get_frame(current_sprite, 0).get_size().x
#		yorigin_node.value = app.base_wad.sprite_data[current_sprite]['center'].y
#		yorigin_node.max_value = meta.sprites.get_frame(current_sprite, 0).get_size().y
#		_on_FpsSpinBox_value_changed(fps_node.value)


func _on_SpriteList_item_selected(index):
	var sprite_name = meta.sprites.get_animation_names()[index]
	if sprite_name == 'default': return
	current_sprite = sprite_name
	current_sprite_list_index = index
	var f :MetaTexture= meta.sprites.get_frame(current_sprite, 0)
	frametexturerect.texture = f
	tex_dimensions_node.text = str(f.get_width()) + ' x ' + str(f.get_height())
	frame_tex_offset_node.text = str(f.region.position.x) + ' , ' + str(f.region.position.y)
	if f is MetaTexture:
		frame_tex_uv_node.text = str(f.uv.position.x) + ', ' + str(f.uv.position.y) + '  ' + str(f.uv.size.x) + ' x ' + str(f.uv.size.y)
	mode = 0
	var s = app.base_wad.get_bin(SpritesBin)
	if !meta.is_gmeta and !(s.sprite_data.has(sprite_name)):
		mode = 1
	timeline.tween.playback_speed = (fps_node.value) / meta.sprites.get_frame_count(current_sprite)
	#timeline.tween.stop_all()
	timeline.set_tween()
	if mode == 0:
		origin_node.visible = true
		xorigin_node.max_value = meta.sprites.get_frame(current_sprite, 0).get_size().x
		yorigin_node.max_value = meta.sprites.get_frame(current_sprite, 0).get_size().y
		if meta.is_gmeta:
			xorigin_node.value = meta.center_norms[current_sprite].x * xorigin_node.max_value
			yorigin_node.value = meta.center_norms[current_sprite].y * yorigin_node.max_value
			frametexturerect.origin_pos = meta.center_norms[current_sprite] * Vector2(xorigin_node.max_value, yorigin_node.max_value)
		else:
			xorigin_node.value = s.sprite_data[current_sprite]['center'].x
			yorigin_node.value = s.sprite_data[current_sprite]['center'].y
			frametexturerect.origin_pos = s.sprite_data[current_sprite]['center']
	else:
		origin_node.visible = false
		frametexturerect.origin_pos = Vector2(-9999,-9999)
	_on_FpsSpinBox_value_changed(fps_node.value)
#	animatedsprite_node.play(sprite_name)
#	animatedsprite_node.stop()


func _on_FpsSpinBox_value_changed(value):
	timeline.tween.playback_speed = (value) / meta.sprites.get_frame_count(current_sprite)


func _on_PausePlayButton_toggled(button_pressed):
#	if timeline.value == 1:
#		timeline.tween.reset_all()
#		timeline.tween.start()
#		return
	if button_pressed:
		timeline.tween.resume_all()
	else:
		timeline.tween.stop_all()


func _on_Button_toggled(button_pressed):
	timeline.tween.repeat = button_pressed

func _on_XOriginInput_value_changed(value):
#	if meta.is_gmeta:
#		meta.center_norms[current_sprite].x = value / xorigin_node.max_value
#	else:
#		app.base_wad.sprite_data[current_sprite]['center'].x = value
#	app.base_wad.changed_files['GL/hlm2_sprites.bin'] = app.base_wad.get_bin(SpritesBin)
	frametexturerect.origin_pos.x = value
	frametexturerect.update()
func _on_YOriginInput_value_changed(value):
#	if meta.is_gmeta:
#		meta.center_norms[current_sprite].y = value / yorigin_node.max_value
#	else:
#		app.base_wad.sprite_data[current_sprite]['center'].y = value
	frametexturerect.origin_pos.y = value
	frametexturerect.update()


func _on_FrameBackTrackButton_pressed():
	timeline.tween.stop_all()
	var v = timeline.value - (1.0/meta.sprites.get_frame_count(current_sprite))
	timeline.tween.seek(v)
	timeline.value = v
	timeline.update_pos(v)
func _on_FrameAdvanceButton_pressed():
	timeline.tween.stop_all()
	var v = timeline.value + (1.0/meta.sprites.get_frame_count(current_sprite))
	timeline.tween.seek(v)
	timeline.value = v
	timeline.update_pos(v)


#func _on_RecalculateSheetButton_pressed():
#	app.base_wad.changed_files[app.selected_asset_name] = meta
#	app.asset_tree.set_bold(app.asset_tree.get_selected())
#	thread = Thread.new()
#	# Third argument is optional userdata, it can be any variable.
#	thread.start(meta, "resolve", [meta.sprites, meta.texture_page], Thread.PRIORITY_HIGH)
#
