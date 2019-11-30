extends Control

func setStats(stats):
	$HBoxContainer/HBoxContainer1/Value.text = str(stats["avg_air_time"])
	$HBoxContainer/HBoxContainer2/Value.text = str(stats["max_air_time"])
	$HBoxContainer/HBoxContainer3/Value.text = str(stats["jump_count"])
	$HBoxContainer/HBoxContainer4/Value.text = str(stats["perfect_jumps"])
	$HBoxContainer/HBoxContainer5/Value.text = str(stats["platforms_hit"])
	$HBoxContainer/HBoxContainer6/Value.text = str(stats["score"])