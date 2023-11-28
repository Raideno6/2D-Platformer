extends CharacterBody2D

const ACCEL = 5;

var maxSpeed = 200;

var maxCrouchSpeed = 100;

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var maxJumpHeight = 150

var timeForFullJump = .1

var xInput = 0;

var JumpForce = 250;

var minHorizontalSpeed = 0.1;

var coyoteTime = .2

var canJump = false

var pushForce = 50.0

@onready var jumpBuffer = $JumpBuffer

@onready var waveTimer = $WaveTimer

var bufferedJump = false


func _ready():
	#Initalizes player
	$AnimatedSprite2D.animation = "Idle"
	$NormalHitbox.set_disabled(false)
	$CrouchingHitbox.set_disabled(true)
	
	global_position = %SpawnPoint.global_position
	
	show()
	
"""
tyt

"""
func _physics_process(delta):
	
	if $AnimatedSprite2D.is_playing():
		if $AnimatedSprite2D.animation == "Waving":
			return
	
	player_movement(delta)
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * (pushForce))
	print("X-Velocity: ",velocity.x)
	print("Y-Velocity: ",velocity.y)
	#When player reaches the floor and if they cannot jump, allow them to jump
	if is_on_floor() and canJump == false:
		canJump = true
	
	#Starts Coyote Timer if player can jump and the timer isnt running
	elif canJump == true and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start(coyoteTime)
	
	# If player hits jump or can buffer jump, allow player to jump
	if canJump:
		if Input.is_action_just_pressed("Jump") or bufferedJump:
			jump()
			canJump = false;
			bufferedJump = false
	
	#When player releases jump earlier, cuts jump off
	if Input.is_action_just_released("Jump"):
		bufferedJump = false
		jump_cut()

	
	play_animation()
	
	# Startr jump buffer timer when player first jumps
	if Input.is_action_just_pressed("Jump"):
		bufferedJump = true
		jumpBuffer.start()
	
	#Changes hitbox to smaller one if player crouches
	if Input.is_action_pressed("Crouch") and is_on_floor():
		$NormalHitbox.set_disabled(true)
		$CrouchingHitbox.set_disabled(false)
	else:
		$NormalHitbox.set_disabled(false)
		$CrouchingHitbox.set_disabled(true)
	
	#Makes player fall if no one floor
	if not is_on_floor():
		velocity.y += gravity * delta;
	
	
	if not is_on_floor() && Input.is_action_pressed("Crouch"):
		velocity.y += 2000 * delta;

#Gets input from user to move left and right
func update_input():
	xInput = Input.get_action_strength("Right") - Input.get_action_strength("Left");



"""
Every frame updates player Movement
"""
func player_movement(delta):
	update_input()
	
	#allows user to crouch and makes them walk slower if so
	if Input.is_action_pressed("Crouch") and is_on_floor():
		velocity.x = lerp(velocity.x ,xInput * maxCrouchSpeed,ACCEL * delta)
		canJump = false
		bufferedJump = false
	else:
		velocity.x = lerp(velocity.x ,xInput * maxSpeed,ACCEL * delta)
	
	#Brings player to a full stop if they are moving at a insanley slow speed
	if xInput == 0 and abs(velocity.x) < minHorizontalSpeed:
		velocity.x = 0
		
	move_and_slide()
	
	# check if we should die
	var collisionInfo = get_last_slide_collision()
	if collisionInfo != null and collisionInfo.get_collider() != null and collisionInfo.get_collider().is_in_group("DeathZone"):
		die()
	
	
	



# Plays animations for user
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
	


#Using kenematic equation to let player jump to certain height
func jump():
	
	var jumpForce = -sqrt(gravity * maxJumpHeight)
	
	
	velocity.y = jumpForce;


#Stops player jump earlier if lets go of jump key
func jump_cut():
	if velocity.y < -100: 
		velocity.y = -100



# Allows player to jump a few seconds after they leave a surface

func _on_coyote_timer_timeout():
	canJump = false

# Sets player as dead and changes scene
func die():
	hide()
	$Death.play()
	$NormalHitbox.set_disabled(false)
	$CrouchingHitbox.set_disabled(false)
	get_tree().change_scene_to_file("res://game_over.tscn")


