extends Node2D
class_name _ArcadeMain

@export var DEBUG : bool
@export var player : RigidBody2D

# GOAL
# make sine wave controllable
# make sin wave follow player

var sin_collision : CollisionShape2D
var seg : SegmentShape2D

var sin_x_bounding_range : float

@export var line : Line2D
@export var vect_array : Array[Vector2]
@export var a_var : float
@export var b_var : float
@export var c_var : float
@export var d_var : float
@export var control_speed : float

func _ready() -> void:
	set_wave_x_range()
	if DEBUG:
		$DEBUG.visible = true
		$DEBUG/A_Edit.text = str(a_var)
		$DEBUG/B_Edit.text = str(b_var)
		$DEBUG/C_Edit.text = str(c_var)
		$DEBUG/D_Edit.text = str(d_var)
	draw_wave()
	start_sin_collision()

#might change to _physics_process if theres a problem
func _physics_process(delta: float) -> void:
	set_wave_x_range()
	move_wave_data(delta)
	draw_wave()
	update_sin_collision() #this may cause problems later, if so try making this and the draw function into lerps

func set_wave_x_range():
	pass #var player.get_transform().x

var sin_collision_array : Array[CollisionShape2D]
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

func move_wave_data(delta : float) -> void:
	if Input.is_action_pressed("up"):
		d_var -= delta * control_speed
	if Input.is_action_pressed("down"):
		d_var += delta * control_speed
	if Input.is_action_pressed("left"):
		c_var += delta * control_speed
	if Input.is_action_pressed("right"):
		c_var -= delta * control_speed

func draw_wave() -> void: 
	var j = player.position.x
	vect_array.clear()
	for x in range(j - 500, j + 501, 20):
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
