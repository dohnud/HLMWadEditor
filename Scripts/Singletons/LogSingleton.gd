extends Node

class_name Logger

var f = File.new()

var log_directory = OS.get_executable_path().get_base_dir() # OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + 'My Games/'

func _init():
	if OS.has_feature("editor"): log_directory = 'res://';
	elif OS.get_name() == 'OSX': log_directory = log_directory.split('.app')[0].get_base_dir() + '/';
	var r = false
	if f.file_exists(log_directory + 'log.txt'):
		r = f.open(log_directory + 'log.txt', File.READ_WRITE)
	else:
		r= f.open(log_directory + 'log.txt', File.WRITE)
	if !r:
		var date_dict = OS.get_datetime()
		f.seek_end()
		f.store_string('\n\n[' + str(date_dict['year']) + '-' + str(date_dict['month']) + '-'+ str(date_dict['day']) + '-' + str(date_dict['dst']) + '-' + str(date_dict['hour']) + '-' + str(date_dict['minute']) + '-' + str(date_dict['second'])  + ']\n')


func log(string, sep='\n'):
	print(string)
	f.store_string(string + sep)

func log_array(array, sep='\n', prefix=''):
	var i = 0
	f.store_string(prefix+'--- array['+str(len(array))+'] ---\n')
	for a in array:
		var p = prefix+str(i) + ': '
		if i > 0:
			var l = len(p)
			p = ''
			for _j in range(l):
				p += ' '
#		if a is Array or a is PoolByteArray:
#			log_array(a, '\n', p)
		if a is Dictionary:
			log_dict(a, '\n', p)
		else:
			f.store_string(p + str(a) + sep)
		i += 1
	f.store_string(prefix+'-------------\n')

func log_dict(dict, sep='\n', prefix=''):
	f.store_string(prefix+'---- dict['+str(len(dict))+'] ----\n')
	var i = 0
	for a in dict.keys():
		var p = prefix+str(a) + ': '
		if i > 0:
			var l = len(p)
			p = ''
			for _j in range(l):
				p += ' '
		if dict[a] is Array or dict[a] is PoolByteArray:
			log_array(dict[a], ', ', prefix)
		if dict[a] is Dictionary:
			log_dict(dict[a], '\n', prefix)
		else:
			f.store_string(prefix + str(dict[a]) + sep)
		i+=1
	f.store_string('--------------\n')

func _exit_tree():
	f.close()
