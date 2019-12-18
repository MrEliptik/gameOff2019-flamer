extends Control

const SCALE_FACTOR_X = 1.15
const SCALE_FACTOR_Y = 1.15

onready var switcher = get_node("/root/scene_switcher")

onready var resolutions_str = ["2560x1440", "1920x1080", "1280x720", "960x540", "640x480"]
onready var resolutions = [Vector2(2560, 1440), Vector2(1920, 1080), Vector2(1280, 720), Vector2(960, 540), Vector2(640, 480)]
onready var window_modes_str = ["borderless_window", "windowed", "fullscreen"]
onready var display_size = OS.get_screen_size()
onready var master_vol = 100
onready var music_vol = 100
onready var effects_vol = 100


func _ready():
	#print("Display size: ", display_size)
	
	for resolution in resolutions_str:
		$VBoxContainer/VBoxContainer/HBoxContainer/OptionButton.add_item(resolution)
	
	for mode in window_modes_str:
		$VBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.add_item(mode)
				
	setCurrentValues()

func _process(delta):
	if $HBoxContainer3/ApplyButton.is_hovered() == true:
		$HBoxContainer3/ApplyButton.grab_focus()
		scaleLabel($HBoxContainer3/BackButton/Label, 1.0, 1.0)
		scaleLabel($HBoxContainer3/CancelButton/Label, 1.0, 1.0)
		scaleLabel($HBoxContainer3/ApplyButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
	elif $HBoxContainer3/CancelButton.is_hovered() == true:
		$HBoxContainer3/CancelButton.grab_focus()
		scaleLabel($HBoxContainer3/BackButton/Label, 1.0, 1.0)
		scaleLabel($HBoxContainer3/CancelButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		scaleLabel($HBoxContainer3/ApplyButton/Label, 1.0, 1.0)
	elif $HBoxContainer3/BackButton.is_hovered() == true:
		$HBoxContainer3/BackButton.grab_focus()
		scaleLabel($HBoxContainer3/BackButton/Label, SCALE_FACTOR_X, SCALE_FACTOR_Y)
		scaleLabel($HBoxContainer3/CancelButton/Label, 1.0, 1.0)
		scaleLabel($HBoxContainer3/ApplyButton/Label, 1.0, 1.0)
	else:
		scaleLabel($HBoxContainer3/CancelButton/Label, 1.0, 1.0)
		scaleLabel($HBoxContainer3/ApplyButton/Label, 1.0, 1.0)

func scaleLabel(label, scale_x, scale_y):
	label.rect_scale.x = scale_x
	label.rect_scale.y = scale_y

func setCurrentValues():
	$VBoxContainer/VBoxContainer2/HBoxContainer3/HSlider_master.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))*100
	$VBoxContainer/VBoxContainer2/HBoxContainer/HSlider_music.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))*100
	$VBoxContainer/VBoxContainer2/HBoxContainer2/HSlider_effects.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))*100
	
	$VBoxContainer/VBoxContainer2/HBoxContainer3/CheckButton_master.pressed = !AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	$VBoxContainer/VBoxContainer2/HBoxContainer2/CheckButton_effects.pressed = !AudioServer.is_bus_mute(AudioServer.get_bus_index("Effects"))
	$VBoxContainer/VBoxContainer2/HBoxContainer/CheckButton_music.pressed = !AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
	
	$VBoxContainer/VBoxContainer/HBoxContainer/OptionButton.select(resolutions.find(OS.get_window_size()))
	
	# Fullscreen
	if OS.is_window_fullscreen():
		$VBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.select(2)
	# Borderless window
	elif OS.get_borderless_window():
		$VBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.select(0)
	# Window
	else:
		$VBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.select(1)

func resetOptions():
	$VBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.select(0)
	$VBoxContainer/VBoxContainer/HBoxContainer/OptionButton.select(2)
	
	$VBoxContainer/VBoxContainer2/HBoxContainer3/HSlider_master.value = 100
	$VBoxContainer/VBoxContainer2/HBoxContainer2/HSlider_effects.value = 100
	$VBoxContainer/VBoxContainer2/HBoxContainer/HSlider_music.value = 100
	$VBoxContainer/VBoxContainer2/HBoxContainer3/CheckButton_master.pressed = true
	$VBoxContainer/VBoxContainer2/HBoxContainer2/CheckButton_effects.pressed = true
	$VBoxContainer/VBoxContainer2/HBoxContainer/CheckButton_music.pressed = true
	
func _on_HSlider_master_value_changed(value):
	master_vol = value
	$VBoxContainer/VBoxContainer2/HBoxContainer3/Value.text = str(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_vol/100))

func _on_HSlider_music_value_changed(value):
	music_vol = value
	$VBoxContainer/VBoxContainer2/HBoxContainer/Value.text = str(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_vol/100))

func _on_HSlider_effects_value_changed(value):
	effects_vol = value
	$VBoxContainer/VBoxContainer2/HBoxContainer2/Value.text = str(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear2db(effects_vol/100))

func _on_CheckButton_master_toggled(button_pressed):
	print(AudioServer.get_bus_index("Master"))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !button_pressed)

func _on_CheckButton_music_toggled(button_pressed):
	print(AudioServer.get_bus_index("Music"))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !button_pressed)

func _on_CheckButton_effects_toggled(button_pressed):
	print(AudioServer.get_bus_index("Effects"))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), !button_pressed)

func _on_ApplyButton_pressed():
	$VBoxContainer/VBoxContainer2/Applied.show()
	$AppliedTimer.start()
	
	########### WINDOW MODE ###############
	var mode = window_modes_str[$VBoxContainer/VBoxContainer/HBoxContainer2/OptionButton.get_selected_id()]
	if mode == "borderless_window":
		OS.set_window_fullscreen(false)
		OS.set_borderless_window(true)
		OS.center_window()
	elif mode == "windowed":
		OS.set_window_fullscreen(false)
		OS.set_borderless_window(false)
		OS.center_window()
	elif mode == "fullscreen":
		OS.set_window_fullscreen(true)
		
	########### RESOLUTION ###############
	var id = $VBoxContainer/VBoxContainer/HBoxContainer/OptionButton.get_selected_id()
	var selectedResolution = resolutions_str[id]
	OS.set_window_size(resolutions[id])

func _on_CancelButton_pressed():
	resetOptions()

func _on_BackButton_pressed():
	switcher.return_to_last()

func _on_AppliedTimer_timeout():
	$VBoxContainer/VBoxContainer2/Applied.hide()

func _on_button_focus_entered():
	$SelectSound.play(0)
