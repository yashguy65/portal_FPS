extends CharacterBody3D

const RUN_SPEED = 10.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const delta = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8
var speed

#bullets
var bullet = load("res://Scenes/bullet.tscn")
var instance

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var shoot_animation = $Head/Camera3D/Gun/RootNode/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/Gun/RayCast3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Handle sprint
	if Input.is_action_pressed("sprint"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
		
	#Handle resetting position
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	#Handle gunfire
	if Input.is_action_pressed("shoot"):
		if !shoot_animation.is_playing():
			shoot_animation.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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