extends CharacterBody2D

const ACCEL = 5;

var max_speed = 200;

var gravity = 500;

var timeHeld = 0;

var timeForFullJump = 0.1;

var xInput = 0;

var JumpSpeed = 200;

var minHorizontalSpeed = 0.1;




func _ready():
	$AnimatedSprite2D.animation = "Idle"
	$NormalHitbox.set_disabled(false)
	$CrouchingHitbox.set_disabled(true)
	
	global_position = %SpawnPoint.global_position
	

func _physics_process(delta):
	
	player_movement(delta)
	
	
	print(velocity.x)

	play_animation()
	
	
	if Input.is_action_pressed("Crouch") && is_on_floor():
		$NormalHitbox.set_disabled(true)
		$CrouchingHitbox.set_disabled(false)
	else:
		$NormalHitbox.set_disabled(false)
		$CrouchingHitbox.set_disabled(true)
	
	if not is_on_floor():
		velocity.y += gravity * delta;
	
	
	handle_jump();
	
	if not is_on_floor() && Input.is_action_pressed("Crouch"):
		velocity.y += 2000 * delta;
	




func update_input():
	xInput = Input.get_action_strength("Right") - Input.get_action_strength("Left");




func player_movement(delta):
	update_input()
	
	velocity.x = lerp(velocity.x ,xInput * max_speed,ACCEL * delta)
	
	if xInput == 0 and abs(velocity.x) < minHorizontalSpeed:
		velocity.x = 0
	print(xInput," ",abs(velocity.x)," ",minHorizontalSpeed)
	
	move_and_slide()




func play_animation():
	update_input()
	if is_on_floor && !Input.is_action_pressed("Crouch"):
		if xInput > 0:
			$AnimatedSprite2D.flip_h = false;
			$AnimatedSprite2D.play("Walking", 1, false)
		elif xInput < 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0;
			$AnimatedSprite2D.play("Walking", 1, false)
	
	if not is_on_floor() && velocity.y < 0:
		$AnimatedSprite2D.animation = "Jumping"
	
	if velocity.y > 0 && !is_on_floor():
		$AnimatedSprite2D.play("Falling", 1, false)
	
	if xInput == 0 && is_on_floor():
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

func handle_jump():
	if Input.is_action_just_pressed("Jump"):
			if is_on_floor():
				velocity.y = -JumpSpeed;
	
	if Input.is_action_just_released("Jump"):
		jump_cut()

func jump_cut():
	if velocity.y < -100:
		velocity.y = -100

func player_death():
	pass
