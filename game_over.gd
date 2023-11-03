extends Control

var respawnButton
var giveUpButton

# Called when the node enters the scene tree for the first time.
func _ready():
	giveUpButton = $CanvasLayer/GiveUpButton
	respawnButton = $CanvasLayer/RespawnButtom
	
	respawnButton.grab_focus()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_respawn_buttom_pressed():
	get_tree().change_scene_to_file("res://start_level.tscn")


func _on_give_up_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
