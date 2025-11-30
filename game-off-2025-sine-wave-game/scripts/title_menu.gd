extends Control

var top_score

func _ready() -> void:
	top_score = _SaveLoad.save_contents.top_score
	$TopScore.text = "Top Score: " + str(top_score)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/arcade.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
