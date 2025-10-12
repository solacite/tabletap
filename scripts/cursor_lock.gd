extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
