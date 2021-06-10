extends VBoxContainer

onready var app = get_tree().get_nodes_in_group('App')[0]

onready var asset_label_node = $HBoxContainer/Label
onready var sprite_sheet_icon_node = $HSplitContainer/VBoxContainer/Panel/HBoxContainer/TexturePageRect
onready var spritelist_node = $HSplitContainer/VBoxContainer/SpriteList
onready var frametexturerect = $HSplitContainer/TabContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect
onready var frame_number_node = $HSplitContainer/TabContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/FrameNumber
onready var origin_node = $HSplitContainer/TabContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/Panel
onready var xorigin_node = $HSplitContainer/TabContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/Panel/HBoxContainer/XOriginInput
onready var yorigin_node = $HSplitContainer/TabContainer/Preview/VBoxContainer/PanelContainer/BG/MarginContainer/SpriteTextureRect/Gizmos/Panel/HBoxContainer/YOriginInput
#onready var fps_node = $HSplitContainer/TabContainer/Preview/VBoxContainer/TimelineControls/HBoxContainer/Left/FpsSpinBox
onready var fps_node = $HSplitContainer/TabContainer/Preview/VBoxContainer/TimelineControls/HBoxContainer/Left/PanelContainer/HBoxContainer/FpsSpinBox
onready var timeline = $HSplitContainer/TabContainer/Preview/VBoxContainer/Timeline/TimelineSlider
onready var pause_button_node = $HSplitContainer/TabContainer/Preview/VBoxContainer/TimelineControls/HBoxContainer/Middle/PausePlayButton


var meta : Meta = Meta.new()
var current_sprite = ''
var mode = 0

var thread = null
var resolve_progress = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_asset(asset_path):
	meta = app.base_wad.parse_meta(asset_path)
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
	current_sprite = sprite_name
	frametexturerect.texture = meta.sprites.get_frame(current_sprite, 0)
	mode = 0
	if !app.base_wad.sprite_data.has(sprite_name):
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
			xorigin_node.value = app.base_wad.sprite_data[current_sprite]['center'].x
			yorigin_node.value = app.base_wad.sprite_data[current_sprite]['center'].y
			frametexturerect.origin_pos = app.base_wad.sprite_data[current_sprite]['center']
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
#		#value = int(value * xorigin_node.max_value)
#		meta.center_norms[current_sprite].x = value
#	else:
#		app.base_wad.sprite_data[current_sprite]['center'].x = value
#	app.base_wad.changed_files['GL/hlm2_sprites.bin'] = app.base_wad.spritebin
	frametexturerect.origin_pos.x = value
	frametexturerect.update()
func _on_YOriginInput_value_changed(value):
#	if meta.is_gmeta:
#		#value = int(value * yorigin_node.max_value)
#		meta.center_norms[current_sprite].y = value
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


func _on_RecalculateSheetButton_pressed():
	thread = Thread.new()
	# Third argument is optional userdata, it can be any variable.
	thread.start(meta, "resolve", [meta.sprites, meta.texture_page], Thread.PRIORITY_HIGH)

