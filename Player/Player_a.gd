extends CharacterBody2D

enum CONDITION { GROUNDED, AIRBORN_ASCENT, AIRBORN_DESCENT }
var condition = CONDITION.GROUNDED

enum STATE { IDLE, RUN, JUMP, FALL, FLOAT, CROUCH}
var state = STATE.IDLE

var momentum = 0.0

@export var acceleration = 0.09
@export var max_speed = 300.0
@export var friction = 0.9
@export var jump_strength = 400.0
@export var jump_duration = 1.0
@export var jump_strength_curve : Curve

@export var tilt_range : float = 90.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping = false

@onready var anim = get_node("AnimatedSprite2D")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump()
	
	elif event.is_action("ui_down"):
		if event.is_pressed():
			crouch()
		elif event.is_released():
			stand()


func _physics_process(delta):
	apply_gravity(delta)
	move()
	move_and_slide()
	tilt()
	match_animation_to_state()


func apply_gravity(delta):
	if not is_on_floor():
		fall(delta)
	else:
		if state == STATE.JUMP or state == STATE.FALL:
			land()
		velocity.y = 0

func fall(delta):
	velocity.y += gravity * delta
	if velocity.y > 0.0:
		state = STATE.JUMP
	else:
		state = STATE.FALL

func land():
	is_jumping = false


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

func accelerate(direction):
	momentum = lerp(momentum, max_speed * direction, acceleration)
	velocity.x += momentum

func deaccelerate():
	momentum = lerp(momentum, 0.0, acceleration)
	velocity.x += momentum


func calculate_state() -> STATE:
	if is_crouching:
		return STATE.CROUCH
	
	
	
	return STATE.IDLE
	
	

func match_animation_to_state(incoming_state = state):
	if abs(velocity.x) > 0:
		anim.play("run")
	else:
		anim.play("idle")
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
	if is_on_floor():
		print('jumped')
		state = STATE.JUMP  # Set jumping state

func jumping():
	pass

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

var is_crouching = false

var crouch_timer = 0.0
@export var crouch_to_super_jump_duration = 0.2

func crouch():
	is_crouching = true

func stand():
	is_crouching = false

func crouch_while_running():
	pass

func crouch_while_falling():
	pass
