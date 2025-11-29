extends RigidBody2D
class_name _PlayerObject

@export var game_node : _ArcadeMain
@export var anim_player : AnimationPlayer
@export var col_impulse_mult : float
@export var col_force_mult : float
@export var downhill_force_mult : float
var collided : bool
var col_timer : float
@onready var initial_grav : float = self.gravity_scale
@export var max_velocity : float
@export var rebound_force : float

@warning_ignore("unused_signal")
signal game_end(end_type_name : String)

func _ready() -> void:
	if height_to_reach.size() != points_per_height.size():
		push_error("variables 'height_to_reach' and 'points+per_height' must be equal to function correctly")

func _process(_delta: float) -> void:
	game_node.fx_controller.update_player_trail_pos(self.global_position)
	game_node.fx_controller.emit_grind(is_snapped)

func _physics_process(delta: float) -> void:
	animation()
	
	if game_node.game_ended: return
	
	if collided:
		var d = 1
		var dir = Vector2(1, game_node.sin_derivative_math(self.global_position.x))
		if dir.y > 0:
			d = downhill_force_mult
		self.apply_central_force(dir.normalized() * col_force_mult * d * delta * 60)
	
	if is_player_below_wave():
		snap_player_above_wave()
		revert_vel()
		is_snapped = true
	
	check_player_at_crest()
	
	if self.linear_velocity.length() > max_velocity:
		var opp = self.linear_velocity.orthogonal().orthogonal()
		self.apply_central_force(opp.normalized() * rebound_force * delta * 60)
	
	height_score()
	
	prev_vel = self.linear_velocity

func animation() -> void:
	if self.linear_velocity.y <= 0 && anim_player.current_animation != "player_up":
		anim_player.play("player_up")
	elif self.linear_velocity.y > 0 && anim_player.current_animation != "player_down":
		anim_player.play("player_down")

@export var clipping_forgiveness : float
func is_player_below_wave() -> bool:
	var y_off = $CollisionShape2D.shape.radius
	var y_wave = game_node.sin_func_math(self.global_position.x)
	if self.global_position.y > (y_wave - y_off + clipping_forgiveness): 
		return true
	else: return false

func snap_player_above_wave() -> void:
	var y_off = $CollisionShape2D.shape.radius
	var y_wave = game_node.sin_func_math(self.global_position.x)
	var normal = Vector2(1, game_node.sin_derivative_math(self.global_position.x)).normalized().orthogonal()
	self.global_position = Vector2(self.global_position.x, y_wave + (normal.y * 2 * y_off))

var prev_vel : Vector2
func revert_vel() -> void:
	var dir_der = Vector2(1, game_node.sin_derivative_math(self.global_position.x))
	self.linear_velocity = dir_der.normalized() * prev_vel.length()

var is_snapped : bool = false
func check_player_at_crest() -> void:
	var wave_height = game_node.sin_func_math(self.global_position.x)
	var a = game_node.a_var
	var n = 15
	if wave_height < (0 - (a/2) + (a*n/100)):
		is_snapped = false
		return
	
	#var deriv = game_node.sin_derivative_math(self.global_position.x)
	#if deriv < 0.3 && -0.6 < deriv:
		#is_snapped = false
		#return
	if is_snapped:
		snap_player_above_wave()


@export var height_to_reach : Array[float]
@export var points_per_height : Array[int]

var last_y
func height_score() -> void:
	var y = self.global_position.y
	for i in height_to_reach.size():
		if y > height_to_reach[i]: continue
		if last_y < height_to_reach[i]: continue
		if y < height_to_reach[i]:
			game_node.add_score(points_per_height[i], "+" + str(points_per_height[i]), Color(0.71, 0.544, 0.0, 1.0))
	last_y = y

func _on_area_2d_body_entered(body: Node2D) -> void:
	if collided: pass #do this for animation
	collided = true
	if body.name == "WaveCollision":
		if is_snapped: return
		var d = 1
		var dir = Vector2(1, game_node.sin_derivative_math(self.global_position.x))
		if dir.y > 0:
			d = downhill_force_mult
		self.apply_central_impulse(dir.normalized() * col_impulse_mult * d)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "WaveCollision":
		collided = false
