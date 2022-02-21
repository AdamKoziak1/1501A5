extends Position2D

func _draw():
	draw_circle(Vector2.ZERO, 20, Color.blanchedalmond)
	
#for moving tiles around on the grid
func select():
	for child in get_tree().get_nodes_in_group("zone"):
		child.deselect()
	modulate = Color.webmaroon

#for moving tiles out of the inventory
func outOfInventorySelect():
	for child in get_tree().get_nodes_in_group("zone"):
		child.deselect()
	for child in get_tree().get_nodes_in_group("SpawnAC"):
		child.deselect()
	modulate = Color.webmaroon
	
func deselect():
	modulate = Color.white
	
