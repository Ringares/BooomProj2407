extends Node
class_name Entity

signal signal_entity_used
const HIGHTLIGHT_SHADER = preload("res://shader/hightlight.gdshader")

@onready var sprite_2d:Sprite2D = %Sprite2D
var cell_id = Vector2i(-1,-1)
@export var type:Constants.ENTITY_TYPE = Constants.ENTITY_TYPE.UNKNOW
var tween: Tween


func on_used():
	queue_free()


func start_highlight():
	if sprite_2d.material == null:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.resource_local_to_scene = true
	
	sprite_2d.material.shader = HIGHTLIGHT_SHADER
	sprite_2d.material.set_shader_parameter("frequency", 8.0)
	sprite_2d.material.set_shader_parameter("highlight_speed", 0.5)
	sprite_2d.material.set_shader_parameter("highlight_width", 4.0)
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite_2d, "position", Vector2(0,-8), 0.25)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite_2d, "position", Vector2(0,0), 0.5)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	add_to_group('highlight_entity')


func stop_highlight():
	sprite_2d.material.set_shader_parameter("frequency", 0.0)
	
	if tween !=null and tween.is_valid():
		tween.kill()
		
	remove_from_group('highlight_entity')
	

	
