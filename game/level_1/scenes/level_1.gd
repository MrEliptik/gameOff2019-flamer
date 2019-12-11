extends Node2D


func _on_Powerup_body_entered(body):
	if body is PhysicsBody2D:
		$Powerup.set_deferred("monitoring", false)                             
		$Powerup.visible = false

func _on_Powerup2_body_entered(body):
	if body is PhysicsBody2D:
		$Powerup2.set_deferred("monitoring", false)
		$Powerup2.visible = false

func _on_Powerup3_body_entered(body):
	if body is PhysicsBody2D:
		$Powerup3.set_deferred("monitoring", false)
		$Powerup3.visible = false

func _on_Powerup4_body_entered(body):
	if body is PhysicsBody2D:
		$Powerup4.set_deferred("monitoring", false)
		$Powerup4.visible = false

func _on_FinishArea_body_entered(body):
	$AudioStreamPlayer.stop()
