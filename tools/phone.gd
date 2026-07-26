extends CanvasLayer

@onready var messages: VBoxContainer = $PanelContainer/ScrollContainer/VBoxContainer

var last_photo: Image
var text_delay: float = 3.0

var time_to_next_message: float = 3.0
var upcoming_texts = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_message("Hi, thanks for agreeing to be a community manager for the team")
	add_message("To take a picture, hit spacebar, move the mouse to where you want to take a picture, and left click when you're ready")
	Signals.photo_taken.connect(func(photo_taken): last_photo = photo_taken, CONNECT_DEFERRED)
	Signals.fishing_attempt_found.connect(handle_fishing, CONNECT_DEFERRED)
	
	#todo
	# 

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_home"):
		add_message("testing")

func handle_fishing() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("People are complaining about fishing not working? That's because it's not a feature of the game. Fine, we can add it.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_phone"):
		visible = !visible
	
	if len(upcoming_texts) > 0:
		time_to_next_message -= delta
		if time_to_next_message <= 0:
			upcoming_texts[0].visible = true
			upcoming_texts.remove_at(0)
			time_to_next_message = 3.0
	
	$IncomingMessageLabel.visible = len(upcoming_texts) > 0

func add_image(img: Image) -> void:
	var text_msg: TextMessage = preload("res://tools/TextMessage.tscn").instantiate()
	var texture = ImageTexture.create_from_image(img)
	messages.add_child(text_msg)
	text_msg.visible = false
	text_msg.set_image(texture)
	upcoming_texts.append(text_msg)

func add_message(msg: String) -> void:
	var text_msg = preload("res://tools/TextMessage.tscn").instantiate()
	messages.add_child(text_msg)
	text_msg.visible = false
	text_msg.set_text(msg)
	upcoming_texts.append(text_msg)
