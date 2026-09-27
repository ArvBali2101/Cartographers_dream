extends RefCounted

var width := 15
var height := 13
var connections := {}
var start := Vector2i(0,0)
var finish := Vector2i.ZERO
var key_cell := Vector2i.ZERO
var outside := Vector2i.RIGHT
var cell_size := 4.4
var rng := RandomNumberGenerator.new()

func generate(w: int,h: int,noise_seed: int) -> void:
	width=w
	height=h
	connections.clear()
	rng.seed=noise_seed
	for y in range(h):
		for x in range(w): connections[Vector2i(x,y)]=[]
	var visited := {start:true}
	var stack: Array[Vector2i]=[start]
	while not stack.is_empty():
		var current: Vector2i = stack.back()
		var candidates: Array[Vector2i]=[]
		for direction in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var next: Vector2i=current+direction
			if connections.has(next) and not visited.has(next): candidates.append(next)
		if candidates.is_empty(): stack.pop_back()
		else:
			var next: Vector2i=candidates[rng.randi_range(0,candidates.size()-1)]
			connect_cells(current,next)
			visited[next]=true
			stack.append(next)
	# Open a few loops and small empty chambers without erasing the maze.
	for i in range(w/2):
		var p := Vector2i(rng.randi_range(1,w-3),rng.randi_range(1,h-3))
		connect_cells(p,p+Vector2i.RIGHT)
		if i%3==0:
			connect_cells(p,p+Vector2i.DOWN)
			connect_cells(p+Vector2i.DOWN,p+Vector2i(1,1))
			connect_cells(p+Vector2i.RIGHT,p+Vector2i(1,1))
	# Unbroken galleries allow the guide to be seen at a distance.
	if w>10:
		for row in [3,7,11]:
			for x in range(2,mini(w-3,10)): connect_cells(Vector2i(x,row),Vector2i(x+1,row))
	var distances := distances_from(start)
	var best := -1
	for p in connections:
		if p.x in [0,w-1] or p.y in [0,h-1]:
			if distances[p]>best:
				best=distances[p]
				finish=p
	if finish.x==w-1: outside=Vector2i.RIGHT
	elif finish.y==h-1: outside=Vector2i.DOWN
	elif finish.x==0: outside=Vector2i.LEFT
	else: outside=Vector2i.UP
	var from_exit := distances_from(finish)
	best=-1
	for p in connections:
		var value: int=distances[p]+from_exit[p]
		if distances[p]<8 or from_exit[p]<8: continue
		if value>best:
			best=value
			key_cell=p

func connect_cells(a: Vector2i,b: Vector2i) -> void:
	if not connections[a].has(b): connections[a].append(b)
	if not connections[b].has(a): connections[b].append(a)

func distances_from(origin: Vector2i) -> Dictionary:
	var result := {origin:0}
	var queue: Array[Vector2i]=[origin]
	var index := 0
	while index<queue.size():
		var p := queue[index]
		index+=1
		for next in connections[p]:
			if result.has(next): continue
			result[next]=result[p]+1
			queue.append(next)
	return result

func route(from: Vector2i,to: Vector2i) -> Array[Vector2i]:
	if not connections.has(from) or not connections.has(to): return []
	var queue: Array[Vector2i]=[from]
	var parent := {from:from}
	var index := 0
	while index<queue.size():
		var p := queue[index]
		index+=1
		if p==to: break
		for next in connections[p]:
			if parent.has(next): continue
			parent[next]=p
			queue.append(next)
	if not parent.has(to): return []
	var path: Array[Vector2i]=[to]
	var cursor := to
	while cursor!=from:
		cursor=parent[cursor]
		path.push_front(cursor)
	return path

func point(cell: Vector2i) -> Vector3:
	return Vector3(cell.x*cell_size,0,cell.y*cell_size)

func cell_at(point_3d: Vector3) -> Vector2i:
	return Vector2i(clampi(roundi(point_3d.x/cell_size),0,width-1),clampi(roundi(point_3d.z/cell_size),0,height-1))
