extends CanvasLayer

@onready var messages: VBoxContainer = %VBoxContainer

var last_photo: Image
var text_delay: float = 3.0

var time_to_next_message: float = 0.0
var upcoming_texts = []

var hint_cd: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_message("Hi, thanks for agreeing to be a community manager for the team")
	add_message("To take a picture, hit spacebar, move the mouse to where you want to take a picture, and left click when you're ready")
	add_message("To start off, I saw the intern added a new hat as a reward when someone completes a quest. Take a picture.")
	add_message("I also saw the famous streamer Vessel_Radio was going to play our game. They are huge, please get me a picture.")
	add_message("Press tab to open/close the phone, and get started!")
	Signals.photo_taken.connect(func(photo_taken): last_photo = photo_taken, CONNECT_DEFERRED)
	Signals.fishing_attempt_found.connect(handle_fishing, CONNECT_DEFERRED)
	Signals.trashcans_noticed.connect(handle_trashcans_noticed, CONNECT_DEFERRED)
	Signals.raid_failure.connect(handle_raid_failure, CONNECT_DEFERRED)
	#todo
	Signals.dog_log_found.connect(handle_dog_log_found, CONNECT_DEFERRED)
	Signals.smithing_noticed.connect(handle_smithing_noticed, CONNECT_DEFERRED)
	Signals.ugly_hat.connect(handle_ugly_hat, CONNECT_DEFERRED)
	Signals.streamer_photographed.connect(handle_streamer_photographed, CONNECT_DEFERRED)
	Signals.rat_sword.connect(handle_rat_sword, CONNECT_DEFERRED)
	Signals.invincible_enemy_found.connect(handle_invincible_enemy_found, CONNECT_DEFERRED)
	Signals.massacre_found.connect(handle_massacre_found, CONNECT_DEFERRED)

func _physics_process(delta: float) -> void:
	hint_cd -= delta
	if Input.is_action_just_pressed("get_hint") && hint_cd <= 0:
		add_message(Globals.game_state.get_hint())
		hint_cd = 5.0

func handle_fishing() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("People are complaining about fishing not working? That's because it's not a feature of the game. Fine, we can add it.")

func handle_trashcans_noticed() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("The trashcans aren't realistic for the time period? Who even put those in, was it the intern? I deleted them all.")
	await get_tree().create_timer(len(upcoming_texts) * 4.0).timeout
	Signals.delete_trashcans.emit()

func handle_massacre_found() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("Aha, it's the green hat that allows them to attack players. I should have known. I forced them to use a different hat, it should be resolved now")

func handle_invincible_enemy_found() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("The players are complaining about the crabs not dying? That's realistic! I lost a fight to a crab last Tuesday. The crabs get nerfed over my dead body")

func handle_ugly_hat() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("That's the hat that the intern added? It looks awful")
	add_message("I'm patching the game so the quest stops giving that as a reward, it's horrible")

func handle_streamer_photographed() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("Nice. I love their content, I hope they have a lot of fun exploring our game!")

func handle_dog_log_found() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("The players are complaining about not being able to pet the dog? What dog? Oh, I see. That's a log")
	add_message("Well, we don't have time to add a dog. I'll force people to say log instead of dog when typing, that will fix the problem")

func handle_smithing_noticed() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("They're using the furnace across the water? Who programmed the furnace? Hang on, it was Steve. brb")
	add_message("Ok, I took care of Steve and the furnace. Players will now have to run around the whole world to smelt, as we intended")

func handle_rat_sword() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("The rats are dropping the mythical sword of Ansdam? That's not right. They're supposed to drop 2 coins. I'll have the intern patch it")

func handle_raid_failure() -> void:
	await get_tree().create_timer(.1).timeout
	add_image(last_photo)
	add_message("Players can't enter the raid? Wait, why is that there? I told Steve that the raid ENTRANCE was ready, not the actual raid. Let me remove that before other players notice...")
	await get_tree().create_timer(len(upcoming_texts) * 4.0).timeout
	Signals.delete_raid.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_phone"):
		visible = !visible
	
	if len(upcoming_texts) > 0:
		time_to_next_message -= delta
		if time_to_next_message <= 0 || upcoming_texts[0].is_image:
			upcoming_texts[0].visible = true
			if upcoming_texts[0].is_image:
				visible = true
			upcoming_texts.remove_at(0)
			time_to_next_message = 3.0
			await get_tree().process_frame
			%ScrollContainer.scroll_vertical = %ScrollContainer.get_v_scroll_bar().max_value
	
	%IncomingMessageLabel.visible = len(upcoming_texts) > 0
	#%MarginContainer.add_theme_constant_override("margin_bottom", 40 if len(upcoming_texts) > 0 else 0)

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
