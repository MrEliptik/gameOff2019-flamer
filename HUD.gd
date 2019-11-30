extends Control

func updateScore(score):
	$HBoxContainer/HBoxContainer/Value.text = str(score)
	
func updateStats(stats):
	$HBoxContainer/HBoxContainer1/Value.text = str(stats["score"])
	$HBoxContainer/HBoxContainer2/Value.text = str(stats["air_time"])
	$HBoxContainer/HBoxContainer3/Value.text = str(stats["perfect_jumps"])
	$HBoxContainer/HBoxContainer4/Value.text = str(stats["platforms_hit"])