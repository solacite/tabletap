extends Node3D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		get_tree().change_scene_to_file("res://scenes/menu/game_menu.tscn")
