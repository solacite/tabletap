extends Node3D  # Or whatever your main scene's root is

var OverlayUI = preload("res://scenes/overlay_ui.tscn")

func _ready():
	show_overlay()
	
func show_overlay():
	var overlay_instance = OverlayUI.instantiate()
	add_child(overlay_instance)
	# No need for set_as_top_level!
