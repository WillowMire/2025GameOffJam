extends Node
class_name _FXController

var text_pop_up = preload("res://objects/text_pop_up.tscn")

func inst_text_pop_up(pos : Vector2, text : String):
	var inst = text_pop_up.instantiate()
	inst.global_position = pos
	inst.text = text
	$TextPopUps.add_child(inst)
