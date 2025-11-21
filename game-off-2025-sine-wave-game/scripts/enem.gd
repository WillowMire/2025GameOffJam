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
		body.gained_score.emit(10)
