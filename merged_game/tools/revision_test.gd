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
	for i in 6: await process_frame

func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://qa")
	root.get_texture().get_image().save_png("res://qa/revision_" + name + ".png")

func face(player: Node3D, target: Vector3) -> void:
	var to: Vector3 = target - player.camera.global_position
	player.rotation.y = atan2(-to.x, -to.z)
	player._pitch = atan2(to.y, Vector2(to.x, to.z).length())
	player.head.rotation.x = player._pitch

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	root.size = Vector2i(1280, 720)
	game = root.get_node("Game")
	change_scene_to_file("res://scenes/intro.tscn")
	await settle()
	var intro = current_scene
	check(intro.FILMS.intro.size() == 7, "seven authored animated opening panels")
	check(intro.FILMS.intro[1].art == "hall", "King commission restored from supplied ZIP")
	intro._panel = 1
	intro._set_up("hall")
	intro.black = 0
	intro._caption.text = "Go west, cartographer. Chart the isle the sea keeps hidden."
	intro._caption.modulate.a = 1
	await create_timer(0.6).timeout
	await shot("king")
	var event := InputEventAction.new()
	event.action = "skip"
	event.pressed = true
	intro._unhandled_input(event)
	check(intro._advance, "opening continue input works")
	intro._done = true
	game.current_level = 0
	game.next_level(Color.BLACK)
	await create_timer(1.9).timeout
	check(current_scene.scene_file_path == "res://scenes/arrival.tscn", "sea flows into authored island-arrival film")
	check(current_scene.film == "arrival", "arrival uses distinct animated island panels")
	current_scene._done = true
	for index in 2:
		game.current_level = index
		change_scene_to_file(game.LEVELS[index].scene)
		await create_timer(2.5).timeout
		check(current_scene.get("grid" if index == 0 else "_grid") != null, "playable chart chapter / " + str(index))
		check(current_scene.BAKE_SCALE >= 1.7, "higher-resolution ink rendering / " + str(index))
		current_scene.say("CTHULHU — a name carved beneath the beacon. The sleeper calls through dreams. Do not answer.\nThe expedition chart was never just a record.", 10)
		await settle()
		check(current_scene.hud._ctx.size.x <= 1130, "in-level lore wraps within viewport / " + str(index))
		await shot("chart_" + str(index))
	game.current_level = 2
	change_scene_to_file(game.LEVELS[2].scene)
	await settle()
	var cave = current_scene
	check(not cave.can_open_cave_door(), "cave exit blocked before reading warnings")
	cave.cave.door.open()
	check(not cave.cave.door.is_open, "unread cave door physically stays shut")
	for key in cave.REQUIRED_PAINTINGS: cave._seen[key] = true
	check(cave.can_open_cave_door(), "three cave warning detours unlock progression")
	cave.cave.door.open()
	check(cave.cave.door.is_open, "read cave door opens")
	game.current_level = 3
	change_scene_to_file(game.LEVELS[3].scene)
	await settle()
	var level = current_scene
	check(level.ward_nodes.size() == 2, "two physical ward stones created")
	check(level.forbidden_gate != null, "optional Azathoth gate exists")
	check(not level.can_take_black_key(), "Black Key cannot start chase before both detours")
	level.maze.keys.Black.interact(Vector3.ZERO)
	check(not level.maze.keys.Black.gone, "premature Black Key interaction retains collectible")
	for ward in level.ward_nodes:
		check(not level.maze.path(level.maze.start_cell, level.maze.cell_of(ward.global_position)).is_empty(), "ward reachable / " + ward.ward_name)
		ward.interact(Vector3.ZERO)
		ward.interact(Vector3.ZERO)
	check(level.wards.size() == 2, "ward count is idempotent")
	check(level.can_take_black_key(), "both wards release Black Key")
	check(is_equal_approx(level.beast.speed_ratio, 0.9), "hunter speed preserves fair 0.9 ratio")
	check(is_equal_approx(level.beast.bash_delay, 1.0), "hunter door pressure increased")
	check(load("res://assets/materials/stone_wall.tres").albedo_texture.resource_path.contains("rock_wall_07"), "ancient rubble stone replaces modern bricks")
	level.player.global_position = level.forbidden_gate.global_position + level.forbidden_gate.global_basis.z * 1.8
	face(level.player, level.forbidden_gate.global_position + Vector3(0, 1.8, 0))
	await create_timer(0.5).timeout
	await shot("gate")
	level.forbidden_gate._cross(level.player)
	check(not level._over, "closed forbidden gate is safe")
	level.forbidden_gate.interact(Vector3.ZERO)
	await create_timer(1.7).timeout
	check(level.forbidden_gate.is_open, "forbidden gate swings open on hinge")
	level.forbidden_gate._cross(level.player)
	check(level._over and level.player.frozen, "crossing kills immediately and freezes player")
	await create_timer(0.5).timeout
	await shot("azathoth")
	await create_timer(5.0).timeout
	check(current_scene.scene_file_path == "res://scenes/ending.tscn", "forbidden gate reaches loss ending")
	check(not current_scene._good and game.ending == "witnessed", "witnessed death is not misclassified as victory")
	current_scene._ending = true
	current_scene.black = 0
	current_scene.maze_k = 1
	current_scene.assimilation = 0.8
	current_scene.cam_center = current_scene._map_rect.get_center()
	current_scene.cam_zoom = 720.0 / current_scene._map_rect.size.y * 0.92
	current_scene._caption.text = "His arms become two lines. His spine closes a passage."
	current_scene._caption.modulate.a = 1
	await settle()
	await shot("assimilation")
	current_scene._show_end()
	check(current_scene._end_box != null, "loss end card remains usable")
	game.ending = "escape"
	change_scene_to_file("res://scenes/ending.tscn")
	await settle()
	check(current_scene._good, "normal escape still selects waking ending")
	var last = current_scene
	current_scene = null
	last.queue_free()
	await settle()
	print("REVISION RESULT / ", checks, " checks / ", failures, " failures")
	quit(0 if failures == 0 else 1)
