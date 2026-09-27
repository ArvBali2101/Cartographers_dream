extends SceneTree

var app: Node

func safe_water(level: Node,point: Vector2) -> bool:
	for offset in [Vector2.ZERO,Vector2(35,0),Vector2(-35,0),Vector2(0,35),Vector2(0,-35)]:
		if not level.can_walk(point+offset): return false
	return true

func _initialize() -> void:
	call_deferred("run")

func route(level: Node,start: Vector2,goal: Vector2) -> Array[Vector2]:
	var step := 30.0
	var origin := start.snapped(Vector2.ONE*step)
	var queue: Array[Vector2]=[origin]
	var parent := {origin:origin}
	var cursor := 0
	var last := origin
	var found := false
	while cursor<queue.size():
		var at := queue[cursor]
		cursor+=1
		if at.distance_to(goal)<step:
			last=at
			found=true
			break
		for d in [Vector2.RIGHT,Vector2.DOWN,Vector2.UP,Vector2.LEFT]:
			var next: Vector2=at+d*step
			if next.x<35 or next.y<105 or next.x>level.world_size.x-35 or next.y>level.world_size.y-35: continue
			if parent.has(next) or not safe_water(level,next): continue
			parent[next]=at
			queue.append(next)
	if not found: return []
	var result: Array[Vector2]=[last,goal]
	while last!=origin:
		last=parent[last]
		result.push_front(last)
	return result

func run() -> void:
	if not "--test" in OS.get_cmdline_user_args(): quit(1); return
	app=load("res://Main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.enter_chapter("sea")
	await process_frame
	var level: Node=app.level
	var targets: Array[Vector2]=[]
	# The soundings can be charted in any order. Sweep the southern open sea
	# before returning north, rather than reversing into the pursuing pack.
	targets.assign([level.soundings[0],level.soundings[2],level.soundings[1]])
	targets.append(Vector2(2980,550))
	var success := true
	for target in targets:
		var path := route(level,level.player,target)
		if path.is_empty(): success=false; break
		for waypoint in path:
			var budget := 0
			var tolerance := 12.0 if waypoint==targets.back() else 38.0
			while level.player.distance_to(waypoint)>tolerance and app.mode=="play":
				budget+=1
				if budget>100:
					print("BOT STUCK / ",level.player," -> ",waypoint)
					success=false
					break
				var direction: Vector2=(waypoint-level.player).normalized()
				if app.stamina>0.05 and not app.exhausted: Input.action_press("sprint")
				else: Input.action_release("sprint")
				for action in ["left","right","forward","back"]: Input.action_release(action)
				if direction.x>0.15: Input.action_press("right",absf(direction.x))
				if direction.x< -0.15: Input.action_press("left",absf(direction.x))
				if direction.y>0.15: Input.action_press("back",absf(direction.y))
				if direction.y< -0.15: Input.action_press("forward",absf(direction.y))
				for tentacle in level.tentacles:
					if level.player.distance_to(tentacle.pos)<75 and level.flare_count>0 and tentacle.stunned<=0: level.flare(); break
				level._process(0.05)
			if not success or app.mode!="play": success=false; break
		if not success: break
	for action in ["left","right","forward","back"]: Input.action_release(action)
	Input.action_release("sprint")
	success=success and app.mode=="play" and level.charted_soundings.size()==3 and level.dockable() and level.age<level.sea_deadline
	print("LIVE VOYAGE / ","PASS" if success else "FAIL"," / ",snappedf(level.age,0.01),"s / flares left ",level.flare_count," / pursuit active ",level.tentacles.size()," / mode ",app.mode," / position ",level.player)
	app.queue_free()
	await process_frame
	await process_frame
	quit(0 if success else 1)
