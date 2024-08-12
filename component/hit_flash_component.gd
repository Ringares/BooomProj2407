extends Node

@export var sprite:Sprite2D
@export var hit_shader: ShaderMaterial

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.material = hit_shader

func execute():
	if tween !=null and tween.is_valid():
		tween.kill()
		
	(sprite.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
	tween = create_tween()
	tween.tween_property(sprite.material, "shader_parameter/lerp_percent", 0., 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		
