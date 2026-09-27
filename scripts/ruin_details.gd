extends RefCounted

var transforms: Array[Transform3D] = []

func block(position: Vector3,size: Vector3,angle: float=0) -> void:
	transforms.append(Transform3D(Basis(Vector3.UP,angle).scaled(size),position))

func build(level: Node3D) -> void:
	var scale: float=level.layout.cell_size
	for cell in level.layout.connections:
		var center: Vector3=level.layout.point(cell)
		for direction in [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]:
			var next: Vector2i=cell+direction
			if level.layout.connections[cell].has(next): continue
			if cell==level.layout.finish and direction==level.layout.outside: continue
			if level.chapter=="cave" and cell==Vector2i.ZERO and direction==Vector2i.UP: continue
			if level.layout.connections.has(next) and direction in [Vector2i.LEFT,Vector2i.UP]: continue
			var at := center+Vector3(direction.x,0,direction.y)*scale/2
			var angle := PI/2 if direction.x!=0 else 0.0
			if level.chapter=="maze":
				block(at+Vector3(0,0.16,0),Vector3(scale+0.48,0.32,0.72),angle)
				block(at+Vector3(0,3.57,0),Vector3(scale+0.48,0.28,0.72),angle)
				for offset in [-1.75,1.75]:
					var side := Vector3(cos(angle),0,-sin(angle))
					block(at+side*offset+Vector3(0,1.86,0),Vector3(0.30,3.12,0.69),angle)
		# Scattered evidence sits near walls, never across the traversable centre.
		if (cell.x*7+cell.y*13)%17==0:
			var table := center+Vector3(1.32,0.36,1.32)
			level.box(table,Vector3(0.65,0.72,0.65),level.cave_material,false)
			var paper: StandardMaterial3D=level.material(Color("#c8b58b"))
			level.box(table+Vector3(0,0.375,0),Vector3(0.46,0.025,0.38),paper,false,0.24)
		if level.chapter=="cave" and (cell.x+cell.y)%2==0:
			var rock := MeshInstance3D.new()
			var cone := CylinderMesh.new()
			cone.top_radius=0.36
			cone.bottom_radius=0.035
			cone.height=1.3+float(cell.x%3)*0.35
			cone.radial_segments=7
			rock.mesh=cone
			rock.material_override=level.cave_material
			rock.position=center+Vector3(1.6,3.3,1.6)
			level.add_child(rock)
	if transforms.is_empty(): return
	var instances := MultiMeshInstance3D.new()
	instances.name="BatchedStoneArchitecture"
	var batch := MultiMesh.new()
	batch.transform_format=MultiMesh.TRANSFORM_3D
	batch.mesh=BoxMesh.new()
	batch.instance_count=transforms.size()
	for i in range(transforms.size()): batch.set_instance_transform(i,transforms[i])
	instances.multimesh=batch
	instances.material_override=level.stone_material
	level.add_child(instances)
