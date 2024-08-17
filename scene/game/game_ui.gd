extends Control
@onready var level_loader = $LevelLoader

const UI_DEFEATED = preload("res://scene/ui/ui_defeated.tscn")
const UI_LEVEL_CLEAR = preload("res://scene/ui/ui_level_clear.tscn")
@export_file("*.tscn") var main_menu_scene : String

# Called when the node enters the scene tree for the first time.
func _ready():
	GameLog.game_started()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_level_loader_level_load_started():
	pass # Replace with function body.


func _on_level_loader_level_loaded():
	await level_loader.current_level.ready
	#if level_loader.current_level.has_signal("level_won"):
		#level_loader.current_level.level_won.connect(_on_level_won)
	#if level_loader.current_level.has_signal("level_lost"):
		#level_loader.current_level.level_lost.connect(_on_level_lost)
	#if level_loader.current_level.has_signal("level_reset"):
		#level_loader.current_level.level_reset.connect(_on_level_reset)
		
	if not AutoLoadEvent.signal_level_won.is_connected(_on_level_won):
		AutoLoadEvent.signal_level_won.connect(_on_level_won, CONNECT_ONE_SHOT)
	if not AutoLoadEvent.signal_level_advance.is_connected(_on_level_advance):
		AutoLoadEvent.signal_level_advance.connect(_on_level_advance, CONNECT_ONE_SHOT)
	if not AutoLoadEvent.signal_level_fail.is_connected(_on_level_lost):
		AutoLoadEvent.signal_level_fail.connect(_on_level_lost, CONNECT_ONE_SHOT)
	if not AutoLoadEvent.signal_level_reset.is_connected(_on_level_reset):
		AutoLoadEvent.signal_level_reset.connect(_on_level_reset, CONNECT_ONE_SHOT)


func _on_level_loader_levels_finished():
	await get_tree().create_timer(0.5).timeout
	print('game_ui _on_level_loader_levels_finished')
	SceneLoader.load_scene(main_menu_scene)
	

func _on_level_lost():
	print('game_ui _on_level_lost')
	await get_tree().create_timer(0.5).timeout
	InGameMenuController.open_menu(UI_DEFEATED, get_viewport())


func _on_level_won():
	print('game_ui _on_level_won')
	await get_tree().create_timer(0.5).timeout
	InGameMenuController.open_menu(UI_LEVEL_CLEAR, get_viewport())
	
	
func _on_level_advance():
	print('game_ui _on_level_advance')
	level_loader.advance_and_load_level()
	
	
func _on_level_reset():
	print('game_ui _on_level_reset')
	level_loader.load_level()
