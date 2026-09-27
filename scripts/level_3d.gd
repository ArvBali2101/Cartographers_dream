extends Node3D

var app: Node
var chapter := "maze"
var layout = preload("res://scripts/maze_layout.gd").new()
var player: CharacterBody3D
var head: Node3D
var camera: Camera3D
var survey_camera: Camera3D
var environment: Environment
var key_object: Node3D
var has_key := false
var exit_door: Node3D
var doors: Array[Node3D]=[]
var wisps: Array[Dictionary]=[]
var paintings: Array[Dictionary]=[]
var seen_paintings := {}
var creature: CharacterBody3D
var creature_model: Node3D
var capture_prepared := false
var guide: Node3D
var legs: Array[Node3D]=[]
var monster_path: Array[Vector2i]=[]
var path_clock := 0.0
var clock := 0.0
var age := 0.0
var awake := false
var spawn_cell := Vector2i.ZERO
var seal: StaticBody3D
var sealed := false
var finish_point := Vector3.ZERO
var breath: AudioStreamPlayer3D
var screech: AudioStreamPlayer
var stone_material: StandardMaterial3D
var cave_material: StandardMaterial3D
var floor_material: StandardMaterial3D
var clue_light: OmniLight3D
var input_block := false
const LORE = preload("res://scripts/lore.gd")
var witnesses: Array[Dictionary] = []
var inscriptions: Array[Dictionary] = []
var seals_broken := 0
var survey_marker: MeshInstance3D
var hunt_surge := 0.0
var echo_played := false
var dust: CPUParticles3D
var halo_texture: Texture2D

func _ready() -> void:
	layout.generate(9,7,221) if chapter=="cave" else layout.generate(19,17,441)
	layout.cell_size=4.4
	build_materials()
	build_environment()
	build_world()
	preload("res://scripts/ruin_details.gd").new().build(self)
	build_player()
	var marker_material := material(Color("#f0d393"))
	marker_material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	survey_marker=sphere_mesh(self,Vector3(0,4.3,0),Vector3(0.65,0.24,0.65),marker_material)
	survey_marker.hide()
	build_wisps()
	build_dust()
	if chapter=="maze":
		build_key()
		build_witnesses()
		build_inscriptions()
		build_monster()
		build_guide()
		app.toast("Two witnessing seals. One brass key. The light alone cannot free you.")
	else:
		build_paintings()
		build_guide()
		guide.hide()
		app.toast("No body. No sky. Only ochre on the walls.")

func material(color: Color,roughness: float=0.95) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color=color
	mat.roughness=roughness
	return mat

func build_materials() -> void:
	stone_material=material(Color("#7e8582"))
	stone_material.albedo_texture=brick_texture(false)
	stone_material.uv1_triplanar=true
	stone_material.uv1_scale=Vector3.ONE*0.38
	stone_material.normal_enabled=true
	stone_material.normal_texture=stone_normal()
	stone_material.normal_scale=0.8
	cave_material=material(Color("#886b4b"))
	cave_material.albedo_texture=brick_texture(true)
	cave_material.uv1_triplanar=true
	cave_material.uv1_scale=Vector3.ONE*0.45
	floor_material=material(Color("#797e73") if chapter=="maze" else Color("#765336"))
	floor_material.albedo_texture=app.art.stone if chapter=="maze" else app.art.ground
	floor_material.uv1_scale=Vector3(18,18,18)
	if chapter=="maze":
		floor_material.albedo_texture=brick_texture(false)
		floor_material.uv1_scale=Vector3(1.4,1.4,1.4)
		floor_material.albedo_color=Color("#707a77")

func stone_normal() -> Texture2D:
	var image := Image.create(256,256,false,Image.FORMAT_RGB8)
	for y in range(256):
		for x in range(256):
			var offset := 32 if (y/32)%2 else 0
			var bx := (x+offset)%64
			var by := y%32
			var nx := -0.48 if bx<5 else 0.48 if bx>60 else 0.0
			var ny := -0.48 if by<5 else 0.48 if by>28 else 0.0
			image.set_pixel(x,y,Color(0.5+nx,0.5+ny,0.94))
	return ImageTexture.create_from_image(image)

func brick_texture(cave: bool) -> Texture2D:
	var noise := FastNoiseLite.new()
	noise.seed=711
	noise.frequency=0.085
	var image := Image.create(256,256,false,Image.FORMAT_RGB8)
	for y in range(256):
		for x in range(256):
			var shade := 0.68+noise.get_noise_2d(x,y)*0.18
			if not cave:
				var offset := 32 if (y/32)%2 else 0
				shade+=sin(floor(float(x+offset)/64)*19+floor(float(y)/32)*13)*0.09
				if y%32<3 or (x+offset)%64<3: shade*=0.3
			image.set_pixel(x,y,Color(shade,shade,shade))
	return ImageTexture.create_from_image(image)

func build_environment() -> void:
	var node := WorldEnvironment.new()
	environment=Environment.new()
	environment.background_mode=Environment.BG_COLOR
	environment.background_color=Color("#020507")
	environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color=Color("#8b9aa0") if chapter=="maze" else Color("#98815d")
	environment.ambient_light_energy=0.32 if chapter=="maze" else 0.19
	environment.fog_enabled=true
	environment.fog_light_color=Color("#111b20") if chapter=="maze" else Color("#1f1710")
	environment.fog_density=0.09 if chapter=="maze" else 0.115
	node.environment=environment
	add_child(node)

