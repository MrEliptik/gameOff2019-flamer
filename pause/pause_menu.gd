extends Control

const SCALE_FACTOR_X = 1.15
const SCALE_FACTOR_Y = 1.15

func _ready():
	$CenterContainer/VBoxContainer/Resume.grab_focus()

func _physics_process(delta):	
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