extends Node
class_name GridMoveComponent

@export var grid_size = 128
@export var actor:Node2D
@export var move_dutation = 0.3
@export var direction = Vector2.RIGHT

#func move_forward(new_direction):
	#if new_direction != null:
		#assert(new_direction is Vector2)
		#direction = new_direction
		#
	#actor.global_position += direction * grid_size
	#await get_tree().create_timer(move_dutation).timeout
	#
#
#func move_to(tar_glo_pos:Vector2):
	#print('move_to', actor.global_position, tar_glo_pos)
	#actor.global_position = tar_glo_pos
	#await get_tree().create_timer(move_dutation).timeout
	
