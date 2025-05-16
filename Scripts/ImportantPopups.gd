extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ExtractResourceDialog_popup_hide():
	hide()


func _on_ExportSpriteStripDialog_popup_hide():
	hide()


func _on_ImportSpriteStripSliceDialog_popup_hide():
	hide()

func _on_OpenPatchDialog_popup_hide():
	hide()


func _on_ImportSpriteStripDialog_popup_hide():
	hide()


func _on_SavePatchDialog_popup_hide():
	hide()


func _on_SaveGIFDialog_popup_hide():
	hide()


func _on_SaveGIFDialog2_about_to_show():
	show()


func _on_MergePatchDialog_popup_hide():
	hide()


func _on_ImportPatchWindowDialog_popup_hide() -> void:
	hide()
