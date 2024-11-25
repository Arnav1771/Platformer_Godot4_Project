extends CharacterBody2D
class_name Mob

enum STATE {FREE, FOLLOWING}
var state = STATE.FREE

enum ACTION {IDLE, JUMP, FALL}
var current_action = ACTION.IDLE

enum MOVEMENT_TYPE {STILL, WALK, RUN, JUMP, FLOAT, SOAR, SWOOP}
var movement_type = MOVEMENT_TYPE.JUMP

var alive = true
signal death
var player
var player_in_vicinity = false
@export var player_vicinity_distance = 200.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var reaction_time = 1.0

@export var killed_by_stomps : bool = true

func _ready():
	if call_deferred('establish_connections'):
		print('identified player')
	else: print('failed to identify player')
	call_deferred('start')

func start():
	pass

func establish_connections():
	var players = get_tree().get_nodes_in_group('player')
	if not players:
		return false
	player = players[0]
	print('player identified: %s %s' % [player.name, player])
	
	# a good safety measure for it if doesn't work the first time
	# but it can get stuck in a loop if no player is present
	# a way to avoid a loop is to have func establish_connections(index = 3): 
	# if index <= 0: push_error('unable to load player')
	# and later call deferred('establish_connections', index -1)
	return true

func _physics_process(delta: float) -> void:
	reaction_time_countdown(delta)
	act(delta)


func act(delta):
	pass


var current_reaction_countdown = 4.0

func reaction_time_countdown(delta):
	current_reaction_countdown -= delta
	if current_reaction_countdown <= 0:
		react()
		current_reaction_countdown = new_countdown_time()
		print(current_reaction_countdown)

func new_countdown_time() -> float:
	return randf() * reaction_time + (reaction_time / 2)
	

func react():
	if is_player_within_vicinity():
		state = STATE.FOLLOWING
	else:
		state = STATE.FREE


func is_player_within_vicinity():
	if not player:
		if not establish_connections():
			print('can not identify player')
		return false
	return abs(player.position.x - position.x) < player_vicinity_distance

func die():
	alive = false
	death.emit(self)

func body_entered_killzone(incoming_body):
	print(incoming_body.name)
	if incoming_body == player:
		player_entered_killzone()
	
func player_entered_killzone():
	print('killed')
	if killed_by_stomps and player.velocity.y > 0:
		die()
