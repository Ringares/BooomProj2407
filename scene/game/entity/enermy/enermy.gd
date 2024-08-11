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
	pass


func dead():
	is_valid = false
	dead_step = curr_step
	visual.modulate = Color.DIM_GRAY
	
	
func revive():
	is_valid = true
	visual.modulate = Color.WHITE


func _on_signal_step_update(step:int):
	curr_step = step
	if not is_valid and revive_step_gap != -1 and (curr_step - dead_step > revive_step_gap):
		revive()
