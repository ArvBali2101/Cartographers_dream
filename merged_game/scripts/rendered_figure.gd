extends Control
## Live HD 3D insert with articulated limbs, lighting and a wind-shaped coat.
var approach := 0.0
var closeup := false
var time := 0.0
var shot_yaw := 0.0
var viewport: SubViewport
var camera: Camera3D
var figure: Node3D
var joints: Array[Node3D] = []
var image_rect: TextureRect
var scanned_model: Node3D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_fit()
	get_parent().resized.connect(_fit)
	viewport = SubViewport.new()
	viewport.size = Vector2i(1920,1080)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_2X
	add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.33,0.4,0.5)
	environment.environment.ambient_light_energy = 0.25
	world.add_child(environment)
	camera = Camera3D.new()
	camera.fov = 36
	world.add_child(camera)
	camera.current = true
	var rim := OmniLight3D.new()
	rim.position = Vector3(-1.8,2.6,-0.8)
	rim.light_color = Color(0.55,0.7,0.94)
	rim.light_energy = 3.0
	rim.omni_range = 7
	world.add_child(rim)
	var key := OmniLight3D.new()
	key.position = Vector3(2,2.4,2)
	key.light_color = Color(0.75,0.65,0.5)
	key.light_energy = 1.8
	key.omni_range = 7
	world.add_child(key)
	figure = Node3D.new()
	world.add_child(figure)
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color(0.075,0.083,0.09)
	cloth.roughness = 0.97
	var boots := StandardMaterial3D.new()
	boots.albedo_color = Color(0.025,0.021,0.018)
	boots.roughness = 0.68
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.22,0.17,0.13)
	skin.roughness = 0.9
	var coat := CylinderMesh.new()
	coat.top_radius = 0.22
	coat.bottom_radius = 0.33
	coat.height = 0.94
	coat.radial_segments = 48
	coat.rings = 12
	var coat_instance := _mesh(coat,Vector3(0,1.03,0),cloth,figure)
	var weave := ShaderMaterial.new()
	weave.shader = preload("res://shaders/figure_cloth.gdshader")
	coat_instance.material_override = weave
	var head := SphereMesh.new()
	head.radius = 0.13
	head.height = 0.3
	head.radial_segments = 32
	head.rings = 24
	_mesh(head,Vector3(0,1.7,0),skin,figure)
	var hood := SphereMesh.new()
	hood.radius = 0.17
	hood.height = 0.38
	_mesh(hood,Vector3(0,1.73,-0.085),cloth,figure)
	for side in [-1,1]:
		var arm := Node3D.new()
		arm.position = Vector3(side*0.24,1.42,0)
		figure.add_child(arm)
		joints.append(arm)
		var sleeve := CapsuleMesh.new()
		sleeve.radius = 0.07
		sleeve.height = 0.6
		_mesh(sleeve,Vector3(side*0.04,-0.25,0),cloth,arm)
		var hand := SphereMesh.new()
		hand.radius = 0.055
		hand.height = 0.14
		_mesh(hand,Vector3(side*0.04,-0.59,0),skin,arm)
		var leg := Node3D.new()
		leg.position = Vector3(side*0.12,0.64,0)
		figure.add_child(leg)
		joints.append(leg)
		var trouser := CapsuleMesh.new()
		trouser.radius = 0.08
		trouser.height = 0.55
		_mesh(trouser,Vector3(0,-0.24,0),cloth,leg)
		var boot := BoxMesh.new()
		boot.size = Vector3(0.15,0.14,0.27)
		_mesh(boot,Vector3(0,-0.54,0.06),boots,leg)
	_load_scanned_figure()
	image_rect = TextureRect.new()
	image_rect.texture = viewport.get_texture()
	image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(image_rect)
	_fit()

func _load_scanned_figure() -> void:
	var path := "res://assets/models/gothic_figure/gothic_statue_2k.gltf"
	if not ResourceLoader.exists(path): return
	var packed := load(path) as PackedScene
	if packed == null: return
	for child in figure.get_children():
		if child is Node3D: child.hide()
	scanned_model = packed.instantiate()
	figure.add_child(scanned_model)
	var bounds := AABB()
	var first := true
	for node in scanned_model.find_children("*","MeshInstance3D",true,false):
		var box: AABB = node.global_transform * node.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	if first or bounds.size.y <= 0: return
	var factor := 1.85 / bounds.size.y
	scanned_model.scale *= factor
	scanned_model.position = Vector3(-bounds.get_center().x,-bounds.position.y,-bounds.get_center().z)*factor

func _mesh(mesh: Mesh, at: Vector3, material: Material, parent: Node3D) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	parent.add_child(instance)
	return instance

func _fit() -> void:
	size = get_parent().size
	if image_rect:
		image_rect.size = size if closeup else Vector2(size.x*0.65,size.y*0.46)
		image_rect.position = Vector2.ZERO if closeup else Vector2(size.x*0.175,size.y*0.025)

func _process(delta: float) -> void:
	time += delta
	if not camera: return
	var moving := 1.0-approach
	figure.position.y = sin(time*7.0)*0.012*moving
	figure.rotation.y = shot_yaw + sin(time*0.4)*0.08
	if scanned_model:
		figure.scale.y = 1.0 + sin(time*1.2)*0.003
	for i in joints.size():
		joints[i].rotation.x = sin(time*3.5 + (PI if i >= 2 else 0))*0.2*moving*(1 if i%2==0 else -1)
	camera.position = Vector3(0,1.25,lerpf(5.5,1.2,approach*approach))
	camera.look_at(Vector3(0,lerpf(1.1,1.55,approach),0))
	queue_redraw()

func _draw() -> void:
	if closeup: draw_rect(Rect2(Vector2.ZERO,size),Color.BLACK)
