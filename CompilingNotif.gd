extends PanelContainer

signal cancel_resolve
signal resolve_complete
var asset_name = ''
var asset = null


onready var app = get_tree().get_nodes_in_group('App')[0]

func _ready():
	$VBoxContainer/HBoxContainer/Label2.text = asset_name

func _on_CancelResolveButton_pressed():
#	emit_signal("cancel_resolve", asset)
	if asset and app and app.threads:
		app.mutex.lock()
		asset.terminate_resolve = true
		app.mutex.unlock()
		call_deferred('wait_for_thread', app.threads[asset][0])
	queue_free()

func resolve_complete(a):
#	emit_signal("resolve_complete", asset)
#	app._resolve_complete(asset)
	if asset and app and app.threads:
		call_deferred('wait_for_thread', app.threads[asset][0])
	else:
		queue_free()

func update_resolve_progress(v=0):
	$VBoxContainer/ProgressBar.value = v

func wait_for_thread(t:Thread):
	var r = t.wait_to_finish()
	if r == null:
		emit_signal("cancel_resolve", asset)
	else:
		emit_signal("resolve_complete", asset)
	queue_free()



