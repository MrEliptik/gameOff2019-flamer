extends Control

func _physics_process(delta):
	pass

func _on_BlinkTimer_timeout():
	if $Label2.is_visible():
		$Label2.hide()
	else:
		$Label2.show()
