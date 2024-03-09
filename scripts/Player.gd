extends KinematicBody2D

export (int) var realSpeed = 500
export (int) var jumpSpeed = 800
export (int) var GRAVITY = 2400
export (float) var doubletapdelay= 0.25
export (float) var stopTime = 0.1
export (int) var jumpAmount = 2

onready var sprite = $AnimatedSprite
onready var collision = $CollisionShape2D
onready var sfxplayer = $AudioStreamPlayer2D
onready var punchsfx = get_node("punchsfx")

var doubletaptime = 0
var dtappedright = false
var dtappedleft = false
var crouch = false
var speed = realSpeed
var jumpLeft = jumpAmount
var superjumpTime= 0
var launchtime = 0
var animation = "jalan_kanan"
var juggleescape = 1
var invultime = 0.5
var invul = 0
var launched = false

const UP = Vector2(0,-1)

var velocity = Vector2()
	

func spritemanip(): #sprite manipulation
	sprite.rotation_degrees = 90*(velocity.x/(realSpeed*4))
	sprite.flip_h = velocity.x < 0
	if sprite.animation != animation:
		sprite.play(animation)
	if velocity.x > 1 or velocity.x < -1:
		sprite.playing = true
	else:
		sprite.playing = false

func get_input(delta):
	animation = "jalan_kanan"
	if crouch: #crouch movement speed
		speed = realSpeed/2
	else:
		speed = realSpeed
		
	if jumpLeft > 0 and Input.is_action_just_pressed('ui_up'):
		if superjumpTime > 0:
			superjumpTime = 0
			sprite.scale.x = 0.1
			velocity.y = -jumpSpeed*2
			sfxplayer.play()
		else:
			velocity.y = -jumpSpeed
			sprite.scale.x = 0.5
		jumpLeft -= 1
	
	if Input.is_action_just_released('ui_down'):
		superjumpTime = delta*3
		
		
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
		

func launch(time, thelaunch):
	if invul <= 0:
		launchtime = time/juggleescape
		velocity = thelaunch
		juggleescape+=0.1
		launched = true
		punchsfx.play()

func _physics_process(delta):
	if doubletaptime > 0:
		doubletaptime -= delta
	if is_on_floor():
		jumpLeft = jumpAmount
	if superjumpTime > 0:
		superjumpTime-=delta
	velocity.y += delta * GRAVITY
	if launchtime > 0:
		launchtime -= delta
		sprite.modulate = Color(0.7, 0.5, 0.5)
	else:
		juggleescape = 1
		get_input(delta)
		if launched:
			invul = invultime
			launched = false
		if invul > 0:
			sprite.modulate = Color(0.5, 0.5, 0.5)
			invul -= delta
		else:
			sprite.modulate = Color(1, 1, 1)
	velocity = move_and_slide(velocity, UP)
	spritemanip()
	var slowdown := min(delta/stopTime, 1.0) #x axis slowdown when no x axis movement input pressed
	velocity.x -= velocity.x * slowdown
	#var slowdownSprite := min(delta/1.6, 1.0)
	if sprite.scale.x < 1:
		sprite.scale.x += sprite.scale.x * slowdown
	
