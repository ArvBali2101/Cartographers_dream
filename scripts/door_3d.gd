extends Node3D

var opened := false
var locked := false
var locked_exit := false
var pivot: Node3D
var body: AnimatableBody3D
var collision: CollisionShape3D
var lock_mesh: MeshInstance3D
var motion: Tween
var app: Node
static var timber: Texture2D

func timber_texture() -> Texture2D:
	if timber!=null: return timber
	var noise := FastNoiseLite.new()
	noise.seed=381
	noise.frequency=0.04
	var image := Image.create(128,256,false,Image.FORMAT_RGB8)
	for y in range(256):
		for x in range(128):
			var wave := sin(float(x)*1.5+noise.get_noise_2d(x,y*0.17)*13)*0.055
			var shade := 0.62+wave+noise.get_noise_2d(x,y)*0.11
			image.set_pixel(x,y,Color(shade*0.69,shade*0.48,shade*0.31))
	timber=ImageTexture.create_from_image(image)
	return timber

func configure(owner_app: Node,at: Vector3,angle: float,needs_key: bool=false) -> void:
	app=owner_app
	position=at
	rotation.y=angle
	locked=needs_key
	locked_exit=needs_key

func _ready() -> void:
	body=AnimatableBody3D.new()
	body.sync_to_physics=true
	pivot=body
	add_child(body)
	body.set_meta("door",self)
	var material := StandardMaterial3D.new()
	material.albedo_color=Color("#ded2bb")
	material.albedo_texture=timber_texture()
	material.roughness=0.94
	var panel := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size=Vector3(2.15,2.85,0.28)
	panel.mesh=mesh
	panel.material_override=material
	panel.position=Vector3(1.075,1.425,0)
	body.add_child(panel)
	collision=CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size=mesh.size
	collision.shape=shape
	collision.position=panel.position
	body.add_child(collision)
	var iron := StandardMaterial3D.new()
	iron.albedo_color=Color("#313835")
	iron.metallic=0.6
	for height in [0.48,2.33]:
		var strap := MeshInstance3D.new()
		var strap_box := BoxMesh.new()
		strap_box.size=Vector3(2.19,0.12,0.32)
		strap.mesh=strap_box
		strap.material_override=iron
		strap.position=Vector3(1.075,height,0)
		body.add_child(strap)
	for x in range(1,8):
		var seam := MeshInstance3D.new()
		var seam_box := BoxMesh.new()
		seam_box.size=Vector3(0.014,2.8,0.3)
		seam.mesh=seam_box
		seam.material_override=iron
		seam.position=Vector3(float(x)*0.269,1.425,0)
		body.add_child(seam)
	lock_mesh=MeshInstance3D.new()
	var lock_box := BoxMesh.new()
	lock_box.size=Vector3(0.33,0.43,0.4)
	lock_mesh.mesh=lock_box
	var brass := StandardMaterial3D.new()
	brass.albedo_color=Color("#bb914d")
	brass.metallic=0.7
	lock_mesh.material_override=brass
	lock_mesh.position=Vector3(1.81,1.36,0)
	body.add_child(lock_mesh)
	lock_mesh.visible=locked
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius=0.1
	torus.outer_radius=0.15
	ring.mesh=torus
	ring.material_override=brass
	ring.rotation.x=PI/2
	ring.position=Vector3(1.81,1.64,0.19)
	body.add_child(ring)
	ring.visible=locked
	# Historical protective motifs are visually distinct from the red witnesses.
	var chalk := StandardMaterial3D.new()
	chalk.albedo_color=Color("#9b9985")
	for i in range(6):
		var mark := MeshInstance3D.new()
		var loop := TorusMesh.new()
		loop.inner_radius=0.058
		loop.outer_radius=0.067
		loop.rings=12
		loop.ring_segments=8
		mark.mesh=loop
		mark.material_override=chalk
		mark.rotation.x=PI/2
		mark.position=Vector3(0.35+cos(i*TAU/6)*0.065,1.55+sin(i*TAU/6)*0.065,0.16)
		body.add_child(mark)

func interact(has_key: bool) -> bool:
	if locked_exit and locked and has_key and is_instance_valid(app.level) and app.level.get("seals_broken") != null and app.level.seals_broken<2:
		app.toast("The key turns, but your name still holds the door. Break both witnessing seals.")
		return false
	if locked and not has_key:
		if is_instance_valid(app): app.toast("A large brass lock. Somewhere in this ruin is its key.")
		return false
	if locked:
		locked=false
		lock_mesh.visible=false
		if is_instance_valid(app): app.toast("The lock gives way. The light is real.")
	opened=not opened
	if is_instance_valid(motion): motion.kill()
	motion=create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	motion.tween_property(pivot,"rotation:y",-PI*0.49 if opened else 0.0,0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return true
