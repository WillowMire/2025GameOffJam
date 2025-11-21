extends Node

const save_path = "user://save_dat.json"

#IF YOU CHANGE ANYTHING HERE ALSO CHANGE IT IN _LOAD() FUNC
var save_contents: Dictionary = {
	"top_score": 0
}

func _ready() -> void:
	_load()

func _save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(save_contents.duplicate())
	file.close()

func _load():
	if !FileAccess.file_exists(save_path): return
	var file = FileAccess.open(save_path, FileAccess.READ)
	var data = file.get_var()
	file.close()
	
	var save_data = data.duplicate()
	save_contents.top_score = save_data.top_score
