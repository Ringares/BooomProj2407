extends MarginContainer

@export var audio_control_scene : PackedScene
@export var mute_control_scene : PackedScene

func _ready():
	# add_audio_bus_controls
	for bus_iter in AudioServer.bus_count:
		var bus_name : String = AudioServer.get_bus_name(bus_iter)
		var linear : float = AppSettings.get_bus_volume_to_linear(bus_name)
		print(bus_name, linear)
		_add_audio_control(bus_name, linear)
	
	_add_mute_control()


func _add_audio_control(bus_name, bus_value):
	if audio_control_scene == null: #or bus_name in hide_busses:
		return
	var audio_control = audio_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", audio_control)
	if audio_control is OptionControl:
		audio_control.option_section = OptionControl.OptionSections.AUDIO
		audio_control.option_name = bus_name
		audio_control.value = bus_value
		audio_control.connect("setting_changed", _on_bus_changed.bind(bus_name))
		
func _add_mute_control():
	if mute_control_scene == null:
		return
	var mute_control = mute_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", mute_control)
	mute_control.option_section = OptionControl.OptionSections.AUDIO
	mute_control.option_name = "mute"
	mute_control.value = AppSettings.is_muted()
	mute_control.connect("setting_changed", _on_mute_changed)
	

func _on_bus_changed(bus_value : float, bus_name : String):
	AppSettings.set_bus_volume_from_linear(bus_name, bus_value)

func _on_mute_changed(value:bool):
	AppSettings.set_mute(value)
