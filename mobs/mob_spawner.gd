extends Node2D

@export var mob_entities : Array[PackedScene] = []

enum WAVE {START, MIDDLE, END}
var wave = WAVE.START

@export var wave_entity_count = [1,3,5]
@export var time_between_waves = 10.0
@export var wait_until_all_enemies_dead_before_interval_timer = true

var current_spawned_entities = []

func _ready() -> void:
	spawn_wave()

func spawn_wave():
	for entry in wave_entity_count[wave]:
		spawn_entity()
	wave += 1

func spawn_entity(entity_index = 0):
	var new_entity = mob_entities[0].instantiate()
	add_child(new_entity)
	current_spawned_entities.append(new_entity)
	new_entity.death.connect(entity_death)

func entity_death(incoming_entity):
	current_spawned_entities.remove_at(current_spawned_entities.find(incoming_entity))
