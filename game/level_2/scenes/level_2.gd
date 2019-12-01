extends Node2D


func _ready():
	$MovingSaws/MovingCircularSaw/AnimationPlayer.set_autoplay("Up_and_down")

func _on_Powerup_body_entered(body):
	if body is PhysicsBody2D:
		$Powerup.set_deferred("monitoring", false)                             
		$Powerup.visible = false


func _on_Powerup2_body_entered(body):
	if body is PhysicsBody2D:
		$Powerup2.set_deferred("monitoring", false)                             
		$Powerup2.visible = false
