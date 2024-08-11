extends Node2D
class_name ItemPreview


var inven_item:IvenItem
var origin_slot_idx:int
@onready var sprite_2d = $Sprite2D

var trans_data = {}


func set_data(_inven_item:IvenItem, _origin_slot_idx:int):
	inven_item = _inven_item
	origin_slot_idx = _origin_slot_idx
	trans_data['item_res'] = inven_item.item_res
	trans_data['origin_slot_idx'] = origin_slot_idx
	
	
func _ready():
	if inven_item:
		sprite_2d.texture = inven_item.item_res.texture


func _enter_tree():
	Engine.time_scale = 0.5


func _exit_tree():
	Engine.time_scale = 1.0


func _process(delta):
	global_position = get_global_mouse_position()
	

func _unhandled_input(event):
	if event.is_action_pressed("right_clk"):
		#trans_data['release_global_postion'] = global_position
		AutoLoadEvent.signal_pickitem_cancel.emit(trans_data)
		print('signal emit: signal_pickitem_cancel')
		queue_free()
	
	if event.is_action_pressed("left_clk"):
		trans_data['release_global_postion'] = global_position
		trans_data['item_preview'] = self
		AutoLoadEvent.signal_pickitem_drop.emit(trans_data)
		print('signal emit: signal_pickitem_drop')

