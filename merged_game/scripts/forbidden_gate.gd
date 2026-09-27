extends Node3D
signal crossed
var is_open := false
var spent := false
var hinge: Node3D
var threshold: Area3D

func _ready() -> void:
	for side in [-1, 1]:
		_block(Vector3(side * 1.0, 1.65, 0), Vector3(0.38, 3.3, 0.6))
	_block(Vector3(0, 3.12, 0), Vector3(2.4, 0.48, 0.6))
	var label := Label3D.new()
	label.text = "AZATHOTH\nNO EYE MAY CROSS"
	label.font_size = 32
	label.pixel_size = 0.0035
	label.position = Vector3(0, 2.48, 0.35)
	label.modulate = Color(0.72, 0.22, 0.16)
	add_child(label)
	hinge = AnimatableBody3D.new()
	hinge.position.x = -0.82
	add_child(hinge)
	var leaf := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.64, 2.65, 0.22)
	leaf.mesh = bm
	leaf.position = Vector3(0.82, 1.325, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.075, 0.055)
	mat.roughness = 1
	leaf.material_override = mat
	hinge.add_child(leaf)
	var body := hinge as AnimatableBody3D
	body.set_meta("interact_target", self)
	body.collision_layer = 3
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = bm.size
	cs.shape = box
	cs.position = leaf.position
	body.add_child(cs)
	threshold = Area3D.new()
	threshold.position = Vector3(0, 1.3, -0.1)
	threshold.collision_layer = 0
	threshold.collision_mask = 1
	var trigger := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(1.4, 2.5, 0.16)
	trigger.shape = bs
	threshold.add_child(trigger)
	add_child(threshold)
	threshold.body_entered.connect(_cross)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 2, 0.5)
	light.light_color = Color(0.65, 0.09, 0.03)
	light.light_energy = 0.6
	light.omni_range = 4.5
	add_child(light)

func _block(pos: Vector3, dimensions: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = dimensions
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = preload("res://assets/materials/stone_wall.tres")
	add_child(mesh)

func prompt() -> String:
	return "FORBIDDEN • step back" if is_open else "open the forbidden gate • the inscription warns of death"

func interact(_from: Vector3) -> void:
	if is_open: return
	is_open = true
	Music.sfx("creak", 0.8, 0.65)
	var tw := create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.tween_property(hinge, "rotation:y", -PI * 0.55, 1.4)
	await tw.finished
	for body in threshold.get_overlapping_bodies(): _cross(body)

func _cross(body: Node3D) -> void:
	if not is_open or spent or not body is CharacterBody3D: return
	spent = true
	crossed.emit()
