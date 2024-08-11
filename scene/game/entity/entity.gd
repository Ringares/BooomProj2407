extends Node
class_name Entity

signal signal_entity_used

var cell_id = Vector2i(-1,-1)
@export var type:Constants.ENTITY_TYPE = Constants.ENTITY_TYPE.UNKNOW

func on_used():
	queue_free()
