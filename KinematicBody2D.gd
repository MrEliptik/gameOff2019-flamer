extends KinematicBody2D

export (int) var speed = 400
export (int) var run_speed = 400
export (int) var jump_speed = -800
export (int) var gravity = 1400

var velocity = Vector2()
var jumping = false

func get_input():
    velocity.x = 0

    if Input.is_action_just_pressed('jump') and is_on_floor():
        jumping = true
        velocity.y = jump_speed
		
    if Input.is_action_pressed("left"):
        velocity.x -= run_speed
    elif Input.is_action_pressed("right"):
        velocity.x += run_speed

func _physics_process(delta):
    get_input()
    velocity.y += delta * gravity

    if jumping and is_on_floor():
        jumping = false

    velocity = move_and_slide(velocity, Vector2(0, -1))