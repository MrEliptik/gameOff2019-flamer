extends KinematicBody2D

const DEBUG = true

export (int) var air_friction = 0.2
export (int) var air_speed = 300
export (int) var run_speed = 400
export (int) var jump_speed = 600
export (int) var dash_speed = 1700
export (int) var gravity = 1600

export (int) var score = 0

# In milliseconds
const PERFECT_JUMP_INTERVAL = 800

const PERFECT_JUMP_VIGNETTE = -0.01
const PLATFORM_HIT_VIGNETTE = -0.005

# In seconds
const DASH_TIME = 1
# Used to count up the time we are dashing
# until we reach DASH_TIME
var dash_acc = 0

var dash_finished = true

var slowmo_finished = true

var last_time_touched_ground = 0

var velocity = Vector2()

var vignette = 1.0

var pre_dash_speed = 0

var max_jumps = 2
var jump_count = 0

var powerups_count = 4

var nextLevel = ""

var last_running_sound_pos = 0

onready var start_level = OS.get_ticks_msec()

onready var powerups_sprites = [get_node("Powerup1"), get_node("Powerup2"), get_node("Powerup3"), get_node("Powerup4")]

var stats = {
	"air_time":0,
	"avg_air_time":0,
	"max_air_time":0,
	"jump_count":0,
	"perfect_jumps":0,
	"platforms_hit":0,
	"level_time":0,
	"score":0
}

var air_time_begin = 0

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
	DEAD,
	WIN
}

enum CONTROLLER{
	KEYBOARD,
	GAMEPAD,
	TOUCHSCREEN	
} 
var control_type = CONTROLLER.KEYBOARD

enum ORIENTATION{
	RIGHT,
	LEFT	
}
var player_orientation = ORIENTATION.RIGHT

func calculateAvgAirTime():
	stats["avg_air_time"] += stats["air_time"]
	stats["avg_air_time"] /= 2
	
func calculateMaxAirTime():
	var currentAirTime = OS.get_ticks_msec() - air_time_begin
	if currentAirTime > stats["max_air_time"]:
		stats["max_air_time"] = currentAirTime
		
func calculateAirTime():
	stats["air_time"] = OS.get_ticks_msec() - air_time_begin
	return stats["air_time"]
	
func calculateDeltaAirTime():
	print((OS.get_ticks_msec() - air_time_begin) - stats["air_time"])
	return (OS.get_ticks_msec() - air_time_begin) - stats["air_time"]

func calculateLevelTime():
	stats["level_time"] = OS.get_ticks_msec() - start_level
	
func addScore(value):
	stats["score"] += value

func calculateScore():
	return 0.25*stats["air_time"] + 0.5*stats["perfect_jumps"] + 0.15*stats["jump_count"] + 0.1*stats["platforms_hit"]

# Goes between 0.7 (no vignette) to 0 (black screen)
func set_vignette(value):
	vignette = value
	# Prevent wrong values
	if vignette > 0.7: vignette = 0.7
	elif vignette < 0: vignette = 0
	$Camera2D/CanvasLayer3/Vignette.get_material().set_shader_param("vignette_radius", vignette)

# If value > 0, increase vignetting
# If value < 0, decrease vignetting
func add_vignette(value):
	vignette -= value
	# Prevent wrong values
	if vignette > 0.7: vignette = 0.7
	elif vignette < 0: vignette = 0
	$Camera2D/CanvasLayer3/Vignette.get_material().set_shader_param("vignette_radius", vignette)
	
func _physics_process(delta):
	
	if get_state() == STATES.DEAD or get_state() == STATES.WIN: return
	
	var powerups_visible = powerups_count
	for sprite in powerups_sprites:
		if powerups_visible > 0:
			sprite.visible = true
			powerups_visible -= 1
		else:
			sprite.visible = false
	
	# Add vignetting every physics frame
	add_vignette(delta * 0.02)
	stats["score"] += delta
	
	calculateLevelTime()
	
	$Camera2D/CanvasLayer/HUD.updateStats(stats)
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	# Goes through every collision that happened
	# during move_and_slide()
	var slide_count = get_slide_count()
	
	#print(slide_count)
	for i in range(slide_count):
		var collision = get_slide_collision(i)

		# Confirm the colliding body is a TileMap
		if collision.collider is TileMap:
			#print(self.position)
			# Find the character's position in tile coordinates
			var tile_pos = get_parent().get_node("TileMap").world_to_map(collision.collider.to_local(self.position))
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
	$Camera2D/CanvasLayer/HUD.updateStats(stats)
		
