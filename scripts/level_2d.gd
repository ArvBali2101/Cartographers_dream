extends Node2D

var app: Node
var chapter := "jungle"
var world_size := Vector2(2230,1450)
var player := Vector2(130,915)
var camera_center := Vector2(430,780)
var facing := 0.0
var velocity := Vector2.ZERO
var age := 0.0
var clock := 0.0
var records := {}
var figure := Vector2(1120,350)
var skull_seen := false
var coat: ColorRect
var discovery: Image
var ink: ImageTexture
var paint_clock := 0.0
var tents: Array[Vector2] = []
var islands: Array[Vector3] = []
var tentacles: Array[Dictionary] = []
var flares: Array[Dictionary] = []
var flare_count := 3
var spawn_clock := 0.0
var drown_time := 0.0
var city_clues := {}
var interior := ""
var body_door := ""
var city_doors := {"home":Vector2(410,365),"archive":Vector2(890,365),"wrong":Vector2(1250,365),"inn":Vector2(430,850),"tower":Vector2(920,850),"chapel":Vector2(1800,725),"cave":Vector2(1960,1260)}
var interior_spawn := Vector2.ZERO
const LORE = preload("res://scripts/lore.gd")
var jungle_exit := Vector2(2170,180)
var observatory := Vector2(1910,1160)
var bearing_found := false
var soundings: Array[Vector2]=[Vector2(1090,1280),Vector2(2220,470),Vector2(3800,1500)]
var charted_soundings := {}
var sea_deadline := 90.0
var scare_time := 0.0
var scare_done := false

func _ready() -> void:
	if chapter=="sea":
		world_size=Vector2(4200,1900)
		player=Vector2(430,1160)
		camera_center=player
		islands=[Vector3(130,1150,220),Vector3(1540,1120,125),Vector3(1850,780,145),Vector3(2100,1120,130),Vector3(2390,680,150),Vector3(2550,1210,95),Vector3(2800,915,115),Vector3(3220,520,185),Vector3(1910,1450,85),Vector3(2670,350,100)]
	elif chapter=="city":
		world_size=Vector2(2180,1450)
		player=Vector2(190,1010)
		camera_center=player
	setup_discovery()
	app.toast("The chart remembers only where you have walked. Hold TAB to survey it.")

func setup_discovery() -> void:
	discovery=Image.create(int(world_size.x/10),int(world_size.y/10),false,Image.FORMAT_R8)
	discovery.fill(Color.BLACK)
	ink=ImageTexture.create_from_image(discovery)
	coat=ColorRect.new()
	coat.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var shader := ShaderMaterial.new()
	shader.shader=preload("res://shaders/cartography.gdshader")
	shader.set_shader_parameter("discovery",ink)
	shader.set_shader_parameter("world_size",world_size)
	coat.material=shader
	add_child(coat)
	reveal(player,235)

func reveal(center: Vector2,radius: float) -> void:
	var p := center/10
	var r := radius/10
	for y in range(maxi(0,int(p.y-r)),mini(discovery.get_height(),int(p.y+r)+1)):
		for x in range(maxi(0,int(p.x-r)),mini(discovery.get_width(),int(p.x+r)+1)):
			var value := clampf((r-Vector2(x,y).distance_to(p))/4.0,0,1)
			if value>discovery.get_pixel(x,y).r: discovery.set_pixel(x,y,Color(value,value,value))
	ink.update(discovery)

