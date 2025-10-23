extends ColorRect

var tween_position: float = -0.2
var tween_in_out: float = 0.0

func _ready():
	if material != null:
		material = material.duplicate()
	material.set_shader_parameter("in_color", Color.html("#eebf83"))
	material.set_shader_parameter("out_color", Color(0, 0, 0, 1))
	material.set_shader_parameter("size", Vector2(8, 8))
	in_transition(2.0)

func _process(delta):
	material.set_shader_parameter("position", tween_position)
	material.set_shader_parameter("in_out", tween_in_out)

func in_transition(duration: float):
	tween_position = -0.2
	tween_in_out = 0.0
	var tween = create_tween()
	tween.tween_property(self, "tween_position", 1.0, duration)
	tween.tween_property(self, "tween_in_out", 1.0, duration)
