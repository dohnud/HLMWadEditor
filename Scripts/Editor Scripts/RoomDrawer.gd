extends Control

onready var app = get_tree().get_nodes_in_group('App')[0]

var room = null
var position = Vector2(10,10)

var a :AtlasesBin= null
var o :ObjectsBin= null
var s :SpritesBin= null
var b :BackgroundsBin= null

func create_room():
	if room:
		for o in get_children():
			remove_child(o)
			o.queue_free()
		if!a: a = app.base_wad.get_bin(AtlasesBin)
		if!o: o = app.base_wad.get_bin(ObjectsBin)
		if!s: s = app.base_wad.get_bin(SpritesBin)
		if!b: b = app.base_wad.get_bin(BackgroundsBin)
		draw_set_transform(rect_position,0,Vector2.ONE)
		var i = 0
		var tile_meta = app.base_wad.parse_meta('Atlases/Backgrounds.meta')
		var tiles = {
		}
		var d = {
			2 : "Backgrounds/tlFloor",
			3 : "Backgrounds/tlAsphalt",
			6 : "Backgrounds/tlRugs",
			7 : "Backgrounds/tlTile",
			5 : "Backgrounds/tlBathroom",
			8 : "Backgrounds/tlStairs",
			47: "Backgrounds/tlTrain",
			17: "Backgrounds/tlSand",
			4 : "Backgrounds/tlDirtBlood",
			9 : "Backgrounds/tlEdges",
			15 : "Backgrounds/tlEdges",
		}
		for tl in room['tiles']:
			var atlas_tuple = a.atlases_backgrounds[tl.id]
			var sprite_name = a.atlas_names.values()[atlas_tuple['id']] + '.meta'
#			print(tl.id, ' ', atlas_tuple, ' ', sprite_name, ' ', tl.tilesheet_pos)
			var meta_sprite_index = tl.id#atlas_tuple['atlas_id']
			var f = null
			if d.has(meta_sprite_index):
				f = tile_meta.sprites.get_frame(d[meta_sprite_index], 0)
				
#			f = tile_meta.sprites.get_frame(tile_meta.sprites.get_animation_names()[atlas_tuple.atlas_id], 0)
			
			var id = tl.id * 1000000 + tl.tilesheet_pos.x * 1000 + tl.tilesheet_pos.y
			if !(tiles.has(id)) and f:
				var nf = AtlasTexture.new()
				nf.region = Rect2(f.region.position + tl.tilesheet_pos, tl.tilesheet_size)
				nf.atlas = f
				tiles[id] = nf
			var s = TextureRect.new()
			if tiles.has(id):
				s.texture = tiles[id]
			s.rect_position = (tl.world_pos)
			s.set('z', 98 + tl.depth)
			s.focus_mode = Control.FOCUS_NONE
			s.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(s)
#			tilemap.set_cellv(tilemap.world_to_map(tl.world_pos), id)
			
		for obj in room['objects']:
			var atlas_tuple = a.atlas_sprites[o.object_data[o.object_names[obj['id']]]['sprite_index']]
			var meta_name = 'Atlases/' + a.atlas_names.values()[atlas_tuple['id']] + '.meta'
			var meta_sprite_index = atlas_tuple['atlas_id']
			var meta = app.base_wad.parse_meta(meta_name)
			var meta_sprite_name = meta.sprite_names_ordered[meta_sprite_index]
			var f = meta.sprites.get_frame(meta_sprite_name, 0)
			var offset = s.sprite_data[meta_sprite_name]['center']
#			draw_texture_rect(f, Rect2((obj['pos'] - offset)*rect_scale, f.region.size*rect_scale), false)
#			draw_circle(obj['pos']*rect_scale,2,Color(1,1,1,1))
			var s = TextureRect.new()
			s.texture = f
			s.rect_position = (obj['pos'] - offset)
			s.focus_mode = Control.FOCUS_NONE
			s.mouse_filter = Control.MOUSE_FILTER_IGNORE
			s.mouse_filter = Control.MOUSE_FILTER_PASS
			s.connect("gui_input", self, 'room_item_clicked', [i, obj, meta_sprite_name])
			i += 1
			add_child(s)
#		for obj in room['objects']:
#			draw_string(get_font('font'), obj['pos']*rect_scale, str(obj['id']))

func room_item_clicked(e:InputEvent, i, obj, meta_sprite_name):
	if e.is_action_pressed("ui_lmb"):
		print(i,':', obj,' ',meta_sprite_name)
		ErrorLog.show_user_error(str(i) + ' : ' + obj + '  ' + meta_sprite_name, false)
	_on_TextureRect_gui_input(e, true)
	
#var rect_scale = 1
func _on_TextureRect_gui_input(e:InputEvent,happy=true):
	if happy:
		if e is InputEventMagnifyGesture:
			var ns = e.factor * rect_scale
			rect_position -= (rect_scale - ns) * (get_local_mouse_position())
			rect_scale = ns
		if e.is_action_pressed("ui_scroll_up"):
			var ns = rect_scale * 1.1
			rect_position -= (ns-rect_scale) * (get_local_mouse_position())
			rect_scale = ns
		if e.is_action_pressed("ui_scroll_down"):
			var ns = rect_scale * 0.90
			rect_position -= (ns-rect_scale) * (get_local_mouse_position())
			rect_scale = ns
	if e is InputEventPanGesture:
		rect_position += e.delta * rect_scale
	if e is InputEventMouseMotion and Input.is_action_pressed('ui_mmb'):
		rect_position += e.relative
