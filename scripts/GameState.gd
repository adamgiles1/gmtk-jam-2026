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

func handle_streamer():
	streamer_found = true

func handle_hat():
	quest_reward_fixed = true

func handle_massacre():
	massacre_solved = true

func invincible_enemy():
	desert_enemy_fixed = true

func enable_fishing():
	fishing_enabled = true

func remove_raid():
	raid_entrance_solved = true

func patch_smithing():
	smithing_fixed = true

func dog_log():
	dog_log_reported = true

func trashcans():
	metal_trashcan_removed = true

func sword_fixed():
	rat_sword_fixed = true
