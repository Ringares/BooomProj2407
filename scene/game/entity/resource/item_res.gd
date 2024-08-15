@tool
extends Resource
class_name ItemRes

@export var entity_type:Constants.ENTITY_TYPE
@export var texture:AtlasTexture
@export var block_scene:PackedScene
@export var energy_cost:int = 1
@export var tile_cell:Vector2i:
	set(value):
		if tile_cell != value:
			tile_cell = value
			get_tile_cell()


func get_tile_cell():
	tile_cell = Vector2i(texture.region.position.x / texture.region.size.x, texture.region.position.y / texture.region.size.y)
