extends Camera2D

const CAMERA_SPEED := 2000
const CURSOR_SCREEN_MARGIN: float = 100.0

var camera_max_x := 2565
var camera_min_x := 660
var camera_max_y := 1450
var camera_min_y := 450

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Signals.game_patched.connect(handle_patching)
	global_position = Vector2(1750, 800)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var movement := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	movement += calculate_cursor_edge_movement()
	movement = movement.clamp(-Vector2.ONE, Vector2.ONE)
	position += movement * CAMERA_SPEED * delta
	position.x = clamp(position.x, camera_min_x, camera_max_x)
	position.y = clamp(position.y, camera_min_y, camera_max_y)
	
	if Input.is_action_just_pressed("ui_page_down"):
		Signals.game_patched.emit(Signals.GamePatch.GRASS_AREA)
	if Input.is_action_just_pressed("ui_page_up"):
		Signals.game_patched.emit(Signals.GamePatch.DESERT_AREA)

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

func handle_patching(state: Signals.GamePatch) -> void:
	if state == Signals.GamePatch.GRASS_AREA:
		camera_min_x = -1930
	elif state == Signals.GamePatch.DESERT_AREA:
		camera_min_y = -1450
