extends Control

var scene_path_to_load

const SCALE_FACTOR_X = 1.15
const SCALE_FACTOR_Y = 1.15

func _ready():
	$Menu/CenterRow/Buttons/PlayButton.grab_focus()
	
	for button in $Menu/CenterRow/Buttons.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load])
		
func get_input():
	if Input.is_action_pressed("ui_up"):
		#$SelectSound.play()
		pass
	elif Input.is_action_pressed("ui_down"):
		#$SelectSound.play()
		pass
	

func _physics_process(delta):
	get_input()
	
	if $Menu/CenterRow/Buttons/PlayButton.is_hovered() == true:
		$Menu/CenterRow/Buttons/PlayButton.grab_focus()
		$Selector1.visible = true
		$Selector2.visible = false
		$Selector3.visible = false
		$Selector4.visible = false
		
		scaleLabel($Menu/CenterRow/Buttons/PlayButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		scaleLabel($Menu/CenterRow/Buttons/TutorialButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/OptionsButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/ExitButton/Label, 1.0, 1.0)
	elif $Menu/CenterRow/Buttons/TutorialButton.is_hovered() == true:
		$Menu/CenterRow/Buttons/TutorialButton.grab_focus()
		$Selector1.visible = false
		$Selector2.visible = true
		$Selector3.visible = false
		$Selector4.visible = false
		
		scaleLabel($Menu/CenterRow/Buttons/PlayButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/TutorialButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		scaleLabel($Menu/CenterRow/Buttons/OptionsButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/ExitButton/Label, 1.0, 1.0)
	elif $Menu/CenterRow/Buttons/OptionsButton.is_hovered() == true:
		$Menu/CenterRow/Buttons/OptionsButton.grab_focus()
		$Selector1.visible = false
		$Selector2.visible = false
		$Selector3.visible = true
		$Selector4.visible = false
		
		scaleLabel($Menu/CenterRow/Buttons/PlayButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/TutorialButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/OptionsButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		scaleLabel($Menu/CenterRow/Buttons/ExitButton/Label, 1.0, 1.0)
	elif $Menu/CenterRow/Buttons/ExitButton.is_hovered() == true:
		$Menu/CenterRow/Buttons/ExitButton.grab_focus()
		$Selector1.visible = false
		$Selector2.visible = false
		$Selector3.visible = false
		$Selector4.visible = true
		
		scaleLabel($Menu/CenterRow/Buttons/PlayButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/TutorialButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/OptionsButton/Label, 1.0, 1.0)
		scaleLabel($Menu/CenterRow/Buttons/ExitButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		
func _on_button_pressed(scene_to_load):
	if scene_to_load == "-1": 
		get_tree().quit()
	else:	
		scene_path_to_load = scene_to_load
		$FadeIn.show()
		$FadeIn.fade_in()

func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)
	
func scaleLabel(label, scale_x, scale_y):
	label.rect_scale.x = scale_x
	label.rect_scale.y = scale_y