func box(at: Vector3,size: Vector3,mat: Material,solid: bool=true,angle: float=0) -> Node3D:
	var node: Node3D=StaticBody3D.new() if solid else Node3D.new()
	node.position=at
	node.rotation.y=angle
	var mesh := MeshInstance3D.new()
	var geometry := BoxMesh.new()
	geometry.size=size
	mesh.mesh=geometry
	mesh.material_override=mat
	node.add_child(mesh)
	if solid:
		var shape := CollisionShape3D.new()
		var geometry_shape := BoxShape3D.new()
		geometry_shape.size=size
		shape.shape=geometry_shape
		node.add_child(shape)
	add_child(node)
	return node

func build_world() -> void:
	var scale: float=layout.cell_size
	var width: float=layout.width*scale
	var depth: float=layout.height*scale
	var base := box(Vector3((width-scale)/2,-0.22,(depth-scale)/2),Vector3(width+34,0.4,depth+34),floor_material)
	base.get_child(0).hide()
	var mat := cave_material if chapter=="cave" else stone_material
	for cell in layout.connections:
		var center: Vector3=layout.point(cell)
		var floor_tile := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size=Vector2(scale,scale)
		floor_tile.mesh=plane
		floor_tile.material_override=floor_material
		floor_tile.position=center
		add_child(floor_tile)
		for direction in [Vector2i.UP,Vector2i.LEFT,Vector2i.RIGHT,Vector2i.DOWN]:
			var next: Vector2i=cell+direction
			if cell==layout.finish and direction==layout.outside: continue
			if chapter=="cave" and cell==Vector2i.ZERO and direction==Vector2i.UP: continue
			if layout.connections[cell].has(next): continue
			if layout.connections.has(next) and direction in [Vector2i.UP,Vector2i.LEFT]: continue
			var at := center+Vector3(direction.x,0,direction.y)*scale/2
			at.y=1.9
			var size := Vector3(scale+0.5,3.8,0.5) if direction.y!=0 else Vector3(0.5,3.8,scale+0.5)
			box(at,size,mat)
			if chapter=="cave":
				var rock := MeshInstance3D.new()
				var sphere := SphereMesh.new()
				sphere.radius=1
				sphere.height=2
				sphere.radial_segments=12
				sphere.rings=7
				rock.mesh=sphere
				rock.material_override=cave_material
				rock.position=at+Vector3(0,0.4,0)
				rock.scale=Vector3(2.4,2.7,0.56) if direction.y!=0 else Vector3(0.56,2.7,2.4)
				add_child(rock)
	var dir := Vector3(layout.outside.x,0,layout.outside.y)
	var side := Vector3(dir.z,0,-dir.x)
	var origin: Vector3=layout.point(layout.finish)
	var angle := atan2(dir.x,dir.z)
	box(origin+dir*7+Vector3(0,-0.11,0),Vector3(2.3,0.2,19),floor_material,false,angle)
	finish_point=origin+dir*12
	for i in range(3):
		var center := origin+dir*(scale/2+float(i)*4)
		for edge in [-1,1]: box(center+side*edge*1.37+Vector3(0,1.9,0),Vector3(0.5,3.8,4.5),mat,true,angle)
	var threshold := origin+dir*5.8
	if chapter=="maze":
		exit_door=make_door(threshold,angle,true)
		var white := material(Color("#dde8d6"))
		white.emission_enabled=true
		white.emission=Color("#e1eedb")
		white.emission_energy_multiplier=3
		box(finish_point+Vector3(0,1.4,0),Vector3(2.1,2.8,0.06),white,false,angle)
		var light := OmniLight3D.new()
		light.position=finish_point+Vector3(0,1.6,0)
		light.light_color=Color("#ecf1d8")
		light.light_energy=3
		light.omni_range=12
		add_child(light)
		var spine: Array[Vector2i]=layout.route(Vector2i.ZERO,layout.finish)
		for i in range(8,spine.size()-5,13):
			var a: Vector3=layout.point(spine[i])
			var b: Vector3=layout.point(spine[i+1])
			var d := (b-a).normalized()
			make_door((a+b)*0.5,atan2(d.x,d.z),false)
	else:
		# The route behind the player physically seals after leaving the entrance.
		seal=box(Vector3(0,1.9,-scale/2),Vector3(scale,3.8,0.65),cave_material) as StaticBody3D
		seal.hide()
		seal.collision_layer=0
		var gateway := material(Color("#713f25"))
		box(finish_point+Vector3(0,1.5,0),Vector3(2.4,3,0.15),gateway,false,angle)

