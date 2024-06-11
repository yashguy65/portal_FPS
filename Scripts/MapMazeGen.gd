extends Node3D

signal player_start(initial: Vector3)

@export_enum("WITHOUT_WALLS",	"NORMAL",	"PLAYGROUND") var mode
@export var nav_path : NodePath
@export var visualize: bool = false

var room1_scene = preload("res://Scenes/room_1_side.tscn")
var room2_adj_scene = preload("res://Scenes/room_2_sides_adjacent.tscn")
var room2_opp_scene = preload("res://Scenes/room_2_sides_opposite.tscn")
var room3_scene = preload("res://Scenes/room_3_sides.tscn")
var room4_scene = preload("res://Scenes/room_4_sides.tscn")
var room0_scene = preload("res://Scenes/room_0_sides.tscn")
var portal_pair = preload("res://Scenes/portal_pair.tscn")

@onready var portal_parent: Node3D = $"../PortalParent"

var destroyer = preload("res://Scenes/Destroyer.tscn")
var turret = preload("res://Scenes/Turret.tscn")
var portal = preload("res://Scenes/Portal.tscn")

var room_size := Vector3(30, 30, 30) #update turret.gd as well

var grid: Array = []
var unvisited: Array = []
var grid_side := 20
var rng = RandomNumberGenerator.new()
var visited_cells: int
var number_of_portal_pairs: int = 5
var number_of_enemies : int = 14

func _ready():
	# Handles easy/hard mode differences
	if g.difficulty == 1:
		grid_side = 10
		number_of_portal_pairs = 3
		number_of_enemies = 7
		
	grid.resize(grid_side)
	for i in range(grid_side):
		grid[i] = []
		for j in range(grid_side):
			grid[i].append([0,0,0,0,  0,0,0,0,  0,0,0,0,  1,1,1,1])
			unvisited.append(Vector2(i, j))

	# START COORDINATES
	var x: int = 0
	var y: int = 0
	var current_cell := Vector2(x, y)
	visited_cells = 1
	var backtrack: Array = []
	unvisited.erase(current_cell)  # Mark starting cell as visited

	# Calculate initial position for player
	var initial_position = Vector3(x * room_size.x, 0, y * room_size.z)

	while visited_cells < (grid_side * grid_side):
		var neighbours: Array = checkNeighboursWithWallsIntact(current_cell)
		if neighbours.size() > 0:
			var z: int = rng.randi_range(0, neighbours.size() - 1)
			var next_cell = neighbours[z]
			# Check which walls the neighbour is connected by
			if next_cell.x == current_cell.x:
				if next_cell.y == current_cell.y + 1: # 0,0 to 0,1 
					grid[current_cell.x][current_cell.y][13] = 0 # SOUTH WALL CURRENT 
					grid[next_cell.x][next_cell.y][15] = 0 # NORTH WALL NEXT
				elif next_cell.y == current_cell.y - 1: #0,1 to 0,0
					grid[current_cell.x][current_cell.y][15] = 0 # NORTH WALL CURRENT
					grid[next_cell.x][next_cell.y][13] = 0 # SOUTH WALL NEXT
			elif next_cell.y == current_cell.y:
				if next_cell.x == current_cell.x + 1: #0,0 to 1,0
					grid[current_cell.x][current_cell.y][14] = 0 #EAST WALL CURRENT
					grid[next_cell.x][next_cell.y][12] = 0 #WEST WALL NEXT
				elif next_cell.x == current_cell.x - 1: #1,0 to 0,0
					grid[current_cell.x][current_cell.y][12] = 0 # WEST WALL CURRENT
					grid[next_cell.x][next_cell.y][14] = 0 #EAST WALL NEXT
			backtrack.append(current_cell)
			current_cell = next_cell            
			visited_cells += 1
			unvisited.erase(next_cell)
		else:
			if backtrack.size() > 0:
				current_cell = backtrack.pop_back()
			else:
				break
	if mode == 2:
		_instantiate_test_rooms() 
		pass
	elif mode == 1:
		_instantiate_rooms()
	else: # mode == 0
		_instantiate_empty_rooms()
	_emit_player_start(initial_position)
	_spawn_enemies()
	_place_portals()
	bake_navigation_mesh(nav_path)

