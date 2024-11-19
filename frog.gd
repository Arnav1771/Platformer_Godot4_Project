extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = true

func _ready():
	get_node("AnimatedSprite2D").play("idle")
	# Get reference to player at start
	player = get_node("../../Player")

func _physics_process(delta):
	# Gravity for Frog
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
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("collsion with: ",collision.get_collider().name)
		

func _on_player_detection_body_entered(body):
	print(body.name)
	if body.name == "Player":
		chase = true

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		chase = false

func _on_player_death_body_entered(body):
	#breakpoint
	if body.name == "Player":
		self.queue_free()


func _on_player_detection_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print(body.name)


func _on_player_detection_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("area Shape:",area.name)
	
	


func _on_player_detection_area_entered(area: Area2D) -> void:
	print("Area enter:", area.name)
