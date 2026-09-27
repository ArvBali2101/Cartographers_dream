extends SceneTree
var checks := 0
var failures := 0
var game

func _initialize() -> void:
	root.set_meta("story_automation", true)
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS / " if ok else "FAIL / ", message)

func settle() -> void:
	for i in 5: await process_frame

func click(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	Input.parse_input_event(motion)
	await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
	await settle()

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	root.size = Vector2i(1280, 720)
	game = root.get_node("Game")
	game.current_level = 3
	change_scene_to_file(game.LEVELS[3].scene)
	await settle()
	var level = current_scene
	var overlay = level.overlay
	var notes = load("res://scripts/map_page.gd")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var initial_mouse: int = Input.mouse_mode
	game.begin_level_timer()
	var note: String = notes.TEXTS[0] + "\n\n---\n\n" + notes.POSTSCRIPTS[0] + "\n\n---\n\n" + notes.GOD_NOTES[0]
	overlay.show_page(note)
	await settle()
	check(overlay.reading and overlay._reader.visible, "paper opens as a readable modal")
	check(paused, "world pauses while reading")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "cursor released for button")
	check(overlay._page_close.text == "Finish reading", "explicit finish button exists")
	check(overlay._page_index == 0 and overlay._page_blocks.size() == 3, "long field note has three navigable pages")
	var time_before: float = game.level_time
	var position_before: Vector3 = level.player.global_position
	Input.action_press("move_up")
	await create_timer(0.6).timeout
	Input.action_release("move_up")
	check(is_equal_approx(time_before, game.level_time), "timer does not run under paper")
	check(level.player.global_position.is_equal_approx(position_before), "player cannot walk behind paper")
	await click(overlay._page_next)
	check(overlay._page_index == 1, "actual Next button click changes paper")
	await click(overlay._page_previous)
	check(overlay._page_index == 0, "actual Previous button click works")
	check(overlay._page.get_global_rect().end.y <= 720, "paper and buttons fit viewport")
	if DisplayServer.get_name() != "headless":
		DirAccess.make_dir_recursive_absolute("res://qa")
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://qa/reader_finish_button.png")
	await click(overlay._page_close)
	check(not overlay.reading and not overlay._reader.visible, "actual Finish reading click dismisses paper")
	check(not paused, "game resumes after button")
	check(Input.mouse_mode == initial_mouse, "original mouse mode returns after closing")
	for action in ["interact", "pause"]:
		overlay.show_page(note)
		await settle()
		var event := InputEventAction.new()
		event.action = action
		event.pressed = true
		Input.parse_input_event(event)
		await settle()
		check(not overlay.reading and not paused, "keyboard dismiss resumes / " + action)
	overlay.show_page(note)
	overlay.show_page("A replacement note")
	await settle()
	check(overlay._page_blocks.size() == 1, "repeated reads replace rather than stack")
	overlay.close_page()
	check(not paused, "repeat read restores original pause state")
	await create_timer(0.5).timeout
	check(not overlay._reader.visible, "paper does not reopen from old tween")
	root.size = Vector2i(900, 600)
	overlay.show_page(note)
	await settle()
	var screen := root.get_visible_rect().size
	check(overlay._page.get_global_rect().end.x <= screen.x and overlay._page.get_global_rect().end.y <= screen.y, "reader resizes with window")
	overlay.close_page()
	root.size = Vector2i(1280, 720)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await settle()
	var old = current_scene
	current_scene = null
	old.queue_free()
	await settle()
	await create_timer(0.3).timeout
	print("READER / ", checks, " CHECKS / ", failures, " FAILURES")
	quit(0 if failures == 0 else 1)
