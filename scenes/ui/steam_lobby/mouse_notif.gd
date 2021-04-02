extends Control
var hover = false
signal entered()
signal exited()

func _process(delta):
	var res = get_global_mouse_position().x >= get_global_rect().position.x
	if res != hover:
		emit_signal("entered") if res else emit_signal("exited")
		hover = res