func make_door(at: Vector3,angle: float,locked: bool) -> Node3D:
	var sideways := Vector3(cos(angle),0,-sin(angle))
	var door := preload("res://scripts/door_3d.gd").new()
	door.configure(app,at-sideways*1.075,angle,locked)
	add_child(door)
	doors.append(door)
	if not locked:
		for side in [-1,1]: box(at+sideways*side*1.68+Vector3(0,1.9,0),Vector3(1.15,3.8,0.5),stone_material,true,angle)
	else:
		for side in [-1,1]: box(at+sideways*side*1.18+Vector3(0,1.9,0),Vector3(0.25,3.8,0.5),stone_material,true,angle)
	box(at+Vector3(0,3.35,0),Vector3(2.7,0.85,0.5),stone_material,true,angle)
	return door

func build_player() -> void:
	player=CharacterBody3D.new()
	player.position=Vector3(0,0.9,0)
	add_child(player)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius=0.28
	capsule.height=1.7
	shape.shape=capsule
	player.add_child(shape)
	head=Node3D.new()
	head.position.y=0.65
	player.add_child(head)
	camera=Camera3D.new()
	camera.fov=78
	camera.near=0.07
	camera.far=90
	head.add_child(camera)
	camera.current=true
	var first: Vector2i=layout.connections[Vector2i.ZERO][0]
	var direction := layout.point(first)-player.position
	player.rotation.y=atan2(-direction.x,-direction.z)
	var lamp := SpotLight3D.new()
	lamp.position=Vector3(0.18,-0.18,-0.18)
	lamp.light_color=Color("#d7d3b3") if chapter=="maze" else Color("#d9aa68")
	lamp.light_energy=2.4
	lamp.spot_range=17
	lamp.spot_angle=58
	lamp.spot_attenuation=1.5
	lamp.shadow_enabled=true
	lamp.shadow_bias=0.15
	lamp.shadow_normal_bias=1.1
	camera.add_child(lamp)
	survey_camera=Camera3D.new()
	survey_camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	survey_camera.size=maxf(layout.width,layout.height)*layout.cell_size+18
	survey_camera.position=Vector3((layout.width-1)*layout.cell_size/2,95,(layout.height-1)*layout.cell_size/2)
	survey_camera.rotation.x=-PI/2
	survey_camera.far=180
	var survey_env := Environment.new()
	survey_env.background_mode=Environment.BG_COLOR
	survey_env.background_color=Color("#080f12")
	survey_env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	survey_env.ambient_light_color=Color.WHITE
	survey_env.ambient_light_energy=1
	survey_camera.environment=survey_env
	add_child(survey_camera)

func build_wisps() -> void:
	var distance: Dictionary=layout.distances_from(Vector2i.ZERO)
	for cell in layout.connections:
		if distance[cell]%7!=0: continue
		var p: Vector3=layout.point(cell)
		var node := Node3D.new()
		node.position=p+Vector3(0.3,2.0,0.3)
		add_child(node)
		for i in range(3):
			var orb := MeshInstance3D.new()
			var sphere := SphereMesh.new()
			sphere.radius=0.055
			sphere.height=0.11
			orb.mesh=sphere
			var mat := material(Color("#d9e7df"))
			mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.emission_enabled=true
			mat.emission=Color("#daeee5")
			orb.material_override=mat
			orb.position=Vector3(sin(i*2.1)*0.6,i*0.22,cos(i*2.1)*0.5)
			node.add_child(orb)
			var halo := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size=Vector2(0.48,0.48)
			halo.mesh=quad
			var glow := material(Color(0.74,0.87,0.82,0.34))
			glow.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
			glow.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
			glow.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED
			glow.albedo_texture=soft_halo()
			halo.material_override=glow
			halo.position=orb.position
			node.add_child(halo)
		var light := OmniLight3D.new()
		light.light_color=Color("#d7e5df")
		light.light_energy=1.4
		light.omni_range=7.5
		node.add_child(light)
		wisps.append({"node":node,"origin":node.position,"phase":float(distance[cell])})

func soft_halo() -> Texture2D:
	if halo_texture!=null: return halo_texture
	var image := Image.create(32,32,false,Image.FORMAT_RGBA8)
	for y in range(32):
		for x in range(32):
			var distance := Vector2(x-15.5,y-15.5).length()/15.5
			image.set_pixel(x,y,Color(1,1,1,pow(maxf(0,1-distance),2)))
	halo_texture=ImageTexture.create_from_image(image)
	return halo_texture

func build_dust() -> void:
	dust=CPUParticles3D.new()
	dust.amount=55
	dust.lifetime=12
	dust.preprocess=3
	dust.use_fixed_seed=true
	dust.seed=291
	dust.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX
	dust.emission_box_extents=Vector3(8,2,8)
	dust.gravity=Vector3(0,0.015,0)
	dust.direction=Vector3.UP
	dust.spread=180
	dust.initial_velocity_min=0.02
	dust.initial_velocity_max=0.08
	dust.scale_amount_min=0.025
	dust.scale_amount_max=0.07
	var mesh := QuadMesh.new()
	var mat := material(Color(0.69,0.72,0.63,0.25))
	mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED
	mat.albedo_texture=soft_halo()
	mesh.material=mat
	dust.mesh=mesh
	dust.position.y=1.3
	player.add_child(dust)

