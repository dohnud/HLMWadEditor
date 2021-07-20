extends PanelContainer

signal cancel_resolve
signal resolve_complete
var asset_name = ''
var asset = null


onready var app = get_tree().get_nodes_in_group('App')[0]

func _ready():
	$VBoxContainer/HBoxContainer/Label2.text = asset_name

func _on_CancelResolveButton_pressed():
	emit_signal("cancel_resolve", asset)
	queue_free()

func resolve_complete(a=''):
#	emit_signal("resolve_complete", asset)
#	app._resolve_complete(asset)
	if asset and app and app.threads:
		call_deferred('wait_for_thread', app.threads[asset][0])
	else:
		queue_free()

func update_resolve_progress(v=0):
	$VBoxContainer/ProgressBar.value = v

func wait_for_thread(t:Thread):
	t.wait_to_finish()
	emit_signal("resolve_complete", asset)
	queue_free()
