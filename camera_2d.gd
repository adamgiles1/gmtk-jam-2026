extends Camera2D

const CAMERA_SPEED := 500
const CURSOR_SCREEN_MARGIN: float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	movement += calculate_cursor_edge_movement()
	movement = movement.clamp(-Vector2.ONE, Vector2.ONE)
	position += movement * CAMERA_SPEED * delta
	position.x = clamp(position.x, -20, 2500)
	position.y = clamp(position.y, -20, 2000)

func calculate_cursor_edge_movement() -> Vector2:
	var mouse_pos := get_viewport().get_mouse_position()
	var viewport_size := get_viewport().get_visible_rect().size
	
	var movement := Vector2.ZERO
	if mouse_pos.x < CURSOR_SCREEN_MARGIN:
		movement.x = -1
	elif mouse_pos.x > viewport_size.x - CURSOR_SCREEN_MARGIN:
		movement.x = 1
	if mouse_pos.y < CURSOR_SCREEN_MARGIN:
		movement.y = -1
	elif mouse_pos.y > viewport_size.y - CURSOR_SCREEN_MARGIN:
		movement.y = 1
	
	return movement
