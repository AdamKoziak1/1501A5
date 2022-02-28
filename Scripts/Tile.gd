extends Node2D

signal dropped
signal selected
signal rotated
var selected = false
var grid_x
var grid_y

func _ready():
	#rest_nodes = get_tree().get_nodes_in_group("zone")
	#spawn_point = get_tree().get_nodes_in_group("SpawnAC")
	#rest_point = spawn_point[0].global_position
	#spawn_point[0].select()
	rotation = 0


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true
		
func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
		var smallest_rotation = PI/2
		if Input.is_action_just_pressed("rotateLeft"):
			rotation = rotation - smallest_rotation
			#print("rotated left")
			#emit_signal("rotated", 1)
		if Input.is_action_just_pressed("rotateRight"):
			rotation = rotation + smallest_rotation
			#emit_signal("rotated", -1)
		z_index = 999
	#else:
		#global_position = lerp(global_position, rest_point, 10 * delta)

func _input(event) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_A and event.pressed:
			pass
			emit_signal("rotated", 1)
		if event.scancode == KEY_D and event.pressed:
			pass
			emit_signal("rotated", -1)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("selected", get_global_mouse_position())
		if event.button_index == BUTTON_LEFT and not event.pressed:
			selected = false
			emit_signal("dropped", get_global_mouse_position())
			hide()
			
			#var shortest_dist = 75
			#for child in spawn_point:
			#	var distance = global_position.distance_to(child.global_position)
			#	if distance < shortest_dist:
			#		child.select()
			#		rest_point = child.global_position
			#		shortest_dist = distance
			#for child in rest_nodes:
			#	var distance = global_position.distance_to(child.global_position)
			#	if distance < shortest_dist:
			#		if moved == false:
			#			child.outOfInventorySelect()
			#			moved = true
			#		else:
			#			child.select()
			#		rest_point = child.global_position
			#		shortest_dist = distance

#func rest_points:

