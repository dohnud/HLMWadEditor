extends FileDialog


onready var app = get_tree().get_nodes_in_group('App')[0]

var meta = null
var sprite = null

var export_mode = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ExportSpriteStripDialog_file_selected(path):
	if !(meta and sprite and path): return
	if export_mode == 0:
		var img = Image.new()
		img.create(1,1,false,Image.FORMAT_RGBA8)
		for i in range(meta.sprites.get_frame_count(sprite)):
			var f :MetaTexture= meta.sprites.get_frame(sprite, i)
			img.crop((i+1) * f.region.size.x, f.region.size.y)
			img.blit_rect(f.atlas.get_data(), f.region, Vector2(i * f.region.size.x,0))
		var e = img.save_png(path)
		get_parent().hide()


func _on_ExportSpriteStripDialog_dir_selected(dir):
	if !dir: return
	if export_mode == 0: return
	for spr in meta.sprites.get_animation_names():
		var img = Image.new()
		img.create(1,1,false,Image.FORMAT_RGBA8)
		for i in range(meta.sprites.get_frame_count(spr)):
			var f :MetaTexture= meta.sprites.get_frame(spr, i)
			img.crop((i+1) * f.region.size.x, f.region.size.y)
			img.blit_rect(f.atlas.get_data(), f.region, Vector2(i * f.region.size.x,0))
		var e = img.save_png(dir+'/'+spr+'_strip.png')
	OS.shell_open(str("file://", dir))