func build_key() -> void:
	key_object=Node3D.new()
	key_object.position=layout.point(layout.key_cell)+Vector3(0,0.85,0)
	add_child(key_object)
	var brass := material(Color("#b99640"),0.3)
	brass.metallic=0.75
	brass.emission_enabled=true
	brass.emission=Color("#59441c")
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius=0.12
	torus.outer_radius=0.19
	ring.mesh=torus
	ring.material_override=brass
	key_object.add_child(ring)
	var stem := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size=Vector3(0.055,0.055,0.5)
	stem.mesh=mesh
	stem.material_override=brass
	stem.position.z=0.3
	key_object.add_child(stem)
	for z in [0.43,0.55]:
		var tooth := MeshInstance3D.new()
		var tooth_mesh := BoxMesh.new()
		tooth_mesh.size=Vector3(0.15,0.055,0.05)
		tooth.mesh=tooth_mesh
		tooth.material_override=brass
		tooth.position=Vector3(0.06,0,z)
		key_object.add_child(tooth)
	clue_light=OmniLight3D.new()
	clue_light.light_color=Color("#e7c47c")
	clue_light.light_energy=1.8
	clue_light.omni_range=7
	key_object.add_child(clue_light)
	var trigger := Area3D.new()
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius=0.85
	collision.shape=sphere
	trigger.add_child(collision)
	key_object.add_child(trigger)
	trigger.body_entered.connect(func(body):
		if body==player: collect_key())

func collect_key() -> void:
	if has_key: return
	has_key=true
	key_object.hide()
	app.toast("The brass key. Now find the locked doorway of light.")
	awake=true

func build_witnesses() -> void:
	var from_start: Dictionary=layout.distances_from(Vector2i.ZERO)
	var from_key: Dictionary=layout.distances_from(layout.key_cell)
	var chosen: Array[Vector2i]=[]
	for index in range(2):
		var best := -1
		var candidate := Vector2i.ZERO
		var separation: Dictionary=layout.distances_from(chosen[0]) if not chosen.is_empty() else from_key
		for cell in layout.connections:
			if cell in chosen or cell==layout.key_cell or cell==layout.finish or from_start[cell]<9: continue
			var score: int=from_start[cell]+separation[cell]
			if score>best:
				candidate=cell
				best=score
		chosen.append(candidate)
		var at: Vector3=layout.point(candidate)
		var pedestal := box(at+Vector3(0,0.55,0),Vector3(0.7,1.1,0.7),stone_material,false)
		var red := material(Color("#ad4f38"))
		red.emission_enabled=true
		red.emission=Color("#b34228")
		red.emission_energy_multiplier=1.8
		var eye := sphere_mesh(pedestal,Vector3(0,0.72,0),Vector3(0.52,0.18,0.25),red)
		var light := OmniLight3D.new()
		light.light_color=Color("#db6e49")
		light.light_energy=1.1
		light.omni_range=5
		pedestal.add_child(light)
		witnesses.append({"pos":at,"cell":candidate,"broken":false,"eye":eye,"light":light})

func break_witness(index: int) -> void:
	if index<0 or index>=witnesses.size() or witnesses[index].broken: return
	witnesses[index].broken=true
	witnesses[index].eye.hide()
	witnesses[index].light.light_energy=0
	seals_broken+=1
	awake=true
	hunt_surge=7.0
	app.play_cue("pulse")
	app.toast("A road closes behind your name. Witnessing seals broken: %d / 2." % seals_broken)
	var text := "The stone bears my signature. As I scratch through it, a distant door slams.\n\nA road has closed. The thing that remembers me is still inside." if index==0 else "Under the second signature is another, carved deeper.\n\nThe surface gives way. For a moment the ruin is silent.\n\nTwo witnesses erased. A brass key remains between me and the light."
	app.show_note("THE BROKEN WITNESS / %d" % (index+1),text)

func build_inscriptions() -> void:
	var spine: Array[Vector2i]=layout.route(Vector2i.ZERO,layout.finish)
	for i in range(LORE.RUINS.size()):
		var cell: Vector2i=spine[mini(spine.size()-1,2+i*maxi(1,(spine.size()-4)/5))]
		var at: Vector3=layout.point(cell)+Vector3(1.45,0,1.45)
		box(at+Vector3(0,0.65,0),Vector3(0.4,1.3,0.4),stone_material,false)
		var plaque := Label3D.new()
		plaque.text="V" if i%2==0 else "VII"
		plaque.font_size=50
		plaque.pixel_size=0.009
		plaque.position=at+Vector3(0,1.02,-0.23)
		plaque.modulate=Color("#b4ae91")
		add_child(plaque)
		inscriptions.append({"pos":at,"id":i})

func sphere_mesh(parent: Node3D,p: Vector3,scale: Vector3,mat: Material) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius=0.5
	sphere.height=1
	mesh.mesh=sphere
	mesh.material_override=mat
	mesh.position=p
	mesh.scale=scale
	parent.add_child(mesh)
	return mesh

