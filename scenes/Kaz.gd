extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var sprite = $AnimatedSprite
onready var yapplayer = get_node("YapPlayer")
onready var attackplayer = get_node("AttackSoundPlayer")
onready var own = get_node(".")
var player = null
var fight = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkanim()
	if player != null:
		sprite.flip_h = (own.global_position.x - player.global_position.x) > 0

func checkanim():
	if !fight:
		if (-1 > own.linear_velocity.x) or (own.linear_velocity.x > 1):
			sprite.set_animation("walking")
		else:
			sprite.set_animation("idle")
	if player != null:
		if own.global_position.distance_to(player.global_position) < 130:
			yapplayer.set_stream_paused(true)
			fight = true
			sprite.set_animation("godfist")
			if sprite.get_frame() == 0:
				attackplayer.play()
				own.linear_velocity.x = player.global_position.x - own.global_position.x
			if sprite.get_frame() == 5:
				player.launch(1,Vector2((player.global_position.x - own.global_position.x),-1000))
		elif own.global_position.distance_to(player.global_position) < 300:
			var move = 300
			if own.global_position.x - player.global_position.x < 0:
				own.linear_velocity.x = move
			else:
				own.linear_velocity.x = -move
			
		else:
			fight = false
			yapplayer.set_stream_paused(false)

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		player = body
