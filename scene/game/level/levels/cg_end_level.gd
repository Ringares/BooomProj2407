extends CanvasLayer

const CG_DIALOGUE = preload("res://scene/dialogue/cg_dialogue.dialogue")
const CG_4 = preload("res://asset/image/cg/cg4.png")

var cg_sequence = [
	['cg4',CG_4],
]


@onready var texture_rect = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialog_ended)
	
	var cg_data = cg_sequence.pop_front()
	texture_rect.texture = cg_data[1]
	
	DialogueManager.show_dialogue_balloon(
		CG_DIALOGUE,
		cg_data[0],
	)

func _on_dialog_ended(_resource: DialogueResource):
	if cg_sequence.is_empty():
		AutoLoadEvent.signal_level_advance.emit()
		return
	
	var cg_data = cg_sequence.pop_front()
	texture_rect.texture = cg_data[1]
	
	DialogueManager.show_dialogue_balloon(
		CG_DIALOGUE,
		cg_data[0],
	)
