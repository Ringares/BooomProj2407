extends MarginContainer

@export var audio_control_scene : PackedScene
@onready var mute_control = %MuteControl
@onready var full_screen_control = %FullScreenControl

const bus_name_lang = {
	'Master': '整体音量',
	'Music': '音乐音量',
	'SFX': '音效音量'
}

func _ready():
	# add_audio_bus_controls
	for bus_iter in AudioServer.bus_count:
		var bus_name : String = AudioServer.get_bus_name(bus_iter)
		var linear : float = AppSettings.get_bus_volume_to_linear(bus_name)
		print(bus_name, linear)
		if bus_name != 'UI':
			_add_audio_control(bus_name, linear)
	


func _add_audio_control(bus_name, bus_value):
	if audio_control_scene == null: #or bus_name in hide_busses:
		return
	var audio_control = audio_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", audio_control)
	if audio_control is OptionControl:
		audio_control.option_section = OptionControl.OptionSections.AUDIO
		audio_control.option_name = bus_name_lang.get(bus_name, bus_name)
		audio_control.value = bus_value
		audio_control.connect("setting_changed", _on_bus_changed.bind(bus_name))
		

func _on_bus_changed(bus_value : float, bus_name : String):
	AppSettings.set_bus_volume_from_linear(bus_name, bus_value)


func _on_mute_control_setting_changed(value):
	AppSettings.set_mute(value)


func _on_full_screen_control_setting_changed(value):
	AppSettings.set_fullscreen_enabled(value, get_window())
