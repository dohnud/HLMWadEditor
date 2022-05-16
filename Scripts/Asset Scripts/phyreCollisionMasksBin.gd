extends "res://Scripts/Asset Scripts/CollisionMasksBin.gd"

class_name phyreCollisionMasksBin

#const file_path = 'GL/hlm2_sprites.bin'
#const alt_file_path = 'GL/hotline_sprites.bin'
static func get_file_path():
	return 'GL/hotline_collision_masks.bin'
func _to_string():
	return 'GL/hotline_collision_masks.bin'

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
