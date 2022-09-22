extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	update()
export(Texture) var origin_icon
export(Color) var icon_modulate
export(Color) var color

var origin_pos = Vector2.ZERO
var origin_draw_pos = Vector2.ZERO

#onready var metaeditor = get_tree().get_nodes_in_group('MetaApp')[0]
export(NodePath) var metaeditor_path
onready var metaeditor = get_node(metaeditor_path)

func _draw():
	if !texture:return
	if !$Gizmos.visible:return
	var sprite_w = texture.get_width()
	var window_w = rect_size.x
	var sprite_h = texture.get_height()
	var window_h = rect_size.y
	var sx = sprite_h / window_h
	var sy = sprite_w / window_w
	var x = window_w/2 - sprite_w/(2*sx)
	if x < 0:
		x = 0
		sx = 1
		sprite_w = window_w
	var y = window_h/2 - sprite_h/(2*sy)
	if y < 0:
		y = 0
		sy = 1
		sprite_h = window_h
	if sx <= 0: sx = 1
	if sy <= 0: sy = 1
	var dx = sprite_w / (sx)
	var dy = sprite_h / (sy)
	draw_rect(Rect2(x,y,dx,dy), color, false, 1)
	origin_draw_pos = Vector2(x,y) + (origin_pos/Vector2(texture.get_width(),texture.get_height())) * Vector2(dx, dy) - origin_icon.get_size()/2
	var s = metaeditor.app.base_wad.get_bin(SpritesBin)
	if metaeditor.meta.is_gmeta:
		var nv = Vector2(origin_pos.x / texture.get_width(), origin_pos.y / texture.get_height())
		if metaeditor.meta.center_norms[metaeditor.current_sprite] != nv:
			metaeditor.meta.center_norms[metaeditor.current_sprite] = nv
			metaeditor.app.base_wad.changed_files[metaeditor.app.selected_asset_name] = metaeditor.meta
	elif s.sprite_data.has(metaeditor.current_sprite):
		if s.sprite_data[metaeditor.current_sprite]['center'] != origin_pos:
			s.sprite_data[metaeditor.current_sprite]['center'] = origin_pos
			metaeditor.app.base_wad.changed_files[s.get_file_path()] = s

#	if metaeditor.show_collision_mask:
#		var sprite_id = s.sprite_data[metaeditor.current_sprite]['id']
#		var c = metaeditor.app.base_wad.get_bin(CollisionMasksBin)
#		var ref = metaeditor.app.base_wad
#		if len(metaeditor.app.base_wad.patchwad_list):
#			var result = metaeditor.app.base_wad.patchwad_list[0].goto(CollisionMasksBin.get_file_path())
#			if result != null:
#				ref = metaeditor.app.base_wad.patchwad_list[0]
#		ref.goto(CollisionMasksBin.get_file_path())
#		var mask = c.find(sprite_id, ref)
#		draw_texture(mask.images[0], Vector2(x,y))

	draw_texture(origin_icon, origin_draw_pos+Vector2.ONE, Color(0,0,0,0.3))
	draw_texture(origin_icon, origin_draw_pos, icon_modulate)
	
var moving = false

func _on_SpriteTextureRect_gui_input(e:InputEvent):
	if !$Gizmos.visible:return
#	var e : InputEvent = event
	if e.is_action_pressed("ui_lmb"):
		grab_focus()
		if get_local_mouse_position().distance_squared_to(origin_draw_pos + origin_icon.get_size()/2) < 500:
			moving = true
	if e.is_action_released('ui_lmb'):
		moving = false
	if e is InputEventMouseMotion and moving:
			if !texture:return
			var sprite_w = texture.get_width()
			var window_w = rect_size.x
			var sprite_h = texture.get_height()
			var window_h = rect_size.y
			var sx = sprite_h / window_h
			var sy = sprite_w / window_w
			var x = window_w/2 - sprite_w/(2*sx)
			if x < 0:
				x = 0
				sx = 1
				sprite_w = window_w
			var y = window_h/2 - sprite_h/(2*sy)
			if y < 0:
				y = 0
				sy = 1
				sprite_h = window_h
			if sx <= 0: sx = 1
			if sy <= 0: sy = 1
			var dx = sprite_w / (sx)
			var dy = sprite_h / (sy)
			origin_pos = (get_local_mouse_position() - Vector2(x+4,y+4) + origin_icon.get_size()/2) * Vector2(texture.get_width(),texture.get_height()) / Vector2(dx, dy)
			origin_pos = origin_pos.floor()
			origin_pos = Vector2(clamp(origin_pos.x,0,texture.get_width()), clamp(origin_pos.y,0,texture.get_height()))
			update()
#			metaeditor.app.base_wad.sprite_data[metaeditor.current_sprite]['center'] = origin_pos
			metaeditor.xorigin_node.value = origin_pos.x
			metaeditor.yorigin_node.value = origin_pos.y
			

func _on_XOriginInput_value_changed(value):
	origin_pos.x = value
	update()

func _on_YOriginInput_value_changed(value):
	origin_pos.y = value
	update()

func _on_SpriteTextureRect_mouse_exited():
	moving = false

