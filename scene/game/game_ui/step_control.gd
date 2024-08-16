extends Control

@onready var pause_button = %PauseButton
@onready var run_button = %RunButton

enum STATE{
	PAUSE,
	RUN
}

@export var curr_state:STATE = STATE.PAUSE:
	set(value):
		if value!=curr_state:
			curr_state = value
			if value == STATE.PAUSE:
				pause_button.hide()
				run_button.show()
			elif value == STATE.RUN:
				pause_button.show()
				run_button.hide()
				

# Called when the node enters the scene tree for the first time.
func _ready():
	AutoLoadEvent.signal_level_run_state_changed.connect(_on_signal_level_run_state_changed)
	

func _on_signal_level_run_state_changed(is_running:bool):
	print('StepControl _on_signal_level_run_state_changed ', is_running)
	curr_state = STATE.RUN if is_running else STATE.PAUSE


func _on_pause_button_pressed():
	AutoLoadEvent.signal_change_level_run_state.emit(false)
	GameLevelLog.set_player_autorun_enable(false)


func _on_run_button_pressed():
	AutoLoadEvent.signal_change_level_run_state.emit(true)
	GameLevelLog.set_player_autorun_enable(true)
