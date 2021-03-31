extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	SteamLobby.connect("chat_message_received", self, "_chat_in")

func _chat_in(sender_steam_id, profile_name, message):
	$log.add_text(profile_name + ": " + message)
	$log.newline()
	if $log.get_line_count() > 24:
		$log.remove_line(0)

func _on_LineEdit_text_entered(new_text):
	$LineEdit.text = ""
	SteamLobby.send_chat_message(new_text)
