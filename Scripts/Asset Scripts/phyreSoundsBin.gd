extends "res://Scripts/Asset Scripts/SoundsBin.gd"

class_name phyreSoundsBin

#const file_path = 'GL/hlm2_sprites.bin'
#const alt_file_path = 'GL/hotline_sprites.bin'
static func get_file_path():
	return 'GL/hotline_sounds.bin'
func _to_string():
	return 'GL/hotline_sounds.bin'

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
