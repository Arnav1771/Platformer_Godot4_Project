extends CharacterBody2D

var momentum = 0.0


@export var acceleration = 0.09
@export var max_speed = 300.0
@export var friction = 0.9
@export var jump_strength = 400.0
@export var tilt_range : float = 90.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping = false

@onready var anim = get_node("AnimatedSprite2D")

func _ready():
	anim.play("idle")

func _physics_process(delta):
	apply_gravity(delta)
	move()
	jump()
	move_and_slide()
	tilt()


func apply_gravity(delta):
	if not is_on_floor():
		fall(delta)
	else:
		if is_jumping:
			land()
		velocity.y = 0

func fall(delta):
	velocity.y += gravity * delta

func land():
	is_jumping = false
	if abs(velocity.x) > 0:
		anim.play("run")
	else:
		anim.play("idle")

func move():
	if direction() != 0: 
		accelerate(direction())
	else: 
		deaccelerate()
	apply_friction()
	orient_sprite_to_direction(momentum)
	
func direction():
	return Input.get_axis("ui_left", "ui_right")

func apply_friction():
	velocity.x *= friction
	# Move the character with calculated velocity

func accelerate(direction):
	momentum = lerp(momentum, max_speed * direction, acceleration)
	velocity.x += momentum

func deaccelerate():
	momentum = lerp(momentum, 0.0, acceleration)
	velocity.x += momentum
	if not is_jumping and anim.animation != "idle":
		anim.play("idle")

	
	if not is_jumping:  # Play run animation only if not jumping
		anim.play("run")


func orient_sprite_to_direction(direction):
	# Flip sprite based on direction
	anim.flip_h = direction < 0


func collide():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if(collision.get_collider().is_in_group('frogs')):
			collision.get_collider().on_death()

func jump():
	if Input.is_action_pressed('jump') and is_on_floor():
		velocity.y -= jump_strength
		is_jumping = true  # Set jumping state
		anim.play("Jump")  # Play jump animation only once when jumping


var desired_tilt_angle : float
var actual_tilt_angle : float
@export var tilt_change_speed = 0.33
@export var tilt_curve : Curve

func tilt():
	var ratio = momentum/max_speed
	var range = tilt_range / 2
	var input_ratio = range * direction()
	if ratio > 0:
		desired_tilt_angle = range * ratio
	elif ratio < 0:
		desired_tilt_angle = range * ratio
	elif ratio == 0:
		desired_tilt_angle = 0
	desired_tilt_angle = lerp(desired_tilt_angle, input_ratio, tilt_change_speed)
	var actual_tilt_speed_change = tilt_change_speed + (tilt_change_speed * int(is_on_floor() == false))
	actual_tilt_angle = lerp(actual_tilt_angle, desired_tilt_angle, actual_tilt_speed_change)
	anim.rotation_degrees = actual_tilt_angle
	
