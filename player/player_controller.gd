extends KinematicBody2D

const DEBUG = true

export (int) var speed = 400
export (int) var run_speed = 500
export (int) var jump_speed = 700
export (int) var dash_speed = 4000
export (int) var gravity = 1600

export (int) var score = 0

# In milliseconds
const PERFECT_JUMP_INTERVAL = 800

# In seconds
const DASH_TIME = 1
# Used to count up the time we are dashing
# until we reach DASH_TIME
var dash_acc = 0

var dash_finished = true

var velocity = Vector2()

var vignette = 1.0

var pre_dash_speed = 0

var max_jumps = 2
var jump_count = 0

var ready_to_idle = false

onready var state = IdleState.new(self)
onready var previous_state = null

enum STATES{
	IDLE,
	RUN_LEFT,
	RUN_RIGHT,
	AIR_LEFT,
	AIR_RIGHT,
	JUMP,
	DOUBLE_JUMP,
	DASH_LEFT,
	DASH_RIGHT,
	FALL,
	DEAD
}

enum CONTROLLER{
	KEYBOARD,
	GAMEPAD,
	TOUCHSCREEN	
} 
var control_type = CONTROLLER.KEYBOARD

func _physics_process(delta):	
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
			#var tile_id = collision.collider.get_cellv(tile_pos)
			#var tile_name = collision.collider.tile_set.tile_get_name(tile_id)
			#print(tile_id, tile_name)
		# Player fell to its death
		elif collision.collider is StaticBody2D:
			set_state(STATES.DEAD)
		else:
			print(collision.collider)
	
	state.update(delta)
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
func _input(e):
	print(Input.get_action_strength("ui_left"), Input.get_action_strength("ui_right"))
	# Check what controller the user is currently using
	if e is InputEventJoypadButton or e is InputEventJoypadMotion:
		control_type = CONTROLLER.GAMEPAD
	elif e is InputEventKey:
		control_type = CONTROLLER.KEYBOARD
	elif e is InputEventScreenTouch:
		control_type = CONTROLLER.TOUCHSCREEN
	state.input(e)
	
func set_state(new_state):
	state.exit()
	if new_state == STATES.IDLE:
		state = IdleState.new(self)
	elif new_state == STATES.RUN_RIGHT:
		state = RunRightState.new(self)
	elif new_state == STATES.RUN_LEFT:
		state = RunLeftState.new(self)
	elif new_state == STATES.JUMP:
		state = JumpState.new(self)
	elif new_state == STATES.DOUBLE_JUMP:
		state = DoubleJumpState.new(self)
	elif new_state == STATES.AIR_LEFT:
		state = AirLeftState.new(self)
	elif new_state == STATES.AIR_RIGHT:
		state = AirRightState.new(self)
	elif new_state == STATES.DASH_LEFT:
		state = DashLeftState.new(self)
	elif new_state == STATES.DASH_RIGHT:
		state = DashRightState.new(self)
	elif new_state == STATES.FALL:
		state = FallState.new(self)
	elif new_state == STATES.DEAD:
		state = DeadState.new(self)


func get_state():
	if state is IdleState:
		return STATES.IDLE
	elif state is RunRightState:
		return STATES.RUN_RIGHT
	elif state is RunLeftState:
		return STATES.RUN_LEFT
	elif state is JumpState:
		return STATES.JUMP
	elif state is DoubleJumpState:
		return STATES.DOUBLE_JUMP
	elif state is AirLeftState:
		return STATES.AIR_LEFT
	elif state is AirRightState:
		return STATES.AIR_RIGHT
	elif state is DashLeftState:
		return STATES.DASH_LEFT
	elif state is DashRightState:
		return STATES.DASH_RIGHT
	elif state is FallState:
		return STATES.FALL
	elif state is DeadState:
		return STATES.DEAD
		
class IdleState:
	var player
	
	func _init(player):
		self.player = player
		player.ready_to_idle = false
		player.get_node("AnimatedSprite").play("idle")
		player.velocity.x = 0
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()

	func _get_name():
		return "Idle"	
	
	func update(delta):
		player.velocity.y += delta * player.gravity
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump"):
			player.set_state(player.STATES.JUMP)
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.RUN_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.RUN_RIGHT)
	
	func exit():
		player.previous_state = player.state
		
