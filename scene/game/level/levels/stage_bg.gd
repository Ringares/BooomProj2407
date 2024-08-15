extends PanelContainer

@export var contain_tile:TileMap
@onready var stage_placehold = %StagePlacehold

var used_rect:Rect2i

func _ready():
	assert(contain_tile != null, "contain_tile not set")
	contain_tile.ready.connect(_on_contain_node_ready)

func _on_contain_node_ready():
	used_rect = contain_tile.get_used_rect()
	stage_placehold.custom_minimum_size = Vector2(used_rect.size.x * 128 , used_rect.size.y * 110)
	global_position = contain_tile.global_position - Vector2(24,36)
	
