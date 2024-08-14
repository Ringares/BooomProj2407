extends Control
class_name ResourceBar

@onready var progress_bar = %ProgressBar
@onready var grid_draw_node:GridDrawNode = %GridDrawNode
@export var resource_color:Color = Color('#5ac3e9')

func _ready():
	AutoLoadEvent.signal_energy_update.connect(_on_signal_energy_update)


func _on_signal_energy_update(curr_count, max_count):
	progress_bar.max_value = max_count
	progress_bar.value = curr_count
	grid_draw_node.set_slot_count(max_count)