func _process(delta: float) -> void:
	clock+=delta
	if app.mode=="play" and not app.paused and not app.note_open:
		age+=delta
		if chapter=="sea":
			if age>=sea_deadline:
				drown_time+=delta
				if drown_time>2.0: app.fail_run("DROWNED")
			elif app.active(): update_tentacles(delta)
	if app.active() and drown_time<=0:
		scare_time=maxf(0,scare_time-delta)
		var d := Input.get_vector("left","right","forward","back")
		app.update_endurance(delta,d.length()>0)
		if d.length()>0: facing=lerp_angle(facing,d.angle(),minf(1,delta*10))
		if chapter=="sea":
			velocity=velocity.move_toward(d*(245 if app.sprinting() else 190),delta*260)
			move_player(velocity*delta)
		else:
			var speed := 205.0 if app.sprinting() else 145.0
			if chapter=="jungle" and in_forest(player): speed*=0.65
			move_player(d*speed*delta)
		if chapter=="jungle":
			if player.distance_to(figure)<150: figure+=Vector2(235,-25)*delta
			if player.distance_to(Vector2(575,870))<70 and not skull_seen:
				skull_seen=true
				app.toast("A skull beside a marker. Its ink is still wet.")
		if chapter=="sea":
			for i in range(soundings.size()):
				if not charted_soundings.has(i) and player.distance_to(soundings[i])<85:
					charted_soundings[i]=true
					flare_count=mini(3,flare_count+1)
					app.play_cue("bell")
					app.toast("Sounding %d recorded. A signal flare recovered. Chart all three, in any order." % (i+1))
			if charted_soundings.size()>=2 and not scare_done:
				scare_done=true
				scare_time=3.0
				app.play_cue("pulse")
				app.toast("That was not an island moving beneath the keel.")
		paint_clock+=delta
		if paint_clock>0.12:
			paint_clock=0
			reveal(player,290 if chapter=="sea" else 235)
	var zoom := 1.05 if chapter=="sea" else 1.35
	if app.overview: zoom=minf(1160/world_size.x,540/world_size.y)
	var half_view := Vector2(640/zoom,300/zoom)
	var focus := world_size/2 if app.overview else player.clamp(half_view,world_size-half_view)
	camera_center=camera_center.lerp(focus,1-exp(-delta*8)) if not app.overview else focus
	var offset := Vector2(640,370)-camera_center*zoom
	coat.visible=interior.is_empty()
	coat.position=offset
	coat.size=world_size*zoom
	queue_redraw()

func move_player(displacement: Vector2) -> void:
	var next := player+displacement
	if can_walk(Vector2(next.x,player.y)): player.x=next.x
	if can_walk(Vector2(player.x,next.y)): player.y=next.y
	player=player.clamp(Vector2(35,105),world_size-Vector2(35,35))

func jungle_walls() -> Array[Rect2]:
	return [Rect2(170,175,340,38),Rect2(530,500,38,220),Rect2(1090,240,260,38),Rect2(1280,750,38,210),Rect2(1770,380,38,410)]

func river(point: Vector2) -> bool:
	var center := 820.0+sin(point.y/155.0)*18.0
	var water := absf(point.x-center)<51
	var bridges := Rect2(742,350,155,95).has_point(point) or Rect2(742,865,155,95).has_point(point)
	return water and not bridges

func can_walk(p: Vector2) -> bool:
	if not interior.is_empty(): return Rect2(70,110,1530,930).has_point(p)
	if chapter=="jungle":
		if river(p): return false
		for wall in jungle_walls():
			if wall.grow(12).has_point(p): return false
	elif chapter=="sea":
		for island in islands:
			if p.distance_to(Vector2(island.x,island.y))<island.z+8: return false
			for i in range(7):
				var rock := Vector2(island.x,island.y)+Vector2.from_angle(i*TAU/7)*(island.z+17)
				if p.distance_to(rock)<12: return false
	elif chapter=="city":
		for house in houses():
			if house.grow(12).has_point(p): return false
	return true

func in_forest(p: Vector2) -> bool:
	return Rect2(290,510,260,200).has_point(p) or Rect2(1000,440,240,280).has_point(p)

func update_tentacles(delta: float) -> void:
	spawn_clock+=delta
	if age>6 and spawn_clock>5.5 and tentacles.size()<7:
		spawn_clock=0
		var angle := PI+facing+(tentacles.size()%2-0.5)*1.4
		tentacles.append({"pos":player+Vector2.from_angle(angle)*260,"stunned":0.0,"phase":tentacles.size()*2.7})
	for tentacle in tentacles:
		tentacle.stunned=maxf(0,tentacle.stunned-delta)
		for light in flares:
			if light.life>0 and tentacle.pos.distance_to(light.pos)<180: tentacle.stunned=maxf(tentacle.stunned,0.35)
		if tentacle.stunned<=0:
			var p: Vector2=tentacle.pos
			var target: Vector2=p.move_toward(player,171*delta)
			if can_walk(target): tentacle.pos=target
			else: tentacle.pos=p+(player-p).normalized().orthogonal()*delta*105
			if tentacle.pos.distance_to(player)<22: app.fail_run("TAKEN BENEATH THE CHART")
	for flare_item in flares: flare_item.life-=delta
	flares=flares.filter(func(item): return item.life>0)

