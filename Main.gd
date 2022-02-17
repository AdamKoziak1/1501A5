extends Node2D

const AC = preload("res://AC.tscn")

func _on_SpawnAC_deselected():
	var newAC = AC.instance()
	self.add_child(newAC)
	
