extends Node2D

@export var frog_scene: PackedScene

var mobs_node: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mobs_node = $Mobs

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_frog() -> void:
	if frog_scene:  # Check if the mob scene is set
		# Instance the mob from the scene
		var frog_instance = frog_scene.instantiate()
		
		frog_instance.position = Vector2(275, -384)
		
		# Add the new mob instance as a child of the Mobs node
		mobs_node.add_child(frog_instance)
		$Timer.wait_time = randi_range(1, 10)
