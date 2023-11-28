extends Control

var originalWidth = ProjectSettings.get_setting("display/window/size/viewport_width")

var originalHeight = ProjectSettings.get_setting("display/window/size/viewport_height")

var oldWidth = 1152

var oldHeight = 648

var windowSize

@onready var heightBox = $SettingsMenu/Settings/ResolutionOptions/HeightBox

@onready var widthBox = $SettingsMenu/Settings/ResolutionOptions/WidthBox

@onready var warningPrompt = $SettingsMenu/Settings/WarningPrompt

@onready var settingsScreen = $SettingsMenu/Settings

@onready var resetButton = $SettingsMenu/Settings/ResolutionOptions/ResetBtn

@onready var timeRemaining = $SettingsMenu/Settings/WarningPrompt/CountdownPrompt/Time

@onready var warningPromptTimer = $SettingsMenu/Settings/WarningPrompt/PromptTimer

@onready var mainScreen = $MainMenu/Main

@onready var resolutionOptions = $SettingsMenu/Settings/ResolutionOptions

@onready var cannotChangeLabel = $SettingsMenu/Settings/CannotChange
# Called when the node enters the scene tree for the first time.
func _ready():
	mainScreen.show()
	cannotChangeLabel.hide()
	settingsScreen.hide()
	warningPrompt.hide()
	resetButton.hide()
	widthBox.set_value_no_signal(Global.width)
	heightBox.set_value_no_signal(Global.height)
	if !(Global.width == originalWidth) or !(Global.height == originalHeight):
			resetButton.show()
	else:
		resetButton.hide()

	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	windowSize = DisplayServer.window_get_size()
	update_countdown()

"Starts the game"
func _on_play_btn_pressed():
	get_tree().change_scene_to_file("res://start_level.tscn")


"Opens settings menu"
func _on_settings_btn_pressed():
	mainScreen.hide()
	settingsScreen.show()

"Closes settings menu"
func _on_back_button_pressed():
	mainScreen.show()
	settingsScreen.hide()
	warningPrompt.hide()

"Changes screensize and starts warning prompt when user accepts settings"
func _on_apply_btn_pressed():
	
	if !(Global.width == oldWidth) or !(Global.height == oldHeight):
		change_screensize()
		warningPrompt.show()
		warningPromptTimer.start()

"Prompts user to reset resolution upon change of width"
func _on_width_box_value_changed(value):
	Global.width = value
	resetButton.show()

"Prompts user to reset resolution upon change of height"
func _on_height_box_value_changed(value):
	Global.height = value
	resetButton.show()

"Runs reset screensize on revert button pressed"
func _on_revert_btn_pressed():
	revert_screensize()

"Accepts the screen size change"
func _on_apply_change_pressed():
	warningPrompt.hide()
	warningPromptTimer.stop()
	oldHeight = Global.height
	oldWidth = Global.width

"Revert screensize to previous width and height"
func revert_screensize():
	Global.width = oldWidth
	Global.height = oldHeight
	widthBox.set_value_no_signal(oldWidth)
	heightBox.set_value_no_signal(oldHeight)
	DisplayServer.window_set_size(Vector2i(oldWidth, oldHeight))
	warningPrompt.hide()

"Changes size of screen"
func change_screensize():
	DisplayServer.window_set_size(Vector2i(Global.width, Global.height))
	warningPrompt.hide()

"Resets the original width and height of screen-res on button press"
func _on_reset_btn_pressed():
	DisplayServer.window_set_size(Vector2i(originalWidth, originalHeight))
	widthBox.set_value_no_signal(originalWidth)
	heightBox.set_value_no_signal(originalHeight)
	resetButton.hide()

"Displays the time remaining on the timer"
func update_countdown():
	var rawTimeRemaining = str(warningPromptTimer.time_left)
	var roundedTimeRemaining = int(rawTimeRemaining)
	timeRemaining.text = str(roundedTimeRemaining)

"Timer that checks if user selects accept before time goes out"
func _on_prompt_timer_timeout():
	revert_screensize()


"Sets screen VSYNC depending on selected option"
func _on_vsync_btn_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

"Makes screen fullscreen"
func _on_full_screen_btn_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		resolutionOptions.hide()
		cannotChangeLabel.show()
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		resolutionOptions.show()
		cannotChangeLabel.hide()