func checkNeighboursWithWallsIntact(coords: Vector2) -> Array:
	var possible: Array = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
	var list: Array = []
	for i in possible:
		var neighbour_coords = coords + i
		if unvisited.has(neighbour_coords) and \
		   grid[neighbour_coords.x][neighbour_coords.y][12] == 1 and \
		   grid[neighbour_coords.x][neighbour_coords.y][13] == 1 and \
		   grid[neighbour_coords.x][neighbour_coords.y][14] == 1 and \
		   grid[neighbour_coords.x][neighbour_coords.y][15] == 1:
			list.append(neighbour_coords)
	return list

func _instantiate_rooms() -> void:
	for x in range(grid_side):
		for y in range(grid_side):
			var room_scene = get_room_type(grid[x][y])
			var room_instance = room_scene.instantiate()
			if room_instance is Node3D:
				room_instance.transform.origin = Vector3(x * room_size.x, 15, y * room_size.z)
				_apply_rotation(room_instance, grid[x][y])
			add_child(room_instance)

func get_room_type(cell: Array) -> PackedScene:
	var walls = cell.slice(12, 16)
	var wall_count = walls.count(1)

	if wall_count == 4:
		print("4 WALL ROOM")
		return room4_scene
	elif wall_count == 3:
		return room3_scene
	elif wall_count == 2:
		if walls[0] == walls[2] or walls[1] == walls[3]:
			return room2_opp_scene
		else:
			return room2_adj_scene
	elif wall_count == 1:
		return room1_scene
	else:
		print("0 WALL ROOM")
		return room0_scene

func _apply_rotation(node: Node3D, cell: Array) -> void:
	var walls = cell.slice(12, 16)
	var rotation_degrees = 0

	if walls.count(1) == 1:			# WALLS ON
		if walls[0] == 1:
			rotation_degrees = 270	# W
		elif walls[1] == 1:
			rotation_degrees = 0 	# S (default)
		elif walls[2] == 1:
			rotation_degrees = 90	# E
		else:
			rotation_degrees = 180	# N

	elif walls.count(1) == 2:
		#ADJACENT WALLS
		if walls[0] == 1 and walls[1] == 1:		# WALLS ON
			rotation_degrees = 90				# WS
		elif walls[1] == 1 and walls[2] == 1:
			rotation_degrees = 180				# SE
		elif walls[2] == 1 and walls[3] == 1:
			rotation_degrees = 270				# EN
		elif walls[3] == 1 and walls[0] == 1:
			rotation_degrees = 0				# NW
		#OPPOSITE WALLS
		if walls[0] == 1 and walls[2] == 1:
			rotation_degrees = 90  				# WE
		elif walls[1] == 1 and walls[3] == 1:
			rotation_degrees = 0				# SN (default)

	elif walls.count(1) == 3:      #WALL NOT ON
		if walls[0] == 0:
			rotation_degrees = 180	# W
		elif walls[1] == 0:
			rotation_degrees = 270	# S
		elif walls[2] == 0:
			rotation_degrees = 0	# E (default)
		elif walls[3] == 0:
			rotation_degrees = 90	# N

	node.rotate_y(deg_to_rad(rotation_degrees))

func _emit_player_start(posn: Vector3) -> void:
	player_start.emit(posn)

func collect_meshes(node: Node, meshes: Array):
	if node == null:
		return

	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		collect_meshes(child, meshes)

# Function to visualize the navigation mesh
func visualize_navigation_mesh(nav_region: NavigationRegion3D) -> void:
	if not nav_region:
		print("Error: NavigationRegion3D node not found!")
		return

	var nav_mesh = nav_region.navigation_mesh
	if not nav_mesh:
		print("Error: NavigationMesh not found!")
		return

	# Create a temporary visualization of the navigation mesh
	var debug_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 1, 0, 0.5)  # Semi-transparent green

	# Add a surface to the ImmediateMesh
	debug_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)

	# Add the vertices and indices from the navigation mesh
	var mesh_data_tool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(nav_mesh, 0)
	
	for i in range(mesh_data_tool.get_face_count()):
		var a = mesh_data_tool.get_face_vertex(i, 0)
		var b = mesh_data_tool.get_face_vertex(i, 1)
		var c = mesh_data_tool.get_face_vertex(i, 2)
		debug_mesh.surface_add_vertex(a)
		debug_mesh.surface_add_vertex(b)
		debug_mesh.surface_add_vertex(c)

	debug_mesh.surface_end()

	var debug_instance = MeshInstance3D.new()
	debug_instance.mesh = debug_mesh
	nav_region.add_child(debug_instance)

	print("Navigation mesh visualized.")

