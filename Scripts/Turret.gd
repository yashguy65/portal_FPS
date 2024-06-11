extends CharacterBody3D

var player = null

@export var player_path := "/root/World/Map/NavigationRegion3D/Player" 
var state_machine # Animation Tree State Machine used for managing animations
var bullet = load("res://Scenes/Bullet.tscn")
var instance
@onready var barrel := $RayCast3D as RayCast3D # For shooting bullets

@onready var nav_agent = $NavigationAgent3D

var rng2 = RandomNumberGenerator.new() # Used to generate 2nd position
var room_size = 30 
var no_of_rooms = 20 #per side
var timeDelta := 0.0
var posn_1 : Vector3
var posn_2 : Vector3
var shotsFired := 0
var setLocation : bool = false

const ShootFrequency := 0.5
const ShootSpeed := 23.0
const gravity := 9.8
const RANGE := 23

func _ready():
	player = get_node_or_null(player_path)
	var posn_1 := global_transform.origin
	# Makes position2 for teleportation
	posn_2 = Vector3(room_size * rng2.randi_range(0, no_of_rooms-1) + rng2.randi_range(0,5), 0, room_size * rng2.randi_range(0, no_of_rooms-1) + rng2.randi_range(0,5))
	while posn_2.distance_to(posn_1)<3: # Ensures it is not too close to position 1
		posn_2 = Vector3(room_size * rng2.randi_range(0, no_of_rooms-1), 0, room_size * rng2.randi_range(0, no_of_rooms-1))
	
	
func _physics_process(delta):
	
	apply_floor_snap()
	velocity = Vector3.ZERO
	
	# LOCK AND FIRE
	if _target_in_range():
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		nav_agent.set_target_position(player.global_transform.origin)
		timeDelta+=delta
		if timeDelta>=0.5:
			instance = bullet.instantiate()
			shotsFired += 1
			print(shotsFired, "shots fired")
			instance.SPEED = ShootSpeed
			instance.position = barrel.global_position
			instance.transform.basis = barrel.global_transform.basis
			get_parent().add_child(instance)
			timeDelta = 0.0
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# TELEPORT AFTER 3 SHOTS
	if shotsFired == 3:
		if not setLocation:  # Resets position 1 the first time it teleports in case _ready has an error
			posn_1 = global_transform.origin
			setLocation = true # Makes sure it runs only the first time
		await get_tree().create_timer(0.3).timeout # Smoother animation, any longer and it shoots 4 bullets
		#print("currently: ", global_transform.origin) # Debug print
		if global_transform.origin.distance_to(posn_1) < 1: 
			# Teleportation, < 1 rather than == 0 as 0 can become 0.00006 in godot sometimes
			global_transform.origin = posn_2
		else:
			global_transform.origin = posn_1
		shotsFired = 0 # Reset for 3 shots
		
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < RANGE # Player targetting
