extends Node2D

var level_grid

#signal bulb_on
#signal bulb_explode

export (int) var grid_length = 9
export (int) var grid_height = 5
export (int) var x_start = 90
export (int) var y_start = 90
export (int) var x_off = 154
export (int) var y_off = 154

var tiles = define_tiles()
var dirs = [Vector2(1,0), Vector2(0,-1), Vector2(-1,0), Vector2(0,1)]

func _ready():
	level_grid = gen_empty_grid()

# Check for input every frame
func select_level1():
	level_grid = gen_level1(gen_empty_grid())
	calculate_price()
	
func select_level2():
	level_grid = gen_level2(gen_empty_grid())
	calculate_price()
	
func solve_level1():
	level_grid = level1_solution(gen_level1(gen_empty_grid()))
	calculate_price()
	
func solve_level2():
	level_grid = level2_solution(gen_level2(gen_empty_grid()))
	calculate_price()

func _process(delta):
	draw_level()
	

# Convert grid coordinates to pixel values
func grid_to_pixel(x, y):
	return Vector2(x * x_off + x_start, y * y_off + y_start)
	

# Convert pixel values to grid coordinates
func pixel_to_grid(x, y):
	return Vector2(round((x - x_start) / x_off), round((y - y_start) / y_off))

# for each index, it gets what tile type is there, instances a tile icon of that kind, places it at the correct location and rotation
func draw_level():
	for i in range(grid_length):
		for j in range(grid_height): 
			var vars = level_grid[i][j]
			var tile = tiles[vars.type].scene.instance()
			add_child(tile)
			var pos = grid_to_pixel(i, j)
			tile.position = Vector2(pos[0], pos[1])
			tile.rotation = -vars.dir*PI/2
			

# generates a tile 'object' with all the required information about it
func gen_tile(type, dir, movable):
	var vars = tiles[type]
	return {
			"type": type, 
			"valid": vars.valid, 
			"dir": dir, 
			"movable": movable, 
			"resistance": vars.resistance, 
			"price": vars.price
		}

# iterates through each tile and sums each price. updates the label.
func calculate_price():
	var price = 0
	for i in range(grid_height):
		for j in range(grid_height):
			if level_grid[i][j].movable:
				price += level_grid[i][j].price
	print("price: $", price)
	$HUD/Cost.text = "Cost: $" + str(price)
	return price

# iterates through each tile. for each, it checks all 4 directions to make sure only valid connections were made.
# skips empty or filled blocks, those will be handled by the tiles they touch
# for all tiles except bulbs, it validates that each edge's validity matches the adjacent tile's corresponding edge in that direction. 
# using xor, if either tile's edge validity doesnt match, a flag is set.
# bulbs are uniquely handled. they can be connected to from all 4 sides, but only two valid connections are allowed. valid connections are counted, any number other than 2 is invalid.
func validate_circuit():
	var flag = true
	for j in range(grid_length):
		for i in range(grid_height):
			var tile_flag = true
			var tile = level_grid[i][j]
			
			if tile.type in ["empty", "filled"]:
				pass
			elif tile.type == "bulb":
				var connections = 0
				for d in range(4):
					var direction = dirs[d];
					var x = i + direction.x
					var y = j + direction.y
										
					if tile.valid[(4 + d - tile.dir)%4] and get_valid(x, y, d, tile):
						connections+=1
				if connections != 2:
					tile_flag = false
					flag = false
			else:
				for d in range(4):
					var direction = dirs[d];
					var x = i + direction.x
					var y = j + direction.y
					if xor(tile.valid[(4 + d - tile.dir)%4], get_valid(x, y, d, tile)):
						tile_flag = false
						flag = false
			if not tile_flag:
				print("tile at ", i, ",", j, " has an invalid connection")
	return flag

# shortcut for taking the xor of two booleans
func xor(a, b):
	return ((not a) and b) or (a and (not b))
	
