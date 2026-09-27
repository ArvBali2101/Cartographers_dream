extends Control
## Asset-based forbidden idol insert. Live 3D, not a painted backdrop.
var age := 0.0
var viewport: SubViewport
var camera: Camera3D
var idol: Node3D
var lamp: OmniLight3D
var frame: TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport = SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_4X
	add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.002, 0.003, 0.004)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.25, 0.29, 0.31)
	env.environment.ambient_light_energy = 0.13
	env.environment.fog_enabled = true
	env.environment.fog_light_color = Color(0.018, 0.022, 0.025)
	env.environment.fog_density = 0.045
	world.add_child(env)
	idol = preload("res://assets/models/forbidden_idol/gothic_statue_4k.gltf").instantiate()
	world.add_child(idol)
	var bounds := AABB()
	var first := true
	for node in idol.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = node.global_transform * node.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	if not first and bounds.size.y > 0:
		var factor := 6.8 / bounds.size.y
		idol.scale *= factor
		idol.position = Vector3(-bounds.get_center().x, -bounds.position.y, -bounds.get_center().z) * factor
	# Reveal fragments of an ancient idol; no invented full anatomy for the god.
	for side in [-1, 1]:
		var stone := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.6, 7.5, 0.8)
		stone.mesh = box
		stone.material_override = preload("res://assets/materials/stone_wall.tres")
		stone.position = Vector3(side * 2.6, 3.2, 1.0)
		stone.rotation.z = side * 0.035
		world.add_child(stone)
	lamp = OmniLight3D.new()
	lamp.position = Vector3(-1.7, 5.1, 3.1)
	lamp.light_color = Color(0.84, 0.73, 0.58)
	lamp.light_energy = 1.4
	lamp.omni_range = 9
	world.add_child(lamp)
	var rim := OmniLight3D.new()
	rim.position = Vector3(2.3, 6.0, -1.2)
	rim.light_color = Color(0.5, 0.62, 0.7)
	rim.light_energy = 1.1
	rim.omni_range = 10
	world.add_child(rim)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 42
	camera.near = 0.05
	world.add_child(camera)
	frame = TextureRect.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.texture = viewport.get_texture()
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	var band := ColorRect.new()
	band.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	band.offset_top = -128
	band.color = Color(0, 0, 0, 0.94)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)
	var caption := Label.new()
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.text = "YOU LOOKED AT A GOD."
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.add_theme_font_override("font", preload("res://assets/fonts/IMFellEnglish.ttf"))
	caption.add_theme_font_size_override("font_size", 36)
	caption.add_theme_color_override("font_color", Color(0.84, 0.81, 0.74))
	band.add_child(caption)
	_process(0)

func _process(delta: float) -> void:
	age += delta
	if not camera: return
	camera.position = Vector3(sin(age * 0.25) * 0.13, 5.9 + age * 0.025, 5.4 - minf(age * 0.11, 0.6))
	camera.look_at(Vector3(0, 5.65, 0))
	lamp.light_energy = 1.4 + sin(age * 9.3) * sin(age * 6.7) * 0.035
