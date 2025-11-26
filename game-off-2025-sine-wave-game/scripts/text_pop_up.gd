extends Node2D
class_name _TextPopUp

var text : String = "smth W3nt Wr0ng"
var color : Color = Color.BLACK
@export var alive_time : float = 1
var alive_timer : float = 0
@export var label : Label


@export var vertical_speed : float = 1
@export var horizontal_speed : float = 1

func _ready() -> void:
	alive_timer = 0
	var lab_set = label.label_settings.duplicate()
	lab_set.font_color = color
	label.text = text
	label.label_settings = lab_set

func _process(delta: float) -> void:
	move_up(delta)
	kill(delta)

func kill(delta) -> void:
	alive_timer += delta
	if alive_timer >= alive_time:
		self.queue_free()

func move_up(delta : float) -> void:
	self.position.y -= delta * vertical_speed
	var rand = randf_range(-1, 1)
	self.position.x += delta * vertical_speed * rand
