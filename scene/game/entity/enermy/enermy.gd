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
@onready var status_label = %StatusLabel
@onready var countdown_label
@onready var dead_body



func _ready():
	AutoLoadEvent.signal_step_update.connect(_on_signal_step_update)
	dead_body = find_child("DeadBody")
	countdown_label = find_child("CountdownLabel")
	call_deferred("update_ui")


func update_ui():
	if hp_label:
		hp_label.text = "%d" % health_component.curr_hp
	if atk_label:
		atk_label.text = "%d" % attack_component.get_attack_damage()


func play_hit_anim():
	# play_hit_flash()
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
	tween.parallel().tween_method(shake_sprite, 0,5,0.3)
	update_ui()
	

func shake_sprite(shake_count):
	var shake = 2
	sprite_2d.position += Vector2(randf_range(-shake, shake),randf_range(-shake, shake))
	

func dead():
	await get_tree().create_timer(0.3).timeout
	is_valid = false
	dead_step = curr_step
	#visual.hide()
	#visual.modulate = Color.DIM_GRAY
	status_label.hide()
	sprite_2d.hide()
	if is_instance_valid(dead_body): dead_body.show()
	start_teleport_out()
	_on_signal_step_update(curr_step)
	
	
func revive():
	is_valid = true
	#visual.modulate = Color.WHITE
	#visual.show()
	SfxManager.play_revive()
	start_teleport_in()
	health_component.reset_hp()
	sprite_2d.position = Vector2.ZERO
	sprite_2d.show()
	update_ui()
	if is_instance_valid(dead_body): dead_body.hide()
	if is_instance_valid(dead_body): countdown_label.hide()
	get_tree().create_timer(0.3).timeout.connect(func():status_label.show())
	

func _on_signal_step_update(step:int):
	curr_step = step
	if not is_valid and revive_step_gap != -1:
		var remaining_countdown = revive_step_gap - (curr_step - dead_step)
		print('remaining_countdown', remaining_countdown)
		if (curr_step - dead_step > revive_step_gap):
			revive()
		else:
			countdown_label.text = str(remaining_countdown+1)
			countdown_label.show()
		
