extends Node

var LoadingScreen = preload("res://scenes/ui/loading_screen.tscn")
var loading_screen_instance = null

func show_loading_screen():
	if loading_screen_instance == null:
		loading_screen_instance = LoadingScreen.instantiate()
		get_tree().current_scene.add_child(loading_screen_instance)

func hide_loading_screen():
	if loading_screen_instance:
		loading_screen_instance.queue_free()
		loading_screen_instance = null
