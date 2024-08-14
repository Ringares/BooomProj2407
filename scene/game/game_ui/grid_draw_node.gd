extends Sprite2D
class_name GridDrawNode

@onready var progress_bar = %ProgressBar
@export var slot_count = 4

@export var width = 340
@export var height = 40


func set_slot_count(count:int):
	slot_count = count
	queue_redraw()


func _draw():
	if slot_count > 1:
		for i in slot_count-1:
			print(i)
			# 340,40
			var start_point = Vector2((i+1)* width / slot_count, 0)
			
			draw_line(start_point, start_point + Vector2(0,height), Color("#3d5070"), 6.0)
			
