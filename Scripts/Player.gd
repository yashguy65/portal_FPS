extends CharacterBody3D

const RUN_SPEED := 80
const WALK_SPEED := 10.0
const JUMP_VELOCITY := 7
const SENSITIVITY := 0.003

var HP := 100.0
var gravity := 9.8
var speed : float

# Signals
signal player_dead
signal screen_shake

# Bullets
var bullet = load("res://Scenes/Bullet.tscn")
var instance

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var shoot_animation = $Head/Camera3D/Gun/RootNode/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/RayCast3D

@export var creative_mode: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#var maze_generator = get_parent().get_node("MazeGen")
	#if maze_generator:
	#	maze_generator.connect("player_start", _on_maze_gen_player_start)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	# Handle resetting position
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if creative_mode:
		_physics_process_creative(delta)
	else:
		_physics_process_normal(delta)

func _physics_process_creative(delta):
	# Disable collisions
	set_collision_layer(0)
	set_collision_mask(0)

	# Handle movement
	var direction = Vector3()
	if Input.is_action_pressed("left"):
		direction -= camera.basis.z
	if Input.is_action_pressed("backward"):
		direction += camera.basis.z
	if Input.is_action_pressed("forward"):
		direction -= camera.basis.x
	if Input.is_action_pressed("right"):
		direction += camera.basis.x
	if Input.is_action_pressed("jump"):
		direction += camera.basis.y
	if Input.is_action_pressed("crouch"):  # Assuming crouch for moving down
		direction -= camera.basis.y

	direction = direction.normalized()
	velocity = direction * RUN_SPEED

	move_and_slide()

	# Handle gunfire
	if Input.is_action_pressed("shoot"):
		if !shoot_animation.is_playing():
			shoot_animation.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)

func _physics_process_normal(delta):
	# Enable collisions
	set_collision_layer(1)
	set_collision_mask(1)

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle sprint
	if Input.is_action_pressed("sprint"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
	
	# Handle gunfire
	if Input.is_action_pressed("shoot"):
		if !shoot_animation.is_playing():
			shoot_animation.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	move_and_slide()

func hit(damage=20.0):
	emit_signal("screen_shake")
	HP -= damage
	print(HP)
	if HP <= -500:
		emit_signal("player_dead")

func _on_maze_gen_player_start(initial: Vector3) -> void:
	global_transform.origin = initial
