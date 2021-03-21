extends Node

onready var player_file = File.new()
var player_data_path:String = ProjectSettings.globalize_path("user://") + "player_data.cfg"
var player_data_default:Dictionary = {
	"audio": {
		"master_volume": 1,
		"master_volume_on": true,
		"background_volume": 1,
		"background_volume_on": true,
		"sfx_volume": 1,
		"sfx_volume_on": true,
	},
	"video": {
		"field_of_view": 70,
		"full_screen": false,
	}
}
onready var player_data:Dictionary = player_data_default.duplicate(true)
	
var readThread:Thread
var writeThread:Thread
var write:bool = false 
var writeMutex:Mutex

func _ready():
	readThread = ThreadUtils.start(self, "_load_game")

func _load_game(_args):
	player_data = _load_dictionary(player_file, player_data_path, player_data)
	if not player_data.has("video"):
		player_data.video = player_data_default.video.duplicate(true)
	if not player_data.has("audio"):
		player_data.audio = player_data_default.audio.duplicate(true)
	writeMutex = Mutex.new()
	writeThread = ThreadUtils.start(self, "_write_player_data")
	Event.emit_signal(Event.GAME_LOADED, player_data)

func _load_dictionary(file:File, path:String, dict:Dictionary) -> Dictionary:
	if file.file_exists(path): 
		if file.open(path, file.READ):
			print("Failed to read file " + path)
		else:
			dict = parse_json(file.get_as_text())
			file.close()	
	else:
		if file.open(path, file.WRITE):
			print("Failed to open file " + path)
		else:
			file.store_line(to_json(dict))
			file.close()
	return dict.duplicate()
	

func _write_player_data(_args):
	while true:
		if write:
			player_file.open(player_data_path, player_file.WRITE)
			player_file.store_line(to_json(player_data))
			player_file.close()
			write = false

func _exit_tree():
	readThread.wait_to_finish()
	writeThread.wait_to_finish()

func update_player_data(data):
	writeMutex.lock()
	self.player_data = data
	write = true
	writeMutex.unlock()
