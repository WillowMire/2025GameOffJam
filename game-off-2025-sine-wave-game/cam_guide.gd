extends Node2D
class_name _CamGuide

@export var player : _PlayerObject
@export var cam : Camera2D
@onready var initial_zoom : Vector2 = cam.zoom

func _physics_process(_delta: float) -> void:
	self.position = find_pos()
	cam.zoom = find_zoom()

func find_pos() -> Vector2:
	var v = Vector2(player.global_position.x, player.global_position.y / 2)
	return v

func find_zoom() -> Vector2:
	# get cam cur pos
	# set zoom to reach bottom of wave
	var zoom = cam.zoom
	var rect_y = get_viewport().get_visible_rect().size.y * (1/initial_zoom.y)
	zoom = (initial_zoom) * abs(rect_y /(player.global_position.y + 250 - rect_y))
	
	#sets minumum cam zoom
	if zoom.y > initial_zoom.y:
		zoom = initial_zoom
	
	return zoom
