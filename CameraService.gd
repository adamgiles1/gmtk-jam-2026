extends Node

var photo_size := Vector2i(200, 150)

func take_photo(position: Vector2i) -> void:
	print("taking photo at position: ", position)
	await RenderingServer.frame_post_draw
	var screen: Image = get_viewport().get_texture().get_image()
	var viewport_size := get_viewport().get_visible_rect().size
	var crop_pos := position - photo_size / 2
	
	var img := Image.create(photo_size.x, photo_size.y, false, screen.get_format())
	img.blit_rect(screen, Rect2i(crop_pos, photo_size), Vector2i.ZERO)
	
	#save_image(img)
	display_image(img)

func display_image(img: Image) -> void:
	Signals.photo_taken.emit(img)

func save_image(img: Image) -> void:
	var desktop = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var filename = "adam-test-%s.png" % Time.get_datetime_string_from_system().replace(":", "-")
	var path = desktop.path_join(filename)
	var err = img.save_png(path)
	if err == OK:
		print("photo saved")
	else:
		print("photo failed to save")
