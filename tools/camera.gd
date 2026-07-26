extends Node2D

@onready var box: ColorRect = $ColorRect
@onready var area: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	global_position = mouse_pos - box.size / 2
	
	if Input.is_action_just_pressed("take_photo"):
		take_photo()
	
	if Input.is_action_just_pressed("close_camera"):
		close_camera()

func take_photo() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	CameraService.take_photo(get_viewport().get_mouse_position())
	check_inside_photo()
	
	queue_free()

func close_camera() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	queue_free()

func check_inside_photo() -> void:
	if area.has_overlapping_areas():
		print("photo had something in it")
		var thing = area.get_overlapping_areas()[0]
		if thing.owner.has_method("photographed"):
			thing.owner.photographed()
	else:
		print("photo had nothing")
