extends Control

onready var highlight = get_node("Background/Highlight")

export(String) var destination = 'none'
export(String) var button_text = 'none'
export(bool) var disabled = false
export(bool) var is_toggle = false

var toggled:bool = false
var hover:bool = false

signal on_pressed()

func _ready():
	$Background/Text.text = button_text

func set_text(text_in):
	button_text = text_in
	$Background/Text.text = button_text

func mouse_over(over:bool) -> void:
	hover = over	
	if !toggled:
		highlight_button(hover)


func toggle_button(on:bool) -> void:
	toggled = on
	highlight_button(toggled)


func highlight_button(is_highlight:bool) -> void:
	if is_highlight:
		$Tween.interpolate_property(highlight, 'rect_size', Vector2(0,0), Vector2(rect_size.x, 0), 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	else:
		$Tween.interpolate_property(highlight, 'rect_size', highlight.rect_scale, Vector2(0, 0), 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()


func gui_input(event) -> void:
	if event.is_action_pressed("click") and !disabled:
		emit_signal("on_pressed")
		if is_toggle:
			toggled = !toggled
