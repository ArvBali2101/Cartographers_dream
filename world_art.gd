extends RefCounted

# Original runtime artwork. Terrain and decorations share the gameplay coordinates.
var ground: Texture2D
var ocean: Texture2D
var stone: Texture2D
var rng := RandomNumberGenerator.new()
var plants: Array[Vector2] = []
var rocks: Array[Vector2] = []

func _init() -> void:
	rng.seed = 7813
	ground = terrain(Color("#182922"), Color("#57604a"), 912)
	ocean = terrain(Color("#061b25"), Color("#244751"), 336)
	stone = terrain(Color("#151a1d"), Color("#414340"), 119)
	for i in range(145): plants.append(Vector2(rng.randf_range(30,1250), rng.randf_range(85,690)))
	for i in range(95): rocks.append(Vector2(rng.randf_range(45,1230),rng.randf_range(90,670)))

func terrain(dark: Color, light: Color, noise_seed: int) -> Texture2D:
	var noise := FastNoiseLite.new()
	noise.seed = noise_seed
	noise.frequency = 0.026
	noise.fractal_octaves = 4
	var img := Image.create(640,360,false,Image.FORMAT_RGB8)
	for y in range(360):
		for x in range(640):
			var v := clampf((noise.get_noise_2d(x,y)+1.0)*0.5,0.0,1.0)
			var c := dark.lerp(light,v)
			c = c.lightened(rng.randf_range(0.0,0.045))
			img.set_pixel(x,y,c)
	return ImageTexture.create_from_image(img)

func jungle(c: CanvasItem, walls: Array[Rect2], time: float) -> void:
	c.draw_texture_rect(ground,Rect2(0,0,1280,720),false)
	var route := PackedVector2Array([Vector2(95,590),Vector2(250,485),Vector2(320,330),Vector2(430,330),Vector2(545,230),Vector2(645,330),Vector2(785,330),Vector2(840,420),Vector2(970,300),Vector2(1090,160)])
	path(c,route)
	for p in rocks:
		if distance_to_route(p,route)>36: rock(c,p,5.0 + fmod(p.x,8.0))
	for p in plants:
		if distance_to_route(p,route)>56: palm(c,p,0.7 + fmod(p.x,27.0)/40.0,time)
	for wall in walls:
		for y in range(int(wall.position.y),int(wall.end.y),22):
			rock(c,Vector2(wall.position.x+wall.size.x/2,y),22)
		for y in range(int(wall.position.y+20),int(wall.end.y),70): palm(c,Vector2(wall.position.x+10,y),0.85,time)
	camp(c,Vector2(110,565),time)
	ruins(c,Vector2(1085,155))
	for i in range(22):
		var p := Vector2(80+i*53,160+sin(i*3.7)*70+fmod(time*4+i*13,410))
		c.draw_circle(p,1.3,Color(0.72,0.82,0.45,0.25+sin(time+i)*0.2))

func distance_to_route(p: Vector2, route: PackedVector2Array) -> float:
	var best := 10000.0
	for i in range(route.size()-1): best = minf(best,p.distance_to(Geometry2D.get_closest_point_to_segment(p,route[i],route[i+1])))
	return best

func path(c: CanvasItem, points: PackedVector2Array) -> void:
	var curve := Curve2D.new()
	curve.bake_interval = 4
	for i in range(points.size()):
		var previous := points[maxi(0,i-1)]
		var next := points[mini(points.size()-1,i+1)]
		var tangent := (next-previous)*0.14
		curve.add_point(points[i],-tangent,tangent)
	var road := curve.get_baked_points()
	c.draw_polyline(road,Color(0.14,0.19,0.12,0.45),63,true)
	c.draw_polyline(road,Color("#4e523b"),54,true)
	c.draw_polyline(road,Color("#6d644a"),42,true)
	c.draw_polyline(road,Color("#776b4e"),25,true)
	for i in range(points.size()-1):
		var length := points[i].distance_to(points[i+1])
		for j in range(int(length/12)):
			var p := points[i].lerp(points[i+1],float(j)*12/length)
			c.draw_line(p+Vector2(-7,3),p+Vector2(4,1),Color(0.3,0.26,0.18,0.4),1)

