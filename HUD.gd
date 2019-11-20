extends Control

func updateScore(score):
	$HBoxContainer/HBoxContainer/Value.text = str(score)
	
func updateFPS(fps):
	$HBoxContainer/HBoxContainer2/Value.text = str(fps)