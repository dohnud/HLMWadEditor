extends PanelContainer

signal cancel_resolve
signal resolve_complete
var asset_name = ''

func _ready():
	$VBoxContainer/HBoxContainer/Label2.text = asset_name

func _on_CancelResolveButton_pressed():
	emit_signal("cancel_resolve", asset_name)
	queue_free()

func resolve_complete(a=''):
	emit_signal("resolve_complete", asset_name)
	queue_free()

func update_resolve_progress(v=0):
	$VBoxContainer/ProgressBar.value = v

func wait_for_thread(t:Thread):
	t.wait_to_finish()
	queue_free()
