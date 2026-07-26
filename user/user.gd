class_name User extends Node2D

enum State {IDLE, MOVING_TO_TASK, TASK}
enum PState {NONE, FISHING, DOGLOG, RAID, SMITHING, HAT}

static var position_tile_offset := Vector2i(16, 16)
static var position_tile_offset_v2 := Vector2(16, 16)

@onready var local_chat: Label = %LocalChatLabel
@onready var art: UserArt = $UserArt

var movement_delay: float = .5 #* .1

var path: PackedVector2Array = []
var path_idx: int = 0
var time_to_next_move = movement_delay

var state: State = State.IDLE
var task: Task.Type = Task.Type.IDLE
var task_time_left: float = 1.0
var task_stage: int = 0
var time_to_acquire_new_task: float = 1.0
var task_multiplier := 1.0
var force_next_task: Task.Type = Task.Type.IDLE

var id: int = 1
var is_streamer := false
var photograph_state: PState = PState.NONE

func init(spot: Vector2i, _id: int, _name: String, _is_streamer := false) -> void:
	$PhotoArea.monitorable = false
	move_to(spot, true)
	art.randomize_appearance()
	id = _id
	$NameLabel.text = _name
	if _is_streamer:
		become_streamer()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	local_chat.visible = false
	Signals.ugly_hat.connect(func(): if photograph_state == PState.HAT: photograph_state = PState.NONE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	art.z_index = clamp(int(position.y * 10 + id * 1), 1, 4096)
	if state == State.MOVING_TO_TASK:
		time_to_next_move -= delta
		if time_to_next_move <= 0:
			move_to(path[path_idx])
			path_idx += 1
			time_to_next_move = movement_delay + time_to_next_move
		if path_idx >= len(path):
			finish_moving()
	elif state == State.IDLE:
		art.play_idle()
		time_to_acquire_new_task -= delta
		if time_to_acquire_new_task <= 0:
			if force_next_task != Task.Type.IDLE:
				Globals.game_manager.give_user_task(self, force_next_task)
				force_next_task = Task.Type.IDLE
			else:
				Globals.game_manager.give_user_task(self)
	elif state == State.TASK:
		task_time_left -= delta
		if task_time_left <= 0:
			enter_idle()
	
	if is_streamer || photograph_state != PState.NONE:
		$PhotoArea.monitorable = true
	else:
		$PhotoArea.monitorable = false

func move_to(pos: Vector2i, instant := false) -> void:
	if len(path) > 0:
		art.play_walk(path[path_idx] - path[max(0, path_idx-1)])
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
		Task.Type.GET_QUEST:
			enter_get_quest()
		Task.Type.QUEST_ONE:
			enter_quest_one()
		Task.Type.TURN_IN_QUEST_ONE:
			enter_turn_in_quest()
		Task.Type.DOG_LOG:
			enter_dog_log()
		Task.Type.RAID:
			enter_raid()
		Task.Type.MINING:
			enter_mining()
		Task.Type.SMITHING:
			enter_smithing()

func assign_new_task(_task: Task.Type, _path: PackedVector2Array) -> void:
	set_path(_path)
	state = State.MOVING_TO_TASK
	task = _task
	task_stage = 0

func enter_idle() -> void:
	state = State.IDLE
	time_to_acquire_new_task = randf_range(1, 5) * task_multiplier

func enter_combat() -> void:
	task_time_left = randf_range(10, 20) * task_multiplier
	art.play_attack(Vector2.LEFT)

func enter_fishing() -> void:
	task_time_left = randf_range(5, 15) * task_multiplier
	if Globals.game_state.fishing_enabled:
		art.play_idle()
		art.equip_fishing_rod()
		if randf() < .25:
			local_chat_message("Fishing lvls?")
	else:
		local_chat_message(["How fish?", "Is fishing broken?", "What button is it to fish?"].pick_random())
		set_photograph_state_for_time(PState.FISHING, task_time_left)

func enter_explore() -> void:
	task_time_left = randf_range(1, 3) * task_multiplier
	var msg = ["I think I'm lost", "This game is beautiful", "Hey guys it's me, video game pheasant!"].pick_random()
	local_chat_message(msg)

func enter_get_quest() -> void:
	var msg = ["Give me a quest please", "quest plox", "ahoy, a quest good sir"].pick_random()
	local_chat_message(msg)
	Globals.game_manager.give_user_task(self, Task.Type.QUEST_ONE)

func enter_dog_log() -> void:
	task_time_left = randf_range(3, 5)
	var msg = ["Nice doggy", "Why can't I pet the dog?", "Doggo"].pick_random()
	local_chat_message(msg)
	set_photograph_state_for_time(PState.DOGLOG, task_time_left)

func enter_raid() -> void:
	task_time_left = randf_range(5, 10)
	var msg = ["How do I enter the raid?", "Bugged?", "Can't enter??????"].pick_random()
	local_chat_message(msg)
	set_photograph_state_for_time(PState.RAID, task_time_left)

func enter_quest_one() -> void:
	if randf() < .66:
		var msg = ["I found the missing ball!", "This quest is hard", "I'm enjoying this quest"].pick_random()
		local_chat_message(msg)
		force_next_task = Task.Type.QUEST_ONE
		task_stage += 1
	else:
		force_next_task = Task.Type.TURN_IN_QUEST_ONE

func enter_mining() -> void:
	force_next_task = Task.Type.SMITHING
	task_time_left = randf_range(5, 10)
	art.play_interact(Vector2.LEFT)

func enter_smithing() -> void:
	if randf() < .75:
		force_next_task = Task.Type.MINING
	task_time_left = randf_range(5, 10)
	art.play_interact(Vector2.LEFT)
	if !Globals.game_state.smithing_fixed:
		set_photograph_state_for_time(PState.SMITHING, task_time_left)

func enter_turn_in_quest() -> void:
	if !Globals.game_state.quest_reward_fixed:
		print("giving hat")
		art.apply_ugly_hat()
		set_photograph_state_for_time(PState.HAT, 9999)
	var msg = ["I finished the quest", "Here's your lost ball", "You better give me something good"].pick_random()
	local_chat_message(msg)

func local_chat_message(msg: String) -> void:
	local_chat.text = msg
	local_chat.visible = true
	
	await get_tree().create_timer(3.0).timeout
	local_chat.visible = false

func set_path(tiles: PackedVector2Array) -> void:
	path = tiles
	time_to_next_move = movement_delay
	path_idx = 0

func set_photograph_state_for_time(p_state: PState, time: float) -> void:
	photograph_state = p_state
	await get_tree().create_timer(time).timeout
	if photograph_state == p_state:
		photograph_state = PState.NONE

func photographed() -> void:
	if is_streamer:
		print("Streamer was photographed")
		Signals.streamer_photographed.emit()
		return
	elif photograph_state == PState.FISHING:
		print("Person trying to fish photographed")
		Signals.fishing_attempt_found.emit()
	elif photograph_state == PState.DOGLOG:
		print("doglog photographed")
		Signals.dog_log_found.emit()
	elif photograph_state == PState.RAID:
		print("raid photographed")
		Signals.raid_failure.emit()
	elif photograph_state == PState.SMITHING:
		print("smithing photographed")
		Signals.smithing_noticed.emit()
	elif photograph_state == PState.HAT:
		print("hat photographed")
		Signals.ugly_hat.emit()
	else:
		print("was photographed: ", self.name)

func become_streamer() -> void:
	is_streamer = true
	art.apply_streamer_outfit()
	name = "Streamer"
