extends SceneTree
var failures := 0

func _initialize() -> void:
	root.set_meta("story_automation", true)
	call_deferred("run")

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	root.size = Vector2i(1280, 720)
	Engine.time_scale = 8.0
	var game = root.get_node("Game")
	for kind in ["escape", "caught", "witnessed"]:
		game.ending = kind
		change_scene_to_file("res://scenes/ending.tscn")
		await process_frame
		await process_frame
		var end = current_scene
		var deadline := Time.get_ticks_msec() + 35000
		var hint_seen := false
		var wall_seen := false
		while end._end_box == null and Time.get_ticks_msec() < deadline:
			if end._caption.text.contains("flute has not stopped"): hint_seen = true
			if end.assimilation > 0.3: wall_seen = true
			await create_timer(0.25).timeout
		var okay: bool = end._end_box != null and (hint_seen if kind == "escape" else wall_seen)
		print("PASS / " if okay else "FAIL / ", "complete ", kind, " sequence reaches end card with ", "dream hint" if kind == "escape" else "animated wall assimilation")
		if not okay: failures += 1
		current_scene = null
		end.queue_free()
		for i in 6: await process_frame
	Engine.time_scale = 1.0
	quit(0 if failures == 0 else 1)