func flare() -> void:
	if chapter!="sea" or not app.active(): return
	if flare_count<=0:
		app.toast("No flares remain.")
		return
	flare_count-=1
	flares.append({"pos":player,"life":5.0})
	for tentacle in tentacles:
		if tentacle.pos.distance_to(player)<360: tentacle.stunned=4.5
	app.toast("The light holds them back. %d flares remain." % flare_count)

func houses() -> Array[Rect2]:
	return [Rect2(260,170,300,180),Rect2(710,145,350,205),Rect2(1150,170,270,180),Rect2(275,620,300,215),Rect2(770,630,300,205),Rect2(1660,515,290,195)]

func dockable() -> bool:
	return chapter=="sea" and Rect2(2950,430,102,200).has_point(player)

func interact() -> void:
	if not app.active(): return
	if chapter=="jungle":
		if player.distance_to(observatory)<90:
			bearing_found=true
			app.play_cue("knock")
			app.show_note("THE UNLISTED OBSERVATORY",LORE.OBSERVATORY)
			return
		for marker in [["I",Vector2(345,820)],["II",Vector2(605,310)],["IV",Vector2(1130,670)]]:
			if player.distance_to(marker[1])<75:
				var id: String=marker[0]
				records[id]=true
				app.show_note("EXPEDITION "+id,LORE.RECORDS[id])
				return
		if player.distance_to(jungle_exit)<90:
			if records.has("I") and records.has("II") and records.has("IV") and bearing_found:
				app.show_note("SURVEY COMPLETE","The destination is where I left it.\n\nBut another mark moves on the page. It turns when I turn.\n\nFrom under the paper: look.",app.chapter_complete)
			else: app.toast("Find surveys I, II, IV and the unlisted eastern observatory.")
	elif chapter=="sea":
		if dockable():
			if charted_soundings.size()<3:
				app.toast("Three bell soundings locate the real shore. Hold TAB to see their marks.")
				return
			app.show_note("THE WHARF","Three tents. No people.\n\nBeyond them, a city I have never drawn.\n\nThe water has become absolutely still.",app.chapter_complete)
		elif player.distance_to(Vector2(2390,680))<245: app.show_note("BONES / THE SHIP'S LOG","These ribs are taller than the ship. A compass bears my initials.\n\nThe wreck's log records our arrival tomorrow. The final entry reads: no shore is safe after it has been named.\n\nA chart tucked under the compass shows a white doorway beyond two crossed eyes.")
	elif chapter=="city": interact_city()

func interact_city() -> void:
	if not interior.is_empty():
		if player.distance_to(Vector2(180,945))<110:
			player=city_doors.home if interior=="tower" else interior_spawn
			if interior=="tower": app.toast("The door returns to the opposite side of the city.")
			interior=""
			return
		if player.distance_to(Vector2(845,490))<130:
			city_clues[interior]=true
			app.play_cue("knock")
			app.show_note("THE "+interior.to_upper(),LORE.CHAPEL if interior=="chapel" else LORE.EXHIBITION if interior=="tower" else LORE.RECORDS.get(interior,"A blank page."))
		return
	for door_name in city_doors:
		if player.distance_to(city_doors[door_name])<95:
			if door_name=="cave":
				if city_clues.size()>=4 and city_clues.has("tower"): app.show_note("BELOW THE CITY","The exhibition was a trap. It borrowed my memories.\n\nThe old cave is not an escape yet, but its marks describe how to cut the two witnessing lines.\n\nSomeone has drawn a doorway on the rock. It is open.",app.chapter_complete)
				else: app.toast("Find four city accounts, including the tower exhibition.")
			elif door_name=="wrong": app.fail_run("WRONG DOOR")
			else:
				interior_spawn=player
				interior=door_name
				player=Vector2(180,925)
				app.toast("E / SPACE at the table. The lower-left doorway leads back outside.")
			return

