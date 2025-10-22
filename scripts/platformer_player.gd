extends CharacterBody2D

# constants
const SPEED = 250.0 # horizontal mvmt
const JUMP_VELOCITY = 400.0 # vertical mvmt

# vars
var respawn_position : Vector2 # stores respawn pos

@onready var tilemap # ref tilemap

# setup anim
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # ref sprite node

# anim state vars
var anim_state = "" # track current anim state
var land_playing = false # true if land anim is currently playing

# gravity value from proj settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("Player") # add node to Player group
	respawn_position = global_position  # save start pos as initial respawn pt

	# automatically find tilemap
	call_deferred("find_tilemap")

# tilemap funny things
func find_tilemap():
	# search for tilemap node + save it
	var scene_root = get_tree().current_scene
	tilemap = search_for_tilemap(scene_root)

func search_for_tilemap(node: Node) -> TileMap:
	# search for first TileMap node
	if node is TileMap:
		return node as TileMap
	for child in node.get_children():
		var result = search_for_tilemap(child)
		if result:
			return result
	return null

func check_checkpoint():
	# check if player standing on checkpt tile
	if not tilemap:
		return
	var tile_pos = tilemap.local_to_map(global_position)
	var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
	if tile_data and tile_data.get_custom_data("is_checkpoint"):
		# upd respawn pt if on checkpt
		if respawn_position != global_position:
			respawn_position = global_position

func respawn():
	# move back to respawn pt
	global_position = respawn_position
	velocity = Vector2.ZERO
	# reset cam
	var cam = get_node("Camera2D")
	if cam and cam.is_class("Camera2D"):
		cam.global_position = global_position

# physics + mvmt
func _physics_process(delta: float) -> void:
	check_checkpoint() # update checkpt
	handle_normal_movement(delta) # handle input + physics
	move_and_slide() # move player

	# anim inputs
	var on_floor = is_on_floor() # if on ground
	var just_landed = on_floor and not (has_meta("was_on_floor") and get_meta("was_on_floor")) # if land
	var is_moving = abs(velocity.x) > 0.01 # if moving horizontally

	update_animations(on_floor, just_landed, is_moving) # update anim state
	set_meta("was_on_floor", on_floor) # store floor state

func handle_normal_movement(delta: float):
	# apply gravity if not on ground
	if not is_on_floor():
		velocity.y += gravity * delta

	# jump only if on ground
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY

	# horizontal mvmt input
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("move_right"):
		direction += 1

	# set/reduce horizontal velocity
	if direction:
		velocity.x = direction * SPEED
	else:
		# slow down if no input
		velocity.x = move_toward(velocity.x, 0, SPEED)

# anims
func update_animations(on_floor: bool, just_landed: bool, is_moving: bool):
	# jump (if jumped)
	if on_floor and Input.is_action_just_pressed("jump"):
		animated_sprite.play("jump")
		anim_state = "jump"
		land_playing = false
	# land (if landed)
	elif just_landed:
		animated_sprite.play("land")
		anim_state = "land"
		land_playing = true
	# finish land if still landing
	elif land_playing:
		return
	# fall (going down)
	elif not on_floor and velocity.y > 0 and anim_state != "fall":
		animated_sprite.play("fall")
		anim_state = "fall"
	# jump (going up)
	elif not on_floor and velocity.y < 0 and anim_state != "jump":
		animated_sprite.play("jump")
		anim_state = "jump"
	# walk
	elif on_floor and is_moving and anim_state != "walk":
		animated_sprite.play("walk")
		anim_state = "walk"
		animated_sprite.flip_h = velocity.x < 0
	# idle
	elif on_floor and not is_moving and anim_state != "idle":
		animated_sprite.play("idle")
		anim_state = "idle"

# func called upon anim end
func _on_animated_sprite_2d_animation_finished() -> void:
	# pick idle/walk anim
	if animated_sprite.animation == "land":
		land_playing = false
		var on_floor = is_on_floor()
		var is_moving = abs(velocity.x) > 0.01
		if on_floor and is_moving:
			animated_sprite.play("walk")
			anim_state = "walk"
		elif on_floor:
			animated_sprite.play("idle")
			anim_state = "idle"