# Function to bake the navigation mesh
func bake_mesh(nav_region: NavigationRegion3D) -> void:
	nav_region.bake_navigation_mesh()
	if visualize:
		visualize_navigation_mesh(nav_region)
	print("Navigation mesh baked.")

# Function to bake the navigation mesh from dynamically instantiated objects
func bake_navigation_mesh(nav_region_path: NodePath) -> void:
	var nav_region = get_node(nav_region_path) as NavigationRegion3D
	if nav_region == null:
		print("Error: NavigationRegion3D node not found!")
		return

	var nav_mesh = NavigationMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	var meshes = []
	collect_meshes(nav_region, meshes)

	for mesh_instance in meshes:
		var mesh = mesh_instance.mesh
		if mesh:
			for surface in range(mesh.get_surface_count()):
				var array = mesh.surface_get_arrays(surface)
				surface_tool.append_from(mesh, surface, Transform3D())

	var combined_mesh = surface_tool.commit()

	# Create the navigation mesh from the combined mesh
	nav_mesh.create_from_mesh(combined_mesh)

	# Set the NavigationMesh to the NavigationRegion3D and bake it
	nav_region.navigation_mesh = nav_mesh
	call_deferred("bake_mesh", nav_region)


func _instantiate_test_rooms():
	var room_scene: Array = [room2_adj_scene, room2_adj_scene]
	for i in range(len(room_scene)):
		var room_instance = room_scene[i].instantiate()                
		if room_instance:
			room_instance.transform.origin = Vector3(i * room_size.x, 0, i * room_size.z)
			if i == 1:
				room_instance.rotate_y(deg_to_rad(180))
	
		add_child(room_instance)
		
func _instantiate_empty_rooms():
	for x in range(grid_side):
		for y in range(grid_side):
			var room_instance = room0_scene.instantiate()
			if room_instance is Node3D:
				room_instance.transform.origin = Vector3(x * room_size.x, 15, y * room_size.z)
			add_child(room_instance)
	

func _spawn_enemies():
	for j in [turret, destroyer]:
		for i in range(number_of_enemies):
			var x: int = 0
			var y: int = 0
			while x == 0 and y == 0:
				x = rng.randi_range(0, grid_side - 1)
				y = rng.randi_range(0, grid_side - 1)
			var enemy = j.instantiate()
			add_child(enemy)
			enemy.global_transform.origin = Vector3(x * room_size.x + rng.randi_range(0, 7), 0, y * room_size.z + rng.randi_range(0, 7))
			if j==destroyer:
				enemy.set_scale(Vector3(0.3,0.3,0.3))
			
			
func _place_portals():
	
	for i in range((number_of_portal_pairs - 1)):  # one pair will be on the ideal path
		var x: int = 0
		var y: int = 0
		var a: int = 0
		var b: int = 0
		
		while x == 0 and y == 0:
			x = rng.randi_range(0, grid_side - 1)
			y = rng.randi_range(0, grid_side - 1)
		
		while (a == 0 and b == 0) or (a == x and b == y):
			a = rng.randi_range(0, grid_side - 1)
			b = rng.randi_range(0, grid_side - 1)
		
		var instance = portal_pair.instantiate()
		add_child(instance)
		#var instance1 = instance.Portal1
		#var instance2 = instance.Portal2
		
		instance.get_node("Portal1").current = true
		
		instance.get_node("Portal1").global_transform.origin = Vector3(x * room_size.x + rng.randi_range(0, 5), 3.286, y * room_size.z + rng.randi_range(0, 5))
		instance.get_node("Portal2").global_transform.origin = Vector3(a * room_size.x + rng.randi_range(0, 5), 3.286, b * room_size.z + rng.randi_range(0, 5))
		
		print("Placed portal pair at", instance.get_node("Portal1").global_transform.origin, "and", instance.get_node("Portal2").global_transform.origin)

		
