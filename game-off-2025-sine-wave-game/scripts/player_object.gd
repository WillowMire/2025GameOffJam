extends RigidBody2D
class_name _PlayerObject

@export var game_node : _ArcadeMain
@export var col_force_mult : float
@export var downhill_force_mult : float
var collided : bool
var col_timer : float

signal game_end(end_type_name : String)

func _process(delta: float) -> void:
	if game_node.game_ended: 
		self.physics_material_override.absorbent = false
		self.physics_material_override.friction = 0.5
	col_timer -= delta
	if col_timer < 0:
		collided = false

func _on_body_entered(body: Node) -> void:
	if game_node.game_ended: return
	# enemy detection
	if body.get_collision_layer() == 2:
		print("col_enem")
	# wave detection
	if collided: pass #do this for animation
	collided = true
	col_timer = 0.25
	if body.name == "WaveCollision":
		self.linear_velocity = Vector2(0, 0)
		var d = 1
		var dir = Vector2(1, game_node.sin_derivative_math(self.global_position.x))
		if dir.y > 0:
			d = downhill_force_mult
		self.apply_impulse(dir.normalized() * col_force_mult * d)
