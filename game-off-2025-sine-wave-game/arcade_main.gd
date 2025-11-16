extends Node2D
class_name _ArcadeMain

@export var DEBUG : bool
@export var player : RigidBody2D
@export var cam : Camera2D
@export var sin_label : Label

# GOAL
# add dynamic grid drawing system, so it looks like you're on a graph, style it similar to desmos
# add 0 enemy

var sin_collision : CollisionShape2D
var seg : SegmentShape2D

@export var line : Line2D
@export var vect_array : Array[Vector2]
@export_group("Wave Variables")
@export var a_var : float
@export var b_var : float
@export var c_var : float
@export var d_var : float
@export var min_control_speed : float
@export var max_control_speed : float
@export var v_move_curve : Curve
@export var v_up_multiplier : float
@export var v_down_multiplier : float
@export var h_move_control_lerp_time : float

func _ready() -> void:
	initial_a = a_var
	if DEBUG:
		$CanvasLayer/DEBUG.visible = true
		$CanvasLayer/DEBUG/A_Edit.text = str(a_var)
		$CanvasLayer/DEBUG/B_Edit.text = str(b_var)
		$CanvasLayer/DEBUG/C_Edit.text = str(c_var)
		$CanvasLayer/DEBUG/D_Edit.text = str(d_var)
	draw_wave()
	start_sin_collision()
	#poly_start_sin_collision()
	update_sin_label()

func _process(_delta: float) -> void:
	if DEBUG:
		$CanvasLayer/DEBUG/PlayerPos.text = "Pos:(" + str(roundi(player.global_position.x)) + ", " + str(roundi(player.global_position.y)) + ")" 

#might change to _process if theres a problem
func _physics_process(delta: float) -> void:
	push_player() # applies force to player, might move this to player
	move_wave_data(delta) # controls wave by changing variables before 
	draw_wave()
	update_sin_collision() #this may cause problems later, if so try making this and the draw function into lerps
	#poly_update_sin_collision()
	update_sin_label()

func push_player():
	pass
	#player.apply_force(Vector2(50, 0))

func update_sin_label():
	var a = str(roundi(a_var))
	var b = str(snappedf(b_var, 0.001))
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
	#for i in vect_array.size() - 1:
		#var _seg = SegmentShape2D.new()
		#_seg.a = vect_array[i]
		#_seg.b = vect_array[i+1]
		#sin_collision_array[i].shape = _seg
	
	# this might be laggy ASF so maybe fix later tee hee
	for child in $WaveCollision.get_children():
		child.queue_free()
	for i in vect_array.size() - 1:
		var inst = CollisionShape2D.new()
		var _seg = SegmentShape2D.new()
		_seg.a = vect_array[i]
		_seg.b = vect_array[i+1]
		inst.shape = _seg
		$WaveCollision.add_child(inst)
		sin_collision_array.append(inst)

var v_move_timer : float
var h_move_timer : float
var prev_v_input
var initial_a : float
var temp_cur_a : float
var moving : bool
var prev_moving : bool
func move_wave_data(delta : float) -> void:
	var v_input = Input.get_axis("up", "down")
	var h_input = Input.get_axis("left", "right")
	
	#region vertical
	#controls a timer var that is used later
	if v_input != 0:
		if prev_v_input != v_input:
			temp_cur_a = a_var
			v_move_timer = 0
			moving = true
		v_move_timer += delta
	elif v_input == 0:
		if prev_v_input != v_input:
			temp_cur_a = a_var
			v_move_timer = 0
		if v_move_timer < v_move_curve.max_domain:
			v_move_timer += delta
		elif v_move_timer > v_move_curve.max_domain:
			v_move_timer = v_move_curve.max_domain
			moving = false
	
	#if moving, move a_var according to vmovetimer and curve stuffs
	if moving:
		var curve = clampf(v_move_curve.sample(v_move_timer), 0, 1)
		if v_input == 1:
			a_var = lerpf(temp_cur_a, initial_a * v_up_multiplier, curve)
		elif v_input == -1:
			a_var = lerpf(temp_cur_a, initial_a * v_down_multiplier, curve)
		elif v_input == 0:
			a_var = lerpf(temp_cur_a, initial_a, curve)
	else:
		if prev_moving != moving:
			a_var = initial_a
	
	prev_v_input = v_input
	prev_moving = moving
	#endregion
	
	#region horizontal
	if h_input != 0:
		h_move_timer += delta / h_move_control_lerp_time
		var h_lerp = clampf(lerpf(min_control_speed, max_control_speed, h_move_timer), min_control_speed, max_control_speed)
		c_var -= delta * h_lerp * h_input
	elif h_input == 0:
		h_move_timer = 0
	#endregion

func draw_wave() -> void: 
	var l = get_viewport().get_visible_rect().size.x * (1 / cam.zoom.x) / 2
	var cent = cam.get_screen_center_position().x
	#$"../Sprite2D".global_position.x = cam.get_screen_center_position().x - l / 2
	#$"../Sprite2D2".global_position.x = cam.get_screen_center_position().x + l / 2
	#var j = roundi(player.position.x)
	vect_array.clear()
	for x in range(cent - l - 50, cent + l + 200, 10):
		var i = Vector2(x, sin_func_math(x, a_var, b_var, c_var, d_var))
		vect_array.append(i)
	line.set_points(vect_array)

func sin_func_math(x : float, a : float, b : float, c : float, d : float) -> float:
	# aSin(b(x+c))+d
	var y
	y = (a * -sin(b * (x + c))) + d
	return y

func sin_derivative_math(x : float, a = a_var, b = b_var, c = c_var) -> float:
	var dydx
	dydx = (a * b * -cos(b * (x + c)))
	return dydx

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
