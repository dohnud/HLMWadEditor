extends HSlider

#onready var editor = get_tree().get_nodes_in_group('MetaApp')[0]
export(NodePath) var editor_p
onready var editor = get_node(editor_p)

onready var parent = get_parent()
onready var tween = $Tween
var stopped = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("value_changed", self, 'update_pos')
	connect("resized", self, "update_pos")
	tween.connect("tween_all_completed", self, 'set_tween')
	update_pos()
	$TimelineBar.rect_position.y = 0
	set_tween()
	
func set_tween():
	tween.interpolate_property(self, "value",
		0, 1, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

var col_bin = null
var spr_bin = null 
var current_mask = null
var current_time = 0

func update_pos(v:float=0):
	current_time = v
	if parent == null : return
	if $TimelineBar == null : return
	$TimelineBar.rect_position.x = parent.rect_size.x * value - 2
	if editor.frametexturerect:
		var c = editor.meta.sprites.get_frame_count(editor.current_sprite)
		var i = int(clamp(value * c, 0, max(0,c-1)))
		var f = editor.meta.sprites.get_frame(editor.current_sprite, i)
		if f:
			editor.frame_tex_offset_node.text = str(f.region.position.x) + ', ' + str(f.region.position.y)
			if f is MetaTexture:
				editor.frame_tex_uv_node.text = str(f.uv.position.x) + ', ' + str(f.uv.position.y) + '  ' + str(f.uv.size.x) + ' x ' + str(f.uv.size.y)
		if editor.show_collision_mask:
			if !current_mask:
				if !col_bin: col_bin = editor.app.base_wad.get_bin(CollisionMasksBin)
				if !spr_bin: spr_bin = editor.app.base_wad.get_bin(SpritesBin)
				var sprite_id = spr_bin.sprite_data[editor.current_sprite]['id']
				current_mask = col_bin.find(sprite_id, null)
				if !current_mask:
					var ref = editor.app.base_wad
					if len(editor.app.base_wad.patchwad_list):
						ref = editor.app.base_wad.patchwad_list[0]
					ref.goto(CollisionMasksBin.get_file_path())
					current_mask = col_bin.find(sprite_id, ref)
					ref.close()
#				var tex :ImageTexture= current_mask.images[min(i, len(current_mask.images)-1)]
			if current_mask:
				editor.frametexturerect.texture = current_mask.images[min(i, len(current_mask.images)-1)]
		else:
			editor.frametexturerect.texture = f
		editor.frame_number_node.text = str(int(i))
		#editor.animatedsprite_node.frame = (value-1/editor.meta.sprites.get_frame_count(editor.current_sprite)) * editor.meta.sprites.get_frame_count(editor.current_sprite)


func _on_TimelineSlider_gui_input(event):
	var e :InputEvent = event
	if event.is_action_pressed('ui_lmb') or event.is_action_released('ui_lmb'):
		tween.stop_all()
		tween.seek(clamp(get_local_mouse_position().x/rect_size.x,0,1))
		editor.pause_button_node.emit_signal('toggled',false)
