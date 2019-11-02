extends Node2D

const platform = preload("res://platform.tscn")

const arr = []

func _init():
    for i in range (4):
        var newPos = Vector2(200*i, 170)
        var plat = platform.instance()
        plat.position = newPos
        add_child(plat)
		
class Platform:
	var x
	var y
	var length
	
	func _init(x, y, length):
		self.x = x
		self.y = y
		self.length = length