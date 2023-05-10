extends Node

class_name ErrorLogger

onready var app = get_tree().get_nodes_in_group("App")[0]
onready var w :AcceptDialog= app.get_node("ErrorDialog")
onready var label = w.get_node("Label2")

const default_err = "Error occured!\n Check that no other program is utilizing the current base wad or that it has been moved."

var error_queue = []

func _ready() -> void:
	w.connect("popup_hide", self, "show_next_user_error_in_queue")

func show_generic_error() -> void:
	w.popup()
	log_error(default_err)

func show_user_error(msg:String, todisk=true) -> void:
	error_queue.append([msg, todisk])
	_show_user_error(msg, todisk)
	

func _show_user_error(msg:String, todisk=true) -> void:
	if len(error_queue) > 0 and !w.visible:
		w.popup()
		label.text = msg
		if todisk:
			log_error(msg)

func show_next_user_error_in_queue() -> void:
	var err = error_queue.pop_back()
	if err:
		_show_user_error(err[0], err[1])

func log_error(msg : String) -> void:
	Log.log("[ERR] : " + msg)
