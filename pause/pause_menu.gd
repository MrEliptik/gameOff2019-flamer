extends Control

const SCALE_FACTOR_X = 1.15
const SCALE_FACTOR_Y = 1.15

const JOY_DEADZONE = 0.2

var y_val = 0
var index_select = 0

enum DIRECTION{
	UP,
	DOWN	
}
var direction = null

onready var btns = [
	get_node("CenterContainer/VBoxContainer/Resume"), 
	get_node("CenterContainer/VBoxContainer/OptionsButton"),
	get_node("CenterContainer/VBoxContainer/MainMenuButton")
]

func _ready():
	$CenterContainer/VBoxContainer/Resume.grab_focus()

func _input(e):
	if not self.is_visible():
		return
	
	if e is InputEventJoypadMotion:
		y_val = Input.get_joy_axis(0, 1)
		#print(y_val)
		# up
		if y_val < -JOY_DEADZONE:
			direction = DIRECTION.UP
		# down
		elif y_val > JOY_DEADZONE:
			direction = DIRECTION.DOWN
		# Released
		else:
			if direction == DIRECTION.UP:
				if index_select == 0:
					index_select = len(btns) - 1
				else:
					index_select -= 1
				direction = null
			elif direction == DIRECTION.DOWN:
				if index_select == len(btns) - 1:
					index_select = 0
				else:
					index_select += 1
				direction = null
				
		#print(index_select)
		btns[index_select].grab_focus()

func _physics_process(delta):	
	if not self.is_visible():
		return

	if $CenterContainer/VBoxContainer/Resume.is_hovered() == true:
		$CenterContainer/VBoxContainer/Resume.grab_focus()
		$Selector1.visible = true
		$Selector2.visible = false
		$Selector3.visible = false
		
		scaleLabel($CenterContainer/VBoxContainer/Resume/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		scaleLabel($CenterContainer/VBoxContainer/OptionsButton/Label, 1.0, 1.0)
		scaleLabel($CenterContainer/VBoxContainer/MainMenuButton/Label, 1.0, 1.0)
	elif $CenterContainer/VBoxContainer/OptionsButton.is_hovered() == true:
		$CenterContainer/VBoxContainer/OptionsButton.grab_focus()
		$Selector1.visible = false
		$Selector2.visible = true
		$Selector3.visible = false
		
		scaleLabel($CenterContainer/VBoxContainer/Resume/Label, 1.0, 1.0)
		scaleLabel($CenterContainer/VBoxContainer/OptionsButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		scaleLabel($CenterContainer/VBoxContainer/MainMenuButton/Label, 1.0, 1.0)
	elif $CenterContainer/VBoxContainer/MainMenuButton.is_hovered() == true:
		$CenterContainer/VBoxContainer/MainMenuButton.grab_focus()
		$Selector1.visible = false
		$Selector2.visible = false
		$Selector3.visible = true
		
		scaleLabel($CenterContainer/VBoxContainer/Resume/Label, 1.0, 1.0)
		scaleLabel($CenterContainer/VBoxContainer/OptionsButton/Label, 1.0, 1.0)
		scaleLabel($CenterContainer/VBoxContainer/MainMenuButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		
func scaleLabel(label, scale_x, scale_y):
	label.rect_scale.x = scale_x
	label.rect_scale.y = scale_y

func _on_Menu_visibility_changed():
	if self.is_visible():
		$CenterContainer/VBoxContainer/Resume.grab_focus()


func _on_Resume_pressed():
	get_tree().paused = false
	self.hide()
	
func _on_OptionsButton_pressed():
	get_tree().paused = false
	self.hide()

func _on_MainMenuButton_pressed():
	get_tree().paused = false
	self.hide()
	get_tree().change_scene("res://titlescreen/scenes/titlescreen.tscn")


func _on_Resume_focus_entered():
	$SelectSound.play(0)

func _on_OptionsButton_focus_entered():
	$SelectSound.play(0)

func _on_MainMenuButton_focus_entered():
	$SelectSound.play(0)
