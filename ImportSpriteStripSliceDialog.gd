extends WindowDialog

onready var app = get_tree().get_nodes_in_group('App')[0]


var texture = null
var f_count = 1

var meta :Meta = null
var sprite = null

func _on_ImportSpriteStripDialog_file_selected(path):
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		print('ouch couldnt load that image')
	texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	$VBoxContainer/Panel/ImportSpriteStripPreview.texture = texture
	popup()


func _on_SpinBox_value_changed(value):
	f_count = int(value)


func _on_Button_pressed():
	var frame_count = f_count
	var row_max = 0
	if row_max == 0: row_max = frame_count
	meta.sprites.remove_animation(sprite)
	meta.sprites.add_animation(sprite)
	var w = texture.get_width()
	var h = texture.get_height()
	var d = w / (frame_count)
	for i in range(frame_count):
		var f = AtlasTexture.new()
		f.region = Rect2(i*d, 0, d, h)
#			f.position = Vector2(i*d, 0)
		f.atlas = texture
#			root.import_selection.append(f)
#			root.import_tex = texture
		meta.sprites.add_frame(sprite, f)
	if 'Backgrounds/' != sprite.substr(0,len('Backgrounds/')):
		app.base_wad.spritebin.sprite_data[sprite]['size'] = Vector2(d, h)
		app.base_wad.spritebin.sprite_data[sprite]['frame_count'] = frame_count
	else:
		var tilesheet = sprite.substr(len('Backgrounds/'))
		app.base_wad.backgroundbin.background_data[tilesheet]['size'] = Vector2(w,h)
#		app.base_wad.backgroundbin.background_data[tilesheet]['tile_size'] = Vector2(w/frame_count, w/frame_count)
	hide()
	get_parent().hide()
