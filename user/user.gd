class_name User extends Node2D

enum State {IDLE, MOVING_TO_TASK, TASK}

static var position_tile_offset := Vector2i(16, 16)
static var position_tile_offset_v2 := Vector2(16, 16)

@onready var local_chat: Label = %LocalChatLabel
@onready var art: UserArt = $UserArt

var movement_delay: float = .5

var path: PackedVector2Array = []
var path_idx: int = 0
var time_to_next_move = movement_delay

var state: State = State.IDLE
var task: Task.Type = Task.Type.IDLE
var task_time_left: float = 1.0
var time_to_acquire_new_task: float = 1.0
var task_multiplier := .5

var id: int = 1

func init(spot: Vector2i, _id: int, name: String) -> void:
	move_to(spot, true)
	art.randomize_appearance()
	id = _id
	$NameLabel.text = name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	local_chat.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	art.z_index = int(position.y * 10 + id * 1)
	if state == State.MOVING_TO_TASK:
		art.play_walk(path[path_idx] - path[max(0, path_idx-1)])
		time_to_next_move -= delta
		if time_to_next_move <= 0:
			move_to(path[path_idx])
			path_idx += 1
			time_to_next_move = movement_delay + time_to_next_move
		if path_idx >= len(path):
			finish_moving()
	elif state == State.IDLE:
		time_to_acquire_new_task -= delta
		if time_to_acquire_new_task <= 0:
			print("acquiring new task")
			Globals.game_manager.give_user_task(self)
	elif state == State.TASK:
		task_time_left -= delta
		if task_time_left <= 0:
			print("finished task")
			enter_idle()

func move_to(pos: Vector2i, instant := false) -> void:
	if instant:
		global_position = pos + position_tile_offset
	else:
		var final_val: Vector2 = pos + position_tile_offset
		create_tween().tween_property(self, "global_position", final_val, movement_delay)

func finish_moving() -> void:
	state = State.TASK
	match task:
		Task.Type.RAT:
			enter_combat()
		Task.Type.FISHING:
			enter_fishing()
		Task.Type.EXPLORE:
			enter_explore()

func assign_new_task(_task: Task.Type, _path: PackedVector2Array) -> void:
	print("starting task: ", task, " with distance of ", len(path))
	set_path(_path)
	state = State.MOVING_TO_TASK
	task = _task

func enter_idle() -> void:
	print("entering idle")
	state = State.IDLE
	time_to_acquire_new_task = randf_range(1, 5) * task_multiplier

func enter_combat() -> void:
	print("starting combat")
	task_time_left = randf_range(10, 20) * task_multiplier
	art.play_attack(Vector2.LEFT)

func enter_fishing() -> void:
	print("starting to fish")
	task_time_left = randf_range(5, 15) * task_multiplier
	art.play_idle()
	art.equip_fishing_rod()

func enter_explore() -> void:
	print("exploring")
	task_time_left = randf_range(1, 3) * task_multiplier
	var msg = ["I think I'm lost", "This game is beautiful", "Hey guys it's me, video game pheasant!"].pick_random()
	local_chat_message(msg)

func local_chat_message(msg: String) -> void:
	local_chat.text = msg
	local_chat.visible = true
	
	await get_tree().create_timer(3.0).timeout
	local_chat.visible = false

func set_path(tiles: PackedVector2Array) -> void:
	print("setting path of size: ", len(tiles))
	path = tiles
	time_to_next_move = movement_delay
	path_idx = 0
