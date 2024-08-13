extends Node
class_name TutorialControl

@export var tutorial_data:TutorialList
@export var level_control:LevelControl
@export var totorial_balloon_scene: PackedScene
@export var dialog_resource: DialogueResource

var local_tutorial_data


func _ready():
	local_tutorial_data = tutorial_data.duplicate()
	AutoLoadEvent.signal_step_update.connect(_on_signal_step_update)
	AutoLoadEvent.signal_cell_arraived.connect(_on_signal_cell_arraived)
	DialogueManager.dialogue_ended.connect(_on_dialog_ended)


func show_tutorial(trigger_step, trigger_cell):
	if local_tutorial_data.data.size() > 0:
		var data = local_tutorial_data.data[0] as Tutorial
		var is_trigger = false
		if data.trigger_step == trigger_step:
			is_trigger = true
		elif data.trigger_cell == trigger_cell:
			is_trigger = true
		
		if is_trigger:
			if level_control.tile_rect.has_point(data.highlight_cell):
				var entity = level_control.cell_data[data.highlight_cell.x][data.highlight_cell.y] as Entity
				entity.start_highlight()
			
			if level_control.is_running():
				level_control.switch_running_state()
			DialogueManager.show_dialogue_balloon_scene(totorial_balloon_scene, dialog_resource, data.dialog_name)
			local_tutorial_data.data.pop_front()

func _on_signal_step_update(step:int):
	print('TutorialControl _on_signal_step_update', step)
	show_tutorial(step, null)
	

func _on_signal_cell_arraived(cell:Vector2i):
	print('TutorialControl _on_signal_cell_arraived', cell)
	show_tutorial(null, cell)
		
		
func _on_dialog_ended(_resource: DialogueResource):
	level_control.switch_running_state()
	get_tree().call_group("highlight_entity", "stop_highlight")
	
	
