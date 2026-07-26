extends Node

signal game_patched(state: GamePatch)
enum GamePatch {GRASS_AREA, DESERT_AREA}

signal photo_taken (photo: Image)
signal fishing_attempt_found
signal dog_log_found
signal raid_failure
signal smithing_noticed
signal trashcans_noticed
signal ugly_hat
signal streamer_photographed
signal rat_sword

signal invincible_enemy_found
signal massacre_found


signal delete_trashcans
signal delete_raid
signal start_massacre

signal all_objectives_found
