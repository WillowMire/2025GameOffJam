extends Node2D
class_name _ArcadeMain

@export var DEBUG : bool

@export_group("Nodes")
@export var player : RigidBody2D
@export var cam_guide : _CamGuide
@export var cam : Camera2D
@export var obj_generator : _ObjectGeneration
@export var sin_label : Label
@export var score_label : Label
@export var top_score_label: Label
@export var dist_traveled_label : Label
@export var player_start_node : Node2D
@export var fx_controller : _FXController
@export var audio_controller : _AudioController

var sin_collision : CollisionShape2D
var seg : SegmentShape2D

@export var line : Line2D
var visual_vect_array : Array[Vector2]
var collision_vect_array : Array[Vector2]
@export_group("Wave Variables")
@export var a_var : float
var initial_a : float
@export var b_var : float
var initial_b : float
@export var c_var : float
var initial_c : float
@export var d_var : float
var initial_d : float
@export var min_control_speed : float
@export var max_control_speed : float
@export var v_move_curve : Curve
@export var v_up_multiplier : float
@export var v_down_multiplier : float
@export var h_move_control_lerp_time : float
var score : int : set = set_score
var top_score : int : set = set_top_score
var dist_traveled : int : set = set_dist_traveled
var start_pos : float
var running : bool

var prev_dist_traveled
func set_dist_traveled(value : int):
	dist_traveled_label.text = "Distance Traveled: " + str(value) + "m"
	dist_traveled = value
	if value == 0: return
	if value%10 == 0 && value != prev_dist_traveled:
		add_score(10, "+10", Color(0.28, 0.28, 0.28, 1.0))
	prev_dist_traveled = value

func calc_dist_traveled(distance : int) -> int:
	#convert distance in pixels to whatever I want
	@warning_ignore("integer_division")
	var dist = roundi(distance / 200)
	return dist

func _ready() -> void:
	setup_game()

func setup_ui():
	$CanvasLayer/Score.visible = true
	$CanvasLayer/DistanceTraveled.visible = true
	$CanvasLayer/EndGameScreen.visible = false
	$CanvasLayer/StartScreen.visible = true
	if DEBUG:
		$CanvasLayer/DEBUG.visible = true

func _process(_delta: float) -> void:
	if DEBUG:
		$CanvasLayer/DEBUG/PlayerPos.text = "Pos:(" + str(roundi(player.global_position.x)) + ", " + str(roundi(player.global_position.y)) + ")" 
	if game_ended: return
	@warning_ignore("narrowing_conversion")
	set_dist_traveled(calc_dist_traveled(player.global_position.x - start_pos))

func _physics_process(delta: float) -> void:
	if !running: 
		if Input.is_anything_pressed():
			start_game()
		return
	move_wave_data(delta) # controls wave by changing variables before 
	if game_ended:
		return
	draw_wave()
	draw_collision()
	update_sin_collision()
	update_sin_label()

func add_score(value : int, custom_message = "default", color : Color = Color.BLACK):
	if game_ended: return
	score += value
	audio_controller.point.pitch_scale = randf_range(0.8, 1.2)
	audio_controller.point.play()
	match custom_message:
		"default":
			fx_controller.inst_text_pop_up(player.global_position, "+ " + str(value), color)
		_:
			fx_controller.inst_text_pop_up(player.global_position, custom_message, color)

func set_score(value : int):
	score_label.text = "Score: " + str(value)
	score = value

func set_top_score(value : int):
	top_score_label.text = "Top Score: " + str(value)
	top_score = value

func update_sin_label():
	var a = str(roundi(a_var))
	var b = str(snappedf(b_var, 0.001))
	var c = str(roundi(c_var))
	var d = str(roundi(d_var))
	sin_label.text = "f(x) = " + a + "Sin(" + b + "(x + " + c + ")) + " + d

func draw_collision():
	var _pos = player.global_position.x
	collision_vect_array.clear()
	for x in range(_pos - 50, _pos + 50, 2):
		var i = Vector2(x, sin_func_math(x, a_var, b_var, c_var, d_var))
		collision_vect_array.append(i)

#change to world thing
var sin_collision_array : Array[CollisionShape2D] #change to poly or normal depending on what sincollision im doing
func start_sin_collision() -> void:
	for i in collision_vect_array.size() - 1:
		var inst = CollisionShape2D.new()
		var _seg = SegmentShape2D.new()
		_seg.a = collision_vect_array[i]
		_seg.b = collision_vect_array[i+1]
		inst.shape = _seg
		$WaveCollision.add_child(inst)
		sin_collision_array.append(inst)

func update_sin_collision() -> void:
	for i in collision_vect_array.size() - 1:
		var _seg = SegmentShape2D.new()
		_seg.a = collision_vect_array[i]
		_seg.b = collision_vect_array[i+1]
		sin_collision_array[i].shape = _seg

var v_move_timer : float
var h_move_timer : float
var prev_v_input
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

func draw_wave(wave_type : String = "") -> void: 
	var func_mult
	match wave_type:
		"": func_mult = 1 
		"zero": func_mult = 0
	var l = get_viewport().get_visible_rect().size.x * (1 / cam.zoom.x) / 2
	var cent = cam.get_screen_center_position().x
	visual_vect_array.clear()
	for x in range(cent - l - 50, cent + l + 200, 5):
		var i = Vector2(x, func_mult * sin_func_math(x, a_var, b_var, c_var, d_var))
		visual_vect_array.append(i)
	line.set_points(visual_vect_array)

func sin_func_math(x : float, a : float = a_var, b : float = b_var, c : float = c_var, d : float = d_var) -> float:
	# aSin(b(x+c))+d
	var y
	y = (a * -sin(b * (x + c))) + d
	return y

func sin_derivative_math(x : float, a = a_var, b = b_var, c = c_var) -> float:
	var dydx
	dydx = (a * b * -cos(b * (x + c)))
	return dydx

func setup_game():
	setup_ui()
	player.global_position = player_start_node.global_position
	top_score = _SaveLoad.save_contents.top_score
	start_pos = player_start_node.global_position.x
	score = 0
	initial_a = a_var
	initial_b = b_var
	initial_c = c_var
	initial_d = d_var
	player.connect("game_end", end_game)
	draw_wave()
	draw_collision()
	start_sin_collision()
	update_sin_label()
	
	player.global_position = player_start_node.global_position
	player.freeze = true
	running = false

func start_game():
	$CanvasLayer/StartScreen.visible = false
	player.freeze = false
	running = true

var game_ended : bool = false
func end_game(end_type : String):
	match end_type:
		"zero": 
			game_ended = true
			sin_label.text = "f(x) = 0"
			draw_wave("zero")
			update_sin_collision()
	audio_controller.explosion.play(0)
	save_top_score()
	$CanvasLayer/SinFunc.label_settings.font_color = Color(1.0, 0.0, 0.0, 1.0)
	$CanvasLayer/Score.visible = false
	$CanvasLayer/TopScore.visible = false
	$CanvasLayer/DistanceTraveled.visible = false
	$CanvasLayer/EndGameScreen/DistanceTraveled.text = "Distance Traveled: " + str(dist_traveled) + "m"
	var i = ""
	if score > top_score: i = " (New High Score)"
	$CanvasLayer/EndGameScreen/Score.text = "Score: " + str(score) + i
	$CanvasLayer/EndGameScreen.visible = true

func save_top_score():
	if score > _SaveLoad.save_contents.top_score:
		_SaveLoad.save_contents.top_score = score
		_SaveLoad._save()

func load_data():
	_SaveLoad._load()
	top_score = _SaveLoad.save_contents.top_score

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_menu.tscn")
