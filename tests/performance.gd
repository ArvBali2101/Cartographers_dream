extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args():
		push_error("Use -- --test to isolate benchmark saves from real player progress.")
		quit(1)
		return
	root.size=Vector2i(1280,720)
	var app: Node = load("res://Main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	for chapter in ["cave","maze"]:
		app.enter_chapter(chapter)
		await process_frame
		await RenderingServer.frame_post_draw
		var start := Time.get_ticks_usec()
		for i in range(120): await process_frame
		var seconds := float(Time.get_ticks_usec()-start)/1000000
		print("RENDER BENCHMARK / ",chapter," / ",snappedf(120/seconds,0.1)," FPS / ",snappedf(seconds,0.01)," s")
	app.queue_free()
	await process_frame
	await process_frame
	quit()