# checks the tile at the coordinate passed in, adjacent in direction d to the tile that is passed in.
# immediately returns if the coordinates are out of bounds
# flips direction around to check the corresponding edge in the adjacent tile, returns compatibility depending on the tile type
# if the adjacent tile is a bulb, any direction is valid so it just returns the original tile's validity in that direction
# otherwise, if the tile is invalid in that direction it returns false.
# the final case to check for is that no aluminum wire pieces connect to a copper piece. 
# if none of those cases are triggered, the connection is considered valid.
func get_valid(x, y, d, tile1):
	if (not x in range(grid_length)) or (not y in range(grid_height)):
		return false
	var dprev = d
	d = (d+2)%4
	var type1 = tile1.type
	var tile2 = level_grid[x][y]
	var type2 = tile2.type
	if type2 == "bulb":
		return tile1.valid[(4 + dprev - tile1.dir)%4]
	if not tile2.valid[(4 + d - tile2.dir)%4]:
		return false
	if ((type1 in ["ac", "as", "a3"]) and (type2 in ["cc", "cs", "c3"])) or ((type2 in ["ac", "as", "a3"]) and (type1 in ["cc", "cs", "c3"])):
		return false;
	return true

# iterates through the board to find the battery, returns the index
func find_battery():
	for i in range(grid_length):
		for j in range(grid_height):
			if level_grid[i][j].type == "battery":
				return Vector2(i, j)

# TODO
# checks validity of the circuit before analyzing
# traverses the circuit to other terminal of the battery, reducing the resistance of all branches (series or parallel) to get current through the circuit.
# upon getting current, traverses through the circuit again, getting the current through each branch to measure success of powering bulbs.
func analyze_circuit(): 
	if not validate_circuit():
		print("circuit is not valid")
		return
	
	print("circuit is valid")
	var start = find_battery()
	var d = (level_grid[start.x][start.y].dir + 2)%4 # facing out of the negative terminal to follow current flow
	

func _on_HUD_analyze():
	analyze_circuit()

func gen_inventory(grid):
	grid[6][2] = gen_tile("ac", 2, true)
	grid[7][2] = gen_tile("as", 0, true)
	grid[8][2] = gen_tile("a3", 0, true)
	grid[6][3] = gen_tile("cc", 0, true)
	grid[7][3] = gen_tile("c3", 1, true)
	grid[8][3] = gen_tile("cs", 0, true)
	grid[6][4] = gen_tile("splice", 0, true)
	grid[7][4] = gen_tile("res_small", 0, true)
	grid[8][4] = gen_tile("res_large", 0, true)
	
func gen_empty_grid():
	var grid = []
	
	for i in range(grid_length):
		grid.append([])
		for _j in range(grid_height):
			grid[i].append(gen_tile("empty", 0, true))
	return grid

func gen_level1(grid):
	grid[0][0] = gen_tile("cc", 0, false)
	grid[0][1] = gen_tile("battery", 3, false)
	grid[0][2] = gen_tile("a3", 1, false)
	grid[0][3] = gen_tile("bulb", 0, false)
	grid[2][1] = gen_tile("filled", 0, false)
	gen_inventory(grid)
	#grid[3][3] = gen_tile("ac", 0, true) #for testing, remove later
	return grid
	
func level1_solution(grid):
	grid[1][0] = gen_tile("splice", 0, true)
	grid[1][2] = gen_tile("res_small", 0, true)
	grid[1][3] = gen_tile("as", 0, true)
	grid[2][0] = gen_tile("as", 0, true)
	grid[2][2] = gen_tile("a3", 0, true)
	grid[2][3] = gen_tile("ac", 2, true)
	grid[3][0] = gen_tile("ac", 3, true)
	grid[3][1] = gen_tile("as", 1, true)
	grid[3][2] = gen_tile("ac", 2, true)
	return grid