func _input(e):
	#print(Input.get_action_strength("ui_left"), Input.get_action_strength("ui_right"))
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
	elif new_state == STATES.WIN:
		state == WinState.new(self)

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
	elif state is WinState:
		return STATES.WIN
		
class IdleState:
	var player
	
	func _init(player):
		self.player = player
		player.get_node("AnimatedSprite").play("idle")
		player.velocity.x = 0
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()

	func _get_name():
		return "Idle"	
	
	func update(delta):
		player.velocity.y += delta * player.gravity
		
		if player.is_on_floor():
			player.get_node("AnimatedSprite").play("idle")
		else:
			if player.velocity.y > 0:
				player.get_node("AnimatedSprite").play("jump_fall")
	
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
		player.get_node("RunningSound").play(player.last_running_sound_pos)
		player.player_orientation = player.ORIENTATION.RIGHT
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
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump"):
			player.set_state(player.STATES.JUMP)
		elif e.is_action_pressed("ui_dash"):
			if player.powerups_count > 0:
				player.set_state(player.STATES.DASH_RIGHT)
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.RUN_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_right") > 0.01:
			pass
		else:
			player.set_state(player.STATES.IDLE)
	
	func exit():
		player.last_running_sound_pos = player.get_node("RunningSound").get_playback_position()
		player.get_node("RunningSound").stop()
		player.last_time_touched_ground = OS.get_ticks_msec()
		player.previous_state = player.state
		
