extends Node
class_name Entity

signal signal_entity_used
const HIGHTLIGHT_SHADER = preload("res://shader/hightlight.gdshader")

@onready var sprite_2d:Sprite2D = %Sprite2D

var cell_id = Vector2i(-1,-1)
@export var type:Constants.ENTITY_TYPE = Constants.ENTITY_TYPE.UNKNOW
var tween: Tween

const HIT_FLASH_SHADER = preload("res://shader/hit_flash.gdshader")
const TELEPORT_SHADER = preload("res://shader/teleport.gdshader")



func on_used():
	queue_free()
	

func on_recycled():
	start_teleport_out()
	get_tree().create_timer(0.3).timeout.connect(func():queue_free())
	
	

func start_highlight(last_sec:float=-1):
	await ready
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
	tween.tween_property(sprite_2d, "position", Vector2(0,-16), 0.25)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite_2d, "position", Vector2(0,0), 0.5)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	add_to_group('highlight_entity')
	
	if last_sec > 0:
		get_tree().create_timer(last_sec).timeout.connect(stop_highlight)


func stop_highlight():
	sprite_2d.material.set_shader_parameter("frequency", 0.0)
	
	if tween !=null and tween.is_valid():
		tween.kill()
	sprite_2d.position = Vector2(0,0)
	remove_from_group('highlight_entity')
	

func play_hit_flash(falsh_color = Vector3(1.0, 1.0, 1.0)):
	if sprite_2d.material == null:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.resource_local_to_scene = true
	
	sprite_2d.material.shader = HIT_FLASH_SHADER
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("flash_color", falsh_color)
	
	tween = create_tween()
	tween.tween_property(sprite_2d.material, "shader_parameter/lerp_percent", 0., 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	

func start_teleport_in():
	if sprite_2d.material == null:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.resource_local_to_scene = true
	
	sprite_2d.material.shader = TELEPORT_SHADER
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("progress", 0.3)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("color", Vector4(0.0, 1.02, 1.5, 1.0))
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("beam_size", 0.1)
	# vec4(0.0, 1.02, 1.2, 1.0)
	tween = create_tween()
	tween.tween_property(sprite_2d.material, "shader_parameter/progress", 0., 2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		



func start_teleport_out():
	if sprite_2d.material == null:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.resource_local_to_scene = true
	
	sprite_2d.material.shader = TELEPORT_SHADER
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("progress", 0.)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("color", Vector4(1.5, 0.4, 0.4, 1.0))
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("beam_size", 0.1)
	# vec4(0.0, 1.02, 1.2, 1.0)
	tween = create_tween()
	tween.tween_property(sprite_2d.material, "shader_parameter/progress", 0.3, 2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func move_to_pos(to_position:Vector2, need_anim:bool):
	if not need_anim:
		self.position = to_position
		return
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	var duration = 0.3
	if self.position.x == to_position.x:
		tween.tween_property(self, "position", to_position, duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(sprite_2d, 'scale', Vector2(1.0,1.1), duration/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.chain().tween_property(sprite_2d, 'scale', Vector2(1.0,1.0), duration/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	else:
		tween.tween_property(self, "position", to_position, duration)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(sprite_2d, 'scale', Vector2(1.1,1.0), duration/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.chain().tween_property(sprite_2d, 'scale', Vector2(1.0,1.0), duration/2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			
	
	await tween.finished
