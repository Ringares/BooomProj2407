extends ItemPreview
class_name ItemRotatePreview


func set_data(_inven_item:IvenItem, _origin_slot_idx:int):
	super(_inven_item, _origin_slot_idx)
	trans_data['rotation'] = 0

func _input(event):
	if event.is_action_pressed("rotate_preview"):
		(sprite_2d as Sprite2D).rotation_degrees += 90
		trans_data['rotation'] = sprite_2d.rotation
		
