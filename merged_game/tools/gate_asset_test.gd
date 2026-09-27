extends SceneTree
var failures := 0

func _initialize() -> void:
	root.set_meta("story_automation", true)
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok: failures += 1
	print("PASS / " if ok else "FAIL / ", message)

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	root.size = Vector2i(1280, 720)
	root.get_node("Game").current_level = 3
	change_scene_to_file("res://levels/level3/level3.tscn")
	await create_timer(1.5).timeout
	var level = current_scene
	var gate = level.forbidden_gate
	level.player.global_position = gate.global_position + gate.global_basis.z * 1.8
	level.player.rotation.y = PI / 2
	level.player._pitch = 0
	level.player.head.rotation.x = 0
	await create_timer(0.2).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://qa/revision_gate_physical.png")
	Input.action_press("move_up")
	await create_timer(0.9).timeout
	Input.action_release("move_up")
	print("closed approach: player=", level.player.global_position, " gate=", gate.global_position, " frozen=", level.player.frozen)
	check(not level._over, "closed gate collider blocks approach without killing")
	check(level.player.global_position.x > gate.global_position.x, "player remains in front of thick door")
	level.player.global_position = gate.global_position + gate.global_basis.z * 1.5
	gate.interact(Vector3.ZERO)
	await create_timer(1.5).timeout
	Input.action_press("move_up")
	await create_timer(0.8).timeout
	Input.action_release("move_up")
	print("open approach: player=", level.player.global_position, " gate=", gate.global_position, " overlaps=", gate.threshold.get_overlapping_bodies().size())
	check(level._over, "walking through opened gate triggers actual death Area3D")
	var inserts = level.find_children("*", "Control", true, false).filter(func(n): return n.get_script() != null and n.get_script().resource_path == "res://scripts/god_reveal.gd")
	check(inserts.size() == 1, "live asset-based reveal appears")
	if inserts.size() == 1:
		check(inserts[0].idol != null, "detailed scanned idol loads")
		check(inserts[0].viewport.size == Vector2i(1920, 1080), "reveal renders in native HD")
		await create_timer(0.3).timeout
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://qa/revision_live_idol.png")
	await create_timer(5.0).timeout
	check(current_scene.scene_file_path == "res://scenes/ending.tscn", "actual gate crossing connects to losing story")
	var old = current_scene
	current_scene = null
	old.queue_free()
	for i in 6: await process_frame
	quit(0 if failures == 0 else 1)