func build_monster() -> void:
	creature=CharacterBody3D.new()
	var distance: Dictionary=layout.distances_from(Vector2i.ZERO)
	var candidate := Vector2i.ZERO
	var closest := 9999
	for cell in distance:
		if abs(distance[cell]-16)<closest:
			closest=abs(distance[cell]-16)
			candidate=cell
	spawn_cell=candidate
	creature.position=layout.point(candidate)+Vector3(0,0.85,0)
	add_child(creature)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.height=1.5
	capsule.radius=0.32
	shape.shape=capsule
	creature.add_child(shape)
	creature_model=Node3D.new()
	creature.add_child(creature_model)
	var dark := material(Color("#111b1c"))
	sphere_mesh(creature_model,Vector3(0,0.1,0),Vector3(0.8,0.85,1.7),dark)
	sphere_mesh(creature_model,Vector3(0,0.35,-0.92),Vector3(0.66,0.73,0.8),dark)
	sphere_mesh(creature_model,Vector3(0,0.2,-1.3),Vector3(0.55,0.33,0.45),dark)
	sphere_mesh(creature_model,Vector3(0,0.1,-1.50),Vector3(0.37,0.18,0.08),material(Color("#030908")))
	var ivory := material(Color("#969987"))
	for x in [-0.14,-0.045,0.045,0.14]:
		var fang := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius=0.038
		cone.bottom_radius=0.002
		cone.height=0.15
		fang.mesh=cone
		fang.material_override=ivory
		fang.position=Vector3(x,0.11,-1.55)
		creature_model.add_child(fang)
	for side in [-1,1]:
		var horn := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius=0.005
		cone.bottom_radius=0.12
		cone.height=0.48
		horn.mesh=cone
		horn.material_override=dark
		horn.position=Vector3(side*0.28,0.83,-0.8)
		horn.rotation.z=side*0.25
		creature_model.add_child(horn)
		var eye_mat := material(Color("#ff2432"))
		eye_mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		eye_mat.emission_enabled=true
		eye_mat.emission=Color("#ff1930")
		sphere_mesh(creature_model,Vector3(side*0.18,0.48,-1.255),Vector3(0.12,0.07,0.07),eye_mat)
		for z in [-0.58,0.58]:
			var leg := Node3D.new()
			leg.position=Vector3(side*0.32,-0.15,z)
			creature_model.add_child(leg)
			sphere_mesh(leg,Vector3(side*0.12,-0.25,0),Vector3(0.18,0.68,0.2),dark)
			legs.append(leg)
	var darkness := material(Color(0.02,0.05,0.05,0.2))
	darkness.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	sphere_mesh(creature_model,Vector3(0,0.2,0),Vector3(1.5,1.6,2.5),darkness)
	breath=AudioStreamPlayer3D.new()
	breath.stream=breath_stream()
	breath.unit_size=7
	breath.max_distance=25
	breath.volume_db=-15
	creature.add_child(breath)
	breath.play()
	screech=AudioStreamPlayer.new()
	screech.stream=screech_stream()
	screech.volume_db=-17
	add_child(screech)

func screech_stream() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	var bytes := PackedByteArray()
	bytes.resize(33000)
	var rng := RandomNumberGenerator.new()
	rng.seed=827
	for i in range(16500):
		var t := float(i)/22050
		var envelope := sin(PI*float(i)/16500)
		var sample := (sin(t*TAU*(430+sin(t*21)*60))*0.3+rng.randf_range(-0.2,0.2))*envelope
		bytes.encode_s16(i*2,int(sample*18000))
	stream.data=bytes
	return stream

func breath_stream() -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new()
	rng.seed=923
	var bytes := PackedByteArray()
	var count := 22050*3
	bytes.resize(count*2)
	var n := 0.0
	for i in range(count):
		var t := float(i)/22050
		n=lerpf(n,rng.randf_range(-1,1),0.12)
		var pulse := pow(maxf(0,sin(t*TAU*0.66)),2)
		var sample := (n*0.8+sin(t*TAU*62)*0.1)*pulse
		bytes.encode_s16(i*2,int(sample*24000))
	var stream := AudioStreamWAV.new()
	stream.mix_rate=22050
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
	stream.loop_end=count
	stream.data=bytes
	return stream

func build_guide() -> void:
	guide=Node3D.new()
	add_child(guide)
	var mat := material(Color("#081316"))
	sphere_mesh(guide,Vector3(0,1.4,0),Vector3(0.24,0.3,0.24),mat)
	var body := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius=0.15
	cone.bottom_radius=0.3
	cone.height=1.15
	body.mesh=cone
	body.material_override=mat
	body.position.y=0.72
	guide.add_child(body)

