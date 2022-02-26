extends CanvasLayer

signal start_level1
signal start_level2
signal analyze

func MessageText(text):
	$Message.text = text
	$Message.show()


func _on_Level1_pressed() -> void:
	level_mode()
	emit_signal("start_level1")

func _on_Level2_pressed() -> void:
	level_mode()
	emit_signal("start_level2")


func _on_Run_pressed() -> void:
	emit_signal("analyze")

func level_mode():
	$Level1.hide()
	$Name.hide()
	$ColorRect.hide()
	$ColorRect2.hide()
	$Level2.hide()
	$Run.show()
	$Cost.show()
