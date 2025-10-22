extends ColorRect

# show anim shader overlay
func show_overlay():
	var mat = self.material
	if mat == null:
		print("No ShaderMaterial assigned to this ColorRect!")
		return
		
	# shader params
	mat.set_shader_parameter("in_out", 0.0)
	
	# anim
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/in_out", 1.0, 1.0)
	
	# set colors
	mat.set_shader_parameter("in_color", Color.html("#eebf83")) # peach
	mat.set_shader_parameter("out_color", Color(0, 0, 0, 1)) # black

func _ready():
	show_overlay()
