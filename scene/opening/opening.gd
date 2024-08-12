extends Control


@export_file("*.tscn") var next_scene : String
@export var images : Array[Texture2D]
@export var start_delay : float = 0.5
@export var end_delay : float = 0.5
@export var show_loading_screen : bool = false


func _ready():
	
	if images.is_empty():
		SceneLoader.load_scene(next_scene)
	else:
		SceneLoader.load_scene(next_scene, true)
		_add_textures_to_container(images)
		_animate_images()


func _add_textures_to_container(textures : Array[Texture2D]):
	for texture in textures:
		var texture_rect : TextureRect = TextureRect.new()
		texture_rect.texture = texture
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.visible = false
		%ImagesContainer.call_deferred("add_child", texture_rect)
		
		
func _animate_images():
	await(get_tree().create_timer(start_delay).timeout)
	for texture_rect in %ImagesContainer.get_children():
		texture_rect.show()
		
		var tween = get_tree().create_tween()
		tween.tween_property(%ImagesContainer, "modulate:a", 0.0, 0)
		tween.tween_property(%ImagesContainer, "modulate:a", 1.0, 0.2)
		tween.tween_interval(1.6)
		tween.tween_property(%ImagesContainer, "modulate:a", 0.0, 0.2)
		await(tween.finished)
		texture_rect.hide()
	
	await(get_tree().create_timer(end_delay).timeout)
	_change_to_next_scene()
	
	
func _change_to_next_scene():
	var status = SceneLoader.get_status()
	if show_loading_screen or status != ResourceLoader.THREAD_LOAD_LOADED:
		SceneLoader.change_scene_to_loading_screen()
	else:
		SceneLoader.change_scene_to_resource()


func _unhandled_input(event):
	if event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel"):
		_change_to_next_scene()


func _gui_input(event):
	if event is InputEventMouseButton and not event.is_pressed():
		_change_to_next_scene()
