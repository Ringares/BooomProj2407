extends CanvasLayer

const CG_DIALOGUE = preload("res://scene/dialogue/cg_dialogue.dialogue")

const CG_1 = preload("res://asset/image/cg/cg1.png")
const CG_2 = preload("res://asset/image/cg/cg2.png")
const CG_3 = preload("res://asset/image/cg/cg3.png")

var cg_sequence = [
	['cg1',CG_1],
	['cg2',CG_2],
	['cg3',CG_3],
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
