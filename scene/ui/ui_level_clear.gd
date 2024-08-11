extends CanvasLayer

@export_file("*.tscn") var main_menu_scene : String
@onready var panel_container = $MarginContainer/PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	#get_tree().paused = true
	panel_container.pivot_offset = panel_container.size / 2
	var tween = create_tween()
	tween.tween_property(panel_container, 'scale', Vector2.ZERO, 0.)
	tween.tween_property(panel_container, 'scale', Vector2.ONE, 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_button_next_pressed():
	get_tree().paused = false
	AutoLoadEvent.signal_level_advance.emit()
	queue_free()


func _on_button_main_menu_pressed():
	get_tree().paused = false
	SceneLoader.load_scene(main_menu_scene)
