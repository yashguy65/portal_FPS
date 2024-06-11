extends Node

var grid: Array = []
var unvisited: Array = []
var cell
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

func printGrid(arr: Array):
	for row in arr:
		print(row)
			
		
func checkNeighboursWithWallsIntact(grid: Array, coords: Vector2) -> Array:
	var possible: Array = [Vector2(0,1), Vector2(1,0), Vector2(0,-1), Vector2(-1,0)]
	var list: Array = []
	for i in possible:
		var neighbour_coords = coords + i
		if unvisited.has(neighbour_coords) and \
		   grid[neighbour_coords.x][neighbour_coords.y][12] and \
		   grid[neighbour_coords.x][neighbour_coords.y][13] and \
		   grid[neighbour_coords.x][neighbour_coords.y][14] and \
		   grid[neighbour_coords.x][neighbour_coords.y][15]:
			list.append(neighbour_coords)
	return list 
		
func _ready():
	for i in grid_side:
		grid.append(Array()) # NOW A 2D ARRAY LIKE [ [], [], [] ]
		for j in grid_side:
			grid[i].append([0,0,0,0,  0,0,0,0,  0,0,0,0,  1,1,1,1]) 
			unvisited.append(Vector2(i,j))
	#START COORDINATES	
	var x : int = rng.randi_range(0,grid_side-1)
	var y :int = rng.randi_range(0, grid_side-1)
	var current_cell := Vector2(x,y)
	visited_cells = 1
	var backtrack: Array = []
	while visited_cells < (grid_side*grid_side):
		var neighbours: Array = checkNeighboursWithWallsIntact(grid, current_cell)
		print("neighbours", neighbours, "\n")
		if neighbours.size()>0:
			var z: int = rng.randf_range(0,neighbours.size()-1)
			var next_cell = Vector2(neighbours[z].x, neighbours[z].y)
			#check which walls the neighbour is connected by
			if next_cell.x == current_cell.x:
				if (next_cell.y - current_cell.y == 1):
					grid[current_cell.x][current_cell.y][14] = 0
				elif (next_cell.y - current_cell.y == -1):
					grid[current_cell.x][current_cell.y][12] = 0
				else:
					print("line 55")
			elif (next_cell.y == current_cell.y):
				if (next_cell.x - current_cell.x == 1):
					grid[current_cell.x][current_cell.y][13] = 0
				elif (next_cell.x - current_cell.x == -1):
					grid[current_cell.x][current_cell.y][15] = 0
				else:
					print("line62")
			else:
				print("neighbour equal to current cell")
			backtrack.append(current_cell)
			current_cell = next_cell			
			visited_cells+=1
		else:
			var z = backtrack.pop_back()
			if z:
				current_cell = z
			else:
				break
	print("GRID:\n\n")
	printGrid(grid)
			
	
			
			
			
		
		
	
	
	
	
	
	
	
	
	
			
		
	
	

	
		
		
		
		
		