func rock(c: CanvasItem,p: Vector2,r: float) -> void:
	c.draw_circle(p+Vector2(6,8),r,Color(0,0,0,0.3))
	var polygon := PackedVector2Array([p+Vector2(-r,-r*0.3),p+Vector2(-r*0.4,-r*0.9),p+Vector2(r*0.65,-r*0.7),p+Vector2(r,r*0.2),p+Vector2(r*0.3,r*0.7),p+Vector2(-r*0.7,r*0.55)])
	c.draw_colored_polygon(polygon,Color("#3d4641"))
	c.draw_colored_polygon(PackedVector2Array([polygon[0],polygon[1],polygon[2],p]),Color("#68716a"))
	c.draw_polyline(PackedVector2Array([polygon[1],p,polygon[4]]),Color("#282e2c"),1,true)
	c.draw_line(p+Vector2(-r*0.4,-r*0.5),p+Vector2(r*0.4,-r*0.5),Color("#84907a"),1)

func palm(c: CanvasItem,p: Vector2,s: float,t: float) -> void:
	c.draw_circle(p+Vector2(9,12),34*s,Color(0,0,0,0.22))
	c.draw_line(p+Vector2(4,17),p,Color("#705f40"),5*s,true)
	for i in range(9):
		var angle := i*TAU/9+sin(t*0.65+p.x)*0.025
		var d := Vector2.from_angle(angle)
		var side := Vector2(-d.y,d.x)
		var length := (31+sin(i+p.x)*9)*s
		var tip := p+d*length
		var leaf := PackedVector2Array([p,p+d*length*0.4+side*8*s,tip,p+d*length*0.65-side*7*s])
		c.draw_colored_polygon(leaf,Color("#2e5239") if i%2==0 else Color("#3d6142"))
		c.draw_line(p,tip,Color("#78935d"),0.9,true)
		for j in range(2,6):
			var root := p+d*length*j/7.0
			c.draw_line(root,root+d*3+side*(7-j)*s,Color(0.08,0.18,0.1,0.6),1,true)

func camp(c: CanvasItem,p: Vector2,t: float) -> void:
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(-40,-50),p+Vector2(-80,-8),p+Vector2(5,-8)]),Color("#81735a"))
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(-40,-50),p+Vector2(-10,-28),p+Vector2(5,-8)]),Color("#b4a180"))
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(-40,-35),p+Vector2(-53,-8),p+Vector2(-28,-8)]),Color("#282b27"))
	for i in range(6): c.draw_circle(p+Vector2(15,0),float(42-i*6),Color(1,0.48,0.12,0.018+i*0.006))
	c.draw_line(p+Vector2(5,5),p+Vector2(26,-3),Color("#503c29"),5)
	c.draw_line(p+Vector2(5,-3),p+Vector2(26,5),Color("#503c29"),5)
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(6,2),p+Vector2(16,-18-sin(t*9)*3),p+Vector2(24,2)]),Color("#e89539"))
	c.draw_circle(p+Vector2(15,-3),4,Color("#ffe2a1"))

func ruins(c: CanvasItem,p: Vector2) -> void:
	for x in [-45,45]:
		c.draw_rect(Rect2(p+Vector2(x-13,-34),Vector2(26,72)),Color("#2a302c"))
		for y in range(-34,36,14):
			c.draw_rect(Rect2(p+Vector2(x-13,y),Vector2(26,12)),Color("#7c8270"))
			c.draw_line(p+Vector2(x-12,y),p+Vector2(x+10,y),Color("#a8aa8d"),1)
	c.draw_rect(Rect2(p+Vector2(-58,-46),Vector2(116,16)),Color("#777f6c"))
	c.draw_rect(Rect2(p+Vector2(-35,-30),Vector2(70,68)),Color(0.01,0.02,0.015,0.7))
	for i in range(5): c.draw_line(p+Vector2(-40,37+i*7),p+Vector2(40,37+i*7),Color("#676f62"),5)

