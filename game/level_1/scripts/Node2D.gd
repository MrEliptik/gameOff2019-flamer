extends Node2D

#TODO: Replace by sprite value after loading if possible
const PLATFORM_WIDTH	= 16
const PLATFORM_HEIGHT	= 16
const MAX_JUMP_X		= 250
const MAX_JUMP_Y		= 150
const MIN_DIST_PLATFORM	= 50

const platform = preload("res://platform.tscn")

var platforms = Array()

class Platform:
	var x
	var y
	var length
	var plats = Array()
	
	func _init(x, y, length):
		self.x = x
		self.y = y
		self.length = length
		for i in range(length):
			var plat = platform.instance()
			self.plats.append(plat)
			self.plats[i].position = Vector2(x + (i* 16), y)
			
	func getWidth():
		return self.length * PLATFORM_WIDTH
		
	func getHeight():
		return PLATFORM_HEIGHT
	
	# Return the starting coordinates of the platform
	# as an array[x, y]
	func getStartCoordinates():
		return [self.x, self.y]
	
	# Return the endinf coordinates of the platform
	# as an array[x, y]
	func getEndCoordinates():
		return [self.x + getWidth(), self.y]
			
# Unused
func generatePlatforms():
	var screensize = get_viewport().get_visible_rect().size
	print(screensize)
	#var screensize = get_tree().get_root().get_visible_rect().size
	
	# Important to change the seed
	# and actually get random values
	randomize()
	
	#get_viewport().get_rect().size
	
	for i in range (4):
		var x
		var y
		var length
		var lastPlatCoords
		
		# First platform is always the same
		if i == 0:
			# TODO: replace with proportion of the 
			# viewport (3/4 of the viewport)
			y = int(screensize[1] * 0.75)
			x = 0
			length = 20
		else:	
			lastPlatCoords = platforms[i-1].getEndCoordinates()
			x = (randi() % int(MAX_JUMP_X)) + lastPlatCoords[0] + MIN_DIST_PLATFORM
			y = (randi() % int(MAX_JUMP_Y)) + lastPlatCoords[1] + MIN_DIST_PLATFORM
			# Loop until value is acceptable
			while x >= screensize[0]:
				x = (randi() % int(MAX_JUMP_X)) + lastPlatCoords[0] + MIN_DIST_PLATFORM
			while y >= screensize[1] and abs(y - lastPlatCoords[1]) < MAX_JUMP_Y:
				y = (randi() % int(abs(MIN_DIST_PLATFORM + lastPlatCoords[1]))) + abs(MIN_DIST_PLATFORM - lastPlatCoords[1])
			length = (randi() % 4) + 2
		
		var plat = Platform.new(x, y, length)
		# Store the platform
		platforms.append(plat)
		# Add platform to the scene
		for p in plat.plats:
			add_child(p)

func _init():
	pass
      
func _ready():
	pass
	
func _process(delta):
	pass