func objective() -> String:
	if chapter=="jungle": return "Surveys %d / 3. Eastern observatory: %s. Reach the ridge terminus." % [records.size(),"FOUND" if bearing_found else "MISSING"]
	if chapter=="sea": return "Bell soundings %d / 3. Then dock at the wharf. Flares: %d" % [charted_soundings.size(),flare_count]
	return "Find four accounts and the tower exhibition, then descend.  %d / 4" % mini(city_clues.size(),4)

func prompt() -> String:
	if app.overview: return "SURVEY VIEW / Release TAB to return. Movement is disabled."
	if chapter=="jungle":
		if player.distance_to(observatory)<90: return "E / SPACE  READ THE STAR BEARINGS"
		for p in [Vector2(345,820),Vector2(605,310),Vector2(1130,670)]:
			if player.distance_to(p)<75: return "E / SPACE  EXAMINE RECORD"
		if player.distance_to(jungle_exit)<90: return "E / SPACE  COMPLETE SURVEY"
	elif chapter=="sea" and dockable(): return "E / SPACE  DOCK AT WHARF"
	elif chapter=="city":
		if not interior.is_empty():
			if player.distance_to(Vector2(180,945))<110: return "E / SPACE  RETURN TO STREET"
			if player.distance_to(Vector2(845,490))<130: return "E / SPACE  EXAMINE"
		else:
			for name in city_doors:
				if player.distance_to(city_doors[name])<95: return "E / SPACE  ENTER / "+name.to_upper()
	return ""

func whisper() -> String:
	if chapter=="sea" and age>20: return ["keep going","closer","we remember","you drew the way"][int(age/7)%4]
	if chapter=="city" and age>18: return ["he noticed you","you draw very well","how is the expedition going?"][int(age/12)%3]
	return ""

func danger_level() -> float:
	if chapter=="sea": return clampf(age/sea_deadline+scare_time*0.12,0,1)
	if chapter=="city": return 0.35+float(city_clues.size())*0.08
	return 0.12 if records.is_empty() else 0.28

func _draw() -> void:
	draw_rect(Rect2(0,0,1280,720),Color("#c8b995"))
	var zoom := 1.05 if chapter=="sea" else 1.35
	if app.overview: zoom=minf(1160/world_size.x,540/world_size.y)
	draw_set_transform(Vector2(640,370)-camera_center*zoom,0,Vector2.ONE*zoom)
	if chapter=="jungle": draw_jungle()
	elif chapter=="sea": draw_sea()
	elif interior.is_empty(): draw_city()
	else: draw_interior()
	if interior.is_empty(): draw_atlas_details()
	if chapter=="sea": app.art.boat(self,player,facing,clock,velocity.length()>5)
	else: app.art.person(self,player,facing,clock,Input.get_vector("left","right","forward","back").length()>0 and app.active())
	draw_set_transform(Vector2.ZERO)

