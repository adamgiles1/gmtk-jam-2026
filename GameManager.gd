class_name GameManager extends Node2D

const GRID_WIDTH: int = 40
const GRID_HEIGHT: int = 30


var possible_tasks: Array[Task.Type] = [Task.Type.RAT, Task.Type.FISHING, Task.Type.EXPLORE]

var user_scn: Resource = preload("res://user/User.tscn")

var pathfind: AStarGrid2D = AStarGrid2D.new()

@onready var tile_map: TileMapLayer = $TileMap/TileMapLayer
var player_spawn_spot := Vector2i(0, 0)

var time_till_next_player: float = 2.5
var active_users: int = 0 :
	set(val):
		active_users = val
		print("number of users: ", active_users)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_pathfinding()
	spawn_player()
	Globals.game_manager = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_next_player -= delta
	if time_till_next_player <= 0:
		spawn_player()
		time_till_next_player = randf_range(.5, .5)
	
	if Input.is_action_just_pressed("ui_end"):
		add_child(preload("res://tools/camera.tscn").instantiate())

func spawn_player() -> void:
	var user: User = user_scn.instantiate()
	add_child(user)
	user.init(player_spawn_spot)
	
	active_users += 1

func init_pathfinding() -> void:
	pathfind.region = Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)
	pathfind.cell_size = Vector2(32, 32)
	pathfind.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfind.update()
	
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var pos := Vector2i(x, y)
			var tile := tile_map.get_cell_tile_data(pos)
			var is_solid := true
			if tile:
				is_solid = tile.get_custom_data("is_solid")
			pathfind.set_point_solid(pos, is_solid)

func calculate_path(start: Vector2i, end: Vector2i) -> PackedVector2Array:
	print("calculating path: ", start, "|", end)
	var path: PackedVector2Array = pathfind.get_point_path(start, end)
	print("len: ", len(path))
	return path

func give_user_task(user: User) -> void:
	print("calculating new task for user: ", user)
	var task_type: Task.Type = get_next_task_type()
	var player_local: Vector2i = tile_map.to_local(user.global_position - User.position_tile_offset_v2)
	var start := tile_map.local_to_map(player_local)
	print("user is starting at tile: ", start)
	var end = get_task_spot(task_type, start)
	print("user is going to tile: ", end)
	var task_path = calculate_path(start, end)
	
	user.assign_new_task(task_type, task_path)

func get_next_task_type() -> Task.Type:
	return possible_tasks.pick_random()

func get_task_spot(task: Task.Type, start: Vector2i) -> Vector2i:
	match task:
		Task.Type.RAT:
			return Vector2i(randi_range(2, 8), randi_range(2, 8))
		Task.Type.FISHING:
			return Vector2i(randi_range(29, 31), randi_range(17, 23))
		Task.Type.EXPLORE:
			return get_random_pathable_spot(start)
	return Vector2i.ZERO

func get_random_pathable_spot(start: Vector2i) -> Vector2i:
	var i = 0
	while i < 10:
		i += 1
		var spot := Vector2i(randi_range(0, GRID_WIDTH - 1), randi_range(0, GRID_HEIGHT - 1))
		var pathing = calculate_path(start, spot)
		if len(pathing) > 0:
			print("found path on iteration: ", i)
			return spot
	# if we fail to find a spot 10 times, give up and return the same spot
	return start
