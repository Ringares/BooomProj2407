@tool
extends SceneLister

signal level_load_started
signal level_loaded
signal levels_finished

## Container where the level instance will be added.
@export var level_container : SubViewport
## Loads a level on start.
@export var auto_load : bool = true

@export_group("Debugging")
@export var test_level : PackedScene

var current_level : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if auto_load:
		load_level()


func load_level(level_id : int = get_current_level_id()):
	_clear_current_level()
	var level_file = get_level_file(level_id) if level_id != -1 else test_level.resource_path
	SceneLoader.load_scene(level_file, true)
	emit_signal("level_load_started")
	await(SceneLoader.scene_loaded)
	current_level = _attach_level(SceneLoader.get_resource())
	emit_signal("level_loaded")


func _attach_level(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance


func _clear_current_level():
	if is_instance_valid(current_level):
		current_level.queue_free()
	current_level = null
	

func get_current_level_id() -> int:
	return GameLevelLog.get_current_level() if test_level == null else -1


func get_level_file(level_id : int = get_current_level_id()):
	if files.is_empty():
		push_error("files is empty")
		return
	if level_id >= files.size():
		push_error("level_id is greater than files size")
		return
	return files[level_id]


func advance_level() -> bool:
	var level_id : int = get_current_level_id()
	level_id += 1
	if level_id >= files.size():
		emit_signal("levels_finished")
		level_id = files.size() - 1
		return false
	GameLevelLog.level_reached(level_id)
	return true
	
func advance_and_load_level():
	if advance_level():
		load_level()
