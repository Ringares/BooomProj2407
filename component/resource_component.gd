extends Node
class_name ResourceComponent


@export var curr_count:int = 1
@export var max_count:int = 1

signal signal_curr_hp_changed

func init_data(_curr_count:int, _max_count:int):
	curr_count = _curr_count
	max_count = _max_count
	AutoLoadEvent.signal_energy_update.emit(curr_count, max_count)
	print('init ResourceComponent: curr_count=%d, max_count=%d' % [curr_count, max_count])
	
	
func add_resource(points:int):
	curr_count = clamp(curr_count+points,0,max_count)
	AutoLoadEvent.signal_energy_update.emit(curr_count, max_count)
	print('add_resource: curr_count=%d, max_count=%d' % [curr_count, max_count])


func consume_resource(points:int):
	curr_count = clamp(curr_count-points,0,max_count)
	AutoLoadEvent.signal_energy_update.emit(curr_count, max_count)
	print('consume_resource: curr_count=%d, max_count=%d' % [curr_count, max_count])


func increase_resource_capacity(points:int):
	max_count+=points
	AutoLoadEvent.signal_energy_update.emit(curr_count, max_count)
	print('increase_resource_capacity: curr_count=%d, max_count=%d' % [curr_count, max_count])
	

func has_enough(points:int):
	return curr_count >= points
