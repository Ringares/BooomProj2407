extends MarginContainer
class_name ItemSlot

@onready var texture_rect = $TextureRect
@onready var count_label = $CountLabel
@onready var animation_player = $AnimationPlayer


const POINTER_TOON = preload("res://asset/image/pointer_toon_a.png")
const HAND_CLOSED = preload("res://asset/image/hand_closed.png")
const HAND_OPEN = preload("res://asset/image/hand_open.png")

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
		if data.count > 1:
			count_label.text = "%d" % data.count
		else:
			count_label.text = ''
		iven_item = data

func is_empty():
	return iven_item == null

func play_invalid_anim():
	animation_player.stop()
	animation_player.play("invalid")

func _on_mouse_entered():
	#modulate = Color(1.5,1.5,1.5)
	modulate = Color('#bdcae2')
	signal_mouse_entered.emit(self)
	
	if get_tree().get_first_node_in_group("item_preview") == null:
		Input.set_custom_mouse_cursor(HAND_OPEN)
	


func _on_mouse_exited():
	modulate = Color.WHITE
	signal_mouse_exited.emit(self)

	if get_tree().get_first_node_in_group("item_preview") == null:
		Input.set_custom_mouse_cursor(POINTER_TOON)
