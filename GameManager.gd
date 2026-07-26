class_name GameManager extends Node2D

var GRID_X_MAX: int = 98
var GRID_X_MIN: int = -79
var GRID_Y_MAX: int = 58
var GRID_Y_MIN: int = -59

var grass_available := false
var desert_available := false

var town_tasks: Array[Task.Type] = [Task.Type.EXPLORE, Task.Type.GET_QUEST]
var grass_tasks: Array[Task.Type] = [Task.Type.RAT, Task.Type.FISHING, Task.Type.DOG_LOG]
var desert_tasks: Array[Task.Type] = [Task.Type.RAID, Task.Type.MINING, Task.Type.CRAB]
var possible_tasks: Array[Task.Type] = []

var user_scn: Resource = preload("res://user/User.tscn")

var pathfind: AStarGrid2D = AStarGrid2D.new()

@onready var tile_map: TileMapLayer = $Environment/TileMap/Collision
var player_spawn_spot := Vector2i(54, 14) * 32

var time_till_next_player: float = 2.5 #* 999999
var users_spawned: int = 0
var max_players: int = 75
var active_users: int = 0 :
	set(val):
		active_users = val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game_state = GameState.new()
	Globals.game_state.init()
	Signals.photo_taken.connect(display_photo)
	init_pathfinding()
	spawn_player(true)
	Globals.game_manager = self
	
	possible_tasks.append_array(town_tasks)
	Signals.game_patched.connect(func(patch: Signals.GamePatch): 
		if patch == Signals.GamePatch.GRASS_AREA: 
			possible_tasks.append_array(grass_tasks)
			grass_available = true
	)
	Signals.game_patched.connect(func(patch: Signals.GamePatch): 
		if patch == Signals.GamePatch.DESERT_AREA: 
			possible_tasks.append_array(desert_tasks)
			desert_available = true
	)
	Signals.raid_failure.connect(func(): possible_tasks.remove_at(possible_tasks.find(Task.Type.RAID)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_next_player -= delta
	if time_till_next_player <= 0 && max_players > users_spawned:
		spawn_player(false)
		time_till_next_player = randf_range(.5, .5)
	
	if Input.is_action_just_pressed("open_camera"):
		add_child(preload("res://tools/camera.tscn").instantiate())

func spawn_player(is_streamer: bool) -> void:
	var user: User = user_scn.instantiate()
	add_child(user)
	user.init(player_spawn_spot, users_spawned, NameGenerator.get_random_name(), is_streamer)
	if active_users == 12:
		user.force_next_task = Task.Type.MASSACRE
	
	active_users += 1
	users_spawned += 1

func init_pathfinding() -> void:
	pathfind.region = Rect2i(GRID_X_MIN, GRID_Y_MIN, GRID_X_MAX + abs(GRID_X_MIN), GRID_Y_MAX + abs(GRID_Y_MIN))
	pathfind.cell_size = Vector2(32, 32)
	pathfind.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfind.update()
	
	for x in range(GRID_X_MIN, GRID_X_MAX):
		for y in range(GRID_Y_MIN, GRID_Y_MAX):
			var pos := Vector2i(x, y)
			var tile := tile_map.get_cell_tile_data(pos)
			var is_solid := false
			if tile:
				is_solid = tile.get_custom_data("is_solid")
			pathfind.set_point_solid(pos, is_solid)

func calculate_path(start: Vector2i, end: Vector2i) -> PackedVector2Array:
	var path: PackedVector2Array = pathfind.get_point_path(start, end)
	return path

func give_user_task(user: User, type: Task.Type = Task.Type.IDLE) -> void:
	var task_type := type
	if type == Task.Type.IDLE:
		task_type = get_next_task_type()
	if user.is_streamer:
		task_type = Task.Type.BE_STREAMER
	var player_local: Vector2i = tile_map.to_local(user.global_position - User.position_tile_offset_v2)
	var start := tile_map.local_to_map(player_local)
	var end = get_task_spot(task_type, start)
	var task_path = calculate_path(start, end)
	
	user.assign_new_task(task_type, task_path)

func get_next_task_type() -> Task.Type:
	#return Task.Type.EXPLORE
	var task = possible_tasks.pick_random()
	if task == Task.Type.RAID && Globals.game_state.raid_entrance_solved:
		task = Task.Type.EXPLORE
	return task

func get_task_spot(task: Task.Type, start: Vector2i) -> Vector2i:
	match task:
		Task.Type.RAT:
			return Vector2i(randi_range(-61, -67), randi_range(19, 25))
		Task.Type.FISHING:
			return Vector2i(randi_range(-10, -13), randi_range(13, 15))
		Task.Type.EXPLORE:
			return get_random_pathable_spot(start)
		Task.Type.QUEST_ONE:
			return get_random_pathable_spot(start)
		Task.Type.GET_QUEST:
			return Vector2i(27, 47)
		Task.Type.TURN_IN_QUEST_ONE:
			return Vector2i(27, 47)
		Task.Type.DOG_LOG:
			return Vector2i(-14, 50)
		Task.Type.RAID:
			return Vector2i(randi_range(50, 54), randi_range(-49, -52))
		Task.Type.MINING:
			return get_random_mining_spot()
		Task.Type.SMITHING:
			return Vector2i(39, 3) if Globals.game_state.smithing_fixed else Vector2i(39, -3)
		Task.Type.BE_STREAMER:
			return Vector2i(randi_range(45, 64), randi_range(15, 34))
		Task.Type.CRAB:
			return Vector2i(randi_range(26, 33), randi_range(-25, -31))
		Task.Type.MASSACRE:
			return Vector2i(randi_range(45, 64), randi_range(15, 34))
	return Vector2i.ZERO

func get_random_pathable_spot(start: Vector2i) -> Vector2i:
	var i = 0
	while i < 10:
		i += 1
		var min_x = -79 if grass_available else 1
		var max_x = 98
		var min_y = -59 if desert_available else 2
		var max_y = 58
		var spot := Vector2i(randi_range(min_x, max_x), randi_range(min_y, max_y))
		var pathing = calculate_path(start, spot)
		if len(pathing) > 0:
			return spot
	# if we fail to find a spot 10 times, give up and return the same spot
	printerr("Failed to find a random pathable spot")
	return start

func get_random_mining_spot() -> Vector2i:
	return [Vector2i(37, -6), Vector2i(28, -9), Vector2i(29, -10), Vector2i(30, -9), Vector2i(34, -10), Vector2i(34, -4), Vector2i(42, -7), Vector2i(42, -9), Vector2i(42, -11), Vector2i(45, -7)].pick_random()

func display_photo(img: Image) -> void:
	pass#var texture := ImageTexture.create_from_image(img)
	#%PhotoRect.texture = texture
