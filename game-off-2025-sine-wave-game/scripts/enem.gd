extends Area2D
class_name _Enem



func _on_body_entered(body: Node2D) -> void:
	if body.get_script().get_global_name() == "_PlayerObject":
		body.game_end.emit("zero")
		self.queue_free()
