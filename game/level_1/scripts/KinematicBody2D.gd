extends KinematicBody2D

export (int) var speed = 400
export (int) var run_speed = 500
export (int) var jump_speed = 700
export (int) var dash_speed = 7000
export (int) var gravity = 1600

export (int) var score = 0

# In milliseconds
const PERFECT_JUMP_INTERVAL = 800

# In seconds
const DASH_TIME = 1
# Used to count up the time we are dashing
# until we reach DASH_TIME
var dash_acc = 0

var velocity = Vector2()
var jumping = false
var dashing = false

var dead = false

var vignette = 1.0

enum ORIENTATION{
	RIGHT,
	LEFT
} 

var player_orientation = ORIENTATION.RIGHT

var jump_count = 0
var max_jump = 2

var pre_dash_speed = 0

var last_time_touched_ground = 0

enum CONTROLLER{
	KEYBOARD,
	GAMEPAD,
	TOUCHSCREEN	
} 

var control_type = CONTROLLER.KEYBOARD

#joy_connection_changed ( int device, bool connected )
#Emitted when a joypad device has been connected or disconnected.

func _input(e):
	# Check what controller the user is currently using
	if e is InputEventJoypadButton or e is InputEventJoypadMotion:
		control_type = CONTROLLER.GAMEPAD
	elif e is InputEventKey:
		control_type = CONTROLLER.KEYBOARD
	elif e is InputEventScreenTouch:
		control_type = CONTROLLER.TOUCHSCREEN

func get_input():
	velocity.x = 0
	
	# Disable controls if dashing or dead
	if dashing or dead: return
		
	if jump_count < max_jump and Input.is_action_just_pressed('ui_jump'):
		# Check if perfect jump
		if is_on_floor():
			if OS.get_ticks_msec() - last_time_touched_ground < PERFECT_JUMP_INTERVAL:
				print("perfect jump")
		jumping = true
		jump_count += 1
		score+=1
		$Camera2D/CanvasLayer/HUD.updateScore(score)
		velocity.y = -jump_speed
	elif Input.is_action_just_pressed('ui_dash'):
		dashing = true;
		if player_orientation == ORIENTATION.RIGHT:
			velocity.x = dash_speed
		else:
			velocity.x = -dash_speed
		$Timer.start()
		
	# double jump
	if Input.is_action_pressed("ui_restart"):
		get_tree().reload_current_scene()
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= run_speed
		pre_dash_speed = velocity.x
		$AnimatedSprite.set_flip_h(true)
		$AnimatedSprite.play("run")
		player_orientation = ORIENTATION.LEFT
	elif Input.is_action_pressed("ui_right"):
		velocity.x += run_speed
		pre_dash_speed = velocity.x
		$AnimatedSprite.set_flip_h(false)
		$AnimatedSprite.play("run")
		player_orientation = ORIENTATION.RIGHT
	elif Input.is_action_pressed("ui_down"):
		pass
		#gravity = 8000
	else:
		#gravity = 1600
		$AnimatedSprite.play("idle")
		
func _physics_process(delta):
	if dead: return
	get_input()
	velocity.y += delta * gravity
	
	vignette -= (delta * 0.1)
	$Camera2D/CanvasLayer3/Vignette.get_material().set_shader_param("vignette_radius", vignette)
	
	# Falling
	if velocity.y < 0:
		#$AnimatedSprite.play("fall")
		pass
	# Jumping
	elif velocity.y > 0:
		#$AnimatedSprite.play("jump_up")
		pass

	# TODO: fix. Doesn't count the first jump
	# because we set jumping to true, but player
	# is stille touching the ground
	if jumping and is_on_floor():
		jumping = false
		last_time_touched_ground = OS.get_ticks_msec()
		jump_count = 0

	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	# Goes through every collision that happened
	# during move_and_slide()
	var slide_count = get_slide_count()
	#print(slide_count)
	for i in range(slide_count):
		var collision = get_slide_collision(i)
		
		# Confirm the colliding body is a TileMap
		if collision.collider is TileMap:
			# Find the character's position in tile coordinates
			var tile_pos = collision.collider.world_to_map(position)
			# Find the colliding tile position
			tile_pos -= collision.normal
			# Get the tile id
			var tile_id = collision.collider.get_cellv(tile_pos)
			var tile_name = collision.collider.tile_set.tile_get_name(tile_id)
			#print(tile_id, tile_name)
		# Player fell to its death
		elif collision.collider is StaticBody2D:
			if control_type == CONTROLLER.GAMEPAD:
				Input.start_joy_vibration(0, 1, 1, 0.4)
				
			$Camera2D.shake(1.5, 15, 20)
			$AnimatedSprite.play("dead")
			dead = true
			$Camera2D/CanvasLayer3/Vignette.get_material().set_shader_param("vignette_radius", 1.0)
			$Camera2D/CanvasLayer2/Dead_screen.visible = true
			#get_tree().change_scene("res://game/Dead_screen.tscn")
		else:
			print(collision.collider)

func _on_Timer_timeout():
	velocity.x = pre_dash_speed
	dashing = false