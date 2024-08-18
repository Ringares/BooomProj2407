extends Entity
class_name FuncChestItem


@onready var visual = $Visual
@onready var contain_item = $Visual/ContainItem
@onready var label = $Visual/ContainItem/Label
@onready var countdown_label = %CountdownLabel
@onready var dead_body = %DeadBody

var contain_type: Constants.ENTITY_TYPE
var contain_count: int = 1

signal signal_chest_pickup

var revive_step_gap = -1
var is_valid:bool = true
var curr_step:int = 0
var dead_step:int = 0


func set_contained(_data:ChestData):
	contain_type = _data.contain_type
	contain_count = _data.contain_count
	var item_res = ResourceLoader.load(Constants.EntityMap[contain_type]) as ItemRes
	await ready
	contain_item.texture = item_res.texture
	if contain_count == 1:
		label.hide()
	else:
		label.show()
		label.text = str(contain_count)
	
	if _data.revive_step_gap > 0:
		revive_step_gap = _data.revive_step_gap
		AutoLoadEvent.signal_step_update.connect(_on_signal_step_update)


func on_used():
	if revive_step_gap != -1:
		is_valid = false
		dead_step = curr_step
		
		dead_body.show()
		countdown_label.show()
		sprite_2d.hide()
		contain_item.hide()
		_on_signal_step_update(curr_step)
	else:
		queue_free()
	
	
func revive():
	is_valid = true
	#visual.modulate = Color.WHITE
	#visual.show()
	SfxManager.play_revive()
	start_teleport_in()
	
	dead_body.hide()
	countdown_label.hide()
	sprite_2d.show()
	await get_tree().create_timer(1).timeout
	contain_item.show()
	

func _on_signal_step_update(step:int):
	curr_step = step
	if not is_valid and revive_step_gap != -1:
		var remaining_countdown = revive_step_gap - (curr_step - dead_step)
		print('remaining_countdown', remaining_countdown)
		if (curr_step - dead_step > revive_step_gap):
			revive()
		else:
			countdown_label.text = str(remaining_countdown+1)
			countdown_label.show()
	
