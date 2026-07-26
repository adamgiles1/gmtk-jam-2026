extends Node2D

var trashcans = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.delete_trashcans.connect(func():
		$Trashcan.queue_free()
		$Trashcan2.queue_free()
		$Trashcan3.queue_free()
		$Trashcan6.queue_free()
		$Trashcan7.queue_free()
		$Trashcan4.queue_free()
		$Trashcan5.queue_free()
		print("trashcans deleted")
	)
	
	Signals.delete_raid.connect(func():
		$Raid.queue_free()
	)
