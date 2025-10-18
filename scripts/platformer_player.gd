extends CharacterBody2D

# constants
const SPEED = 250.0
const JUMP_VELOCITY = 400.0

var respawn_position : Vector2

@onready var tilemap

# anim & visuals
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("Player")
	
	respawn_position = global_position
	
	# check sprite node exists
	if not sprite:
		print("warn: animatedsprite2d not found! ensure named 'Sprite2D'")
	
	# find tilemap auto
	call_deferred("find_tilemap")

func find_tilemap():
	# search for tilemap in scene tree
	var scene_root = get_tree().current_scene
	tilemap = search_for_tilemap(scene_root)
	
	if tilemap:
		print("found tilemap: ", tilemap.name)
	else:
		print("warn: no tilemap found!")

func search_for_tilemap(node: Node) -> TileMap:
	if node is TileMap:
		return node as TileMap
	
	for child in node.get_children():
		var result = search_for_tilemap(child)
		if result:
			return result
	return null

# get default grav
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func check_checkpoint():
	if not tilemap:
		return

	# get the tile under the player's feet
	var tile_pos = tilemap.local_to_map(global_position)
	var tile_data = tilemap.get_cell_tile_data(0, tile_pos)

	if tile_data and tile_data.get_custom_data("is_checkpoint"):
		# save checkpoint position if it's new
		if respawn_position != global_position:
			respawn_position = global_position
			print("checkpoint reached at: ", respawn_position)

func respawn():
	global_position = respawn_position
	velocity = Vector2.ZERO
	
	# reset camera to player immediately
	var cam = get_node("Camera2D")
	if cam and cam.is_class("Camera2D"):
		cam.global_position = global_position

func _physics_process(delta: float) -> void:
	check_checkpoint()

	handle_normal_movement(delta)

	# apply movement
	move_and_slide()

	# update anims
	update_animations()

func handle_normal_movement(delta: float):
	# apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY

	# horizontal input
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("move_right"):
		direction += 1

	# set horizontal vel
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func update_animations():
	var animated_sprite = $AnimatedSprite2D
	
	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x < 0
		
	else:
		animated_sprite.play("idle")