func draw_jungle() -> void:
	draw_texture_rect(app.art.ground,Rect2(Vector2.ZERO,world_size),false)
	draw_rect(Rect2(Vector2.ZERO,world_size),Color(0.68,0.59,0.36,0.2))
	var trails := PackedVector2Array([Vector2(130,915),Vector2(345,820),Vector2(285,550),Vector2(290,295),Vector2(605,310),Vector2(715,400),Vector2(955,400),Vector2(1040,590),Vector2(1130,670),Vector2(1490,1080),observatory,Vector2(2010,930),Vector2(2060,400),jungle_exit])
	app.art.path(self,trails)
	app.art.path(self,PackedVector2Array([Vector2(345,820),Vector2(640,950),Vector2(950,910),Vector2(1130,670)]))
	var water := PackedVector2Array()
	for y in range(0,int(world_size.y)+20,20): water.append(Vector2(820+sin(y/155.0)*18-53,y))
	for y in range(int(world_size.y),-20,-20): water.append(Vector2(820+sin(y/155.0)*18+53,y))
	draw_colored_polygon(water,Color("#45686a"))
	for y in range(10,int(world_size.y),28): draw_line(Vector2(790,y),Vector2(845,y+4),Color(0.68,0.78,0.72,0.26),1)
	for at in [Vector2(745,365),Vector2(745,880)]:
		draw_rect(Rect2(at,Vector2(152,60)),Color("#4e3f2c"))
		for x in range(0,151,9): draw_line(at+Vector2(x,0),at+Vector2(x,60),Color("#aa9062"),6)
		for edge in [0,60]: draw_line(at+Vector2(0,edge),at+Vector2(152,edge),Color("#d1b87e"),3)
	for i in range(310):
		var p := Vector2(50+fmod(i*157,world_size.x-80),120+fmod(i*97,world_size.y-155))
		if not app.overview and (absf(p.x-camera_center.x)>580 or absf(p.y-camera_center.y)>370): continue
		if absf(p.x-820)<110 or app.art.distance_to_route(p,trails)<68 or p.distance_to(Vector2(130,915))<100: continue
		app.art.palm(self,p,0.75+fmod(p.x,17)/20,clock)
	for wall in jungle_walls():
		for x in range(int(wall.position.x),int(wall.end.x),22):
			for y in range(int(wall.position.y),int(wall.end.y),25): app.art.rock(self,Vector2(x,y),21)
	for i in range(4): draw_arc(Vector2(300,180),120+i*16,PI,TAU,32,Color(0.67,0.66,0.49,0.3),1)
	app.art.camp(self,Vector2(125,915),clock)
	app.art.camp(self,Vector2(200,1000),clock)
	for item in [["I",Vector2(345,820)],["II",Vector2(605,310)],["IV",Vector2(1130,670)]]: signpost(item[1],item[0])
	app.art.ruins(self,jungle_exit)
	app.art.ruins(self,observatory)
	for i in range(4): draw_arc(observatory,25+i*13,0,TAU,32,Color("#8b8d6d"),1)
	note(observatory+Vector2(-65,-80),"UNLISTED OBSERVATORY")
	if records.has("I") and age<90: draw_figure(figure)
	draw_circle(Vector2(575,870),11,Color("#c2bb9c"))
	for x in [-4,4]: draw_circle(Vector2(575+x,867),3,Color("#282e26"))
	note(Vector2(440,730),"dense woodland")
	note(Vector2(910,210),"the bridge is further south")
	note(jungle_exit+Vector2(-70,-65),"RIDGE TERMINUS")

func draw_sea() -> void:
	draw_rect(Rect2(Vector2.ZERO,world_size),Color("#8b947f"))
	draw_texture_rect(app.art.ocean,Rect2(Vector2.ZERO,world_size),false,Color(0.72,0.81,0.68,0.62))
	for i in range(190):
		var p := Vector2(fmod(i*213+clock*6,world_size.x),90+fmod(i*103,world_size.y-130))
		draw_arc(p,25,0.1,0.8,8,Color(0.65,0.76,0.65,0.19),1)
	for island in islands:
		var p := Vector2(island.x,island.y)
		app.art.island(self,p,island.z,clock)
		for i in range(7):
			var angle := i*TAU/7
			app.art.rock(self,p+Vector2.from_angle(angle)*(island.z+17),8+(i%3)*3)
	# Only three tents at the destination; no wandering ghost ships.
	for i in range(3):
		var p := Vector2(3190+i*48,510+(i%2)*65)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-22,15),p+Vector2(0,-20),p+Vector2(25,15)]),Color("#c7ba91"))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-9,15),p+Vector2(0,-7),p+Vector2(9,15)]),Color("#333f34"))
	draw_rect(Rect2(3025,500,185,35),Color("#554936"))
	for x in range(3030,3205,12): draw_line(Vector2(x,500),Vector2(x,535),Color("#ae9d70"),7)
	note(Vector2(2960,400),"DOCK / either side")
	for i in range(7): draw_arc(Vector2(2390+i*13,670),38,2,4.6,18,Color("#c2bea3"),5)
	var shadow := Vector2(1450+sin(clock*0.15)*800,970)
	draw_circle(shadow,230,Color(0.01,0.06,0.05,0.12))
	for i in range(soundings.size()):
		var at := soundings[i]
		for ring in range(4): draw_circle(at,16+ring*12,Color(0.9,0.75,0.42,0.028))
		draw_line(at+Vector2(0,12),at+Vector2(0,-28),Color("#554638"),5)
		draw_circle(at+Vector2(0,-22),7,Color("#cbb075") if not charted_soundings.has(i) else Color("#83ac90"))
		note(at+Vector2(-42,40),"BELL / %d" % (i+1))
	for i in range(9):
		var at := Vector2(3440+i*43,990+sin(i)*80)
		draw_colored_polygon(PackedVector2Array([at+Vector2(-15,25),at+Vector2(0,-80-i*7),at+Vector2(22,18)]),Color(0.11,0.20,0.19,0.55))
	if scare_time>0:
		var at := player+Vector2(0,90)
		for i in range(8): draw_arc(at,80+i*14,0.1,3.0,32,Color(0.02,0.08,0.07,0.07),5)
		app.art.eye(self,at,90*sin(minf(1,scare_time/3)*PI),clock)
	for tentacle in tentacles: draw_tentacle(tentacle.pos,tentacle.phase,tentacle.stunned>0)
	for item in flares:
		for i in range(6): draw_circle(item.pos,50+i*38,Color(1,0.54,0.2,(6-i)*0.012))
		draw_circle(item.pos,6,Color("#ffe4a2"))
	if drown_time>0:
		for i in range(9): draw_tentacle(player+Vector2.from_angle(i*TAU/9)*(150-drown_time*42),i,false)
		draw_circle(player,95,Color(0,0.02,0.02,0.45))
	note(Vector2(700,500),"uncharted waters")

