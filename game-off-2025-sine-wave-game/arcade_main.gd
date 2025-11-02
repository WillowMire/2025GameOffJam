extends Node2D
class_name _ArcadeMain

@export var DEBUG : bool

# GOAL
# Make a line that conforms to aSin(b(x+c))+d

@export var line : Line2D
@export var vect_array : Array[Vector2]
@export var a_var : float
@export var b_var : float
@export var c_var : float
@export var d_var : float

func _ready() -> void:
	if DEBUG:
		$DEBUG.visible = true
		$DEBUG/A_Edit.text = str(a_var)
		$DEBUG/B_Edit.text = str(b_var)
		$DEBUG/C_Edit.text = str(c_var)
		$DEBUG/D_Edit.text = str(d_var)
	draw_wave()

func draw_wave() -> void: 
	vect_array.clear()
	for x in range(0, 1001, 20):
		var i = Vector2(x, sin_func_math(x, a_var, b_var, c_var, d_var) + 300)
		vect_array.append(i)
	line.set_points(vect_array)

func sin_func_math(x : float, a : float, b : float, c : float, d : float) -> float:
	# aSin(b(x+c))+d
	var y
	y = a * -sin(b * (x + c)) + d
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
