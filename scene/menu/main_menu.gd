class_name MainMenu
extends Control

const NO_VERSION_NAME : String = "0.0.0"

@export_file("*.tscn") var game_scene_path : String
@export var option_packed_scene: PackedScene

var game_scene
var option_scene
var sub_menu
var curr_container

@onready var continue_button = %ContinueButton
@onready var new_game_button = %NewGameButton

@onready var option_button = %OptionButton
@onready var exit_button = %ExitButton
@onready var version_label = %VersionLabel

func _ready():
	# set availabel buttons
	if OS.has_feature("web"): exit_button.hide()
	if not game_scene_path: new_game_button.hide()
	if not option_packed_scene:
		option_button.hide()
	else:
		option_scene = option_packed_scene.instantiate()
		%OptionVbox.call_deferred("add_child", option_scene)
		%OptionVbox.call_deferred("move_child", option_scene, 1)
		
	curr_container = %MenuContainer
	%OptionContainer.hide()
	if GameLevelLog.get_current_level() > 0:
		continue_button.show()
	else:
		continue_button.hide()
		
	

	# set version name
	var version_name : String = ProjectSettings.get_setting("application/config/version", NO_VERSION_NAME)
	if version_name.is_empty():
		version_name = NO_VERSION_NAME
	#AppLog.version_opened(version_name)
	version_label.text = 'v ' + version_name
	
	
func _open_sub_menu():
	curr_container.show()
	%MenuContainer.hide()
	

func _close_sub_menu():
	curr_container.hide()
	curr_container = %MenuContainer
	%MenuContainer.show()
	


func _on_continue_button_pressed():
	SceneLoader.load_scene(game_scene_path)


func _on_option_button_pressed():
	curr_container = %OptionContainer
	_open_sub_menu()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	_close_sub_menu()


func _on_new_game_button_pressed():
	GameLevelLog.reset_game_data()
	SceneLoader.load_scene(game_scene_path)


