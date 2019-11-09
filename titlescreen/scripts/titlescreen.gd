extends Control

var scene_path_to_load

func _ready():
	$Menu/CenterRow/Buttons/PlayButton.grab_focus()
	
	for button in $Menu/CenterRow/Buttons.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load])
		
func _physics_process(delta):
	if $Menu/CenterRow/Buttons/PlayButton.is_hovered() == true:
		$Menu/CenterRow/Buttons/PlayButton.grab_focus()
		$Selector1.visible = true;
		$Selector2.visible = false;
		$Selector3.visible = false;
	if $Menu/CenterRow/Buttons/OptionsButton.is_hovered() == true:
		$Menu/CenterRow/Buttons/OptionsButton.grab_focus()
		$Selector1.visible = false;
		$Selector2.visible = true;
		$Selector3.visible = false;
	if $Menu/CenterRow/Buttons/ExitButton.is_hovered() == true:
		$Menu/CenterRow/Buttons/ExitButton.grab_focus()
		$Selector1.visible = false;
		$Selector2.visible = false;
		$Selector3.visible = true;
		
func _on_button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)
