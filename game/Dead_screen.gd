extends Control

func _physics_process(delta):
	if Input.is_action_pressed("ui_restart"):
		get_tree().change_scene("res://game.tscn")