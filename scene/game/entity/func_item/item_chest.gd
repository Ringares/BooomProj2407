extends Entity
class_name FuncChestItem


@onready var visual = $Visual
@onready var contain_item = $Visual/ContainItem
@onready var label = $Visual/ContainItem/Label

var contain_type: Constants.ENTITY_TYPE
var contain_count: int = 1

signal signal_chest_pickup

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
	