func sea(c: CanvasItem,t: float,horror: float) -> void:
	c.draw_texture_rect(ocean,Rect2(0,0,1280,720),false)
	for i in range(155):
		var p := Vector2(fmod(i*173+t*9,1280),90+fmod(i*97,600))
		c.draw_arc(p,14+fmod(i,22),0.1,0.65,7,Color(0.49,0.72,0.73,0.08+sin(t+i)*0.04),1,true)
	island(c,Vector2(340,230),69,t)
	island(c,Vector2(690,480),69,t)
	island(c,Vector2(1100,175),49,t)
	# ribs and skull at the bone island
	for i in range(6): c.draw_arc(Vector2(324+i*7,230),18,2,4.3,10,Color("#bdb79e"),3,true)
	c.draw_circle(Vector2(365,225),12,Color("#bdb79e"))
	c.draw_circle(Vector2(362,222),3,Color("#34372e"))
	boat(c,Vector2(683,490),-0.5,t,false)
	c.draw_rect(Rect2(1088,131,24,45),Color("#c4c3b0"))
	c.draw_rect(Rect2(1085,126,30,9),Color("#526662"))
	c.draw_circle(Vector2(1100,125),6,Color("#ffde88"))
	var beam := Vector2.from_angle(t*0.25)*250
	c.draw_colored_polygon(PackedVector2Array([Vector2(1100,125),Vector2(1100,125)+beam.rotated(-0.1),Vector2(1100,125)+beam.rotated(0.1)]),Color(1,0.86,0.54,0.075))
	for p in [Vector2(720,220),Vector2(530,500)]:
		for j in range(7): c.draw_arc(p,10+j*7,t+j*0.3,t+j*0.3+4.0,24,Color(0.28,0.58,0.59,0.25),2,true)
	for i in range(int(horror*6)):
		var p := Vector2(240+i*165,580-(i%3)*140)
		for j in range(18):
			var q := p+Vector2(sin(j*0.12+t)*30,j*-4)
			c.draw_circle(q,12-j*0.5,Color("#182d2d"))
			c.draw_circle(q+Vector2(3,0),3,Color("#52706a"))

func island(c: CanvasItem,p: Vector2,r: float,t: float) -> void:
	for i in range(3): c.draw_arc(p,r+9+i*7,0,TAU,40,Color(0.64,0.79,0.72,0.1+sin(t+i)*0.04),2,true)
	var edge := PackedVector2Array()
	for i in range(20): edge.append(p+Vector2.from_angle(i*TAU/20)*(r+sin(i*4+p.x)*8))
	c.draw_colored_polygon(edge,Color("#827a5b"))
	for i in range(20): edge[i]=p+(edge[i]-p)*0.78
	c.draw_colored_polygon(edge,Color("#36483a"))
	for i in range(5): rock(c,p+Vector2(sin(i*6)*r*0.55,cos(i*6)*r*0.55),8)

func nightmare(c: CanvasItem,walls: Array[Rect2],t: float) -> void:
	c.draw_texture_rect(stone,Rect2(0,0,1280,720),false)
	for y in range(90,720,35):
		for x in range(0,1280,52):
			var p := Vector2(x+(17 if y%2==0 else 0),y)
			c.draw_rect(Rect2(p,Vector2(50,33)),Color(0.31,0.34,0.31,0.13),false,1)
	for wall in walls:
		c.draw_rect(Rect2(wall.position+Vector2(9,12),wall.size),Color(0,0,0,0.6))
		c.draw_rect(wall,Color("#515650"))
		c.draw_line(wall.position,wall.position+Vector2(wall.size.x,0),Color("#929381"),3)
		for y in range(int(wall.position.y),int(wall.end.y),18):
			c.draw_line(Vector2(wall.position.x,y),Vector2(wall.end.x,y),Color("#252c2b"),2)
			for x in range(int(wall.position.x)+12,int(wall.end.x),26):
				c.draw_line(Vector2(x,y),Vector2(x,y+16),Color("#303834"),1)
	for i in range(22):
		var p := Vector2(75+i*53,130+sin(i*3.7)*45+(i%4)*132)
		c.draw_line(p,p+Vector2(18,8),Color("#090f10"),2)
		c.draw_line(p+Vector2(18,8),p+Vector2(6,23),Color("#090f10"),2)
	# An enormous eye embedded in the architecture.
	eye(c,Vector2(642,391),100,t)
	ruins(c,Vector2(1110,160))

