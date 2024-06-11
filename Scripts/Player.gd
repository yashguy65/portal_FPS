extends CharacterBody3D

# Constants for character movement and attributes.
var RUN_SPEED := 18
const WALK_SPEED := 10.0
const JUMP_VELOCITY := 4
const SENSITIVITY := 0.003

# Player attributes.
var HP := 100.0
var gravity := 9.8
var speed : float
var DMG := 14

# Signals emitted by the player.
signal player_dead
signal screen_shake
signal game_win

# Bullet variables.
var bullet = load("res://Scenes/Bullet.tscn")
var instance

# References to player components.
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var shoot_animation = $Head/Camera3D/Gun/RootNode/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/RayCast3D

# Maze parameters.
var maze_side = 20
const room_side = 30
var endpoint : Vector3

func _ready():
	# Initialize player position and adjust settings.
	global_transform.origin = Vector3(0,20,0)
	apply_floor_snap()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Adjust settings based on game difficulty.
	if g.difficulty == 1: #easy
		RUN_SPEED = 22
		DMG = 8
		maze_side = 10
	# Enable journalist mode.
	if g.game_journalist:
		RUN_SPEED = 80
		HP = 1000000
	endpoint = Vector3((maze_side-1) * room_side, 0, (maze_side-1) * room_side)
	
# Handle player input.
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

# Update player physics.
func _physics_process(delta):
	# Apply gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("duck") and !is_on_floor():
		velocity.y = -JUMP_VELOCITY/3
		
	# Check if player reached the endpoint.
	if endpoint.distance_to(self.global_transform.origin) < 14:
		game_win.emit()
		
	# Handle sprint.
	if Input.is_action_pressed("sprint"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
		
	# Handle quitting the game.
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Handle gunfire.
	if Input.is_action_pressed("shoot"):
		if !shoot_animation.is_playing():
			shoot_animation.play("Shoot")
			instance = bullet.instantiate()
			instance.set_player(self)
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)

	# Get input direction and update movement.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0 )
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0 )
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0 )
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0 )
	
	move_and_slide()

# Function to handle player being hit by an enemy.
func hit(damage=DMG):
	shake()
	HP-=damage
	print(HP)
	if HP<=0:
		emit_signal("player_dead")

# Function triggered when player starts in a new maze.
func _on_maze_gen_player_start(initial: Vector3) -> void:    
	global_transform.origin = initial

# Function to trigger screen shake effect.
func shake():
	screen_shake.emit()
