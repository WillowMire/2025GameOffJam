extends Node2D
class_name _CamGuide

@export var game_node : _ArcadeMain
@export var player : _PlayerObject
@export var cam : Camera2D
@export var min_zoom : Vector2
@onready var initial_zoom : Vector2 = cam.zoom

func _physics_process(_delta: float) -> void:
	if game_node.game_ended: return
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
	if zoom.y > min_zoom.y:
		zoom = min_zoom
	
	return zoom
