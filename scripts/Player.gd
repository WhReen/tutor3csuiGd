extends KinematicBody2D

export (int) var realSpeed = 500
export (int) var jumpSpeed = 800
export (int) var GRAVITY = 2400
export (int) var doubletapdelay= 0.25
export (int) var stopTime = 0.1
export (int) var jumpAmount = 2

onready var sprite = $AnimatedSprite
onready var collision = $CollisionShape2D
onready var sfxplayer = $AudioStreamPlayer2D

var doubletaptime = 0
var dtappedright = false
var dtappedleft = false
var crouch = false
var speed = realSpeed
var jumpLeft = jumpAmount
var superjumpTime= 0

const UP = Vector2(0,-1)

var velocity = Vector2()


func sprite(): #sprite manipulation
	sprite.rotation_degrees = 90*(velocity.x/(realSpeed*4))
	sprite.flip_h = velocity.x < 0
	
	

func get_input(delta):
	var animation = "diri_kanan"
	
	if crouch: #crouch movement speed
		speed = realSpeed/2
	else:
		speed = realSpeed
		
	if jumpLeft > 0 and Input.is_action_just_pressed('ui_up'):
		if superjumpTime > 0:
			velocity.y = -jumpSpeed*2
			sprite.scale.x = 0.3
			sfxplayer.play()
		else:
			velocity.y = -jumpSpeed
			sprite.scale.x = 0.5
		jumpLeft -= 1
	
	if Input.is_action_just_released('ui_down'):
		superjumpTime = delta*5
		
		
	if Input.is_action_just_pressed('ui_right'): #doubletap right to run right
		animation = "jalan_kanan"
		if doubletaptime > 0 and velocity.x > 0:
			dtappedright = true
			if velocity.y > 0:
				velocity.y = 0
		else:
			doubletaptime = 0
		doubletaptime = doubletapdelay
		
	if Input.is_action_just_pressed('ui_left'): #doubletap left to run left
		if doubletaptime > 0 and velocity.x < 0:
			dtappedleft = true
			if velocity.y > 0:
				velocity.y = 0
		else:
			doubletaptime = 0
		doubletaptime = doubletapdelay
		
	if Input.is_action_pressed('ui_right'):
		if dtappedright:
			velocity.x = speed*4
		else:
			velocity.x = speed
		dtappedleft = false
		
	if Input.is_action_pressed('ui_left'):
		if dtappedleft:
			velocity.x = -speed*4
		else:
			velocity.x = -speed
		dtappedright = false
		
	if Input.is_action_just_released('ui_right'): #limiting dash
		if dtappedright:
			dtappedright = false
		
	if Input.is_action_just_released('ui_left'): #limiting dash
		if dtappedleft:
			dtappedleft = false
	
	if Input.is_action_pressed('ui_up'):
		if sprite.scale.x > 0.7:
			sprite.scale.x = 0.7
		if velocity.y > GRAVITY/16:
			velocity.y = GRAVITY/16
		
	if Input.is_action_pressed('ui_down'): #crouch and faster down movement
		velocity.y += speed
		sprite.scale.y = 0.5
		collision.scale.y = 0.5
		crouch = true
	else:
		sprite.scale.y = 1
		collision.scale.y = 1
		crouch = false
		
	if $AnimatedSprite.animation != animation:
		$AnimatedSprite.play(animation)

func _physics_process(delta):
	if doubletaptime > 0:
		doubletaptime -= delta
	if is_on_floor():
		jumpLeft = jumpAmount
	if superjumpTime > 0:
		superjumpTime-=delta
		print_debug(superjumpTime)
	velocity.y += delta * GRAVITY
	get_input(delta)
	sprite()
	velocity = move_and_slide(velocity, UP)
	var slowdown := min(delta/stopTime, 1.0) #x axis slowdown when no x axis movement input pressed
	velocity.x -= velocity.x * slowdown
	var slowdownSprite := min(delta/1.6, 1.0)
	if sprite.scale.x < 1:
		sprite.scale.x += sprite.scale.x * slowdown
	
