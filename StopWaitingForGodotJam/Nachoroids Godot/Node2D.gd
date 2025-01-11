extends Node2D
var highscore_list : Array

var original_score_dict = {
	"Current": true,
	"Score": 0,
	"Time": "00:00",
	"Name": "Alex"
}

func _ready():
	highscore_list = General.read_savegame()["Highscore List"]
	updatetext()

func updatetext():
	$Label.text = ""
	for i in highscore_list:
		$Label.text += str(i) + "\n"

func _on_Button_pressed():
	var new_score_dict = original_score_dict.duplicate()
	new_score_dict["Score"] = int($Button/LineEdit.text)
	check_score(new_score_dict)

func check_score(current_score):
	for element in highscore_list:
		if current_score["Score"] > element["Score"]:
			highscore_list.insert(highscore_list.rfind(element), current_score) #INSERT OVER ELEMENT
			current_score["Current"] = false
			break
		elif current_score["Score"] == element["Score"]:
			highscore_list.insert(highscore_list.rfind(element), current_score) #replace score - INSERT UNDER ELEMENT
			current_score["Current"] = false
			break
	highscore_list.resize(10)
	updatetext()
