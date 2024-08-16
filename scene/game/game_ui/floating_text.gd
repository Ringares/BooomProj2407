extends Node2D
class_name FloatingText

@export var init_offset:Vector2

func display_floating(text:String):
	$Label.text = text
	
	$Label.position += init_offset
	
	var pos_tween = create_tween()
	var scale_tween = create_tween()
	pos_tween.tween_property(self, "global_position", global_position + Vector2.UP * 32, 0.4)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector2(1.3,1.3), 0.4)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	pos_tween.tween_property(self, "global_position", global_position + Vector2.UP * 64, 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector2(0.,0.), 0.4)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	pos_tween.tween_callback(self.queue_free)

