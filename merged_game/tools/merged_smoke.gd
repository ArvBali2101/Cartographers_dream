extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print("PASS / " if ok else "FAIL / ",message)

func settle() -> void:
	for i in range(4): await process_frame
	await physics_frame

func shot(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://qa")
	root.get_texture().get_image().save_png("res://qa/"+name+".png")

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	root.size=Vector2i(1920,1080) if "--hd" in OS.get_cmdline_user_args() else Vector2i(1280,720)
	var game := root.get_node("Game")
	check(game.RECORDS_PATH.contains("verification"),"verification isolates player records")
	check(game.LEVELS.size()==4,"friend build has four authored chapters")
	check(game.LEVELS[0].id=="level2_beacons","sea-first merged progression retained")
	check(load("res://assets/fonts/Caveat.ttf")!=null,"friend handwriting font loads")
	check(load("res://assets/ui_theme.tres")!=null,"friend UI theme loads")
	for asset in ["rock_wall_07_diff", "cobblestone_floor_08_diff", "rock_wall_02_diff"]:
		var texture: Texture2D = load("res://assets/textures/hd/"+asset+"_2k.jpg")
		check(texture != null and texture.get_width() == 2048 and texture.get_height() == 2048,"true 2K texture / "+asset)
	game.set_render_quality(0)
	check(root.msaa_3d == Viewport.MSAA_DISABLED,"performance preset")
	game.set_render_quality(1)
	check(root.msaa_3d == Viewport.MSAA_2X,"HD preset")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await settle()
	check(current_scene!=null,"correct merged menu loads")
	await create_timer(1.0).timeout
	await shot("merged_menu")
	current_scene._open_settings()
	await settle()
	check(current_scene.settings_panel.size.y < 720,"settings panel fits base viewport")
	await shot("merged_settings")
	current_scene._close_settings()
	for i in range(game.LEVELS.size()):
		game.current_level=i
		game.level_finished=false
		game.timing=false
		var scene_path: String=game.LEVELS[i].scene
		check(ResourceLoader.exists(scene_path),"chapter scene exists / "+str(i+1))
		change_scene_to_file(scene_path)
		await settle()
		await create_timer(1.8).timeout
		check(current_scene!=null and current_scene.scene_file_path==scene_path,"chapter instantiates / "+str(i+1))
		if i==0: check(current_scene.get_node_or_null("Ship")!=null,"actual ship scene present")
		if i==1: check(current_scene.get_node_or_null("Explorer")!=null,"friend explorer scene present")
		if i>=2: check(current_scene.get_node_or_null("Player") is CharacterBody3D,"physical first-person chapter / "+str(i+1))
		await shot("merged_chapter_"+str(i+1))
		if i==3:
			var overlay = get_nodes_in_group("fps_overlay")[0]
			var page = load("res://scripts/map_page.gd")
			overlay.show_page(page.TEXTS[0])
			await create_timer(0.6).timeout
			check(overlay._page.size.y < 650,"field note fits base viewport")
			await shot("merged_lore")
			overlay.show_page(page.POSTSCRIPTS[0])
			await create_timer(0.6).timeout
			check(overlay._page.size.y < 650,"extended lore fits base viewport")
			await shot("merged_lore_evidence")
			overlay.close_page()
	change_scene_to_file("res://scenes/main_menu.tscn")
	await settle()
	print("MERGED SMOKE / ",checks," CHECKS / ",failures," FAILURES")
	quit(0 if failures==0 else 1)
