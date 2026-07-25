extends Node2D

@onready var box: ColorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	global_position = mouse_pos - box.size / 2
	
	if Input.is_action_just_pressed("take_photo"):
		take_photo()

func take_photo() -> void:
	print("az taking photo at: ", get_viewport().get_mouse_position())
	CameraService.take_photo(get_viewport().get_mouse_position())
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	queue_free()
