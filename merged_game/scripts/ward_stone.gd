extends Node3D
signal claimed(stone: Node3D)
var ward_name := "West"
var taken := false
var glow: OmniLight3D

func _ready() -> void:
	var mesh := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = 0.22
	shape.bottom_radius = 0.35
	shape.height = 1.35
	mesh.mesh = shape
	mesh.position.y = 0.675
	mesh.material_override = preload("res://assets/materials/stone_wall.tres")
	add_child(mesh)
	var label := Label3D.new()
	label.text = "YOG-SOTHOTH\nTHE GATE • THE KEY\n" + ward_name.to_upper() + " WARD"
	label.font_size = 34
	label.pixel_size = 0.006
	label.position = Vector3(0, 1.35, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(0.74, 0.82, 0.72)
	add_child(label)
	glow = OmniLight3D.new()
	glow.position.y = 1.4
	glow.light_color = Color(0.55, 0.8, 0.68)
	glow.light_energy = 0.7
	glow.omni_range = 3.5
	add_child(glow)
	var body := StaticBody3D.new()
	body.collision_layer = 3
	body.set_meta("interact_target", self)
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.65, 1.5, 0.65)
	cs.shape = box
	cs.position.y = 0.75
	body.add_child(cs)
	add_child(body)

func prompt() -> String:
	return "the ward is broken" if taken else "break the " + ward_name + " ward • before taking the Black Key"

func interact(_from: Vector3) -> void:
	if taken: return
	taken = true
	glow.light_color = Color(0.8, 0.18, 0.06)
	claimed.emit(self)
