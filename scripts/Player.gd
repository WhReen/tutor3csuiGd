extends KinematicBody2D

export (int) var speed = 400
export (int) var jumpSpeed = 800
export (int) var GRAVITY = 1200
export (int) var doubletapdelay= 0.25
var doubletaptime = 0
var lastinput = "none"
var dtapped = false

const UP = Vector2(0,-1)

var velocity = Vector2()

func get_input():
	if Input.is_action_just_pressed('ui_right'):
		if doubletaptime > 0 and velocity.x > 0:
			dtapped = true
		doubletaptime = doubletapdelay
	if Input.is_action_just_pressed('ui_left'):
		if doubletaptime > 0 and velocity.x < 0:
			dtapped = true 
		doubletaptime = doubletapdelay
	if Input.is_action_pressed('ui_right'):
		velocity.x += speed
	if Input.is_action_pressed('ui_left'):
		velocity.x -= speed
	if Input.is_action_just_pressed('ui_up'):
		velocity.y = -jumpSpeed
	if Input.is_action_pressed('ui_down'):
		velocity.y += speed

func _physics_process(delta):
	doubletaptime -= delta
	velocity.y += delta * GRAVITY
	if velocity.x > 0:
		velocity.x -= delta * (GRAVITY*2)
	if velocity.x < 0:
		velocity.x += delta * (GRAVITY*2)
	print_debug(velocity.y)
	print_debug(delta)
	get_input()
	velocity = move_and_slide(velocity, UP)
