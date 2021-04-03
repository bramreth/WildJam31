extends Viewport

func _ready():
	update_from_os()
	get_tree().get_root().connect("size_changed", self, "update_from_os")
	
func update_dim(dim):
	size = dim

func update_from_os():
	size = OS.window_size
