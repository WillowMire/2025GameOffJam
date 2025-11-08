extends Node2D
class_name _ArcadeMain

@export var DEBUG : bool
@export var player : RigidBody2D
@export var cam : Camera2D
@export var sin_label : Label

# GOAL
# tune collision and movement to feel good
# learn and configure viewport, then adjust wave size depending on viewport

var sin_collision : CollisionShape2D
var seg : SegmentShape2D

var sin_x_bounding_range : float

@export var line : Line2D
@export var vect_array : Array[Vector2]
@export_group("Wave Variables")
@export var a_var : float
@export var b_var : float
@export var c_var : float
@export var d_var : float
@export var min_control_speed : float
@export var max_control_speed : float
@export var move_control_lerp_time : float

func _ready() -> void:
	if DEBUG:
		$DEBUG.visible = true
		$DEBUG/A_Edit.text = str(a_var)
		$DEBUG/B_Edit.text = str(b_var)
		$DEBUG/C_Edit.text = str(c_var)
		$DEBUG/D_Edit.text = str(d_var)
	draw_wave()
	start_sin_collision()
	#poly_start_sin_collision()
	update_sin_label()

#might change to _process if theres a problem
func _physics_process(delta: float) -> void:
	push_player() # applies force to player, might move this to player
	move_wave_data(delta) # controls wave by changing variables before 
	draw_wave()
	update_sin_collision() #this may cause problems later, if so try making this and the draw function into lerps
	#poly_update_sin_collision()
	update_sin_label()

func push_player():
	player.apply_force(Vector2(50, 0))

func update_sin_label():
	var a = str(roundi(a_var))
	var b = str(roundi(b_var))
	var c = str(roundi(c_var))
	var d = str(roundi(d_var))
	sin_label.text = "f(x) = " + a + "Sin(" + b + "(x + " + c + ")) + " + d

var sin_collision_array : Array[CollisionShape2D] #change to poly or normal depending on what sincollision im doing
func start_sin_collision() -> void:
	for i in vect_array.size() - 1:
		var inst = CollisionShape2D.new()
		var _seg = SegmentShape2D.new()
		_seg.a = vect_array[i]
		_seg.b = vect_array[i+1]
		inst.shape = _seg
		$WaveCollision.add_child(inst)
		sin_collision_array.append(inst)

func update_sin_collision() -> void:
	for i in vect_array.size() - 1:
		var _seg = SegmentShape2D.new()
		_seg.a = vect_array[i]
		_seg.b = vect_array[i+1]
		sin_collision_array[i].shape = _seg

func poly_start_sin_collision() -> void:
	var inst = CollisionPolygon2D.new()
	inst.polygon.append(vect_array[0] + Vector2(0, 500))
	for i in vect_array.size() - 1:
		inst.polygon.append(vect_array[i])
	inst.polygon.append(vect_array[vect_array.size() - 1] + Vector2(0, 500))
	sin_collision_array.append(inst)
	$WaveCollision.add_child(inst)

func poly_update_sin_collision() -> void:
	sin_collision_array[0].polygon.clear()
	sin_collision_array[0].polygon.append(vect_array[0] + Vector2(0, 500))
	for i in vect_array.size() - 1:
		sin_collision_array[0].polygon.append(vect_array[i])
	sin_collision_array[0].polygon.append(vect_array[vect_array.size() - 1] + Vector2(0, 500))

var v_move_timer : float
var h_move_timer : float
func move_wave_data(delta : float) -> void:
	pass
	var v_input = Input.get_axis("up", "down")
	var h_input = Input.get_axis("left", "right")
	
	if v_input != 0:
		v_move_timer += delta / move_control_lerp_time
		var v_lerp = clampf(lerpf(min_control_speed, max_control_speed, v_move_timer), min_control_speed, max_control_speed)
		d_var += delta * v_lerp * v_input
	elif v_input == 0:
		v_move_timer = 0
	
	if h_input != 0:
		h_move_timer += delta / move_control_lerp_time
		var h_lerp = clampf(lerpf(min_control_speed, max_control_speed, h_move_timer), min_control_speed, max_control_speed)
		c_var -= delta * h_lerp * h_input
	elif h_input == 0:
		h_move_timer = 0

func draw_wave() -> void: 
	var j = player.position.x
	vect_array.clear()
	for x in range(j - 1200, j + 1201, 20):
		var i = Vector2(x, sin_func_math(x, a_var, b_var, c_var, d_var))
		vect_array.append(i)
	line.set_points(vect_array)

func sin_func_math(x : float, a : float, b : float, c : float, d : float) -> float:
	# aSin(b(x+c))+d
	var y
	y = (a * -sin(b * (x + c))) + d
	return y

func _on_a_edit_text_submitted(new_text: String) -> void:
	a_var = float(new_text)
	draw_wave()


func _on_b_edit_text_submitted(new_text: String) -> void:
	b_var = float(new_text)
	draw_wave()


func _on_c_edit_text_submitted(new_text: String) -> void:
	c_var = float(new_text)
	draw_wave()


func _on_d_edit_text_submitted(new_text: String) -> void:
	d_var = float(new_text)
	draw_wave()