class RunRightState:
	var player
	
	func _init(player):
		self.player = player
		player.velocity.x = 0
		player.get_node("AnimatedSprite").set_flip_h(false)
		player.velocity.x += player.run_speed
		player.get_node("AnimatedSprite").play("run")
		player.pre_dash_speed = player.velocity.x
		
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Run right"
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.ready_to_idle:
			player.set_state(player.STATES.IDLE)
		# Useful for analog control
		#var dir_strength = Input.get_action_strength("ui_right")
		#print(dir_strength)
		#player.velocity.x *= dir_strength
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump"):
			player.set_state(player.STATES.JUMP)
		elif e.is_action_pressed("ui_dash"):
			player.set_state(player.STATES.DASH_RIGHT)
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.RUN_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_right") > 0.01:
			pass
		else:
			player.set_state(player.STATES.IDLE)
			#player.get_node("IdleTimer").start()
	
	func exit():
		player.previous_state = player.state
		
class RunLeftState:
	var player
	
	func _init(player):
		self.player = player
		player.velocity.x = 0
		player.get_node("AnimatedSprite").set_flip_h(true)
		player.velocity.x -= player.run_speed
		player.get_node("AnimatedSprite").play("run")
		player.pre_dash_speed = player.velocity.x
		
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Run left"
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.ready_to_idle:
			player.set_state(player.STATES.IDLE)
		# Useful for analog control
		#var dir_strength = Input.get_action_strength("ui_left")
		#print(dir_strength)
		#player.velocity.x *= dir_strength
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump"):
			player.set_state(player.STATES.JUMP)
		elif e.is_action_pressed("ui_dash"):
			player.set_state(player.STATES.DASH_LEFT)
		elif e.is_action_pressed("ui_right") or e.get_action_strength("ui_right") > 0.01:
			player.set_state(player.STATES.RUN_RIGHT)
		elif e.is_action_pressed("ui_left") or e.get_action_strength("ui_left") > 0.01:
			pass
		else:
			player.set_state(player.STATES.IDLE)
			#player.get_node("IdleTimer").start()
	
	func exit():
		player.previous_state = player.state
		
