extends Node
class_name _FXController

var new = preload("res://objects/text_pop_up.tscn")

@export var text_pop_ups_node : Node2D
@export var player_particles_node : Node2D

func update_player_trail_pos(pos : Vector2):
	player_particles_node.global_position = pos

func inst_text_pop_up(pos : Vector2, text : String, color : Color):
	var inst = new.instantiate()
	inst.global_position = pos
	inst.text = text
	inst.color = color
	text_pop_ups_node.add_child(inst)
