extends Spatial


func _ready():
	Event.connect_signal(Event.OPEN_DOORS, self, "_on_open")

func _on_open():
	$animation_player.play("open_doors")
