extends Panel

signal attempting_to_connect()

onready var ip_input:TextEdit = $Container/IP/TextEdit
onready var port_input:TextEdit = $Container/Port/TextEdit
onready var warning_label:Label = $Container/Warning


func _ready() -> void:
	hide()


func show() -> void:
	_reset_dialog()
	.show()


func _reset_dialog() -> void:
	warning_label.text = ""
	ip_input.text = ""
	port_input.text = String(NetworkHelper.DEFAULT_PORT)


func _on_Cancel_pressed() -> void:
	_reset_dialog()
	hide()


func _on_Join_pressed() -> void:
	if _verify_ip() and _verify_port():
		NetworkHelper.join_server(ip_input.text, int(port_input.text))
		warning_label.text = 'Connecting'


func _verify_ip() -> bool:
	if not ip_input.text.is_valid_ip_address():
		warning_label.text = "Invalid IP Address"
		return false
	return true


func _verify_port() -> bool:
	var port:int = int(port_input.text)
	if port <= 1023 or port > 25565:
		warning_label.text = "Invalid Port"
		return false
	return true
