extends Area2D

var cost = 0
var resistance = 0
var Connect = 0
var LocalWorkCount= 0
var LocalThreeway = 0
onready var Variables = get_node("/res/Global")

func _on_CThreeway_area_entered(area: Area2D) -> void:
	Connect += 1
	CheckConnect(Connect)
	CheckThreeway(Connect)
	
func _on_CThreeway_area_exited(area: Area2D) -> void:
	Connect -= 1
	CheckConnect(Connect)
	CheckThreeway(Connect)
	
func CheckConnect(Connect) -> void:
	if(Connect >= 4): 
		Variables.WorkCount += 1
	else:
		Variables.WorkCount -= 1

func CheckThreeway(Connect) -> void:
	if(Connect >= 3):
		Variables.Threeways += 1
	else:
		Variables.Threeways -= 1