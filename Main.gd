extends Node2D

func _on_SpawnAC_deselected():
	var AC = load("res://AC.tscn")
	var newAC = AC.instance()
	add_child(newAC)
	


func _on_SpawnAC_selected():
	#remove AC tile on the spawn_point
	pass
