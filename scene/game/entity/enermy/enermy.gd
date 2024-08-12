extends Entity
class_name Enermy

@export var loot_energy = 0

@onready var attack_component:AttackComponent = $AttackComponent
@onready var health_component:HealthComponent = $HealthComponent
@onready var visual = $Visual
@export var revive_step_gap:int = -1
var is_valid:bool = true
var curr_step:int = 0
var dead_step:int = 0
@onready var hp_label = %HPLabel
@onready var atk_label = %AtkLabel

const HIT_FLASH_SHADER = preload("res://shader/hit_flash.gdshader")
const TELEPORT_SHADER = preload("res://shader/teleport.gdshader")

func _ready():
	AutoLoadEvent.signal_step_update.connect(_on_signal_step_update)
	call_deferred("update_ui")


func update_ui():
	if hp_label:
		hp_label.text = "HP: %d" % health_component.curr_hp
	if atk_label:
		atk_label.text = "ATK: %d" % attack_component.get_attack_damage()


func play_hit_anim():
	# TODO anim
	start_flash()


func dead():
	is_valid = false
	dead_step = curr_step
	#visual.hide()
	#visual.modulate = Color.DIM_GRAY
	start_teleport_out()
	
	
func revive():
	is_valid = true
	#visual.modulate = Color.WHITE
	#visual.show()
	start_teleport_in()



func start_flash():
	if sprite_2d.material == null:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.resource_local_to_scene = true
	
	sprite_2d.material.shader = HIT_FLASH_SHADER
	
	if tween !=null and tween.is_valid():
		tween.kill()
	
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
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
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("beam_size", 0.01)
	# vec4(0.0, 1.02, 1.2, 1.0)
	tween = create_tween()
	tween.tween_property(sprite_2d.material, "shader_parameter/progress", 0.3, 2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	


func _on_signal_step_update(step:int):
	curr_step = step
	if not is_valid and revive_step_gap != -1 and (curr_step - dead_step > revive_step_gap):
		revive()
