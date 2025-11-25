extends Node
class_name _FXController

var new = preload("res://objects/text_pop_up.tscn")

func inst_text_pop_up(pos : Vector2, text : String, color : Color):
	var inst = new.instantiate()
	inst.global_position = pos
	inst.text = text
	inst.color = color
	$TextPopUps.add_child(inst)
