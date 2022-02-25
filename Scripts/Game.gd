extends Node2D

var level_grid

export (int) var grid_size = 5
export (int) var x_start = 90
export (int) var y_start = 90
export (int) var x_off = 150
export (int) var y_off = 150

var tiles = define_tiles()
var dirs = [Vector2(1,0), Vector2(0,-1), Vector2(-1,0), Vector2(0,1)]

func gen_empty_grid():
	var grid = []
	
	for i in range(grid_size):
		grid.append([])
		for j in range(grid_size):
			grid[i].append(gen_tile("empty", 0, true))
	return grid

func gen_level1(grid):
	grid[0][0] = gen_tile("cc", 0, false)
	grid[0][1] = gen_tile("battery", 3, false)
	grid[0][2] = gen_tile("a3", 1, false)
	grid[0][3] = gen_tile("bulb", 0, false)
	grid[2][1] = gen_tile("filled", 0, false)
	return grid

func gen_level2(grid):
	grid[2][0] = gen_tile("battery", 0, false)
	grid[0][3] = gen_tile("bulb", 0, false)
	grid[2][2] = gen_tile("bulb", 0, false)
	grid[1][3] = gen_tile("a3", 2, false)
	return grid

func _ready():
	level_grid = gen_level2(gen_empty_grid())
	
	draw_level()
	
	print(calculate_price())
	validate_circit()

# Check for input every frame
func _process(delta):
	pass
	

# Convert grid coordinates to pixel values
func grid_to_pixel(x, y):
	return Vector2(x * x_off + x_start, y * y_off + y_start)
		

# Draw each tile in the level grid
func draw_level():
	for i in range(grid_size):
		for j in range(grid_size):
			var vars = level_grid[i][j]
			var tile = tiles[vars.type].scene.instance()
			add_child(tile)
			var pos = grid_to_pixel(i, j)
			tile.position = Vector2(pos[0], pos[1])
			tile.rotation = -vars.dir*PI/2
			

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

func calculate_price():
	var price = 0
	for i in range(grid_size):
		for j in range(grid_size):
			price += level_grid[i][j].price
	return price

func validate_circit():
	var flag = true
	for j in range(grid_size):
		for i in range(grid_size):
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
					if xnor(tile.valid[(d - tile.dir)%4], get_valid(x, y, d)):
						connections+=1
				if connections != 2:
					tile_flag = false
					flag = false
					print("tile at ", i, ",", j, " has an invalid connection")
			else:
				for d in range(4):
					var direction = dirs[d];
					var x = i + direction.x
					var y = j + direction.y
					if not xnor(tile.valid[(d - tile.dir)%4], get_valid(x, y, d)):
						tile_flag = false
						flag = false
				if not tile_flag:
					print("tile at ", i, ",", j, " has an invalid connection")
	return flag

func xnor(a, b):
	return (a and b) or ((not a) and (not b))
	
func get_valid(x, y, d):
	if (not x in range(5)) or (not y in range(5)):
		return false
	d = (d-2)%4
	var tile = level_grid[x][y]
	return tile.valid[(d - tile.dir)%4]

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
		"largeres":
			{"scene":preload("res://Scenes/ResistorLarge.tscn"), 
			"price":15,
			"resistance":2,
			"valid":[true, false, true, false]}, # right and left
		"smallres":
			{"scene":preload("res://Scenes/ResistorSmall.tscn"), 
			"price":10,
			"resistance":1,
			"valid":[true, false, true, false]}, # right and left
		"bulb":
			{"scene":preload("res://Scenes/Bulb.tscn"), 
			"price":0,
			"resistance":1,
			"valid":[true, true, true, true]}, # all, processed later so only any two edges can be connected
		"splice":
			{"scene":preload("res://Scenes/SpliceConnector.tscn"), 
			"price":10,
			"resistance":0.2,
			"valid":[true, false, true, false]}, # right and left
	}
