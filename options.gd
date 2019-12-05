extends Control

# Useful
# OS.get_screen_size()

func _ready():
	var resolutions = ["2560x1440", "1920x1080", "1280x720", "960x540", "640x480"]
	
	for resolution in resolutions:
		$VBoxContainer/HBoxContainer1/VBoxContainer/HBoxContainer/OptionButton.add_item(resolution)


func _on_HSlider_music_value_changed(value):
	$VBoxContainer/HBoxContainer1/VBoxContainer2/HBoxContainer/Value.text = str(value)

func _on_HSlider_effects_value_changed(value):
	$VBoxContainer/HBoxContainer1/VBoxContainer2/HBoxContainer2/Value.text = str(value)


func _on_CheckButton_music_toggled(button_pressed):
	pass # Replace with function body.

func _on_CheckButton_effects_toggled(button_pressed):
	pass # Replace with function body.