func draw_tentacle(at: Vector2,phase: float,stunned: bool) -> void:
	for i in range(23):
		var p := at+Vector2(sin(i*0.12+clock*2+phase)*22,-i*3.3)*0.9
		draw_circle(p,(17-i*0.58)*0.9,Color("#242a20") if not stunned else Color("#756e46"))
		draw_circle(p+Vector2(5,0),maxf(1,4-i*0.12),Color("#9f7952"))
		if i%3==0: draw_circle(p+Vector2(-3,0),2,Color("#4e6450"))

func draw_city() -> void:
	draw_texture_rect(app.art.stone,Rect2(Vector2.ZERO,world_size),false)
	for y in range(120,int(world_size.y),36):
		for x in range(0,int(world_size.x),55): draw_rect(Rect2(x+(y%2)*20,y,53,34),Color(0.44,0.48,0.39,0.16),false,1)
	for house in houses():
		draw_rect(Rect2(house.position+Vector2(15,20),house.size),Color(0,0,0,0.4))
		draw_rect(house,Color("#545849"))
		draw_line(house.position+Vector2(0,house.size.y/2),house.position+Vector2(house.size.x,house.size.y/2),Color("#879079"),4)
		for x in range(int(house.position.x)+15,int(house.end.x),18): draw_line(Vector2(x,house.position.y),Vector2(x,house.end.y),Color("#353f38"),1)
		# Slate roof courses, projecting cornice, windows and creeping ivy.
		for y in range(int(house.position.y)+10,int(house.end.y)-18,16):
			draw_line(Vector2(house.position.x+5,y),Vector2(house.end.x-5,y),Color("#677063"),1)
		draw_rect(Rect2(house.position-Vector2(7,6),Vector2(house.size.x+14,9)),Color("#93927a"))
		for x in range(int(house.position.x)+26,int(house.end.x)-16,58):
			var window := Vector2(x,house.end.y-8)
			draw_rect(Rect2(window,Vector2(17,13)),Color("#151f20"))
			draw_line(window+Vector2(8,0),window+Vector2(8,13),Color("#a09c78"),1)
		for i in range(12):
			var leaf := house.position+Vector2(6+sin(i*2)*9,15+i*12)
			draw_circle(leaf,5,Color("#354e40"))
	for name in city_doors:
		var p: Vector2=city_doors[name]
		draw_rect(Rect2(p-Vector2(19,15),Vector2(38,25)),Color("#aa8c5e"))
		note(p+Vector2(-45,45),"NO FLOOR" if name=="wrong" else "way below" if name=="cave" else name)
	draw_figure(Vector2(780,480))
	for p in [Vector2(320,550),Vector2(1070,980),Vector2(1310,520)]:
		for i in range(5): draw_circle(p,12+i*9,Color(0.86,0.87,0.71,0.015))
		draw_circle(p,4,Color("#e1ddb7"))
	note(Vector2(95,990),"the city from whence we came")

