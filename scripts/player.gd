extends CharacterBody3D

@export var speed := 8.0
@export var jump_velocity := 9.0
@export var mouse_sens := 0.002
var pitch := 0.0
var tgt_pitch := 0.0
var yaw := 0.0
var tgt_yaw := 0.0
const PITCH_UP := deg_to_rad(10)
const PITCH_DN := deg_to_rad(-20)

const LOADING_SCREEN = preload("res://scenes/ui/loading_screen.tscn")

var respawn_point: Vector3 = Vector3(-91.69894, -31.41502, 60.24416)
var pivot

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pivot = $Pivot

func _input(event):
	if event is InputEventMouseMotion:
		tgt_yaw -= event.relative.x * mouse_sens
		tgt_pitch -= event.relative.y * mouse_sens
		tgt_pitch = clamp(tgt_pitch, PITCH_DN, PITCH_UP)

func _process(delta):
	yaw = lerp_angle(yaw, tgt_yaw, 8.0 * delta)
	pitch = lerp(pitch, tgt_pitch, 8.0 * delta)
	rotation.y = yaw
	pivot.rotation.x = pitch

func _physics_process(delta):
	var inp_dir = Input.get_vector("move_left", "move_right", "move_fwd", "move_bkwd")
	var direction = Vector3.ZERO
	direction.x = inp_dir.x
	direction.z = inp_dir.y
	direction = (transform.basis * direction).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# gravity + jump
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity

	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		show_loading_screen()
		global_position = respawn_point
		velocity = Vector3.ZERO

func show_loading_screen():
	var screen = LOADING_SCREEN.instantiate()
	get_tree().current_scene.add_child(screen)
	await get_tree().create_timer(1.0).timeout
	screen.queue_free()
