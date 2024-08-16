extends Node
class_name NumberIndicatorComponent

@export var float_text_scene : PackedScene
var float_text


func display(text:String):
	float_text = float_text_scene.instantiate() as Node2D
	var tar_node = get_parent()
	tar_node.get_parent().add_child(float_text)
	float_text.global_position = tar_node.global_position + Vector2.UP * 16
	(float_text as FloatingText).display_floating(text)
	