func draw_interior() -> void:
	draw_rect(Rect2(50,95,1560,980),Color("#403b31"))
	for y in range(115,1060,35): draw_line(Vector2(70,y),Vector2(1590,y),Color("#272b24"),2)
	draw_rect(Rect2(695,400,300,170),Color("#745e40"))
	draw_rect(Rect2(785,450,130,75),Color("#cec09b"))
	for i in range(5): draw_line(Vector2(800,465+i*8),Vector2(902,468+i*8),Color("#746b50"),1)
	draw_rect(Rect2(130,1000,95,45),Color("#b5af86"))
	note(Vector2(120,990),"street")
	if interior=="archive":
		for x in range(310,1410,150):
			draw_rect(Rect2(x,160,90,180),Color("#695637"))
			for y in range(170,320,20): draw_line(Vector2(x+5,y),Vector2(x+85,y),Color("#b9a778"),6)
			for i in range(3):
				var at := Vector2(x+15,185+i*48)
				draw_rect(Rect2(at,Vector2(60,37)),Color("#c2b58e"))
				draw_circle(at+Vector2(36,15),2.5,Color("#203128"))
	elif interior=="inn": app.art.person(self,Vector2(965,465),PI,clock,false)
	if interior=="tower": draw_figure(Vector2(1100,260))
	if interior=="tower":
		draw_rect(Rect2(1000,180,360,190),Color("#111c1b"))
		app.art.eye(self,Vector2(1180,270),65,clock)
	if interior=="chapel":
		for x in [300,1100]:
			for i in range(6): draw_arc(Vector2(x,400)+Vector2.from_angle(i*TAU/6)*35,35,0,TAU,32,Color("#a6a188"),2)

func signpost(at: Vector2,text: String) -> void:
	draw_line(at+Vector2(0,-15),at+Vector2(0,20),Color("#7d6749"),4)
	draw_rect(Rect2(at+Vector2(-17,-25),Vector2(34,23)),Color("#62523c"))
	draw_string(ThemeDB.fallback_font,at+Vector2(-8,-9),text,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#dbcd9c"))

func draw_atlas_details() -> void:
	# All marks use world coordinates and remain under the discovery mask.
	var color := Color(0.79,0.77,0.60,0.19)
	for x in range(0,int(world_size.x),240): draw_line(Vector2(x,105),Vector2(x,world_size.y),color,0.7)
	for y in range(120,int(world_size.y),240): draw_line(Vector2(25,y),Vector2(world_size.x-25,y),color,0.7)
	if chapter=="jungle":
		for i in range(12):
			var center := Vector2(1210,300)
			draw_arc(center,55+i*13,0.1,2.8,44,Color(0.77,0.76,0.58,0.20),0.8)
		for i in range(35):
			var at := Vector2(80+(i*127)%1520,155+(i*173)%830)
			if river(at): continue
			draw_line(at,at+Vector2(4,-6),Color(0.64,0.65,0.39,0.3),1)
			if sin(clock+i*1.7)>0.8: draw_circle(at+Vector2(0,-sin(clock+i)*8),1.8,Color(0.83,0.86,0.55,0.6))
	elif chapter=="sea":
		for island in islands:
			for ring in [35,55]: draw_arc(Vector2(island.x,island.y),island.z+ring,0,TAU,48,Color(0.74,0.78,0.63,0.26),1)
		for i in range(20):
			var at := Vector2(600+i*130,740+sin(i*1.7)*380)
			var dir := Vector2(24,sin(i)*12)
			draw_line(at,at+dir,color,1)
			draw_line(at+dir,at+dir+Vector2(-7,-5),color,1)
			note(at+Vector2(2,22),str(18+i%9))
	var center := world_size-Vector2(150,160)
	for i in range(8):
		var angle := i*TAU/8
		var direction := Vector2.from_angle(angle)
		draw_colored_polygon(PackedVector2Array([center,center+direction*55,center+Vector2.from_angle(angle+0.16)*23]),Color(0.67,0.62,0.43,0.35))
	draw_arc(center,62,0,TAU,64,color,1)
	note(center+Vector2(-5,-72),"N")

func draw_figure(at: Vector2) -> void:
	draw_circle(at,7,Color("#0a1513"))
	draw_colored_polygon(PackedVector2Array([at+Vector2(-5,4),at+Vector2(5,4),at+Vector2(10,25),at+Vector2(-8,25)]),Color("#0a1513"))

func note(at: Vector2,text: String) -> void:
	draw_string(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#c4bea3"))
