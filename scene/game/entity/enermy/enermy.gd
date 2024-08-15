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
@onready var dead_body = %DeadBody



func _ready():
	AutoLoadEvent.signal_step_update.connect(_on_signal_step_update)
	call_deferred("update_ui")


func update_ui():
	if hp_label:
		hp_label.text = "%d" % health_component.curr_hp
	if atk_label:
		atk_label.text = "%d" % attack_component.get_attack_damage()


func play_hit_anim():
	# TODO anim
	start_flash()
	update_ui()


func dead():
	is_valid = false
	dead_step = curr_step
	#visual.hide()
	#visual.modulate = Color.DIM_GRAY
	status_label.hide()
	if is_instance_valid(dead_body): dead_body.show()
	start_teleport_out()
	
	
func revive():
	is_valid = true
	#visual.modulate = Color.WHITE
	#visual.show()
	SfxManager.play_revive()
	start_teleport_in()
	health_component.reset_hp()
	update_ui()
	if is_instance_valid(dead_body): dead_body.hide()
	get_tree().create_timer(0.3).timeout.connect(func():status_label.show())
	

func _on_signal_step_update(step:int):
	curr_step = step
	if not is_valid and revive_step_gap != -1 and (curr_step - dead_step > revive_step_gap):
		revive()
