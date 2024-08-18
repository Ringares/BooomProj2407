extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().create_timer(5).timeout.connect(func():AutoLoadEvent.signal_level_advance.emit())

