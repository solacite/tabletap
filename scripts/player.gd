extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 9.0
var mouse_sens := 0.002
var pitch := 0.0
var tgt_pitch := 0.0
const PITCH_UP := deg_to_rad(80) # up lim
const PITCH_DN := deg_to_rad(-30) # dn lim

var pivot

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # lock mouse
	pivot = $Pivot # get pivot

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sens) # horiz rot
		tgt_pitch = clamp(tgt_pitch - event.relative.y * mouse_sens, PITCH_DN, PITCH_UP) # vert rot lim

func _process(delta):
	pitch = lerp(pitch, tgt_pitch, 8.0 * delta) # smooth pitch
	pivot.rotation.x = pitch # set pitch

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta # gravity
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY # jump
	var inp_dir = Input.get_vector("move_left", "move_right", "move_fwd", "move_bkwd") # get dir
	var dir = (transform.basis * Vector3(inp_dir.x, 0, inp_dir.y)).normalized() # local dir
	if dir != Vector3.ZERO:
		velocity.x = dir.x * SPEED # x vel
		velocity.z = dir.z * SPEED # z vel
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) # x decel
		velocity.z = move_toward(velocity.z, 0, SPEED) # z decel
	move_and_slide() # move
