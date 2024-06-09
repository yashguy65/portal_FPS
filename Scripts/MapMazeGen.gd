extends Node3D

@export var testing : bool = false

var room1_scene = preload("res://Scenes/room_1_side.tscn")
var room2_adj_scene = preload("res://Scenes/room_2_sides_adjacent.tscn")
var room2_opp_scene = preload("res://Scenes/room_2_sides_opposite.tscn")
var room3_scene = preload("res://Scenes/room_3_sides.tscn")
var room4_scene = preload("res://Scenes/room_4_sides.tscn")

var initial := Vector3(0,0,0)
var maze_size := Vector2(20,20)
var room_size := Vector3(30,30,30)

signal player_start

var grid: Array = []
var unvisited: Array = []
var hard: bool # for when easy and hard mode are added
const grid_side := 20
var rng = RandomNumberGenerator.new()
var visited_cells : int 
@export var number_of_portal_pairs : int = 4

#----------------------------------------KEY------------------------------------------------
#BACKTRACK SOLUTION BORDER      WALLS
# 0123		4567	8/9/10/11	12/13/14/15
# 0000		0000	0000		0000
# WSEN		WSEN	WSEN		WSEN

#NOW ONLY WALLS
#-------------------------------------------------------------------------------------------

func printGrid(arr: Array) -> void:
	for row in arr:
		for ele in row:
			var lol = ele.slice(12,16)
			print(lol)
			
		
func checkNeighboursWithWallsIntact(coords: Vector2) -> Array:
	var possible: Array = [Vector2(0,1), Vector2(1,0), Vector2(0,-1), Vector2(-1,0)]
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

func _ready():
	grid.resize(grid_side)
	for i in range(grid_side):
		grid[i] = []
		for j in range(grid_side):
			grid[i].append([0,0,0,0,  0,0,0,0,  0,0,0,0,  1,1,1,1]) 
			unvisited.append(Vector2(i,j))
	#START COORDINATES    
	var x : int = rng.randi_range(0,grid_side-1)
	var y : int = rng.randi_range(0, grid_side-1)
	var current_cell := Vector2(x,y)
	initial = Vector3(x * room_size.x, 15, y * room_size.z)
	player_start.emit(initial)
	visited_cells = 1
	var backtrack: Array = []
	unvisited.erase(current_cell)  # Mark starting cell as visited
	while visited_cells < (grid_side * grid_side):
		var neighbours: Array = checkNeighboursWithWallsIntact(current_cell)
		if neighbours.size() > 0:
			var z: int = rng.randi_range(0,neighbours.size()-1)            
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
	if testing:
		_instantiate_test_rooms()
	else:
		_instantiate_rooms()
	printGrid(grid)

func get_room_type(cell: Array) ->  PackedScene:
	var walls = cell.slice(12, 16)
	var wall_count = walls.count(1)
	
	if wall_count == 4:
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
		print("count0: No walls")
		return room4_scene

func _instantiate_rooms() -> void:
	for x in range(grid_side):
		for y in range(grid_side):
			var room_scene = get_room_type(grid[x][y])
			print(room_scene.resource_name)
			var room_instance = room_scene.instantiate()
			if room_instance is Node3D:
				room_instance.transform.origin = Vector3(x * room_size.x, 15, y * room_size.z)
				_apply_rotation(room_instance, grid[x][y])    
			add_child(room_instance)
			
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
	
func _instantiate_test_rooms():
	var room_scene: Array = [room2_adj_scene, room2_adj_scene]
	for i in range(len(room_scene)):
		var room_instance = room_scene[i].instantiate()                
		if room_instance:
			room_instance.transform.origin = Vector3(i * room_size.x, 0, 0*i * room_size.z)
			if i==1:
				room_instance.rotate_y(deg_to_rad(180))
	
		add_child(room_instance)