func build_paintings() -> void:
	var route: Array[Vector2i]=layout.route(Vector2i.ZERO,layout.finish)
	var locations: Array[Vector2i]=[]
	for fraction in [0.12,0.35,0.57,0.83]: locations.append(route[mini(route.size()-1,int(route.size()*fraction))])
	for i in range(locations.size()):
		var cell: Vector2i=locations[i]
		var direction := Vector2i.UP
		for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			if not layout.connections[cell].has(cell+d):
				direction=d
				break
		var p: Vector3=layout.point(cell)+Vector3(direction.x,0,direction.y)*(layout.cell_size/2-0.6)
		p.y=1.9
		var plane := MeshInstance3D.new()
		var mesh := PlaneMesh.new()
		mesh.size=Vector2(2.6,1.9)
		plane.mesh=mesh
		plane.position=p
		plane.rotation_degrees=Vector3(90,rad_to_deg(atan2(direction.x,direction.y)),0)
		var mat := StandardMaterial3D.new()
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode=BaseMaterial3D.CULL_DISABLED
		mat.albedo_texture=painting_texture(i)
		mat.albedo_color=Color("#ac5d3f")
		mat.emission_enabled=true
		mat.emission=Color("#482415")
		mat.emission_energy_multiplier=0.12
		plane.material_override=mat
		add_child(plane)
		paintings.append({"pos":p,"id":i,"node":plane})
		var light := OmniLight3D.new()
		light.position=p-Vector3(direction.x,0,direction.y)
		light.light_color=Color("#bfa275")
		light.light_energy=0.5
		light.omni_range=5
		add_child(light)

func glyph_circle(image: Image,center: Vector2,radius: Vector2) -> void:
	for i in range(36):
		var a := float(i)*TAU/36
		var b := float(i+1)*TAU/36
		ink_line(image,Vector2i(center+Vector2(cos(a),sin(a))*radius),Vector2i(center+Vector2(cos(b),sin(b))*radius),Color.WHITE)

func glyph_person(image: Image,at: Vector2i) -> void:
	glyph_circle(image,Vector2(at)+Vector2(0,-5),Vector2(3,3))
	ink_line(image,at,at+Vector2i(0,13),Color.WHITE)
	ink_line(image,at+Vector2i(0,4),at+Vector2i(-7,9),Color.WHITE)
	ink_line(image,at+Vector2i(0,4),at+Vector2i(7,8),Color.WHITE)
	ink_line(image,at+Vector2i(0,13),at+Vector2i(-6,21),Color.WHITE)
	ink_line(image,at+Vector2i(0,13),at+Vector2i(6,21),Color.WHITE)

