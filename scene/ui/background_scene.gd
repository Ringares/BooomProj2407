extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_dir = Vector2(randf_range(-1.,1.),1.0)
	print(rand_dir)
	(material as ShaderMaterial).set_shader_parameter("direction", rand_dir)
