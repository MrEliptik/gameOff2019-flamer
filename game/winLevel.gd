extends Control

var nextLevel = ""

func setNextLevel(level):
	nextLevel = level

func _process(delta):
	if self.is_visible():
		if Input.is_action_pressed("ui_restart") or Input.is_action_just_pressed("ui_dash") \
		or Input.is_action_just_pressed("ui_jump") or Input.is_action_just_pressed("ui_slowmo"):
			get_tree().change_scene(nextLevel)

func setStats(stats):
	$VBoxContainer2/HBoxContainer0/HBoxContainer/Value.text = str(int(stats["level_time"]/1000))
	$VBoxContainer2/HBoxContainer1/HBoxContainer/Value.text = str(stats["avg_air_time"])
	$VBoxContainer2/HBoxContainer2/HBoxContainer/Value.text = str(stats["max_air_time"])
	$VBoxContainer2/HBoxContainer3/HBoxContainer/Value.text = str(stats["jump_count"])
	$VBoxContainer2/HBoxContainer4/HBoxContainer/Value.text = str(stats["perfect_jumps"])
	$VBoxContainer2/HBoxContainer5/HBoxContainer/Value.text = str(stats["platforms_hit"])
	$VBoxContainer2/HBoxContainer6/Value.text = str(int(stats["score"]))

func _on_BlinkTimer_timeout():
	if $CenterContainer/Label.is_visible():
		$CenterContainer/Label.hide()
	else:
		$CenterContainer/Label.show()
