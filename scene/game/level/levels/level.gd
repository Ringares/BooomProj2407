extends Node

signal level_won
signal level_lost
signal level_reset


@onready var level_control = %LevelControl

func _ready():
	SfxManager.reset()
	AutoLoadEvent.signal_level_won.connect(_on_signal_level_won)
	#AutoLoadEvent.signal_level_fail.connect(_on_signal_level_fail)


func _on_signal_level_won():
	level_control._on_save()
	

func _on_win_button_pressed():
	AutoLoadEvent.signal_level_won.emit()


func _on_lose_button_pressed():
	AutoLoadEvent.signal_level_fail.emit()


func _on_reset_button_pressed():
	AutoLoadEvent.signal_level_reset.emit()
