class_name User extends Node2D

enum State {IDLE, MOVING_TO_TASK, TASK}
enum PState {NONE, FISHING, DOGLOG, RAID, SMITHING, HAT, SWORD, MASSACRE, INVINCIBLE}

static var position_tile_offset := Vector2i(16, 16)
static var position_tile_offset_v2 := Vector2(16, 16)

@onready var local_chat: Label = %LocalChatLabel
@onready var art: UserArt = $UserArt
@onready var massacre_area: Area2D = $MassacreArea

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

var has_sword := false

var massacre_cd: float = 0.0

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
	
	if task == Task.Type.MASSACRE:
		massacre_cd -= delta
		if massacre_cd <= 0 && massacre_area.has_overlapping_areas():
			massacre_cd = 2.0
			var user: User = massacre_area.get_overlapping_areas()[0].owner
			user.attack()
			local_chat_message(["DIE", "HIYA", "KILL", "I love this bug"].pick_random())

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
		Task.Type.CRAB:
			enter_crab_combat()
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
		Task.Type.BE_STREAMER:
			enter_streamer()
		Task.Type.MASSACRE:
			enter_massacre()

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
	art.play_attack(Vector2.LEFT if randf() < .5 else Vector2.RIGHT)
	if !Globals.game_state.rat_sword_fixed:
		if has_sword:
			set_photograph_state_for_time(PState.SWORD, task_time_left)
		else:
			await get_tree().create_timer(5.0).timeout
			art.apply_rare_sword()
			local_chat_message(["Why did the rat drop this?", "Woah, cool sword", "No way, super rare sword"].pick_random())
			has_sword = true
			set_photograph_state_for_time(PState.SWORD, task_time_left)

func enter_crab_combat() -> void:
	task_time_left = randf_range(10, 20) * task_multiplier
	art.play_attack(Vector2.LEFT)
	if !Globals.game_state.desert_enemy_fixed:
		set_photograph_state_for_time(PState.INVINCIBLE, task_time_left)
		await get_tree().create_timer(5.0).timeout
		local_chat_message(["Why won't they die?", "Is the game bugged? I can't kill them", "No damage?"].pick_random())

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
	if !Globals.game_state.smithing_fixed && randf() < .75:
		force_next_task = Task.Type.MINING
	task_time_left = randf_range(5, 10)
	art.play_interact(Vector2.LEFT)
	if !Globals.game_state.smithing_fixed:
		set_photograph_state_for_time(PState.SMITHING, task_time_left)
		local_chat_message(["This is very fast", "I don't think I'm supposed to do this", "Is the furnace meant to be across the river?"].pick_random())

func enter_turn_in_quest() -> void:
	if !Globals.game_state.quest_reward_fixed:
		print("giving hat")
		art.apply_ugly_hat()
		set_photograph_state_for_time(PState.HAT, 9999)
	var msg = ["I finished the quest", "Here's your lost ball", "You better give me something good"].pick_random()
	local_chat_message(msg)

func enter_massacre() -> void:
	massacre_area.monitoring = true
	$PlayerArea.monitorable = false
	art.apply_pvp_hat()
	task_time_left = 999999999999
	art.play_attack(Vector2.LEFT if randf() < .5 else Vector2.RIGHT)
	Signals.start_massacre.emit()
	Signals.massacre_found.connect(exit_massacre)
	set_photograph_state_for_time(PState.MASSACRE, task_time_left)

func exit_massacre() -> void:
	await get_tree().create_timer(5.0).timeout
	art.apply_ugly_hat()
	task_time_left = 0
	photograph_state = PState.NONE

func attack() -> void:
	var msg = ["Ouch, how did they attack me?", "A player attacked me?", "How are you doing that?"].pick_random()
	if is_streamer:
		msg = ["Chat, did I just get attacked by a player?", "Chat help me, I'm being attacked", "What do I do chat? I can't attack back"].pick_random()
	local_chat_message(msg)

func enter_streamer() -> void:
	task_time_left = randf_range(2, 4)
	var msg = ["Chat, what do you think about this game?", "I'm a little lost chat, which way?", "This game is too  hard chat", "Can someone in chat donate me a better weapon?", "Thanks %s for the donation" % NameGenerator.get_random_name()].pick_random()
	if randf() < .33:
		msg = "Thanks %s for the donation" % NameGenerator.get_random_name()
		
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
	elif photograph_state == PState.SWORD:
		print("sword photographed")
		Signals.rat_sword.emit()
	elif photograph_state == PState.MASSACRE:
		print("Massacre photographed")
		Signals.massacre_found.emit()
	elif photograph_state == PState.INVINCIBLE:
		print("crab photographed")
		Signals.invincible_enemy_found.emit()
	else:
		print("was photographed: ", self.name)

func become_streamer() -> void:
	is_streamer = true
	art.apply_streamer_outfit()
	name = "Streamer"
