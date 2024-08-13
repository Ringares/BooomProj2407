extends Resource
class_name Tutorial

@export var dialog_name:String
@export_enum("none", "boy", "cat", "ai") var portrait = "none"
@export var trigger_step:int = -1
@export var trigger_cell:Vector2i = Vector2i(-1,-1)
@export var highlight_item:Constants.ENTITY_TYPE = Constants.ENTITY_TYPE.UNKNOW
@export var highlight_cell:Vector2i = Vector2i(-1,-1)
