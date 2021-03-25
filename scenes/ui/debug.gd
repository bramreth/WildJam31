extends Control

onready var controls = get_node("CenterContainer/Panel/debug_controls")
onready var data = get_node("CenterContainer/Panel/debug_data")

func _ready():
	$CenterContainer.visible = false
	for child in $realtime.get_children():
		child.visible = false
	$realtime.visible = false
	Event.connect(Event.SETUP_DEBUG, self, "setup_debug")

func show_debug(on):
	$CenterContainer.visible = on

func setup_debug():
	Game.continuous_waves = controls.get_node("contwave").pressed

func _on_startwave_pressed():
	Event.emit_signal("start_wave")


func _on_CheckButton_toggled(button_pressed):
	Game.continuous_waves = button_pressed

func _process(delta):
	if Game.debug:
		if data.get_node("fps_view").pressed:
			$realtime/fps.text = "fps: " + str(Engine.get_frames_per_second())
		if data.get_node("ocount").pressed:
			$realtime/ocount.text = "objects: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))

func _on_show_data_toggled(button_pressed):
	$realtime.visible = button_pressed


func _on_fps_view_toggled(button_pressed):
	if button_pressed:
		data.get_node("show_data").pressed = true
	$realtime/fps.visible = button_pressed


func _on_ocount_toggled(button_pressed):
	if button_pressed:
		data.get_node("show_data").pressed = true
	$realtime/ocount.visible = button_pressed

func _on_LineEdit_text_entered(new_text):
	controls.get_node("HBoxContainer/LineEdit").text = ""
	Event.emit_signal(Event.EQUIP_AMMO, new_text)
