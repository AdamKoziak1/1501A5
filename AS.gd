extends Node2D

var selected = false
var rest_point
var spawn_point
var rest_nodes = []

func _ready():
	rest_nodes = get_tree().get_nodes_in_group("zone")
	spawn_point = get_tree().get_nodes_in_group("SpawnAC")
	rest_point = spawn_point[0].global_position
	#spawn_point[0].select()
	rotation = 0

func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true
		
func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(),25*delta)
		var smallest_rotation = PI/2
		if Input.is_action_just_pressed("rotateLeft"):
			rotation = rotation - smallest_rotation
		if Input.is_action_just_pressed("rotateRight"):
			rotation = rotation + smallest_rotation
	else:
		global_position = lerp(global_position,rest_point,10*delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			selected = false
			var shortest_dist = 75
			for child in rest_nodes:
				var distance = global_position.distance_to(child.global_position)
				if distance < shortest_dist:
					child.select()
					rest_point = child.global_position
					shortest_dist = distance
