extends SceneTree
var checks := 0
var failures := 0

func _initialize() -> void:
	root.set_meta("story_automation", true)
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS / " if ok else "FAIL / ", message)

func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://qa")
	root.get_texture().get_image().save_png("res://qa/" + name + ".png")

func settle() -> void:
	for i in 4: await process_frame

func advance() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = "skip"
	event.pressed = true
	return event

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	root.size = Vector2i(1280,720)
	var game = root.get_node("Game")
	var music = root.get_node("Music")
	check(music._ritual_players.size() == 2,"two new horror music layers load")
	for player in music._ritual_players:
		check(player.stream.get_length() >= 23.9,"horror music loop duration")
	music.set_ritual(0.7)
	music._process(0.5)
	check(music._ritual > 0.0,"horror layers fade in")
	var saved_volume: float = music.music_volume
	music.music_volume = 0.0
	music._process(0.1)
	check(music._ritual_players[0].volume_db <= -79.0,"music mute includes horror layers")
	music.music_volume = saved_volume
	music.stop(0.1)
	music._process(2.0)
	check(music._ritual == 0.0,"silence clears horror layers")
	change_scene_to_file("res://scenes/intro.tscn")
	await settle()
	check(current_scene.FILMS.intro.size() == 7,"authored animated opening restored")
	check(current_scene.size.x >= 1000,"intro animation fills stage")
	current_scene._unhandled_input(advance())
	check(current_scene._advance,"press advances authored opening")
	current_scene._unhandled_input(advance())
	check(current_scene._advance,"next press is accepted by intro")
	await create_timer(2.8).timeout
	await shot("story_intro")
	for chapter in 3:
		game.current_level = chapter
		change_scene_to_file("res://scenes/interlude.tscn")
		await settle()
		var scene = current_scene
		check(scene._vignette != null,"animated interlude / " + str(chapter))
		check(scene._vignette.size.x >= 1000,"interlude animation fills stage / " + str(chapter))
		check(scene._figure_render.viewport.size == Vector2i(1920,1080),"live HD figure / " + str(chapter))
		check(scene._lines.size() >= 2,"brief connective story / " + str(chapter))
		scene._show_line(scene._lines.size()-1)
		await create_timer(4.1).timeout
		check(not scene._busy,"text reveal completes / " + str(chapter))
		check(scene._label.get_minimum_size().x <= 1240,"story text fits width / " + str(chapter))
		await shot("story_god_" + str(chapter))
	var notes = load("res://scripts/map_page.gd")
	check(notes.GOD_NOTES.size() == 3,"three readable deity evidence pages")
	for god in ["NYARLATHOTEP","YOG-SOTHOTH","AZATHOTH","SHUB-NIGGURATH"]:
		check("\n".join(notes.GOD_NOTES).contains(god),"named god / " + god)
	change_scene_to_file("res://scenes/main_menu.tscn")
	await settle()
	check(current_scene._chapters_btn.visible,"chapter picker always available")
	current_scene._open_chapters()
	for i in game.LEVELS.size():
		var button = current_scene._chapters.get_child(0).get_child(i+1).get_child(0)
		check(not button.disabled,"chapter selectable / " + str(i+1))
	await shot("story_chapters")
	current_scene._close_chapters()
	var visitor = load("res://scripts/last_visitor.gd").new()
	current_scene.add_child(visitor)
	visitor.approach = 0.75
	await settle()
	check(visitor.mouse_filter == Control.MOUSE_FILTER_IGNORE,"visitor cannot trap input")
	check(visitor.size.x >= 1000,"visitor fills stage")
	check(visitor.scanned_model != null,"detailed downloaded figure instantiates")
	await create_timer(0.4).timeout
	await shot("story_last_visitor")
	visitor.queue_free()
	await settle()
	var chapter_button = current_scene._chapters.get_child(0).get_child(4).get_child(0)
	chapter_button.pressed.emit()
	await create_timer(5.0).timeout
	check(game.current_level == 3,"chapter picker starts selected chapter")
	check(current_scene.scene_file_path == game.LEVELS[3].scene,"chapter picker loads actual labyrinth")
	var scene = current_scene
	current_scene = null
	scene.queue_free()
	await settle()
	print("STORY / ",checks," CHECKS / ",failures," FAILURES")
	quit(0 if failures == 0 else 1)
