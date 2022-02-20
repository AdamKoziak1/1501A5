extends Position2D

signal deselected
var price

func _draw():
	draw_circle(Vector2.ZERO, 20, Color.blanchedalmond)
	
func select():
	for child in get_tree().get_nodes_in_group("SpawnAC"):
		child.deselect()
	modulate = Color.webmaroon
	
func deselect():
	modulate = Color.white
	#add to total cost
	#emit_signal("deselected")
