extends WindowDialog

var next_method_tuple = [self, '']
var cancel_method_tuple = [self, '']
var meta :Meta= null

func _ready():
	hide()

func _on_CancelButton_pressed():
	cancel_method_tuple[0].call(cancel_method_tuple[1])
	hide()

var ok = false
func _on_OkButton_pressed():
	ok = true
	next_method_tuple[0].call(next_method_tuple[1])
	hide()


func _on_GmetaWarningDialog_popup_hide():
	if !ok:
		_on_CancelButton_pressed()
