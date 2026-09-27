extends Node2D

var app: Node
var no_walls: Array[Rect2] = []

func text(words: String,at: Vector2,size: int,color: Color=Color("#e6dfc8")) -> void:
	var width := ThemeDB.fallback_font.get_string_size(words,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	draw_string(ThemeDB.fallback_font,at-Vector2(width/2,0),words,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func _draw() -> void:
	if app.mode in ["menu","settings","leaderboard","archive"]:
		draw_frontispiece()
		if app.mode=="menu":
			text("CARTOGRAPHER'S",Vector2(640,164),39)
			text("DREAM",Vector2(640,228),63)
			text("M A P",Vector2(640,267),17,Color("#b6b49b"))
			text("A world does not become safe because you have named it.",Vector2(640,659),14,Color("#a6a994"))
		else: draw_rect(Rect2(270,75,740,610),Color(0.025,0.035,0.035,0.9))
	elif app.mode=="cinema": draw_cinema()
	elif app.mode=="capture": draw_capture()
	elif app.mode=="death": draw_rect(Rect2(0,0,1280,720),Color(0.005,0.015,0.015,0.87))
	elif app.mode=="play":
		draw_rect(Rect2(0,0,1280,91),Color(0.008,0.019,0.018,0.86))
		draw_line(Vector2(28,83),Vector2(1252,83),Color(0.62,0.64,0.54,0.25),1)
		draw_rect(Rect2(0,674,1280,46),Color(0.008,0.019,0.018,0.9))
		if app.chapter in ["cave","maze"] and not app.overview and not app.note_open:
			draw_line(Vector2(636,360),Vector2(644,360),Color(0.8,0.86,0.77,0.75),1)
			draw_line(Vector2(640,356),Vector2(640,364),Color(0.8,0.86,0.77,0.75),1)
		elif app.chapter in ["jungle","sea","city"] and not app.note_open:
			draw_memory_map()
			if app.overview: draw_survey_targets()
		if app.paused: draw_rect(Rect2(0,0,1280,720),Color(0,0.01,0.015,0.72))
		if app.stamina<0.995 and not app.note_open:
			text("BREATH" if not app.exhausted else "CATCH YOUR BREATH",Vector2(1150,693),9,Color("#c5bc9f"))
			draw_rect(Rect2(1080,701,140,3),Color(0.1,0.13,0.12,0.8))
			draw_rect(Rect2(1080,701,140*app.stamina,3),Color("#b19e72") if not app.exhausted else Color("#b36b52"))
		if app.reveal_time>0:
			draw_rect(Rect2(0,0,1280,720),Color(0.005,0.01,0.01,0.97))
			app.art.eye(self,Vector2(640,300),240,app.time)
			text("So why is it looking at me?",Vector2(640,562),24)

func draw_frontispiece() -> void:
	app.art.jungle(self,no_walls,app.time)
	draw_rect(Rect2(0,0,1280,720),Color(0.01,0.027,0.025,0.8))
	# A field sheet surrounded by instruments, independent of the world art plates.
	draw_set_transform(Vector2(995,355),-0.15)
	draw_rect(Rect2(-160,-200,325,390),Color(0.67,0.63,0.48,0.12))
	for i in range(8): draw_arc(Vector2(0,-30),40+i*12,-2.5,1.3,30,Color(0.72,0.73,0.53,0.14),1)
	draw_polyline(PackedVector2Array([Vector2(-130,150),Vector2(-80,70),Vector2(35,25),Vector2(40,-60),Vector2(130,-150)]),Color(0.72,0.71,0.5,0.25),2)
	draw_set_transform(Vector2.ZERO)
	app.art.atmosphere(self,app.time,0)

func draw_memory_map() -> void:
	var frame := Rect2(1045,109,205,155)
	draw_rect(frame,Color(0.015,0.028,0.025,0.94))
	draw_rect(frame,Color("#737866"),false,1)
	text("REMEMBERED CHART",Vector2(1147,130),10,Color("#d8d6bb"))
	var size: Vector2=app.level.world_size
	var pos: Vector2=app.level.player
	var origin := Vector2(1057,145)
	var extent := Vector2(180,102)
	if app.chapter=="jungle":
		var river_x := origin.x+820/size.x*extent.x
		draw_line(Vector2(river_x,145),Vector2(river_x,247),Color("#5e8985"),7)
		for y in [295,880]: draw_line(Vector2(river_x-8,145+y/size.y*102),Vector2(river_x+8,145+y/size.y*102),Color("#baaf81"),3)
		for marker in [Vector2(345,820),Vector2(605,310),Vector2(1130,670),app.level.observatory,app.level.jungle_exit]: draw_circle(origin+marker/size*extent,3,Color("#c6b385"))
	elif app.chapter=="sea":
		for island in app.level.islands: draw_circle(origin+Vector2(island.x,island.y)/size*extent,maxf(2,island.z/size.x*180),Color("#8e9470"))
		draw_circle(origin+Vector2(3000,530)/size*extent,3,Color("#e4d19a"))
		for p in app.level.soundings: draw_circle(origin+p/size*extent,3,Color("#d29964"))
	else:
		for name in app.level.city_doors: draw_rect(Rect2(origin+app.level.city_doors[name]/size*extent-Vector2(3,4),Vector2(6,8)),Color("#a6ac8c"))
	draw_circle(origin+pos/size*extent,3,Color("#ffdea0"))

func draw_survey_targets() -> void:
	var level: Node=app.level
	var points: Array[Vector2]=[]
	var labels: Array[String]=[]
	if app.chapter=="jungle":
		points=[Vector2(345,820),Vector2(605,310),Vector2(1130,670),level.observatory,level.jungle_exit]
		labels=["I","II","IV","OBSERVATORY","TERMINUS"]
	elif app.chapter=="sea":
		points.assign(level.soundings)
		points.append(Vector2(3000,530))
		labels=["BELL I","BELL II","BELL III","WHARF"]
	else:
		for name in level.city_doors:
			points.append(level.city_doors[name])
			labels.append(name.to_upper())
	var zoom: float=minf(1160/level.world_size.x,540/level.world_size.y)
	for i in range(points.size()):
		var at: Vector2=Vector2(640,370)+(points[i]-level.world_size/2)*zoom
		draw_circle(at,5,Color("#563c2d"))
		text(labels[i],at+Vector2(0,-10),11,Color("#47392c"))

func draw_cinema() -> void:
	var kind: String=app.cinematic
	var index: int=app.page
	var t: float=app.page_time
	if kind=="sting":
		draw_rect(Rect2(0,0,1280,720),Color("#020506"))
		if index==0:
			var approach := clampf(t/7,0,1)
			draw_set_transform(Vector2(640,300),0,Vector2.ONE*(0.35+approach*7.5))
			draw_circle(Vector2.ZERO,7,Color("#263332"))
			draw_colored_polygon(PackedVector2Array([Vector2(-6,6),Vector2(6,6),Vector2(13,36),Vector2(-11,36)]),Color("#172321"))
			draw_set_transform(Vector2.ZERO)
			if t>5: text(app.STORIES[kind][index],Vector2(640,594),23)
		else:
			text("CARTOGRAPHER'S DREAM",Vector2(640,275),43)
			text("M A P",Vector2(640,325),22)
			text("An expedition into the unknown",Vector2(640,390),17)
			text("Godot / original runtime artwork and sound",Vector2(640,431),14,Color("#9ea598"))
			text("SPACE / ENTER  EXPEDITION RECORDS",Vector2(640,637),13)
		return
	if kind in ["intro","jungle","win"]:
		app.art.jungle(self,no_walls,app.time)
		var darkness := 0.40 if kind!="win" else 0.1
		draw_rect(Rect2(0,0,1280,720),Color(0.01,0.027,0.025,darkness))
		if kind=="intro" and index<3:
			for i in range(4): app.art.person(self,Vector2(435+i*50+t*2,420+i*4),0,app.time,true)
		else:
			app.art.camp(self,Vector2(605,364),app.time)
			app.art.camp(self,Vector2(440,395),app.time)
			app.art.person(self,Vector2(682,370),-1.5,app.time,false)
			draw_set_transform(Vector2(688,420),-0.1)
			draw_rect(Rect2(-85,-42,170,95),Color("#d4c49c"))
			for i in range(7): draw_line(Vector2(-70,-28+i*11),Vector2(70,-25+i*8),Color("#737c5c"),1)
			if kind=="jungle": draw_line(Vector2(-70,37),Vector2(-70,37).lerp(Vector2(67,-22),clampf(t/3,0,1)),Color("#843f31"),2)
			draw_set_transform(Vector2.ZERO)
		if kind=="win" and index>=4:
			draw_rect(Rect2(0,0,1280,720),Color("#19201d"))
			draw_rect(Rect2(340,140,600,380),Color("#6c5336"))
			for i in range(3):
				draw_rect(Rect2(400+i*155,220,135,180),Color("#d1c198"))
				for j in range(7): draw_line(Vector2(416+i*155,245+j*19),Vector2(515+i*155,249+j*17),Color("#697458"),1)
			text("1897" if index==4 else "1908",Vector2(640,480),17,Color("#d5c6a3"))
	elif kind=="sea":
		app.art.sea(self,app.time,0.6)
		draw_rect(Rect2(0,0,1280,720),Color(0.01,0.02,0.03,0.58))
	elif kind=="city":
		draw_rect(Rect2(0,0,1280,720),Color("#182220"))
		for i in range(6):
			draw_rect(Rect2(65+i*210,130+(i%2)*60,175,335),Color("#40473a"))
			draw_rect(Rect2(110+i*210,350+(i%2)*60,45,100),Color("#0e1a17"))
		app.art.eye(self,Vector2(641,254),110,app.time)
	elif kind=="cave":
		draw_rect(Rect2(0,0,1280,720),Color("#030707"))
		for i in range(5): app.art.eye(self,Vector2(180+i*265,190+sin(i)*110),90+i*22,app.time)
		if index>=2: app.art.eye(self,Vector2(640,290),260,app.time)
	else:
		draw_rect(Rect2(0,0,1280,720),Color("#101614"))
		draw_rect(Rect2(440,200,400,265),Color("#bfaf87"))
		for i in range(6): draw_line(Vector2(463,229+i*32),Vector2(810,215+i*34),Color("#687752"),1)
		draw_circle(Vector2(625,327),6,Color("#753b2f"))
	# Cinema letterbox and consistent high-contrast text.
	draw_rect(Rect2(0,0,1280,70),Color("#060c0c"))
	draw_rect(Rect2(0,531,1280,189),Color("#08100f"))
	text(app.STORIES[kind][index],Vector2(640,588),23)
	text("SPACE / ENTER  CONTINUE     HOLD  SKIP SEQUENCE",Vector2(640,657),12,Color("#b9beb0"))
	text("%02d / %02d" % [index+1,app.STORIES[kind].size()],Vector2(640,39),12,Color("#929c8d"))
	var fade := clampf(1-t/0.65,0,1)
	draw_rect(Rect2(0,0,1280,720),Color(0,0,0,fade))
	if app.holding_continue and app.hold_time>0.2:
		draw_rect(Rect2(470,685,340*clampf(app.hold_time/1.25,0,1),3),Color("#bec3b1"))

func draw_capture() -> void:
	# The real beast is placed in front of the first-person camera for the catch.
	var t: float=app.capture_time
	for i in range(65):
		var p := Vector2(640+sin(i*17.3)*610,360+cos(i*7.31)*340)
		var radius := 4+(i%7)*7
		var splatter := PackedVector2Array()
		for j in range(16):
			var r := radius*(0.65+sin(j*13+i)*0.28)
			splatter.append(p+Vector2.from_angle(j*TAU/16)*r)
		draw_colored_polygon(splatter,Color(0.28,0.012,0.008,clampf((t-0.08)*1.8,0,0.8)))
		if i%3==0: draw_line(p,p+Vector2(0,t*48),Color(0.32,0.012,0.01,0.6),radius*0.3)
	draw_rect(Rect2(0,0,1280,720),Color(0,0,0,clampf((t-0.9)/1.6,0,1)))
