extends Node
class_name UISound

@export var root_path:NodePath

@onready var sfxs = {
	&"ui_hover": AudioStreamPlayer.new(),
	&"ui_click": AudioStreamPlayer.new(),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(root_path != null, "Empty root path for UISound")
	
	for i in sfxs.keys():
		sfxs[i].stream = load("res://asset/audio/ui_audio/" + str(i) + ".ogg")
		sfxs[i].bus = &"UI"
		add_child(sfxs[i])
	
	install_sounds(get_node(root_path))


func install_sounds(node:Node):
	for i in node.get_children():
		if i is Button:
			i.mouse_entered.connect(func(): ui_sfx_play(&"ui_hover"))
			i.pressed.connect(func(): ui_sfx_play(&"ui_click"))
		
		
		install_sounds(i)

func ui_sfx_play(sfxs_name:StringName):
	sfxs[sfxs_name].play()
	
