extends CanvasLayer

signal start_level1
signal start_level2
signal solve_level1
signal solve_level2
signal analyze

func MessageText(text):
	$Name.text = text
	$Name.show()

var level = 0

func _on_Level1_pressed() -> void:
	level_mode()
	level = 1
	emit_signal("start_level1")

func _on_Level2_pressed() -> void:
	level_mode()
	level = 2
	emit_signal("start_level2")

func _on_Run_pressed() -> void:
	print("Test")
	emit_signal("analyze")

func level_mode():
	$solve.show()
	$exit.show()
	$Level1.hide()
	$Name.hide()
	$ColorRect.hide()
	$ColorRect2.hide()
	$Level2.hide()
	$Run.show()
	$Cost.show()

func menu_mode():
	level = 0
	$solve.hide()
	$exit.hide()
	$Level1.show()
	$Name.show()
	$ColorRect.show()
	$ColorRect2.show()
	$Level2.show()
	$Run.hide()
	$Cost.hide()

func solve_pressed():
	if level == 1:
		emit_signal("solve_level1")
	if level == 2:
		emit_signal("solve_level2")
		

