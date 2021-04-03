extends Viewport

func _ready():
	size = OS.window_size
	
func update_dim(dim):
	size = dim
