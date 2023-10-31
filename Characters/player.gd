extends CharacterBody2D

const ACCEL = 5;

var maxSpeed = 200;

var maxCrouchSpeed = 100;

var gravity = 750;

var maxJumpHeight = 150

var timeForFullJump = .1

var xInput = 0;

var JumpForce = 250;

var minHorizontalSpeed = 0.1;

var coyoteTime = .2

var canJump = false

@onready var jumpBuffer = $JumpBuffer

@onready var waveTimer = $WaveTimer

var bufferedJump = false


func _ready():
	$AnimatedSprite2D.animation = "Idle"
	$NormalHitbox.set_disabled(false)
	$CrouchingHitbox.set_disabled(true)
	
	global_position = %SpawnPoint.global_position
	
	show()
	

func _physics_process(delta):
	
	if $AnimatedSprite2D.is_playing():
		if $AnimatedSprite2D.animation == "Waving":
			return
	
	player_movement(delta)
	
	if is_on_floor() and canJump == false:
		canJump = true
	
	elif canJump == true and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start(coyoteTime)
	
	if canJump:
		if Input.is_action_just_pressed("Jump") or bufferedJump:
			jump()
			bufferedJump = false
	
	if Input.is_action_just_released("Jump"):
		jump_cut()
		bufferedJump = false
	
	play_animation()
	
	if Input.is_action_just_pressed("Jump"):
		bufferedJump = true
		jumpBuffer.start()
	
	if Input.is_action_pressed("Crouch") and is_on_floor():
		$NormalHitbox.set_disabled(true)
		$CrouchingHitbox.set_disabled(false)
	else:
		$NormalHitbox.set_disabled(false)
		$CrouchingHitbox.set_disabled(true)
	
	if not is_on_floor():
		velocity.y += gravity * delta;
	
	
	if not is_on_floor() && Input.is_action_pressed("Crouch"):
		velocity.y += 2000 * delta;
	



func update_input():
	xInput = Input.get_action_strength("Right") - Input.get_action_strength("Left");




func player_movement(delta):
	update_input()
	
	if Input.is_action_pressed("Crouch") and is_on_floor():
		velocity.x = lerp(velocity.x ,xInput * maxCrouchSpeed,ACCEL * delta)
	else:
		velocity.x = lerp(velocity.x ,xInput * maxSpeed,ACCEL * delta)
	
	if xInput == 0 and abs(velocity.x) < minHorizontalSpeed:
		velocity.x = 0
		
	move_and_slide()
	
	#check if we should die
	var collisionInfo = get_last_slide_collision()
	if collisionInfo != null and collisionInfo.get_collider() != null and collisionInfo.get_collider().is_in_group("DeathZone"):
		die()
	
	
	




func play_animation():
	update_input()
	if is_on_floor() && !Input.is_action_pressed("Crouch"):
		if xInput > 0:
			$AnimatedSprite2D.flip_h = false;
			$AnimatedSprite2D.play("Walking", 1, false)
		elif xInput < 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0;
			$AnimatedSprite2D.play("Walking", 1, false)
	
	if not is_on_floor() && velocity.y < 0:
		$AnimatedSprite2D.animation = "Jumping"
	
	if velocity.y > 0 && !is_on_floor():
		$AnimatedSprite2D.play("Falling", 2, false)
	
	if xInput == 0 && is_on_floor() && !Input.is_action_pressed("Wave"):
		$AnimatedSprite2D.animation = ("Idle")
	
	if is_on_floor() && Input.is_action_pressed("Crouch") && xInput == 0:
		$AnimatedSprite2D.animation = ("Crouch")
	
	if is_on_floor() && Input.is_action_pressed("Crouch"):
		if xInput > 0:
			$AnimatedSprite2D.flip_h = false;
			$AnimatedSprite2D.play("CrouchWalk", 1, false)
		elif xInput < 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0;
			$AnimatedSprite2D.play("CrouchWalk", 1, false)
	
	if Input.is_action_pressed("Wave"):
		$AnimatedSprite2D.play("Waving", 5, false)
		await $AnimatedSprite2D.animation_finished
	



func jump():
	
	var jumpForce = -sqrt(gravity * maxJumpHeight)
	
	
	velocity.y = jumpForce;


func jump_cut():
	if velocity.y < -100:
		velocity.y = -100



func _on_coyote_timer_timeout():
	canJump = false

func die():
	hide()
	$Death.play()
	$NormalHitbox.set_disabled(false)
	$CrouchingHitbox.set_disabled(false)
	get_tree().change_scene_to_file("res://game_over.tscn")