func painting_texture(index: int) -> Texture2D:
	var image := Image.create(256,192,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	if index==0:
		# A remembered river, three shelters, and the uncounted traveller.
		for i in range(25):
			var y := 14+i*6
			ink_line(image,Vector2i(123+sin(i*0.32)*23,y),Vector2i(123+sin((i+1)*0.32)*23,y+6),Color.WHITE)
		for i in range(3):
			var at := Vector2i(36+i*67,65+(i%2)*42)
			ink_line(image,at+Vector2i(-15,10),at+Vector2i(0,-16),Color.WHITE)
			ink_line(image,at+Vector2i(0,-16),at+Vector2i(15,10),Color.WHITE)
			ink_line(image,at+Vector2i(-15,10),at+Vector2i(15,10),Color.WHITE)
			glyph_person(image,at+Vector2i(0,25))
		glyph_person(image,Vector2i(218,140))
	elif index==1:
		# An oversized closed eye over a many-limbed animal.
		glyph_circle(image,Vector2(128,40),Vector2(75,16))
		ink_line(image,Vector2i(53,39),Vector2i(202,39),Color.WHITE)
		glyph_circle(image,Vector2(124,113),Vector2(64,26))
		glyph_circle(image,Vector2(198,94),Vector2(21,19))
		for i in range(4):
			ink_line(image,Vector2i(80+i*30,125),Vector2i(70+i*33,164),Color.WHITE)
			ink_line(image,Vector2i(70+i*33,164),Vector2i(57+i*33,170),Color.WHITE)
		ink_line(image,Vector2i(65,107),Vector2i(29,73),Color.WHITE)
		ink_line(image,Vector2i(29,73),Vector2i(17,103),Color.WHITE)
		for x in [194,208]: glyph_circle(image,Vector2(x,91),Vector2(3,3))
		glyph_person(image,Vector2i(34,139))
	elif index==2:
		# A jagged maze, two crossed witnesses and a key outside its border.
		for i in range(6):
			var x := 27+i*31
			ink_line(image,Vector2i(x,32),Vector2i(x,126),Color.WHITE)
			ink_line(image,Vector2i(x,32 if i%2==0 else 126),Vector2i(x+28,32 if i%2==0 else 126),Color.WHITE)
		for x in [71,161]:
			glyph_circle(image,Vector2(x,155),Vector2(21,9))
			ink_line(image,Vector2i(x-16,139),Vector2i(x+16,172),Color.WHITE)
		glyph_circle(image,Vector2(231,49),Vector2(9,9))
		ink_line(image,Vector2i(230,58),Vector2i(230,106),Color.WHITE)
		ink_line(image,Vector2i(230,88),Vector2i(245,88),Color.WHITE)
		ink_line(image,Vector2i(230,101),Vector2i(243,101),Color.WHITE)
	else:
		# A palm and five distinct fingers beside the eye containing a house.
		glyph_circle(image,Vector2(63,123),Vector2(28,32))
		for i in range(5):
			var x := 39+i*12
			ink_line(image,Vector2i(x,105),Vector2i(x-4,40+absi(i-2)*9),Color.WHITE)
		ink_line(image,Vector2i(42,143),Vector2i(38,177),Color.WHITE)
		ink_line(image,Vector2i(82,146),Vector2i(86,177),Color.WHITE)
		glyph_circle(image,Vector2(181,98),Vector2(55,26))
		ink_line(image,Vector2i(161,108),Vector2i(181,83),Color.WHITE)
		ink_line(image,Vector2i(181,83),Vector2i(200,108),Color.WHITE)
		ink_line(image,Vector2i(159,77),Vector2i(205,123),Color.WHITE)
	return ImageTexture.create_from_image(image)
func ink_line(image: Image,a: Vector2i,b: Vector2i,color: Color) -> void:
	var distance := maxi(1,roundi(Vector2(a).distance_to(Vector2(b))))
	for i in range(distance+1):
		var p := Vector2(a).lerp(Vector2(b),float(i)/distance)
		for y in range(-2,3):
			for x in range(-2,3):
				var at := Vector2i(p)+Vector2i(x,y)
				if at.x>=0 and at.x<image.get_width() and at.y>=0 and at.y<image.get_height():
					var grain := fmod(absf(sin(at.x*12.7+at.y*4.3)*1453.3),1.0)
					var pigment := color
					pigment.a=0.48+grain*0.52
					if grain>0.11: image.set_pixelv(at,pigment)

func _input(event: InputEvent) -> void:
	if not app.active(): return
	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		player.rotation.y-=event.relative.x*float(app.data.settings.sensitivity)
		head.rotation.x=clampf(head.rotation.x-event.relative.y*float(app.data.settings.sensitivity),-1.32,1.32)

func _process(delta: float) -> void:
	clock+=delta
	if app.mode=="play" and not app.paused and not app.note_open: age+=delta
	for item in wisps:
		item.node.position=item.origin+Vector3(sin(clock*0.8+item.phase)*0.28,sin(clock*1.2+item.phase)*0.18,cos(clock*0.7+item.phase)*0.23)
	if is_instance_valid(key_object) and not has_key:
		key_object.rotation.y+=delta*0.5
		key_object.position.y=0.9+sin(clock)*0.1
	if is_instance_valid(creature_model):
		for i in range(legs.size()): legs[i].rotation.x=sin(clock*8+i*PI)*0.25 if awake else 0
		creature_model.position.y=sin(clock*3)*0.025
	if app.mode=="capture" and is_instance_valid(creature):
		if not capture_prepared:
			capture_prepared=true
			# The catch is a cinematic close-up, never hidden behind a door or wall.
			for mesh in find_children("*","MeshInstance3D",true,false):
				if not creature.is_ancestor_of(mesh): mesh.hide()
		creature.position=camera.global_position-camera.global_basis.z*2.55-Vector3(0,0.45,0)
		creature.look_at(Vector3(camera.global_position.x,creature.position.y,camera.global_position.z),Vector3.UP)
		return
	if app.mode!="play": return
	survey_camera.current=app.overview
	camera.current=not app.overview
	survey_marker.visible=app.overview
	survey_marker.position=Vector3(player.position.x,4.3,player.position.z)
	if not app.active(): return
	hunt_surge=maxf(0,hunt_surge-delta)
	if chapter=="cave" and seen_paintings.size()>=2:
		if not echo_played:
			echo_played=true
			app.play_cue("knock")
			app.toast("Three steps answer yours. You have stopped walking.")
		var path: Array[Vector2i]=layout.route(layout.cell_at(player.position),layout.finish)
		guide.visible=path.size()>4 and fmod(age,13)<2.5
		if path.size()>4: guide.position=layout.point(path[4])
	if chapter=="cave" and not sealed and player.position.distance_to(Vector3.ZERO)>3:
		sealed=true
		seal.show()
		seal.collision_layer=1
		app.toast("Stone where the entrance was. There is only one direction now.")
	if chapter=="maze":
		if age>14: awake=true
		update_guide()
		if bool(app.data.settings.shake) and creature.position.distance_to(player.position)<12:
			camera.rotation.z=sin(clock*11)*0.004
		else: camera.rotation.z=0
		if exit_door.opened and player.position.distance_to(finish_point)<2.1: app.chapter_complete()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not app.active(): return
	var input := Input.get_vector("left","right","forward","back")
	app.update_endurance(delta,input.length()>0)
	var direction := player.basis*Vector3(input.x,0,input.y)
	var speed := 7.4 if app.sprinting() else 5.2
	player.velocity.x=direction.x*speed
	player.velocity.z=direction.z*speed
	player.velocity.y-=18*delta
	player.move_and_slide()
	if chapter=="cave" and not sealed and player.position.z < -1.0:
		player.position.z=-1.0
		sealed=true
		seal.show()
		seal.collision_layer=1
		app.toast("Stone where the entrance was. There is only one direction now.")
	head.position.y=0.65+sin(clock*9)*0.025*input.length()
	if chapter=="maze" and awake: move_creature(delta)

func move_creature(delta: float) -> void:
	path_clock-=delta
	var nearest: Vector3=layout.point(layout.cell_at(creature.position))
	var centered := Vector2(nearest.x,nearest.z).distance_to(Vector2(creature.position.x,creature.position.z))<0.32
	if monster_path.is_empty() or (path_clock<=0 and centered):
		path_clock=0.5
		monster_path=layout.route(layout.cell_at(creature.position),layout.cell_at(player.position))
	var target := player.position
	if monster_path.size()>1:
		target=layout.point(monster_path[1])
		if Vector2(creature.position.x,creature.position.z).distance_to(Vector2(target.x,target.z))<0.3: monster_path.pop_front()
	var d := target-creature.position
	d.y=0
	d=d.normalized()
	var hunting_speed := 5.35 if hunt_surge>0 else 4.68
	creature.velocity=Vector3(d.x*hunting_speed,creature.velocity.y-18*delta,d.z*hunting_speed)
	creature.move_and_slide()
	if d.length()>0.1: creature.rotation.y=lerp_angle(creature.rotation.y,atan2(-d.x,-d.z),minf(1,delta*8))
	for door in doors:
		if not door.opened and not door.locked and creature.position.distance_to(door.global_position+door.global_basis.x*1.0)<2.8: door.interact(false)
	if creature.position.distance_to(player.position)<1.15:
		screech.play()
		app.fail_run("SEEN",true)
	breath.volume_db=-12+linear_to_db(maxf(0.0001,float(app.data.settings.horror)))

func update_guide() -> void:
	var target: Vector2i=layout.finish if has_key else layout.key_cell
	var nearest := 9999
	for witness in witnesses:
		if not witness.broken:
			var distance := layout.route(layout.cell_at(player.position),witness.cell).size()
			if distance<nearest:
				nearest=distance
				target=witness.cell
	var route: Array[Vector2i]=layout.route(layout.cell_at(player.position),target)
	if route.size()>3:
		guide.visible=fmod(age,9.0)<3.0
		guide.position=layout.point(route[mini(4,route.size()-1)])
	else: guide.visible=false

func ray_interaction() -> Dictionary:
	if not is_instance_valid(camera) or not is_inside_tree(): return {}
	var start := camera.global_position
	var end := start-camera.global_basis.z*3.2
	var query := PhysicsRayQueryParameters3D.create(start,end)
	query.exclude=[player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)

func interact() -> void:
	if not app.active(): return
	if chapter=="cave":
		for item in paintings:
			if player.position.distance_to(item.pos)<3.4:
				seen_paintings[item.id]=true
				app.show_note("OCHRE / %d" % (item.id+1),LORE.CAVE[item.id])
				return
		if player.position.distance_to(finish_point)<3.5:
			if seen_paintings.size()>=4: app.chapter_complete()
			else: app.toast("Read all four warnings. The last explains why escape is not safety.")
		return
	for i in range(witnesses.size()):
		if not witnesses[i].broken and player.position.distance_to(witnesses[i].pos+Vector3(0,0.9,0))<2.2:
			break_witness(i)
			return
	for item in inscriptions:
		if player.position.distance_to(item.pos+Vector3(0,0.9,0))<2:
			app.show_note(LORE.RUINS[item.id][0],LORE.RUINS[item.id][1])
			return
	var hit := ray_interaction()
	if not hit.is_empty() and hit.collider.has_meta("door"):
		hit.collider.get_meta("door").interact(has_key)

func objective() -> String:
	if chapter=="cave": return "Read four ochre warnings. Follow the cave to the old doorway.  %d / 4" % mini(seen_paintings.size(),4)
	return "Break the witnesses: %d / 2. Brass key: %s. Reach the doorway of light." % [seals_broken,"FOUND" if has_key else "MISSING"]

func prompt() -> String:
	if app.overview: return "SURVEY VIEW / Release TAB to return. Movement and mouse-look are disabled."
	if app.note_open or not app.active(): return ""
	if chapter=="cave":
		for item in paintings:
			if player.position.distance_to(item.pos)<3.4: return "E / SPACE  READ OCHRE"
		if player.position.distance_to(finish_point)<3.5: return "E / SPACE  FOLLOW THE PASSAGE"
	else:
		for witness in witnesses:
			if not witness.broken and player.position.distance_to(witness.pos+Vector3(0,0.9,0))<2.2: return "E / SPACE  ERASE YOUR NAME / BREAK WITNESS"
		for item in inscriptions:
			if player.position.distance_to(item.pos+Vector3(0,0.9,0))<2: return "E / SPACE  READ INSCRIPTION"
		var hit := ray_interaction()
		if not hit.is_empty() and hit.collider.has_meta("door"):
			var door: Node=hit.collider.get_meta("door")
			if door.locked: return "E / SPACE  UNLOCK" if has_key else "LOCKED / A brass key is missing"
			return "E / SPACE  CLOSE DOOR" if door.opened else "E / SPACE  OPEN DOOR"
	return ""

func whisper() -> String:
	if chapter=="cave" and sealed: return "the first maps were warnings" if int(age)%21<3 else ""
	if chapter=="maze" and awake: return "don't look back" if int(age)%17<3 else ""
	return ""

func danger_level() -> float:
	if chapter=="cave": return 0.18+float(seen_paintings.size())*0.13
	if not awake: return 0.1
	return clampf(1.0-creature.position.distance_to(player.position)/22.0+hunt_surge*0.025,0.2,1.0)

func _exit_tree() -> void:
	if is_instance_valid(breath):
		breath.stop()
		breath.stream=null
