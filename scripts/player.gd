extends CharacterBody3D

@export var speed := 8.0
@export var jump_velocity := 9.0
@export var mouse_sens := 0.002

var pitch = 0.0
var tgt_pitch = 0.0
var yaw = 0.0
var tgt_yaw = 0.0
const PITCH_UP = deg_to_rad(10)
const PITCH_DN = deg_to_rad(-20)

var respawn_point: Vector3 = Vector3(-91.69894, -31.41502, 60.24416)
var pivot

# Animation state management
var was_on_floor = true
var land_playing = false
var anim_state = ""

# Camera shake and offset
var camera_offset = Vector3(-0.132, 15.841, 27.888)
var shake_amount = 0.0
var shake_time = 0.0
var shake_duration = 0.2
var shake_strength = 0.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pivot = $Pivot
	$AnimatedSprite3D.connect("animation_finished", Callable(self, "_on_anim_finished"))
	$Pivot/Camera3D.transform.origin = camera_offset

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

	# Screen shake effect
	if shake_time > 0.0:
		shake_time -= delta
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var offset = Vector3(
			rng.randf_range(-shake_amount, shake_amount),
			rng.randf_range(-shake_amount, shake_amount),
			0
		)
		$Pivot/Camera3D.transform.origin = camera_offset + offset
	else:
		$Pivot/Camera3D.transform.origin = camera_offset

func start_screen_shake():
	shake_time = shake_duration
	shake_amount = shake_strength

func _physics_process(delta):
	# Movement input
	var inp_dir = Input.get_vector("move_left", "move_right", "move_fwd", "move_bkwd")
	print("inp_dir:", inp_dir)
	var direction = Vector3.ZERO
	direction.x = inp_dir.x
	direction.z = inp_dir.y
	if direction.length() > 0.01:
		direction = (transform.basis * direction).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	var on_floor = is_on_floor()
	var just_landed = on_floor and not was_on_floor
	var is_moving = abs(velocity.x) > 0.01 or abs(velocity.z) > 0.01
	print("velocity:", velocity, " is_moving:", is_moving, " anim_state:", anim_state)

	# Apply gravity if not on floor
	if not on_floor:
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	move_and_slide()

	# Animation state machine
	if on_floor and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity
		$AnimatedSprite3D.play("jump")
		print("Switching to: jump")
		anim_state = "jump"
		land_playing = false
	elif just_landed:
		$AnimatedSprite3D.play("land")
		print("Switching to: land")
		anim_state = "land"
		land_playing = true
		start_screen_shake()
	elif land_playing:
		pass
	elif not on_floor and anim_state != "fall" and anim_state != "jump":
		$AnimatedSprite3D.play("fall")
		print("Switching to: fall")
		anim_state = "fall"
	elif on_floor and is_moving and anim_state != "walk":
		$AnimatedSprite3D.play("walk")
		print("Switching to: walk")
		anim_state = "walk"
	elif on_floor and not is_moving and anim_state != "idle":
		$AnimatedSprite3D.play("idle")
		print("Switching to: idle")
		anim_state = "idle"

	was_on_floor = on_floor

func _on_anim_finished():
	var anim_name = $AnimatedSprite3D.animation
	print("Animation finished:", anim_name)
	if anim_name == "land":
		land_playing = false
		var on_floor = is_on_floor()
		var is_moving = abs(velocity.x) > 0.01 or abs(velocity.z) > 0.01
		if on_floor and is_moving:
			$AnimatedSprite3D.play("walk")
			print("Switching to: walk (after land)")
			anim_state = "walk"
		elif on_floor:
			$AnimatedSprite3D.play("idle")
			print("Switching to: idle (after land)")
			anim_state = "idle"
	# After jump, fall anim will be handled by state machine

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		global_position = respawn_point
		velocity = Vector3.ZERO
