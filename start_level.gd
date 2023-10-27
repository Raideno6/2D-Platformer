extends Node2D

var input = Vector2.ZERO;

func _physics_process(delta):
	respawn()

func respawn():
	if Input.is_action_pressed("Respawn"):
		$Player.position = $SpawnPoint.position




