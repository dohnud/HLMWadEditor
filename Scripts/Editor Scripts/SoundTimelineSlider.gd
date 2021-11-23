extends HSlider

onready var editor = get_tree().get_nodes_in_group('SoundEditor')[0]

onready var parent = get_parent()
onready var tween = $Tween
var stopped = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("value_changed", self, 'update_pos')
	connect("resized", self, "update_pos")
	tween.connect("tween_all_completed", self, 'set_tween')
	update_pos()
#	$TimelineBar.rect_position.y = 0
	set_tween()
	get_stylebox('custom_styles/slider').content_margin_top = rect_size.y
	
func set_tween():
	tween.interpolate_property(self, "value",
		0, 1, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)


func update_pos(v:float=0):
	if parent == null : return
	if $TimelineBar == null : return
	$TimelineBar.rect_position.x = parent.rect_size.x * value - 2
	$TimelineBar.rect_size = rect_size
	if editor.timecode:
		if editor.sound.stream:
			editor.timecode.text = str(v*editor.sound.stream.get_length())+'s'
#	if editor.frametexturerect:
#		var c = editor.meta.sprites.get_frame_count(editor.current_sprite)
#		var i = clamp(value * c, 0, max(0,c-1))
#		var f = editor.meta.sprites.get_frame(editor.current_sprite, i)
#		editor.frametexturerect.texture = f
#		editor.frame_tex_offset_node.text = str(f.region.position.x) + ' x ' + str(f.region.position.y)
#		if f is MetaTexture:
#			editor.frame_tex_uv_node.text = str(f.uv.position.x) + ' x ' + str(f.uv.position.y)
#		editor.frame_number_node.text = str(int(i))
		#editor.animatedsprite_node.frame = (value-1/editor.meta.sprites.get_frame_count(editor.current_sprite)) * editor.meta.sprites.get_frame_count(editor.current_sprite)

var holding = false
func _on_TimelineSlider_gui_input(event):
	var e :InputEvent = event
	holding = event.is_action_pressed('ui_lmb')
	if event.is_action_pressed('ui_lmb') or event.is_action_released('ui_lmb'):
		tween.stop_all()
		tween.seek(clamp(get_local_mouse_position().x/rect_size.x,0,1))
		editor.pause_button_node.emit_signal('toggled',false)


func _on_TimelineSlider_resized():
	get_stylebox('slider').content_margin_top = rect_size.y-2
#	add_stylebox_override('slider')
	var p :Polygon2D= get_parent().get_child(0).get_child(0).get_child(0)
	p.scale = Vector2(rect_size.x/100, rect_size.y/100)
	p = get_parent().get_child(0).get_child(0).get_child(1)
	p.scale = Vector2(rect_size.x/100, rect_size.y/100)


