extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = true
var alive = true
var death_time = 0

func _ready():
	get_node("AnimatedSprite2D").play("idle")
	# Get reference to player at start
	player = get_node("../../Player")

func _physics_process(delta):
	# Gravity for Frog
	if not alive:
		if (death_time > 35):
			self.queue_free()
		elif (death_time == 0):
			get_node("AnimatedSprite2D").play("Death")
		death_time += 1
		return
	velocity.y += gravity * delta
	
	if chase and player:
		# Get direction to player
		var direction = position.direction_to(player.position)
		
		# Set velocity based on direction
		velocity.x = direction.x * SPEED
		
		# Update animation
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("jump")
		
		# Flip sprite based on movement direction
		if velocity.x > 0:
			get_node("AnimatedSprite2D").flip_h = true
		elif velocity.x < 0:
			get_node("AnimatedSprite2D").flip_h = false
	else:
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("idle")
		velocity.x = 0
	
	move_and_slide()
		

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		chase = false

func _on_player_death_body_entered(body):
	#breakpoint
	if body.name == "Player":
		self.queue_free()
		
func on_death():
	get_node("AnimatedSprite2D").play("Death")
	alive = false
