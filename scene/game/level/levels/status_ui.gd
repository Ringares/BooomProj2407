extends Control

@onready var hp_label = %HPLabel
@onready var str_label = %STRLabel
@onready var energy_label = %EnergyLabel
@onready var step_label = %StepLabel
@onready var status_label = %StatusLabel



# Called when the node enters the scene tree for the first time.
func _ready():
	AutoLoadEvent.signal_step_update.connect(_on_signal_step_update)
	AutoLoadEvent.signal_hp_update.connect(_on_signal_hp_update)
	AutoLoadEvent.signal_str_update.connect(_on_signal_str_update)
	AutoLoadEvent.signal_energy_update.connect(_on_signal_energy_update)
	AutoLoadEvent.signal_inventory_capacity_increase.connect(_on_signal_inventory_capacity_temp_update)
	
	AutoLoadEvent.signal_level_timer_stopped.connect(_on_signal_level_timer_stopped)


func _on_signal_step_update(data):
	step_label.text = str(data)

func _on_signal_hp_update(data1, data2):
	hp_label.text = "%d / %d" % [data1, data2]

func _on_signal_str_update(data1, data2):
	str_label.text = "%d / %d" % [data1, data2]

func _on_signal_energy_update(data1, data2):
	energy_label.text = "%d / %d" % [data1, data2]

func _on_signal_inventory_capacity_temp_update(data1, data2):
	pass

func _on_signal_level_timer_stopped(is_stoped:bool):
	if is_stoped:
		status_label.text = 'PAUSED'
	else:
		status_label.text = 'RUNNING'
