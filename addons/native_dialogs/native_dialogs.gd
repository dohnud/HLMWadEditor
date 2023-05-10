extends Node

const Message = preload("./bin/native_dialog_message.gdns")
const Notify = preload("./bin/native_dialog_notify.gdns")
const OpenFile = preload("./bin/native_dialog_open_file.gdns")
const SaveFile = preload("./bin/native_dialog_save_file.gdns")
const SelectFolder = preload("./bin/native_dialog_select_folder.gdns")

enum MessageChoices { OK, OK_CANCEL, YES_NO, YES_NO_CANCEL }
enum MessageIcons { INFO, WARNING, ERROR, QUESTION }
enum MessageResults { OK, CANCEL, YES, NO }

enum NotifyIcons { INFO, WARNING, ERROR }


onready var app = get_tree().get_nodes_in_group('App')[0]
onready var important_popups = app.get_node("ImportantPopups")

func popup_open_dialog(title='Open a File', filters=['* ; Any File'], target=null,callback='', autopopup=true):
	var dialog = OpenFile.new()
	dialog.title = title
	dialog.filters = filters
	important_popups.add_child(dialog)
	
	dialog.connect("files_selected", self, "_on_FileSelected", [dialog, target, callback])
	if autopopup: dialog.show()
	return dialog

func popup_save_dialog(title='Save a File', filters=['* ; Any File'], file_name='', target=null,callback='', autopopup=true):
	var dialog = SaveFile.new()
	dialog.initial_path = file_name
	dialog.title = title
	dialog.filters = filters
	important_popups.add_child(dialog)
	
	dialog.connect("file_selected", self, "_on_FileSelected", [dialog, target, callback])
	important_popups.show()
	if autopopup: dialog.show()
	return dialog

func popup_folder_dialog(title="Open a Folder", target=null, callback='', autopopup=true):
	var dialog = SelectFolder.new()
	dialog.title = title
	
	important_popups.add_child(dialog)
	dialog.connect("folder_selected", self, "_on_FileSelected", [dialog, target, callback])
	important_popups.show()
	if autopopup: dialog.show()
	return dialog

func _on_FileSelected(files, dialog, target, method):
	#var nw :WindowDialog= get_node("ImportantPopups/ImportSpriteStripSliceDialog")
	important_popups.hide()
	dialog.queue_free()
	if files is String and target:
		target.call(method, files)
		return
	for f in files:
		if target: target.call(method, f)
		break