func eye(c: CanvasItem,p: Vector2,r: float,t: float) -> void:
	for ring in range(14):
		var size := r*(1.18-float(ring)*0.026)
		var crease := PackedVector2Array()
		for i in range(65):
			var a := i*TAU/64
			crease.append(p+Vector2(cos(a)*size,sin(a)*absf(sin(a))*size*0.48))
		c.draw_polyline(crease,Color(0.13+ring*0.009,0.17+ring*0.006,0.16+ring*0.005,0.7),2,true)
	for ring in range(12):
		var size := r*(1-float(ring)*0.024)
		var lid := PackedVector2Array()
		for i in range(64):
			var a := i*TAU/64
			lid.append(p+Vector2(cos(a)*size,sin(a)*absf(sin(a))*size*0.40))
		c.draw_colored_polygon(lid,Color("#414b42").lerp(Color("#b1ae89"),float(ring)/14))
	for i in range(19):
		var side := -1.0 if i%2 else 1.0
		var origin := p+Vector2(side*(r*0.48+i*r*0.017),sin(i*3.0)*r*0.12)
		c.draw_polyline(PackedVector2Array([origin,origin+Vector2(-side*r*0.08,sin(i)*r*0.06),origin+Vector2(-side*r*0.16,cos(i)*r*0.04)]),Color(0.31,0.19,0.12,0.3),1,true)
	var center := p+Vector2(sin(t*0.3)*r*0.06,0)
	c.draw_circle(center,r*0.35,Color("#1b2c29"))
	for ring in range(10):
		c.draw_circle(center,r*(0.34-ring*0.017),Color("#6d7948").lerp(Color("#273f31"),float(ring)/10))
	for i in range(110):
		var d := Vector2.from_angle(i*TAU/110)
		var length := r*(0.28+sin(i*13)*0.045)
		c.draw_line(center+d*r*0.14,center+d*length,Color("#a1a566") if i%3==0 else Color("#263d30"),r*0.007,true)
	c.draw_circle(center,r*0.145,Color("#030909"))
	c.draw_circle(center+Vector2(-r*0.08,-r*0.09),r*0.025,Color(0.9,0.93,0.79,0.7))

func person(c: CanvasItem,p: Vector2,angle: float,t: float,moving: bool) -> void:
	c.draw_circle(p+Vector2(5,7),12,Color(0,0,0,0.4))
	var d := Vector2.from_angle(angle)
	var side := Vector2(-d.y,d.x)
	var walk := sin(t*13)*4 if moving else 0.0
	c.draw_line(p-side*4-d*4,p-side*4-d*(12+walk),Color("#302923"),5,true)
	c.draw_line(p+side*4-d*4,p+side*4-d*(12-walk),Color("#302923"),5,true)
	c.draw_line(p-side*8-d*2,p+side*8-d*2,Color("#ad9972"),8,true)
	c.draw_circle(p-d*4,7,Color("#4f5749"))
	c.draw_circle(p+d*2,7,Color("#c6ab78"))
	c.draw_line(p-side*9+d*2,p+side*9+d*2,Color("#e0c48e"),3,true)
	c.draw_circle(p+d*5,3,Color("#dec8a0"))
	var lamp := p+side*12+d*4
	for i in range(5): c.draw_circle(lamp,25-i*4,Color(1,0.73,0.35,0.014+i*0.008))
	c.draw_circle(lamp,2.5,Color("#ffe4a5"))

func boat(c: CanvasItem,p: Vector2,angle: float,t: float,moving: bool) -> void:
	var d := Vector2.from_angle(angle)
	var side := Vector2(-d.y,d.x)
	if moving:
		for i in range(6): c.draw_arc(p-d*(22+i*8),10+i*3,angle-0.8,angle+0.8,12,Color(0.7,0.85,0.78,0.28-i*0.035),1,true)
	var points := PackedVector2Array([p+d*27,p+d*12+side*12,p-d*21+side*9,p-d*25,p-d*21-side*9,p+d*12-side*12])
	c.draw_colored_polygon(points,Color("#33251d"))
	for i in range(points.size()): points[i]=p+(points[i]-p)*0.8
	c.draw_colored_polygon(points,Color("#a18150"))
	for i in range(-2,3): c.draw_line(p+d*i*7-side*7,p+d*i*7+side*7,Color("#574531"),2,true)
	c.draw_line(p-side*19,p+side*19,Color("#d0b581"),2,true)
	c.draw_circle(p,5,Color("#6c7259"))
	c.draw_circle(p+d*3,3,Color("#e2c898"))

func atmosphere(c: CanvasItem,t: float,danger: float) -> void:
	for i in range(12):
		c.draw_rect(Rect2(i*4,i*4,1280-i*8,720-i*8),Color(0.005,0.01,0.015,0.025),false,9)
	for i in range(5):
		var y := 130+i*110+sin(t*0.15+i)*30
		c.draw_line(Vector2(0,y),Vector2(1280,y+30),Color(0.49,0.62,0.63,0.018),38,true)
	if danger>0: c.draw_rect(Rect2(0,0,1280,720),Color(0.19,0.015,0.008,danger*0.12))
