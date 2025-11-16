extends RigidBody2D
class_name _PlayerObject

@export var game_node : _ArcadeMain
@export var col_force_mult : float
var collided : bool
var col_timer : float

func _process(delta: float) -> void:
	if self.linear_velocity.x == 0:
		pass#print("GAME OVER")
	col_timer -= delta
	if col_timer < 0:
		collided = false

func _on_body_entered(body: Node) -> void:
	# enemy detection
	
	# wave detection
	if collided: return
	collided = true
	col_timer = 0.25
	if body.name == "WaveCollision":
		var dir = Vector2(1, game_node.sin_derivative_math(self.global_position.x))
		self.apply_impulse(dir.normalized() * col_force_mult)
