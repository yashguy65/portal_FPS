extends Node

# Foundation for DFS Maze Gen, in case MapMazeGen is messed up use as reference

var grid: Array = []
var unvisited: Array = []
var cell
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
			
		
func checkNeighboursWithWallsIntact(coords: Vector2) -> Array:
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
			
			# MAKE MAZE IMPOSSIBLE TO TRAVERSE WITHOUT PORTAL
			# By blocking the "right path" to (grid_side-1, grid_side-1) and having portals 
			# on either side and all of this info abstracted from the player, plus some 
			# rand int to introduce unpredictability
			
			if current_cell == Vector2(grid_side-1, grid_side-1):
				var left: Vector2 = backtrack[int(backtrack.size()/2)-1] # Middle left element of array backtrack
				var right: Vector2 = backtrack[int(backtrack.size()/2)] # Middle right element of array
				# Make wall between them like above but reversed
				if right.x == left.x:
					if right.y == left.y + 1: # 0,0 to 0,1 
						grid[left.x][left.y][13] = 1 # SOUTH WALL LEFT
						grid[right.x][right.y][15] = 1 # NORTH WALL RIGHT
					elif right.y == left.y - 1: #0,1 to 0,0
						grid[left.x][left.y][15] = 1 # NORTH WALL LEFT
						grid[right.x][right.y][13] = 1 # SOUTH WALL RIGHT
				elif right.y == left.y:
					if right.x == left.x + 1: #0,0 to 1,0
						grid[left.x][left.y][14] = 1 #EAST WALL LEFT
						grid[right.x][right.y][12] = 1 #WEST WALL RIGHT
					elif right.x == left.x - 1: #1,0 to 0,0
						grid[left.x][left.y][12] = 1 # WEST WALL LEFT
						grid[right.x][right.y][14] = 1 #EAST WALL RIGHT					
			current_cell = next_cell            
			visited_cells += 1
			unvisited.erase(next_cell)
		else:
			if backtrack.size() > 0:
				current_cell = backtrack.pop_back()
			else:
				break
	print("GRID:\n\n")
	printGrid(grid)
			
	
			
			
			
		
		
	
	
	
	
	
	
	
	
	
			
		
	
	

	
		
		
		
		
		
