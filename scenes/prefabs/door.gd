extends Spatial

var open:bool = false
func _ready():
	Event.connect_signal(Event.OPEN_DOORS, self, "_on_open")
	Event.connect_signal(Event.CLOSE_DOORS, self, "_on_close")

func _on_open():
	if not open:
		$animation_player.play("open_doors")
		open = true

func _on_close():
	if open:
		$animation_player.play("close_doors")
		open = false