class JumpState:
	var player
	
	func _init(player):
		self.player = player
		player.velocity.y = -player.jump_speed
		player.jump_count = 1
		player.score+=1
		player.get_node("Camera2D/CanvasLayer/HUD").updateScore(player.score)
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Jump"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.is_on_floor():
			player.set_state(player.STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump"):
			player.set_state(player.STATES.DOUBLE_JUMP)
		elif e.is_action_pressed("ui_left"):
			player.set_state(player.STATES.AIR_LEFT)
		elif e.is_action_pressed("ui_right"):
			player.set_state(player.STATES.AIR_RIGHT)
	
	func exit():
		player.previous_state = player.state
	
class DoubleJumpState:
	var player
	
	func _init(player):
		self.player = player
		player.velocity.y = -player.jump_speed
		player.jump_count = 2
		player.score+=1
		player.get_node("Camera2D/CanvasLayer/HUD").updateScore(player.score)
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Double Jump"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.is_on_floor():
			player.set_state(player.STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_left"):
			player.set_state(player.STATES.AIR_LEFT)
		elif e.is_action_pressed("ui_right"):
			player.set_state(player.STATES.AIR_RIGHT)
	
	func exit():
		player.previous_state = player.state

class AirLeftState:
	var player
	
	func _init(player):
		self.player = player
		player.velocity.x = 0
		player.get_node("AnimatedSprite").set_flip_h(true)
		player.velocity.x -= player.run_speed
		player.get_node("AnimatedSprite").play("run")
		player.pre_dash_speed = player.velocity.x
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Air left"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.is_on_floor():
			if Input.is_action_pressed("ui_right"):
				player.set_state(player.STATES.RUN_RIGHT)
			elif Input.is_action_pressed("ui_left"):
				player.set_state(player.STATES.RUN_LEFT)
			else:
				player.set_state(player.STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump") and player.jump_count < player.max_jumps:
			player.set_state(player.STATES.DOUBLE_JUMP)
		elif e.is_action_pressed("ui_dash"):
			player.set_state(player.STATES.DASH_LEFT)
		elif e.is_action_pressed("ui_right") or e.get_action_strength("ui_right") > 0.01:
			player.set_state(player.STATES.AIR_RIGHT)
		elif e.is_action_pressed("ui_left") or e.get_action_strength("ui_left") > 0.01:
			pass
		else:
			pass
			#player.set_state(player.STATES.FALL)
	
	func exit():
		player.previous_state = player.state

class AirRightState:
	var player
	
	func _init(player):
		self.player = player
		player.velocity.x = 0
		player.get_node("AnimatedSprite").set_flip_h(false)
		player.velocity.x += player.run_speed
		player.get_node("AnimatedSprite").play("run")
		player.pre_dash_speed = player.velocity.x
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Air right"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.is_on_floor():
			if Input.is_action_pressed("ui_right"):
				player.set_state(player.STATES.RUN_RIGHT)
			elif Input.is_action_pressed("ui_left"):
				player.set_state(player.STATES.RUN_LEFT)
			else:
				player.set_state(player.STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump") and player.jump_count < player.max_jumps:
			player.set_state(player.STATES.DOUBLE_JUMP)
		elif e.is_action_pressed("ui_dash"):
			player.set_state(player.STATES.DASH_RIGHT)
		elif e.is_action_pressed("ui_left") or e.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.AIR_LEFT)
		elif e.is_action_pressed("ui_right") or e.get_action_strength("ui_right") > 0.01:
			pass
		else:
			pass
			#player.set_state(player.STATES.FALL)
	
	func exit():
		player.previous_state = player.state
		
class DashLeftState:
	var player
	
	func _init(player):
		self.player = player

		player.velocity.x = -player.dash_speed
		player.dash_finished = false
		player.get_node("DashTimer").start()
		
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Dash left"	
		
	func update(delta):
		if player.dash_finished:
			player.set_state(player.STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
	
	func exit():
		player.previous_state = player.get_state()
		
class DashRightState:
	var player
	
	func _init(player):
		self.player = player

		player.velocity.x = player.dash_speed
		player.dash_finished = false
		player.get_node("DashTimer").start()
		
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Dash right"	
		
	func update(delta):
		if player.dash_finished:
			player.set_state(player.STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
	
	func exit():
		player.previous_state = player.get_state()
		
class FallState:
	var player
	
	func _init(player):
		self.player = player
		player.velocity.x = 0
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Fall"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.is_on_floor():
			if Input.is_action_pressed("ui_right"):
				player.set_state(player.STATES.RUN_RIGHT)
			elif Input.is_action_pressed("ui_left"):
				player.set_state(player.STATES.RUN_LEFT)
			else:
				player.set_state(player.STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_right") or e.get_action_strength("ui_right") > 0.01:
			player.set_state(player.STATES.AIR_RIGHT)
		elif e.is_action_pressed("ui_left") or e.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.AIR_LEFT)
	
	func exit():
		player.previous_state = player.get_state()
		
class DeadState:
	var player
	
	func _init(player):
		self.player = player
		player.get_node("AnimatedSprite").play("dead")
		
		if player.control_type == player.CONTROLLER.GAMEPAD:
			Input.start_joy_vibration(0, 1, 1, 0.4)
		player.get_node("Camera2D").shake(1.5, 15, 20)
		player.get_node("AnimatedSprite").play("dead")
		player.get_node("Camera2D/CanvasLayer3/Vignette").get_material().set_shader_param("vignette_radius", 1.0)
		player.get_node("Camera2D/CanvasLayer2/Dead_screen").visible = true
		
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Dead"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
	
	func input(e):
		if e.is_action_pressed("ui_restart"): 	
			player.get_tree().reload_current_scene()
	func exit():
		player.previous_state = player.state


func _on_IdleTimer_timeout():
	print("idle timeout")
	ready_to_idle = true

func _on_DashTimer_timeout():
	dash_finished = true

func _on_GhostTimer_timeout():
	if get_state() == STATES.DASH_RIGHT or get_state() == STATES.DASH_LEFT:
		# make a copy of the ghost obj
		var this_ghost = preload("res://ghost.tscn").instance()
		# give the ghost a parent
		get_parent().add_child(this_ghost)
		this_ghost.position = position
		this_ghost.texture = $AnimatedSprite.frames.get_frame($AnimatedSprite.animation, $AnimatedSprite.frame)
		this_ghost.flip_h = $AnimatedSprite.flip_h
		this_ghost.scale = $AnimatedSprite.scale
