extends AcceptDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ErrorDialog_popup_hide():
	$Label2.text = "Error occured!\n Check that no other program is utilizing the current base wad or that it has been moved."
