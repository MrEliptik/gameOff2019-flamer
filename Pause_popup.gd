extends Control

func set_overlay(value):
	$ColorRect.visible = value

func _on_PopupMenu_index_pressed(index):
	print(index)
	# Resume
	if index == 0:
		get_tree().paused = false
		set_overlay(false)
	# Options
	elif index == 1:
		get_tree().paused = false
		set_overlay(false)
		#get_tree().change_scene("")
		
	# Titlescreen	
	elif index == 2:
		get_tree().paused = false
		set_overlay(false)
		get_tree().change_scene("res://titlescreen/scenes/titlescreen.tscn")
