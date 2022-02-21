extends Position2D

signal deselected
signal selected
var price = 5

func _draw():
	draw_circle(Vector2.ZERO, 20, Color.blanchedalmond)
	
func select():
	modulate = Color.webmaroon
	for child in get_tree().get_nodes_in_group("zone"):
		child.deselect()
	#subtract from total cost
	emit_signal("selected")
	
func deselect():
	modulate = Color.white
	#add to total cost
	emit_signal("deselected")
