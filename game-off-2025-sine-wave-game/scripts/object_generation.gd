extends Node2D
class_name _ObjectGeneration
## Instantiates all the objects the player can interact with


@export var game_node : _ArcadeMain
@export var cam : Camera2D
@export var player : _PlayerObject
## preload for 0 enemy node
var zero_enem = preload("res://objects/zero_enemy.tscn")
@export var spawn_separation_dist : int
var initial_pos
@export var max_spawn_y : float 
@export var min_spawn_y : float 

func _ready() -> void:
	randomize()
	initial_pos = cam.global_position.x

func _physics_process(delta: float) -> void:
	if !game_node.running: return
	spawner(delta)
	despawner()

var prev_dist
func spawner(delta : float) -> void:
	var dist = snappedi((player.global_position.x - initial_pos), spawn_separation_dist) 
	if dist%spawn_separation_dist == 0 && dist != prev_dist:
		spawn_zero(get_spawn_location(4))
		spawn_zero(get_spawn_location(3))
		spawn_zero(get_spawn_location(2))
		spawn_zero(get_spawn_location(3))
	prev_dist = dist

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
	var offset = abs(min_spawn_y - max_spawn_y)
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
