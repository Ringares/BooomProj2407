extends Entity
class_name FuncTrailItem

@onready var visual = $Visual

var init_direction_info
var direction = Vector2.RIGHT

func _ready():
	if init_direction_info:
		safe_set_direction_info(init_direction_info)

func safe_set_direction_info(direction_info):
	if visual != null:
		set_direction_info(direction_info)
	else:
		init_direction_info = direction_info

func set_direction_info(direction_info):
	var rotattion = direction_info[0]
	var is_flip_v = direction_info[1]
	visual.rotation = rotattion
	if is_flip_v:
		visual.scale = Vector2(visual.scale.x, -visual.scale.y)
		
	direction = Vector2.RIGHT.rotated(visual.rotation)


func set_direction_by_rad(rotation:float):
	visual.rotation = rotation
	direction = Vector2.RIGHT.rotated(visual.rotation)
	
