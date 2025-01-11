extends Node

@onready var rank_list = [
	$MarginContainer/VBoxContainer/HBoxContainer/Ranks,
	$MarginContainer/VBoxContainer/HBoxContainer/Scores,
	$MarginContainer/VBoxContainer/HBoxContainer/Times,
	$MarginContainer/VBoxContainer/HBoxContainer/Names
]
var highscore_list = General.read_savegame()["Highscore List"]
var new_best := false

var original_score_dict = { #DEBUG
	"Current": true,
	"Score": 0,
	"Time": "00:00",
	"Name": "ALEX"
}

func _on_Button_pressed(): #DEBUG
	var new_score_dict = original_score_dict.duplicate()
	new_score_dict["Score"] = int($DEBUG/LineEdit.text)
	highscore_list = General.add_score(new_score_dict)
	fix_score()

func _ready():
	highscore_list = General.read_savegame()["Highscore List"]
	fix_score()

func boldify(stringy : String, is_best):
	if is_best: #for new best
		return "[i]" + stringy + "[/i]"
	else: #for current
		return "[b]" + stringy + "[/b]"

func fix_score():
	var rank_array := ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th"]
	
	for element in rank_list:
		element.text = "[center]"
	
	for element in highscore_list:
		if element["Current"]: #make the current score visible (if it made it)
			new_best = true if rank_array[0] == "1st" else false #do something special if score is a new best
			rank_list[0].text += boldify(rank_array.pop_front(), new_best) + "\n"
			rank_list[1].text += boldify(str(element["Score"]), new_best) + "\n"
			rank_list[2].text += boldify(str(element["Time"]), new_best) + "\n"
			rank_list[3].text += boldify(str(element["Name"]), new_best) + "\n"
			element["Current"] = false
			General.save()
		else: #add the rest of the scores
			rank_list[0].text += rank_array.pop_front() + "\n"
			rank_list[1].text += str(element["Score"]) + "\n"
			rank_list[2].text += str(element["Time"]) + "\n"
			rank_list[3].text += str(element["Name"]) + "\n"

func _on_TextureButton_pressed():
	get_tree().change_scene_to_file("Titlescreen.tscn")
