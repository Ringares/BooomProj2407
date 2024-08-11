extends MarginContainer
class_name ItemSlot

@onready var texture_rect = $TextureRect
@onready var count_label = $CountLabel


var iven_item: IvenItem = null
var idx:int

signal signal_mouse_entered
signal signal_mouse_exited


func set_data(data:IvenItem):
	if data == null:
		texture_rect.texture = null
		count_label.text = ""
		iven_item = data
	else:
		texture_rect.texture = data.item_res.texture
		count_label.text = "%d" % data.count
		iven_item = data

func is_empty():
	return iven_item == null

func _on_mouse_entered():
	modulate = Color(1.5,1.5,1.5)
	signal_mouse_entered.emit(self)


func _on_mouse_exited():
	modulate = Color.WHITE
	signal_mouse_exited.emit(self)
