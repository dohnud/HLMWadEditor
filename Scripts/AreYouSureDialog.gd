extends ConfirmationDialog

onready var label = $Label2

signal choice_made(yes)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_cancel().connect("pressed", self, "result", [false])
	connect("confirmed", self, "result", [true])


func result(yes):
	print(yes)
	emit_signal("choice_made", yes)