func gen_level2(grid):
	grid[0][3] = gen_tile("bulb", 0, false)
	grid[1][3] = gen_tile("a3", 2, false)
	grid[2][0] = gen_tile("battery", 0, false)
	grid[2][2] = gen_tile("bulb", 0, false)
	gen_inventory(grid)
	return grid

func level2_solution(grid):
	grid[0][0] = gen_tile("ac", 0, true)
	grid[0][1] = gen_tile("as", 1, true)
	grid[0][2] = gen_tile("as", 1, true)
	grid[1][0] = gen_tile("as", 0, true)
	grid[1][2] = gen_tile("ac", 0, true)
	grid[2][3] = gen_tile("res_small", 0, true)
	grid[3][0] = gen_tile("ac", 3, true)
	grid[3][1] = gen_tile("as", 1, true)
	grid[3][2] = gen_tile("a3", 3, false)
	grid[3][3] = gen_tile("ac", 2, true)
	return grid

func define_tiles():
	return {
		"empty":
			{"scene":preload("res://Scenes/Empty.tscn"), 
			"price":0,
			"resistance":0,
			"valid":[false, false, false, false]}, # no sides
		"battery":
			{"scene":preload("res://Scenes/Battery.tscn"), 
			"price":0,
			"resistance":0,
			"valid":[true, false, true, false]}, # right and left
		"ac":
			{"scene":preload("res://Scenes/AluminumCorner.tscn"), 
			"price":5,
			"resistance":0.2,
			"valid":[true, false, false, true]}, # right and bottom
		"as":
			{"scene":preload("res://Scenes/AluminumStraight.tscn"), 
			"price":5,
			"resistance":0.2,
			"valid":[true, false, true, false]}, # right and left
		"a3":
			{"scene":preload("res://Scenes/AluminumThreeway.tscn"), 
			"price":7.5,
			"resistance":0.3,
			"valid":[true, false, true, true]}, # left, right, and bottom
		"cc":
			{"scene":preload("res://Scenes/CopperCorner.tscn"), 
			"price":10,
			"resistance":0.1,
			"valid":[true, false, false, true]}, # right and bottom
		"cs":
			{"scene":preload("res://Scenes/CopperStraight.tscn"), 
			"price":10,
			"resistance":0.1,
			"valid":[true, false, true, false]}, # right and left
		"c3":
			{"scene":preload("res://Scenes/CopperThreeway.tscn"), 
			"price":15,
			"resistance":0.15,
			"valid":[true, false, true, true]}, # left, right, and bottom
		"filled":
			{"scene":preload("res://Scenes/Filled.tscn"), 
			"price":0,
			"resistance":0,
			"valid":[false, false, false, false]}, # none
		"res_large":
			{"scene":preload("res://Scenes/ResistorLarge.tscn"), 
			"price":15,
			"resistance":2,
			"valid":[true, false, true, false]}, # right and left
		"res_small":
			{"scene":preload("res://Scenes/ResistorSmall.tscn"), 
			"price":10,
			"resistance":1,
			"valid":[true, false, true, false]}, # right and left
		"bulb":
			{"scene":preload("res://Scenes/Bulb.tscn"), 
			"price":0,
			"resistance":1,
			"valid":[true, true, true, true]}, # all, processed later so only any two edges can be connected
		"ExplodingBulb":
			{"scene":preload("res://Scenes/ExplodingLightbulb.tscn"), 
			"price":0,
			"resistance":1,
			"valid":[true, true, true, true]}, # all, processed later so only any two edges can be connected
		"splice":
			{"scene":preload("res://Scenes/SpliceConnector.tscn"), 
			"price":10,
			"resistance":0.2,
			"valid":[true, false, true, false]}, # right and left
	}
	
	#if(level_grid == gen_level1(gen_empty_grid())):
	#	grid[0][3] = gen_tile("ExplodingBulb", 0, false)
	#else:
	#	grid[0][3] = gen_tile("ExplodingBulb", 0, false)
	#	grid[2][2] = gen_tile("ExplodingBulb", 0, false)


func _on_Tile_dropped() -> void:
	
