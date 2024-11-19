extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("CollisionShape2D/AnimatedSprite2D")

func _ready():
	anim.play("Jump")


func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y = gravity * delta
	
	#handling jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("ui_left","ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.play("run")
	else:
		anim.play("idle")
		velocity.x = move_toward(velocity.x,0, SPEED)
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print(collision)
		if (collision.get_collider().name == "Frog"):
			print("Frog player collision")

		
	
