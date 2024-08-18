extends Node2D
class_name GridIndicatorComponent

@export var tile:TileMap
@export var indicator_scene:PackedScene
@export var valid_modulate:Color = Color("#32a6316a")
@export var invalid_modulate:Color = Color("#cd5c5c60")
@export var disable_modulate:Color = Color("#181a2760")

var used_rect:Rect2i
var tile_size:Vector2i

enum VALID_STATE{
	INVALID=0,
	VALID=1,
	NORM=2,
	DISABLE=3
}

var state_color = {
	VALID_STATE.VALID:valid_modulate,
	VALID_STATE.INVALID:invalid_modulate,
	VALID_STATE.NORM:Color.TRANSPARENT,
	VALID_STATE.DISABLE:disable_modulate,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	used_rect = tile.get_used_rect()
	tile_size = tile.tile_set.tile_size
	
	AutoLoadEvent.signal_gird_indicaotr_show.connect(on_signal_gird_indicaotr_show)
	AutoLoadEvent.signal_gird_indicaotr_dismiss.connect(on_signal_gird_indicaotr_dismiss)
	


func on_signal_gird_indicaotr_show(cells:Array, state:VALID_STATE):
	hide()
	get_tree().call_group("grid_indicators", "queue_free")
	
	for cell in cells:
		var node = indicator_scene.instantiate() as Node2D
		node.add_to_group("grid_indicators")
		add_child(node)
		node.global_position = tile.to_global(tile.map_to_local(cell))
		node.modulate = state_color[state]
	show()
	

func on_signal_gird_indicaotr_dismiss():
	hide()
	
