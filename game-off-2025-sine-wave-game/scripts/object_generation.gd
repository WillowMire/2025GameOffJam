extends Node2D
class_name _ObjectGeneration

@export var game_node : _ArcadeMain
@export var cam : Camera2D
var zero_enem = preload("res://objects/zero_enemy.tscn")
@export var max_spawn_y : float 
@export var min_spawn_y : float 
@export var spawn_base_interval : float
@export var interval_random_variance : float

func _ready() -> void:
	if spawn_base_interval - interval_random_variance < 0:
		push_error("timer cant be negative, make sure interval_random_variance is less than spawn_base_interval")

func _physics_process(delta: float) -> void:
	if !game_node.running: return
	spawner(delta)
	despawner()

var spawn_timer : float
@onready var temp_spawn_inteval = spawn_base_interval
func spawner(delta : float) -> void:
	if spawn_timer >= temp_spawn_inteval:
		temp_spawn_inteval = randf_range(spawn_base_interval - interval_random_variance, spawn_base_interval + interval_random_variance)
		spawn_zero(get_spawn_location(2))
		spawn_zero(get_spawn_location(1))
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

func despawn_all() -> void:
	for i in $ZeroSpawn.get_children():
		queue_free()

func get_spawn_location(curve_exponent : float) -> Vector2:
	var l = get_viewport().get_visible_rect().size.x * (1 / cam.zoom.x) / 2
	var cent = cam.get_screen_center_position().x
	var offset = min_spawn_y - max_spawn_y
	var tx = pow(max_spawn_y + offset, 1/curve_exponent)
	var ty = pow(min_spawn_y + offset, 1/curve_exponent)
	var i = randf_range(tx, ty)
	var j = pow(i, curve_exponent) - offset
	var k = randf_range(50, 100 + offset)
	return Vector2(cent + l  + k, j)

func spawn_zero(pos : Vector2) -> void:
	var i = zero_enem.instantiate()
	i.position = pos
	$ZeroSpawn.add_child(i)
