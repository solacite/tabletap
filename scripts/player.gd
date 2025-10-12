extends CharacterBody3D

@export var speed := 8.0
@export var jump_velocity := 9.0
@export var mouse_sens := 0.002
var pitch := 0.0
var tgt_pitch := 0.0
const PITCH_UP := deg_to_rad(80)
const PITCH_DN := deg_to_rad(-30)

var pivot

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pivot = $Pivot

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sens)
		tgt_pitch = clamp(tgt_pitch - event.relative.y * mouse_sens, PITCH_DN, PITCH_UP)

func _process(delta):
	pitch = lerp(pitch, tgt_pitch, 8.0 * delta)
	pivot.rotation.x = pitch

func _physics_process(delta):
	var inp_dir = Input.get_vector("move_left", "move_right", "move_fwd", "move_bkwd")
	var direction = Vector3.ZERO
	# In Godot, forward/backward is Z, left/right is X
	direction.x = inp_dir.x
	direction.z = inp_dir.y
	direction = (transform.basis * direction).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Gravity & Jump
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity

	move_and_slide()
