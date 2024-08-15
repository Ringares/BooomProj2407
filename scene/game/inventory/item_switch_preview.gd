extends ItemPreview
class_name ItemSwitchPreview

@onready var switch_line = $SwitchLine
@onready var start_point = $StartPoint
@onready var end_point = $EndPoint

var line_point_start
var line_point_end


func _process(delta):
	super(delta)
	if line_point_start != null:
		switch_line.clear_points()
		switch_line.add_point(to_local(line_point_start))
		switch_line.add_point(to_local(global_position))
		start_point.global_position = line_point_start
		end_point.global_position = global_position
	
	
	
func _unhandled_input(event):
	if event.is_action_pressed("right_clk"):
		#trans_data['release_global_postion'] = global_position
		AutoLoadEvent.signal_pickitem_cancel.emit(trans_data)
		print('signal emit: signal_pickitem_cancel')
	
	if event.is_action_pressed("left_clk"):
		if line_point_start == null:
			trans_data['switch_start_global_postion'] = global_position
			trans_data['release_global_postion'] = global_position
			trans_data['click_count'] = 1
			trans_data['item_preview'] = self
			AutoLoadEvent.signal_pickitem_drop.emit(trans_data)
			print('signal emit: signal_pickitem_drop by switch 1')
		else:
			line_point_end = global_position
			trans_data['switch_end_global_postion'] = global_position
			trans_data['release_global_postion'] = global_position
			trans_data['click_count'] = 2
			trans_data['item_preview'] = self
			AutoLoadEvent.signal_pickitem_drop.emit(trans_data)
			print('signal emit: signal_pickitem_drop by switch 2')


func stat_point_accept(pos):
	line_point_start = pos
