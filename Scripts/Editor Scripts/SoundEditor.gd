extends VBoxContainer

onready var app = get_tree().get_nodes_in_group('App')[0]
#onready var sound_tree = $TabContainer2/Advanced/SoundTree

#var sounds = null
#var sound = {}
var sound_s :AudioStreamSample= null
var sound :WadSound= null
var sound_duration = 1
onready var sound_player = $AudioStreamPlayer

onready var timeline = $Container/VBoxContainer/Timeline/TimelineSlider
onready var poly :Polygon2D= $Container/VBoxContainer/Timeline/Control/Control/Polygon2D
onready var poly2 :Polygon2D= $Container/VBoxContainer/Timeline/Control/Control/Polygon2D2
onready var timecode = $Container/VBoxContainer/TimelineControls/HBoxContainer/Right/TimecodeLabel

onready var pause_button_node = $Container/VBoxContainer/TimelineControls/HBoxContainer/Middle/PausePlayButton

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.volume_db = -90*(exp(6.90775527898*(1-.25))*0.001)
	pass
#	file = SoundsBin.get_file_path()
#	tree = sound_tree


func set_sound(asset):
	$Label.text = asset
#	set_bin_asset(sound_name)
##	sound_tree.reset()
#	sounds = bin #app.base_wad.soundbin
#	sound = selected_struct #sounds.sound_data[sound_name]
##	sound_tree.create_dict(sound)
#	return sounds
	sound = app.base_wad.audio_stream(asset)
	# https://aneescraftsmanship.com/wav-file-format/
#	var samplenum = sound.stream.loop_end*4 # check wad->audio_stream towards the bottom
#	for i in range(len(sound.data) *  * (1+int(sound.stereo)))
	var polygon = []
	var polygon2 = []
	var i = 0
	var s = 1
	if sound.stream:
		s = len(sound.stream.data)
	var rand_s = 5+randf()*6+s/50000
	var d = s/150.0
	if s<150:
		d = 1
	for b in range(0, s, d):
#		polygon.append(Vector2((float(b)/float(s))*1600-800, -480*sound.data[b]/255))
		var p = float(b)/float(s)
		var v = Vector2 (
			p*100-50,
			-50*0.333*(.6+0.4*sin((rand_s/11.315)*p*PI) \
			+.6-0.4*cos(s+212+(rand_s/6.315)*p*PI) \
			+ (0.4+0.6*sin(s+(rand_s)*p*PI)))*(1-2*abs(p-0.5))
		)
		polygon.append(v)
		polygon2.append(Vector2(v.x,-v.y))

		i += 1
	polygon.append(Vector2(50, 0))
	polygon.append(Vector2(-50, 0))
	polygon2.append(Vector2(50, 0))
	polygon2.append(Vector2(-50, 0))
	poly.polygon = polygon
	poly2.polygon = polygon2

	sound_player.stream = sound.stream
	
	timeline.tween.playback_speed = 0
	if sound.stream:
		sound.stream.loop_mode = timeline.tween.repeat
		timeline.tween.playback_speed = float(1) / sound.stream.get_length()
	timeline.tween.seek(0)
	timeline.set_tween()
	if timeline.tween.is_active():
		sound_player.play()

	pause_button_node.grab_focus()
	timecode.text = '0.000000s'
	return sound
#
#func parse_new_value(key, value, new_text_value):
#	if key == 'sprite_index' or key == 'mask_sprite':
#		var sprite_index = value
#		if int(new_text_value) == -1 or new_text_value=='Null':
#			return [-1, 'Null']
#		# sets sprite index from name
#		if app.base_wad.get_bin(SpritesBin).sprite_data.has(new_text_value):
#			sprite_index = app.base_wad.get_bin(SpritesBin).sprite_data[new_text_value]['id']
#		# sets sprite index from index
#		elif (int(new_text_value) or new_text_value=='0') and app.base_wad.get_bin(SpritesBin).sprites.has(int(new_text_value)):
#			sprite_index = int(new_text_value)
#		if app.base_wad.get_bin(SpritesBin).sprites.has(sprite_index):
#			return [sprite_index, app.base_wad.get_bin(SpritesBin).sprites[sprite_index]['name']]
#	if key == 'parent':
#		var sound_index = value
#		if bin.data.has(new_text_value):
#			sound_index = bin.data[new_text_value]['id']
#		if bin.names.has(can_be_int_fuck_you_godot(new_text_value)):
#			sound_index = can_be_int_fuck_you_godot(new_text_value)
#		return [sound_index, bin.names[sound_index]]
#	return [value, new_text_value]

#func _on_SoundTree_item_edited(deleted=0):
#	_on_Tree_item_edited(deleted)
#	return

func _on_PausePlayButton_toggled(button_pressed):
#	if timeline.value == 1:
#		timeline.tween.reset_all()
#		timeline.tween.start()
#		return
	if button_pressed:
		timeline.tween.resume_all()
#		print(sound_player.volume_db)
		if sound.stream:
			sound_player.play(timeline.value * sound.stream.get_length() * int(timeline.value!=1))
	else:
		timeline.tween.stop_all()
		sound_player.stop()


func _on_Button_toggled(button_pressed):
	timeline.tween.repeat = button_pressed
	if sound.stream:
		sound.stream.loop_mode = sound.stream.LOOP_FORWARD




func _on_FrameBackTrackButton_pressed():
	timeline.tween.stop_all()
	var v = timeline.value
#	var v = timeline.value - (1.0/meta.sprites.get_frame_count(current_sprite))
	timeline.tween.seek(v)
	timeline.value = v
	timeline.update_pos(v)
func _on_FrameAdvanceButton_pressed():
	timeline.tween.stop_all()
	var v = timeline.value
#	var v = timeline.value + (1.0/meta.sprites.get_frame_count(current_sprite))
	timeline.tween.seek(v)
	timeline.value = v
	timeline.update_pos(v)


func _on_HSlider_value_changed(value):
	sound_player.volume_db = -90*(exp(6.90775527898*(1-value))*0.001)
