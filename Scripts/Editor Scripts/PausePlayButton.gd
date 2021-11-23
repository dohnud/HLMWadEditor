extends Button


export(Texture) var pause
export(Texture) var play
#onready var playf = load(play)
#onready var pausef = load(pause)

onready var d = { false: pause, true : play}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PausePlayButton_toggled(button_pressed):
	icon = d[button_pressed]
	pressed = button_pressed


func _on_Tween_tween_all_completed():
	pressed = false


func _on_FrameBackTrackButton_pressed():
	_on_PausePlayButton_toggled(false)
func _on_FrameAdvanceButton_pressed():
	_on_PausePlayButton_toggled(false)
