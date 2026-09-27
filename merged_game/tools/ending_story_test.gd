extends SceneTree

func _initialize() -> void:
	root.set_meta("story_automation", true)
	call_deferred("run")

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	root.size = Vector2i(1280, 720)
	root.get_node("Game").ending = "escape"
	change_scene_to_file("res://scenes/ending.tscn")
	for i in 4: await process_frame
	var deadline := Time.get_ticks_msec() + 120000
	var visitor_seen := false
	while Time.get_ticks_msec() < deadline and current_scene._end_box == null:
		for child in current_scene.get_children():
			if child.get_script() and child.get_script().resource_path == "res://scripts/last_visitor.gd" and child.approach > 0.7:
				if not visitor_seen:
					visitor_seen = true
					print("PASS / ending visitor approaches in actual ending")
					if DisplayServer.get_name() != "headless":
						await RenderingServer.frame_post_draw
						root.get_texture().get_image().save_png("res://qa/ending_visitor.png")
		await create_timer(0.25).timeout
	var complete: bool = current_scene._end_box != null and visitor_seen
	print("PASS / " if complete else "FAIL / ", "complete escape ending reaches end card after sting")
	quit(0 if complete else 1)
