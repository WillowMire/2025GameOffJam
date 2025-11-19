extends Node2D
class_name _ObjectGeneration

@export var cam : Camera2D
var zero_enem = preload("res://objects/zero_enemy.tscn")
@export var y_spawn_range : Vector2 
@export var spawn_base_interval : float
@export var interval_random_variance : float

func _process(delta: float) -> void:
	if spawn_base_interval - interval_random_variance < 0:
		push_error("timer can be negative, make sure interval_random_variance is less than spawn_base_interval")
	spawner(delta)
	despawner()

var spawn_timer : float
@onready var temp_spawn_inteval = spawn_base_interval
func spawner(delta : float) -> void:
	if spawn_timer >= temp_spawn_inteval:
		temp_spawn_inteval = randf_range(spawn_base_interval - interval_random_variance, spawn_base_interval + interval_random_variance)
		spawn_zero(get_spawn_location())
		spawn_timer = 0
	spawn_timer += delta

func check_out_bounds(area : Area2D):
	var l = get_viewport().get_visible_rect().size.x * (1 / cam.zoom.x) / 2
	var cent = cam.get_screen_center_position().x
	if area.global_position.x <= cent - l - 150: return area
	else: return false

func despawner() -> void: 
	for i in $ZeroSpawn.get_children().filter(check_out_bounds):
		i.queue_free()

func get_spawn_location() -> Vector2:
	var l = get_viewport().get_visible_rect().size.x * (1 / cam.zoom.x) / 2
	var cent = cam.get_screen_center_position().x
	var i = randf_range(y_spawn_range.x, y_spawn_range.y)
	return Vector2(cent + l + 150, i)

func spawn_zero(pos : Vector2) -> void:
	var i = zero_enem.instantiate()
	i.position = pos
	$ZeroSpawn.add_child(i)
