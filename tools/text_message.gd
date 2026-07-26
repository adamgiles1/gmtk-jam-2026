class_name TextMessage extends Container

@onready var text: Label = $Label
@onready var img: TextureRect = $TextureRect

var is_image := false

func set_text(msg: String) -> void:
	text.text = msg
	img.visible = false
	
func set_image(texture: Texture2D) -> void:
	text.visible = false
	img.texture = texture
	is_image = true
