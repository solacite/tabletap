extends Node2D

var LoadingScreen = preload("res://scenes/ui/loading_screen.tscn")

func transition_to_scene(target_scene_path: String):
	var loading_screen = show_loading_screen()
	ResourceLoader.load_threaded_request(target_scene_path)
	while ResourceLoader.load_threaded_get_status(target_scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	if ResourceLoader.load_threaded_get_status(target_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		var next_scene = ResourceLoader.load_threaded_get(target_scene_path)
		get_tree().change_scene_to_packed(next_scene)
	elif ResourceLoader.load_threaded_get_status(target_scene_path) == ResourceLoader.THREAD_LOAD_FAILED:
		print("Failed to load scene: %s" % target_scene_path)

func show_loading_screen():
	var loading_screen = LoadingScreen.instantiate()
	get_tree().current_scene.add_child(loading_screen)
	return loading_screen

# start btn
func _on_start_pressed() -> void:
	transition_to_scene("res://scenes/map/main.tscn")

# settings btn
func _on_settings_pressed() -> void:
	transition_to_scene("res://scenes/menu/settings.tscn")
	
# help btn
func _on_help_pressed() -> void:
	transition_to_scene("res://scenes/menu/help.tscn")

# credits btn
func _on_credits_pressed() -> void:
	transition_to_scene("res://scenes/menu/credits.tscn")
