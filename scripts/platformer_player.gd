extends CharacterBody2D

# constants
const SPEED = 250.0
const JUMP_VELOCITY = 400.0

var respawn_position : Vector2

@onready var tilemap

# anim & visuals
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# anim vars
var anim_state = ""
var land_playing = false

# get default grav
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("Player")
	respawn_position = global_position

	# find tilemap auto
	call_deferred("find_tilemap")

func find_tilemap():
	var scene_root = get_tree().current_scene
	tilemap = search_for_tilemap(scene_root)

func search_for_tilemap(node: Node) -> TileMap:
	if node is TileMap:
		return node as TileMap
	for child in node.get_children():
		var result = search_for_tilemap(child)
		if result:
			return result
	return null

func check_checkpoint():
	if not tilemap:
		return
	var tile_pos = tilemap.local_to_map(global_position)
	var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
	if tile_data and tile_data.get_custom_data("is_checkpoint"):
		if respawn_position != global_position:
			respawn_position = global_position

func respawn():
	global_position = respawn_position
	velocity = Vector2.ZERO
	var cam = get_node("Camera2D")
	if cam and cam.is_class("Camera2D"):
		cam.global_position = global_position

func _physics_process(delta: float) -> void:
	check_checkpoint()
	handle_normal_movement(delta)
	move_and_slide()

	# animation state machine inputs
	var on_floor = is_on_floor()
	var just_landed = on_floor and not (has_meta("was_on_floor") and get_meta("was_on_floor"))
	var is_moving = abs(velocity.x) > 0.01

	update_animations(on_floor, just_landed, is_moving)
	set_meta("was_on_floor", on_floor) # save state for next frame

func handle_normal_movement(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("move_right"):
		direction += 1
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func update_animations(on_floor: bool, just_landed: bool, is_moving: bool):
	if on_floor and Input.is_action_just_pressed("jump"):
		print("jump")
		animated_sprite.play("jump")
		anim_state = "jump"
		land_playing = false
	elif just_landed:
		print("just landed")
		animated_sprite.play("land")
		anim_state = "land"
		land_playing = true
	elif land_playing:
		print("land is playing")
		return
	elif not on_floor and velocity.y > 0 and anim_state != "fall":
		print("fall")
		animated_sprite.play("fall")
		anim_state = "fall"
	elif not on_floor and velocity.y < 0 and anim_state != "jump":
		print("jump")
		animated_sprite.play("jump")
		anim_state = "jump"
	elif on_floor and is_moving and anim_state != "walk":
		print("walk")
		animated_sprite.play("walk")
		anim_state = "walk"
		animated_sprite.flip_h = velocity.x < 0
	elif on_floor and not is_moving and anim_state != "idle":
		print("idle")
		animated_sprite.play("idle")
		anim_state = "idle"

func _on_animated_sprite_2d_animation_finished() -> void:
	print("anim finished")
	if animated_sprite.animation == "land":
		print("land playing should be false now")
		land_playing = false
		var on_floor = is_on_floor()
		var is_moving = abs(velocity.x) > 0.01
		if on_floor and is_moving:
			animated_sprite.play("walk")
			anim_state = "walk"
		elif on_floor:
			animated_sprite.play("idle")
			anim_state = "idle"
