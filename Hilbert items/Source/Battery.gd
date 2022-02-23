extends Area2D

var cost = 0
var resistance = 0
var Connect = 0
var LocalWorkCount = 0
onready var Variables = get_node("/res/Global")

func _on_Battery_area_entered(area: Area2D) -> void:
	Connect += 1  
	CheckConnect(Connect)

func _on_Battery_area_exited(area: Area2D) -> void:
	Connect -= 1 
	CheckConnect(Connect)

func CheckConnect(Connect) -> void:
	if(Connect >= 3): 
		Variables.WorkCount += 1
	else:
		Variables.WorkCount -= 1
