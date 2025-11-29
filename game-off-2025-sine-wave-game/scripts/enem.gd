extends Area2D
class_name _Enem

var player_die : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.get_script().get_global_name() == "_PlayerObject":
		body.game_end.emit("zero")
		self.queue_free()
		player_die = true

func _on_close_call_body_exited(body: Node2D) -> void:
	if body.get_script().get_global_name() == "_PlayerObject":
		if player_die: return
		body.game_node.add_score(25, "Close!", Color(0.77, 0.316, 0.702, 1.0))
