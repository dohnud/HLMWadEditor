extends File

class_name Logger

func _init():
	open('log.txt', WRITE)


func log(string, sep='\n'):
	store_string(string + sep)

func log_array(array, sep='\n'):
	var i = 0
	store_string('--- array ---')
	for a in array:
		store_string(str(i) +': ' + str(a) + sep)
		i += 1
	store_string('-------------')

func log_dict(dict, sep='\n'):
	store_string('---- dict ----')
	for a in dict.keys():
		store_string(str(a) +': ' + str(dict[a]) + sep)
	store_string('--------------')
