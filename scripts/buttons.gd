extends TextureButton

var original_position : Vector2

func _ready():
	original_position = position

func _on_mouse_entered():
	var tween := create_tween()
	tween.tween_property(self, "position", original_position + Vector2(20, 0), 0.15)

func _on_mouse_exited():
	var tween := create_tween()
	tween.tween_property(self, "position", original_position, 0.15)
