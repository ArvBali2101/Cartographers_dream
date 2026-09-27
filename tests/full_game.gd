extends SceneTree

var game: Node
var failures := 0
var total := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool,message: String) -> void:
	total+=1
	if condition: print("PASS / ",message)
	else:
		failures+=1
		push_error("FAIL / "+message)

func key(code: Key,pressed: bool=true) -> void:
	var event := InputEventKey.new()
	event.keycode=code
	event.physical_keycode=code
	event.pressed=pressed
	game._input(event)

func continuation() -> void:
	key(KEY_SPACE)
	key(KEY_SPACE,false)

func capture(name: String) -> void:
	if not "--screenshots" in OS.get_cmdline_user_args(): return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://qa/expanded")
	root.get_texture().get_image().save_png("res://qa/expanded/"+name+".png")

func settle() -> void:
	await process_frame
	await physics_frame
	await physics_frame

func reachable(level: Node,start: Vector2,goal: Vector2,step: float=25) -> bool:
	var origin := start.snapped(Vector2.ONE*step)
	var queue: Array[Vector2]=[origin]
	var seen := {origin:true}
	var index := 0
	while index<queue.size():
		var p := queue[index]
		index+=1
		if p.distance_to(goal)<step*1.5: return true
		for direction in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
			var next: Vector2=p+direction*step
			if next.x<35 or next.y<105 or next.x>level.world_size.x-35 or next.y>level.world_size.y-35: continue
			if seen.has(next) or not level.can_walk(next): continue
			seen[next]=true
			queue.append(next)
	return false

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args():
		push_error("Use -- --test so verification never changes the real journal or leaderboard.")
		quit(1)
		return
	root.size=Vector2i(1280,720)
	game=load("res://Main.tscn").instantiate()
	root.add_child(game)
	await settle()
	game.data.settings.timer=false
	check(game.mode=="menu","main menu loads")
	check(not game.data.settings.timer,"run timer can remain hidden")
	await capture("01_menu")
	game.show_archive()
	check(game.note_open and game.mode=="archive","research field guide is accessible from menu")
	game.close_note()
	game.show_settings()
	await capture("02_settings")
	game.begin_run()
	game.page_time=2
	await capture("03_opening")
	for i in range(game.STORIES.intro.size()): continuation()
	await settle()
	check(game.chapter=="jungle" and game.mode=="play","opening connects to jungle")
	var level: Node=game.level
	check(level.discovery.get_pixel(level.discovery.get_width()-1,0).r==0,"unexplored chart edges start completely hidden")
	check(not level.can_walk(Vector2(820,650)),"river blocks walking")
	check(level.can_walk(Vector2(820,395)) and level.can_walk(Vector2(820,905)),"both bridges permit crossing")
	check(level.in_forest(Vector2(360,590)),"forest terrain affects speed")
	check(level.world_size.x>2100 and level.world_size.y>1400,"jungle geography enlarged")
	check(reachable(level,level.player,Vector2(345,820)),"first record physically reachable")
	check(reachable(level,Vector2(345,820),Vector2(605,310)),"second record physically reachable")
	check(reachable(level,Vector2(605,310),Vector2(1485,160)),"survey exit reachable across river")
	var original: Vector2=level.player
	game.overview=true
	Input.action_press("right")
	level._process(0.2)
	check(level.player==original,"holding map blocks 2D movement")
	game.overview=false
	level._process(0.2)
	check(level.player.x>original.x,"WASD action moves cartographer")
	Input.action_release("right")
	Input.action_press("sprint")
	game.update_endurance(4,true)
	check(game.exhausted and not game.sprinting(),"continuous sprint exhausts the player")
	Input.action_release("sprint")
	game.update_endurance(3,false)
	check(not game.exhausted and game.stamina>0.35,"rest restores usable endurance")
	level.player=Vector2(345,820)
	game.level.interact()
	check(game.note_open,"marker opens real readable record")
	key(KEY_E,false)
	check(game.note_open,"key release cannot close the record")
	key(KEY_E)
	level.player=Vector2(605,310)
	level.interact()
	game.close_note()
	check(reachable(level,Vector2(605,310),Vector2(1130,670)),"third surviving record reachable")
	level.player=Vector2(1130,670)
	level.interact()
	check(game.note_open and game.records.back().contains("DON'T LET IT FOLLOW YOU"),"third survey carries expanded lore")
	game.close_note()
	check(reachable(level,Vector2(1130,670),level.observatory),"new observatory reachable beyond old survey")
	check(reachable(level,level.observatory,level.jungle_exit),"new eastern terminus reachable")
	level.player=level.observatory
	level.interact()
	check(level.bearing_found and game.note_open,"star-bearing account unlocks extended survey")
	game.close_note()
	level.player=level.jungle_exit
	level.camera_center=level.player
	level.reveal(level.player,180)
	level._process(0)
	await capture("04_jungle")
	level.interact()
	game.close_note()
	check(game.mode=="cinema" and game.cinematic=="jungle","jungle ends in campsite transition")
	game.finish_cinematic()
	await settle()
	check(game.chapter=="sea","transition connects to ocean")
	level=game.level
	check(level.world_size.x>=3000,"sea chart substantially larger than viewport")
	check(level.world_size.x>4000 and level.soundings.size()==3,"expanded voyage requires three bell soundings")
	level.player=Vector2(3000,550)
	level.interact()
	check(not game.note_open and game.mode=="play","wharf cannot skip the navigation soundings")
	var previous := Vector2(430,1160)
	for i in range(3):
		check(reachable(level,previous,level.soundings[i],35),"required bell sounding reachable")
		level.player=level.soundings[i]
		level._process(0.01)
		previous=level.soundings[i]
	check(level.charted_soundings.size()==3,"passing each bell records all navigation bearings")
	check(level.scare_done,"second sounding triggers submerged-eye scare")
	check(reachable(level,level.player,Vector2(3000,550),35),"ocean has a navigable route to wharf")
	check(reachable(level,level.player,Vector2(2100,250),40) and reachable(level,Vector2(2100,250),Vector2(3000,550),40),"northern sea route remains viable")
	check(reachable(level,level.player,Vector2(2400,1560),40) and reachable(level,Vector2(2400,1560),Vector2(3000,550),40),"longer southern sea route remains viable")
	level.player=Vector2(3000,485)
	check(level.dockable() and level.can_walk(level.player),"wharf can be approached from north")
	level.player=Vector2(3000,565)
	check(level.dockable() and level.can_walk(level.player),"wharf can be approached from south")
	level.tentacles.clear()
	level.tentacles.append({"pos":Vector2(3100,600),"stunned":0.0,"phase":0.0})
	level.flare()
	check(level.tentacles[0].stunned>0 and level.flare_count==2,"flare consumes a charge and stuns a tentacle")
	level.camera_center=level.player
	level.reveal(level.player,350)
	level._process(0)
	await capture("05_sea")
	level.age=level.sea_deadline+0.1
	level._process(2.1)
	check(game.mode=="death","expanded voyage deadline still causes drowning")
	game.enter_chapter("sea")
	await settle()
	level=game.level
	for i in range(3):
		level.player=level.soundings[i]
		level._process(0.01)
	level.player=Vector2(3000,550)
	level.interact()
	game.close_note()
	check(game.cinematic=="sea","docking connects to city cutscene")
	game.finish_cinematic()
	await settle()
	check(game.chapter=="city","dream city chapter exists")
	level=game.level
	for building in ["home","archive","inn","tower"]:
		level.player=level.city_doors[building]
		level.interact()
		check(level.interior==building,"enter city building / "+building)
		level.player=Vector2(845,490)
		level.interact()
		check(game.note_open,"city room has story interaction / "+building)
		game.close_note()
		level.player=Vector2(180,945)
		level.interact()
	check(level.city_clues.size()==4 and level.city_clues.has("tower"),"four accounts include required exhibition")
	check(reachable(level,level.city_doors.home,level.city_doors.cave),"expanded city passage physically reachable")
	level.player=Vector2(960,520)
	level.camera_center=level.player
	level.reveal(level.player,330)
	level._process(0)
	await capture("06_city")
	level.player=level.city_doors.cave
	level.interact()
	game.close_note()
	game.finish_cinematic()
	await settle()
	check(game.chapter=="cave" and game.level is Node3D,"cave transitions into actual 3D")
	level=game.level
	check(level.paintings.size()==4,"four red-ochre murals exist")
	check(level.layout.width*level.layout.height>=63,"cave now contains sixty-three cells")
	check(level.layout.route(Vector2i.ZERO,level.layout.finish).size()>3,"cave route is connected")
	level.player.position=Vector3(0,0.9,4)
	level._process(0.01)
	check(level.sealed and level.seal.collision_layer==1,"cave entrance becomes solid stone")
	for i in range(4):
		var painting: Dictionary=level.paintings[i]
		level.player.position=painting.pos-Vector3(0,0.9,0)
		level.interact()
		if game.note_open: game.close_note()
	check(level.seen_paintings.size()==4,"all four ancient warnings can be read")
	var mural: Dictionary=level.paintings[2]
	level.player.position=level.layout.point(level.layout.cell_at(mural.pos))+Vector3(0,0.9,0)
	level.camera.look_at(mural.pos,Vector3.UP)
	await capture("07_cave")
	level.player.position=level.finish_point+Vector3(0,0.9,0)
	level.interact()
	check(game.cinematic=="cave","cave leads to Blind God cutscene")
	game.page=2
	game.page_time=2
	await capture("08_blind_god")
	game.finish_cinematic()
	await settle()
	check(game.chapter=="maze" and game.level is Node3D,"finale is first person 3D")
	level=game.level
	if DisplayServer.get_name() != "headless":
		var yaw_before: float=level.player.rotation.y
		var mouse := InputEventMouseMotion.new()
		mouse.relative=Vector2(30,0)
		Input.parse_input_event(mouse)
		Input.flush_buffered_events()
		await process_frame
		check(not is_equal_approx(yaw_before,level.player.rotation.y),"real mouse events turn first-person camera")
	else:
		print("SKIP / captured mouse requires a real window; verified in renderer run")
	check(level.layout.width*level.layout.height>=240,"labyrinth contains over 240 connected cells")
	check(level.layout.width*level.layout.height==323,"final labyrinth expanded to 323 cells")
	check(level.layout.route(Vector2i.ZERO,level.layout.key_cell).size()>8,"key requires exploration")
	check(level.layout.route(level.layout.key_cell,level.layout.finish).size()>8,"key and exit lie in different parts of maze")
	check(level.exit_door.locked and not level.exit_door.interact(false),"exit refuses to open without key")
	check(level.player.get_children().filter(func(node): return node is MeshInstance3D).is_empty(),"first-person player has no visible body")
	var before: Vector3=level.player.position
	game.overview=true
	Input.action_press("forward")
	level._physics_process(0.1)
	check(level.player.position==before,"survey camera blocks first-person movement")
	game.overview=false
	Input.action_release("forward")
	await capture("09_maze")
	var door: Node3D=level.doors[1]
	var normal: Vector3=door.global_basis.z
	var center: Vector3=door.global_position+door.global_basis.x*1.075
	level.player.position=center-normal*1.05+Vector3(0,0.9,0)
	await physics_frame
	var collision: KinematicCollision3D=level.player.move_and_collide(normal*2.1)
	check(collision!=null,"closed wooden door physically blocks player")
	door.interact(false)
	await create_timer(1.1).timeout
	check(absf(door.pivot.rotation.y)>1,"door swings on hinge")
	level.player.position=center-normal*1.05+Vector3(0,0.9,0)
	await physics_frame
	collision=level.player.move_and_collide(normal*2.1)
	check(collision==null,"open doorway allows physical passage")
	level.player.position=level.key_object.position
	await physics_frame
	await physics_frame
	check(level.has_key,"key is collected by touching its 3D trigger")
	check(not level.exit_door.interact(level.has_key),"key alone cannot bypass the two witnessing seals")
	check(level.witnesses.size()==2 and level.inscriptions.size()==5,"maze contains two seals and five lore inscriptions")
	for i in range(2):
		check(level.layout.route(Vector2i.ZERO,level.witnesses[i].cell).size()>8,"witness seal requires a reachable detour")
		level.player.position=level.witnesses[i].pos+Vector3(0,0.9,0)
		level.interact()
		check(level.witnesses[i].broken,"interacting breaks witness seal")
		if game.note_open: game.close_note()
	check(level.seals_broken==2,"both erased signatures remembered")
	check(level.hunt_surge>0,"breaking a seal triggers a telegraphed pursuit surge")
	check(level.exit_door.interact(level.has_key),"key unlocks the exit door")
	level.player.position=center+Vector3(0,0.9,0)
	level.creature.position=level.player.position+Vector3(0.8,0,0)
	level.move_creature(0.001)
	check(game.mode=="capture","being caught selects capture ending")
	game.capture_time=0.6
	await capture("10_capture")
	game._process(3)
	check(game.cinematic=="lose","blood and fade connect to losing story")
	game.enter_chapter("maze")
	await settle()
	level=game.level
	level.collect_key()
	level.break_witness(0)
	game.close_note()
	level.break_witness(1)
	game.close_note()
	level.exit_door.interact(true)
	level.player.position=level.finish_point+Vector3(0,0.9,0)
	level._process(0.01)
	check(game.cinematic=="win" and game.final_result=="escape","doorway of light selects escape ending")
	game.page_time=2
	await capture("11_morning")
	game.finish_cinematic()
	check(game.cinematic=="sting","morning and epilogue connect to approaching figure")
	game.page_time=7
	await capture("12_sting")
	key(KEY_SPACE)
	game._process(1.5)
	check(game.cinematic=="sting","final sting cannot be skipped by holding continue")
	key(KEY_SPACE,false)
	continuation()
	check(game.mode=="leaderboard","credits connect to local leaderboard")
	check(not game.data.scores.is_empty(),"completed escape records a local time")
	await capture("13_leaderboard")
	print("FULL GAME CHECKS: ",total," / FAILURES: ",failures)
	game.queue_free()
	await process_frame
	game=null
	await process_frame
	quit(1 if failures else 0)
