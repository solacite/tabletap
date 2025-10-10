@tool
extends EditorScript

func _run():
	var toon_mat = preload("res://materials/toon_shader_material.tres")
	var root = get_editor_interface().get_edit_scene_root()
	if root:
		_apply_toon_material_recursive(root, toon_mat)

func _apply_toon_material_recursive(node, toon_mat):
	if node is MeshInstance3D:
		node.material_override = toon_mat
	for child in node.get_children():
		_apply_toon_material_recursive(child, toon_mat)
