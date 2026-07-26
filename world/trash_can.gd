extends Node2D

func _ready() -> void:
	Signals.trashcans_noticed.connect(handle_signal)

func photographed():
	Signals.trashcans_noticed.emit()

func handle_signal():
	$Area2D.monitorable = false
	
	await get_tree().create_timer(5.0)
	queue_free()
