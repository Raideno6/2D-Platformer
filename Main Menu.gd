extends Control

var width = 1152

var height = 648

var newWidth = 1152

var newHeight = 648

var oldWidth = 1152

var oldHeight = 648

var windowSize
# Called when the node enters the scene tree for the first time.
func _ready():
	$MainMenu/Main.show()
	$SettingsMenu/Settings.hide()
	$SettingsMenu/Settings/WarningPrompt.hide()
	print()
	DisplayServer.window_set_size(Vector2i(width, height))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	windowSize = DisplayServer.window_get_size()

func _on_play_btn_pressed():
	get_tree().change_scene_to_file("res://start_level.tscn")



func _on_settings_btn_pressed():
	$MainMenu/Main.hide()
	$SettingsMenu/Settings.show()


func _on_back_button_pressed():
	$MainMenu/Main.show()
	$SettingsMenu/Settings.hide()
	$SettingsMenu/Settings/WarningPrompt.hide()


func _on_apply_btn_pressed():
	
	if !(newWidth == width) or !(newHeight == height):
		$SettingsMenu/Settings/WarningPrompt.show()


func _on_width_box_value_changed(value):
	newWidth = value


func _on_height_box_value_changed(value):
	newHeight = value



func _on_revert_btn_pressed():
	newWidth = width
	newHeight = height
	$SettingsMenu/Settings/WidthBox.set_value_no_signal(newWidth)
	$SettingsMenu/Settings/HeightBox.set_value_no_signal(newHeight)
	$SettingsMenu/Settings/WarningPrompt.hide()


func _on_apply_change_pressed():
	width = newWidth
	height = newHeight
	DisplayServer.window_set_size(Vector2i(width, height))
	$SettingsMenu/Settings/WarningPrompt.hide()

func revert_screensize():
	
