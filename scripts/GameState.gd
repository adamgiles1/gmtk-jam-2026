class_name GameState extends RefCounted

var fishing_enabled := false
var streamer_found := false
var massacre_solved := false
var raid_entrance_solved := false
var dog_log_reported := false
var metal_trashcan_removed := false
var smithing_fixed := false
var rat_sword_fixed := false
var desert_enemy_fixed := false
var quest_reward_fixed := false

func init() -> void:
	Signals.fishing_attempt_found.connect(enable_fishing)
	Signals.raid_failure.connect(remove_raid)
	Signals.smithing_noticed.connect(patch_smithing)
	Signals.dog_log_found.connect(dog_log)
	Signals.trashcans_noticed.connect(trashcans)
	Signals.rat_sword.connect(sword_fixed)
	Signals.invincible_enemy_found.connect(invincible_enemy)
	Signals.massacre_found.connect(handle_massacre)
	Signals.streamer_photographed.connect(handle_streamer)
	Signals.ugly_hat.connect(handle_hat)

func calculate_state():
	var completed: int = 0
	if fishing_enabled: completed += 1
	if streamer_found: completed += 1
	if massacre_solved: completed += 1
	if raid_entrance_solved: completed += 1
	if dog_log_reported: completed += 1
	if metal_trashcan_removed: completed += 1
	if smithing_fixed: completed += 1
	if rat_sword_fixed: completed += 1
	if desert_enemy_fixed: completed += 1
	if quest_reward_fixed: completed += 1
	print("completed objects: ", completed, "/10")
	
	if completed > 1 && !Globals.game_manager.grass_available:
		Signals.game_patched.emit(Signals.GamePatch.GRASS_AREA)
	
	if completed > 4 && !Globals.game_manager.desert_available:
		Signals.game_patched.emit(Signals.GamePatch.DESERT_AREA)
	
	if completed >= 10:
		Signals.all_objectives_found.emit()

func get_hint() -> String:
	if !streamer_found:
		return "You still need to find Vessel_Radio. They should be around the starting area"
	if !quest_reward_fixed:
		return "Can you get me a picture of the new hat? Anyone who beat the quest should be wearing it"
	if !fishing_enabled:
		return "I heard some players were at the dock complaining about something, can you check it out?"
	if !rat_sword_fixed:
		return "I see a lot of people with strong weapons, can you find where they're getting that?"
	if !dog_log_reported:
		return "I'm seeing people complain about not being able to pet a dog. What dog?"
	if !metal_trashcan_removed:
		return "I see reports that something unrealistic is in the desert town, can you find it?"
	if !massacre_solved:
		return "Someone is somehow attacking other players in the starting zone. They must be wearing a bugged hat, but I don't know which one. Photograph it please"
	if !desert_enemy_fixed:
		return "Players are reporting an enemy in the desert isn't behaving correctly"
	if !smithing_fixed:
		return "Players are mining and smelting WAY faster than we expected, can you look into that?"
	if !raid_entrance_solved:
		return "People are complaining about some hole in the ground in the desert"
	return "You fixed everything, I don't think there's anything left to investigate"

func handle_streamer():
	streamer_found = true
	calculate_state()

func handle_hat():
	quest_reward_fixed = true
	calculate_state()

func handle_massacre():
	massacre_solved = true
	calculate_state()

func invincible_enemy():
	desert_enemy_fixed = true
	calculate_state()

func enable_fishing():
	fishing_enabled = true
	calculate_state()

func remove_raid():
	raid_entrance_solved = true
	calculate_state()

func patch_smithing():
	smithing_fixed = true
	calculate_state()

func dog_log():
	dog_log_reported = true
	calculate_state()

func trashcans():
	metal_trashcan_removed = true
	calculate_state()

func sword_fixed():
	rat_sword_fixed = true
	calculate_state()
