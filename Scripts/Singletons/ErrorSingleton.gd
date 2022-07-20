extends Node

class_name ErrorLogger

onready var app = get_tree().get_nodes_in_group("App")[0]
onready var w = app.get_node("ErrorDialog")
onready var label = w.get_node("Label2")

func show_generic_error():
	w.popup()
	log_error(label.text)

func show_user_error(msg : String, todisk=true):
	w.popup()
	label.text = msg
	if todisk:
		log_error(msg)

func log_error(msg : String):
	Log.log("ERR: " + msg)