class RunLeftState:
	var player
	
	func _init(player):
		self.player = player
		player.get_node("RunningSound").play(player.last_running_sound_pos)
		player.player_orientation = player.ORIENTATION.LEFT
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
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump"):
			player.set_state(player.STATES.JUMP)
		elif e.is_action_pressed("ui_dash"):
			if player.powerups_count > 0:
				player.set_state(player.STATES.DASH_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_right") > 0.01:
			player.set_state(player.STATES.RUN_RIGHT)
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			pass
		else:
			player.set_state(player.STATES.IDLE)
	
	func exit():
		player.last_running_sound_pos = player.get_node("RunningSound").get_playback_position()
		player.last_time_touched_ground = OS.get_ticks_msec()
		player.get_node("RunningSound").stop()
		player.previous_state = player.state
		
class JumpState:
	var player
	
	func _init(player):
		self.player = player
		player.get_node("JumpSound").play(0)
		player.air_time_begin = OS.get_ticks_msec()
		player.get_node("AnimatedSprite").play("jump_up")
		player.get_node("JumpParticles").emitting = true
		player.velocity.y = -player.jump_speed
		player.jump_count = 1
		player.stats["jump_count"]+=1
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Jump"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.velocity.y > 0:
			player.get_node("AnimatedSprite").play("jump_fall")
		if player.is_on_floor():
			player.last_time_touched_ground = OS.get_ticks_msec()
			player.addScore(player.calculateAirTime())
			player.add_vignette(-delta*0.01)
			player.calculateMaxAirTime()
			player.calculateAvgAirTime()
			player.set_state(STATES.IDLE)
		else:
			player.calculateAirTime()
			player.add_vignette(-delta*0.01)
			player.calculateMaxAirTime()
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump"):
			if player.powerups_count > 0:
				player.set_state(player.STATES.DOUBLE_JUMP)
			if player.is_on_floor():
				if OS.get_ticks_msec() - player.last_time_touched_ground < player.PERFECT_JUMP_INTERVAL:
					print("perfect jump")
					player.get_node("TwinkleParticles").emitting = true
					player.stats["perfect_jumps"]+=1
					player.add_vignette(player.PERFECT_JUMP_VIGNETTE)
				player.calculateAvgAirTime()
		elif e.is_action_pressed("ui_dash"):
			if player.powerups_count > 0:
				if player.player_orientation == player.ORIENTATION.RIGHT:
					player.set_state(player.STATES.DASH_RIGHT)
				elif player.player_orientation == player.ORIENTATION.LEFT:
					player.set_state(player.STATES.DASH_LEFT)
		elif e.is_action_pressed("ui_slowmo"):
			if player.powerups_count > 0:
				player.powerups_count -= 1
				player.get_node("Camera2D").zoom = Vector2(0.8, 0.8)
				player.get_node("NormalToSlow").play(0)
				player.get_node("SlowmoTimer").start()
				player.get_node("SlowmoSoundTimer").start()
				Engine.time_scale = 0.1
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.AIR_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_right") > 0.01:
			player.set_state(player.STATES.AIR_RIGHT)
	
	func exit():
		player.previous_state = player.state
	
class DoubleJumpState:
	var player
	
	func _init(player):
		self.player = player
		player.powerups_count -= 1
		player.get_node("DJumpSound").play(0)
		#player.get_node("DJumpTimer").start()
		player.get_node("AnimatedSprite").play("double_jump")
		player.get_node("DJumpParticles").emitting = true
		player.velocity.y = -player.jump_speed
		player.jump_count = 2
		player.stats["jump_count"]+=1
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Double Jump"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.velocity.y > 0:
			player.get_node("AnimatedSprite").play("jump_fall")
		if player.is_on_floor():
			player.last_time_touched_ground = OS.get_ticks_msec()
			player.addScore(player.calculateAirTime())
			player.add_vignette(-delta*0.01)
			player.calculateMaxAirTime()
			player.calculateAvgAirTime()
			player.set_state(STATES.IDLE)
		else:
			player.calculateAirTime()
			player.add_vignette(-delta*0.01)
			player.calculateMaxAirTime()
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_dash"):
			if player.powerups_count > 0:
				if player.player_orientation == player.ORIENTATION.RIGHT:
					player.set_state(player.STATES.DASH_RIGHT)
				elif player.player_orientation == player.ORIENTATION.LEFT:
					player.set_state(player.STATES.DASH_LEFT)
		elif e.is_action_pressed("ui_slowmo"):
			if player.powerups_count > 0:
				player.powerups_count -= 1
				player.get_node("Camera2D").zoom = Vector2(0.8, 0.8)
				player.get_node("NormalToSlow").play(0)
				player.get_node("SlowmoTimer").start()
				player.get_node("SlowmoSoundTimer").start()
				Engine.time_scale = 0.1
		elif e.is_action_pressed("ui_jump"):
			if OS.get_ticks_msec() - player.last_time_touched_ground < player.PERFECT_JUMP_INTERVAL:
				print("perfect jump")
				player.get_node("TwinkleParticles").emitting = true
				player.stats["perfect_jumps"]+=1
				player.add_vignette(player.PERFECT_JUMP_VIGNETTE)
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.AIR_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_right") > 0.01:
			player.set_state(player.STATES.AIR_RIGHT)
		elif player.is_on_floor():
			player.calculateAvgAirTime()
			player.set_state(player.STATES.IDLE)
	
	func exit():
		player.previous_state = player.state

class AirLeftState:
	var player
	
	func _init(player):
		self.player = player
		player.get_node("AnimatedSprite").play("jump_up")
		player.player_orientation = player.ORIENTATION.LEFT
		player.velocity.x = 0
		player.get_node("AnimatedSprite").set_flip_h(true)
		player.velocity.x -= player.air_speed
		player.pre_dash_speed = player.velocity.x
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Air left"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.velocity.y > 0:
			player.get_node("AnimatedSprite").play("jump_fall")
		if player.is_on_floor():
			player.last_time_touched_ground = OS.get_ticks_msec()
			player.calculateAvgAirTime()
			player.addScore(player.calculateAirTime())
			player.calculateMaxAirTime()
			if Input.is_action_pressed("ui_right"):
				player.set_state(player.STATES.RUN_RIGHT)
			elif Input.is_action_pressed("ui_left"):
				player.set_state(player.STATES.RUN_LEFT)
			else:
				player.set_state(player.STATES.IDLE)
		else:
			player.calculateAirTime()
			player.add_vignette(-delta*0.01)
			player.calculateMaxAirTime()
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump") and player.jump_count < player.max_jumps:
			if player.is_on_floor():
				if OS.get_ticks_msec() - player.last_time_touched_ground < player.PERFECT_JUMP_INTERVAL:
					print("perfect jump")
					player.get_node("TwinkleParticles").emitting = true
					player.stats["perfect_jumps"]+=1
					player.add_vignette(player.PERFECT_JUMP_VIGNETTE)
			if player.powerups_count > 0:
				player.set_state(player.STATES.DOUBLE_JUMP)
		elif e.is_action_pressed("ui_slowmo"):
			if player.powerups_count > 0:
				player.powerups_count -= 1
				player.get_node("Camera2D").zoom = Vector2(0.8, 0.8)
				player.get_node("NormalToSlow").play(0)
				player.get_node("SlowmoTimer").start()
				player.get_node("SlowmoSoundTimer").start()
				Engine.time_scale = 0.1
		elif e.is_action_pressed("ui_dash"):
			if player.powerups_count > 0:
				player.set_state(player.STATES.DASH_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_right") > 0.01:
			player.set_state(player.STATES.AIR_RIGHT)
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			pass
		elif player.is_on_floor():
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
		player.get_node("AnimatedSprite").play("jump_up")
		player.player_orientation = player.ORIENTATION.RIGHT
		player.velocity.x = 0
		player.get_node("AnimatedSprite").set_flip_h(false)
		player.velocity.x += player.air_speed
		player.pre_dash_speed = player.velocity.x
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Air right"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
		if player.velocity.y > 0:
			player.get_node("AnimatedSprite").play("jump_fall")
		if player.is_on_floor():
			player.last_time_touched_ground = OS.get_ticks_msec()
			player.addScore(player.calculateAirTime())
			player.calculateMaxAirTime()
			player.calculateAvgAirTime()
			if Input.is_action_pressed("ui_right"):
				player.set_state(player.STATES.RUN_RIGHT)
			elif Input.is_action_pressed("ui_left"):
				player.set_state(player.STATES.RUN_LEFT)
			else:
				player.set_state(player.STATES.IDLE)
		else:
			player.calculateAirTime()
			player.add_vignette(-delta*0.01)
			player.calculateMaxAirTime()
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
		elif e.is_action_pressed("ui_jump") and player.jump_count < player.max_jumps:
			if player.is_on_floor():
				if OS.get_ticks_msec() - player.last_time_touched_ground < player.PERFECT_JUMP_INTERVAL:
					print("perfect jump")
					player.get_node("TwinkleParticles").emitting = true
					player.stats["perfect_jumps"]+=1
					player.add_vignette(player.PERFECT_JUMP_VIGNETTE)
			if player.powerups_count > 0:
				player.set_state(player.STATES.DOUBLE_JUMP)
		elif e.is_action_pressed("ui_slowmo"):
			if player.powerups_count > 0:
				player.powerups_count -= 1
				player.get_node("Camera2D").zoom = Vector2(0.8, 0.8)
				player.get_node("NormalToSlow").play(0)
				player.get_node("SlowmoTimer").start()
				player.get_node("SlowmoSoundTimer").start()
				Engine.time_scale = 0.1
		elif e.is_action_pressed("ui_dash"):
			if player.powerups_count > 0:
				player.set_state(player.STATES.DASH_RIGHT)
		elif e.is_action_pressed("ui_left") or Input.get_action_strength("ui_left") > 0.01:
			player.set_state(player.STATES.AIR_LEFT)
		elif e.is_action_pressed("ui_right") or Input.get_action_strength("ui_right") > 0.01:
			pass
		elif player.is_on_floor():
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
		player.powerups_count -= 1
		player.velocity.y = 0
		player.velocity.x = -player.dash_speed
		player.dash_finished = false
		player.get_node("Camera2D").shake(0.5, 10, 20)
		player.get_node("DashTimer").start()
		player.get_node("GhostTimer").start()
		player.get_node("AnimatedSprite").play("dash")
		player.get_node("SwooshSound").play(0)
				
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Dash left"	
		
	func update(delta):
		if player.dash_finished:
			if Input.is_action_pressed("ui_jump"):
				if OS.get_ticks_msec() - player.last_time_touched_ground < player.PERFECT_JUMP_INTERVAL:
					print("perfect jump")
					player.get_node("TwinkleParticles").emitting = true
					player.stats["perfect_jumps"]+=1
					player.add_vignette(player.PERFECT_JUMP_VIGNETTE)
			elif Input.is_action_pressed("ui_right"):
				if player.is_on_floor():
					player.set_state(STATES.RUN_RIGHT)
				else:
					player.set_state(STATES.AIR_RIGHT)
			elif Input.is_action_pressed("ui_left"):
				if player.is_on_floor():
					player.set_state(STATES.RUN_LEFT)
				else:
					player.set_state(STATES.AIR_LEFT)
			else:
				player.set_state(STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
	
	func exit():
		player.previous_state = player.state
		
class DashRightState:
	var player
	
	func _init(player):
		self.player = player
		player.powerups_count -= 1
		player.velocity.y = 0
		player.velocity.x = player.dash_speed
		player.dash_finished = false
		player.get_node("Camera2D").shake(0.3, 10, 20)
		player.get_node("DashTimer").start()
		player.get_node("GhostTimer").start()
		player.get_node("AnimatedSprite").play("dash")
		player.get_node("SwooshSound").play(0)
		
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Dash right"	
		
	func update(delta):
		if player.dash_finished:
			if Input.is_action_pressed("ui_right"):
				if player.is_on_floor():
					player.calculateAvgAirTime()
					player.set_state(STATES.RUN_RIGHT)
				else:
					player.set_state(STATES.AIR_RIGHT)
			elif Input.is_action_pressed("ui_left"):
				if player.is_on_floor():
					player.calculateAvgAirTime()
					player.set_state(STATES.RUN_LEFT)
				else:
					player.set_state(STATES.AIR_LEFT)
			else:
				player.set_state(STATES.IDLE)
	
	func input(e):
		if e.is_action_pressed("ui_restart"):
			player.get_tree().paused = true
			player.get_node("Camera2D/CanvasLayer4/Menu").show()
			
		
	func exit():
		player.previous_state = player.state
		
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
		player.previous_state = player.state
		
class DeadState:
	var player
	
	func _init(player):
		self.player = player
		self.player.velocity = Vector2(0, 0)
		#player.get_node("Camera2D").force_update_scroll()
		player.get_node("Camera2D").zoom = Vector2(0.6, 0.6)
		player.get_node("AnimatedSprite").play("dead")
		
		if player.control_type == player.CONTROLLER.GAMEPAD:
			Input.start_joy_vibration(0, 1, 1, 0.4)
		player.get_node("Camera2D").shake(1, 15, 20)
		player.set_vignette(0.7)
		player.get_node("Camera2D/CanvasLayer2/Dead_screen").visible = true
		player.get_node("DeathSound").play(0)
		
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

class WinState:
	var player
	
	func _init(player):
		self.player = player
		player.get_node("WinSound").play(0)
		player.get_node("Camera2D/CanvasLayer/HUD").hide()
		player.get_node("Camera2D/CanvasLayer5/win_screen").setNextLevel(player.nextLevel)
		player.get_node("Camera2D/CanvasLayer5/win_screen").setStats(player.stats)
		self.player.velocity = Vector2(0, 0)
		#player.get_node("Camera2D").force_update_scroll()
		player.get_node("Camera2D").zoom = Vector2(0.7, 0.7)
		player.get_node("AnimatedSprite").play("idle")

		player.set_vignette(0.7)
		player.get_node("Camera2D/CanvasLayer5/win_screen").visible = true
		
		if player.DEBUG:
			player.get_node("player_state").text = _get_name()
		
	func _get_name():
		return "Win"	
		
	func update(delta):
		player.velocity.y += delta * player.gravity
	
	func input(e):
		if e.is_action_pressed("ui_restart"): 	
			player.get_tree().reload_current_scene()
			
	func exit():
		player.previous_state = player.state

func _on_DashTimer_timeout():
	dash_finished = true
	print("dash timeout")

func _on_GhostTimer_timeout():
	if get_state() == STATES.DASH_RIGHT or get_state() == STATES.DASH_LEFT:
		# make a copy of the ghost obj
		var this_ghost = preload("res://effects/ghost.tscn").instance()
		# give the ghost a parent
		get_parent().add_child(this_ghost)
		this_ghost.position = position
		this_ghost.texture = $AnimatedSprite.frames.get_frame($AnimatedSprite.animation, $AnimatedSprite.frame)
		this_ghost.flip_h = $AnimatedSprite.flip_h
		this_ghost.scale = $AnimatedSprite.scale

func _on_SlowmoTimer_timeout():
	get_node("Camera2D").zoom = Vector2(1, 1)
	slowmo_finished = true
	print("slowmo finished")
	Engine.time_scale = 1.0


func _on_SlowmoSoundTimer_timeout():
	$SlowToNormal.play(0)

func _on_FinishArea_body_entered(body):
	if body is PhysicsBody2D:
		print("entered")
		nextLevel = "res://game/level_2/scenes/level_2.tscn"
		set_state(STATES.WIN)

func _on_FinishArea_level2_body_entered(body):
	if body is PhysicsBody2D:
		print("entered")
		nextLevel = "titlescreen/scenes/titlescreen.tscn"
		set_state(STATES.WIN)
		
func _on_Powerup_body_entered(body):
	if body is PhysicsBody2D:
		print("flame entered")
		if powerups_count < 4:
			powerups_count += 1
			
func _on_DJumpTimer_timeout():
	if get_state() == STATES.DOUBLE_JUMP:
		# make a copy of the ghost obj
		var this_ghost = preload("res://effects/ghost.tscn").instance()
		# give the ghost a parent
		get_parent().add_child(this_ghost)
		this_ghost.position = position
		this_ghost.texture = $AnimatedSprite.frames.get_frame($AnimatedSprite.animation, $AnimatedSprite.frame)
		this_ghost.flip_h = $AnimatedSprite.flip_h
		this_ghost.scale = $AnimatedSprite.scale
		this_ghost.modulate = Color(0, 0, 1) # blue shade
