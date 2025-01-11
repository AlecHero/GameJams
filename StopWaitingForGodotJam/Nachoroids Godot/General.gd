extends Node
#class_name General

const save_path = "user://savegame.save" #place of the file

var highscore_list
var borderless_fullscreen
var mouse_hue

var save_dict = {
	"Highscore List": highscore_list,
	"Borderless": borderless_fullscreen,
	"Mouse Hue": mouse_hue
}

func _notification(notification):
	match notification:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			get_tree().paused = false
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			get_tree().paused = true

func _ready():
	first_save()

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE) #open file to write
	save_dict["Highscore List"] = highscore_list
	save_dict["Borderless"] = borderless_fullscreen
	save_dict["Mouse Hue"] = mouse_hue
	
	file.store_var(save_dict) #store the data
	file = null

func read_savegame():
	var file = FileAccess.open(save_path, FileAccess.READ) #open the file
	
	save_dict = file.get_var() #get the value
	highscore_list = save_dict["Highscore List"]
	borderless_fullscreen = save_dict["Borderless"]
	mouse_hue = save_dict["Mouse Hue"]

	return save_dict

func first_list():
	var list_element = {
		"Score": 0,
		"Time": "00:00",
		"Name": "ALEX",
		"Current": false
	}
	var pre_save_list = []
	for i in range(10):
		pre_save_list.append(list_element)
	return pre_save_list

func first_save():
	if not savegame.file_exists(save_path):
		
		highscore_list = first_list()
		borderless_fullscreen = false
		mouse_hue = 0.0
		
		save_dict["Highscore List"] = highscore_list
		save_dict["Borderless"] = borderless_fullscreen
		save_dict["Mouse Hue"] = mouse_hue
		
		save()

func add_score(current_score):
	read_savegame()
	
	for element in highscore_list:
		if current_score["Score"] > element["Score"]:
			highscore_list.insert(highscore_list.find(element), current_score)
			highscore_list.resize(10)
			break
	save()
	return highscore_list

func set_borderless(mode): #THIS COULD PROBABLY BE PRETTIER
	if !mode and !borderless_fullscreen: #This makes sure it doesn't recenter/resize if it's already in windowed mode
		pass
	elif !mode:
		get_window().set_size(Vector2(800, 450))
		OS.center_window()
	
	get_window().borderless = (mode)
	get_window().mode = Window.MODE_MAXIMIZED if (mode) else Window.MODE_WINDOWED
	borderless_fullscreen = mode
	save()

func weighted_average(initial, current, weight_increase):
	var selected
	var sum_weight = 0.0
	for weight in current.values():
		sum_weight += weight
	
	for type in current.keys():
		var rand_num = randf()
		if current[type] / sum_weight >= rand_num:
			selected = type
			break
		else:
			sum_weight -= current[type]
	
	current[selected] = initial[selected]
	for type in current.keys():
		if type != selected:
			current[type] += weight_increase
	
	return selected
