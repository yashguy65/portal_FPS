extends CharacterBody3D

var player = null

@export var player_path := "/root/World/Map/NavigationRegion3D/Player"
@onready var barrel := $RayCast3D as RayCast3D

var timeDelta := 0.0
const ShootFrequency := 0.5

signal screen_shake

var state_machine
var bullet = load("res://Scenes/Bullet.tscn")
var instance

@onready var nav_agent = $NavigationAgent3D
@onready var animation_tree = $AnimationTree

var HP := 100

var SPEED := 14.0
const gravity := 9.8
const SIGHT_RANGE := 4
var TRACK_RANGE := 48

func _ready():
	player = get_node_or_null(player_path)
	state_machine = animation_tree.get("parameters/playback") # Setup animation tree state machine for animation based on conditions 
	state_machine.start("Start")
	if g.difficulty == 1: # Novice mode, makes it easy
		TRACK_RANGE = 38
		SPEED = 11

func _physics_process(delta):
	
	apply_floor_snap() # Get on the floor 
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node(): # State machines are goated
		"Walk": # Move towards player using inbuilt A* on navmesh baked at runtime
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
			
		"Attack2": 
			# Attacks every 0.5s using timedelta, targets player
			timeDelta+=delta
			if timeDelta>=0.5:
				look_at(Vector3(player.global_position.x, player.global_position.y-1, player.global_position.z), Vector3.UP)
				instance = bullet.instantiate()
				instance.position = barrel.global_position
				instance.transform.basis = barrel.global_transform.basis
				get_parent().add_child(instance)
				timeDelta=0.0
			player.hit(0.2)
			
		"End":
			# Disappear the enemy, free resources
			queue_free()
		
		"Idle":
			# Lite, nothing
			pass
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	animation_tree.set("parameters/conditions/player_spotted", _target_in_range(SIGHT_RANGE))
	animation_tree.set("parameters/conditions/player_traceable", (_target_in_range(TRACK_RANGE) && !_target_in_range(SIGHT_RANGE) ))
	animation_tree.set("parameters/conditions/idle", !_target_in_range(TRACK_RANGE))
	# Uses range functions for state machine to find whether to idle, walk or attack 
	move_and_slide()
	
func _target_in_range(rangey): # Get distance from player
	return global_position.distance_to(player.global_transform.origin) < rangey
	
	
func _hit_finished(): # Cause effect to player on physical damage
	if global_position.distance_to(player.global_position) < SIGHT_RANGE + 1.0:
		player.hit()	

func _on_Timer_timeout():
	queue_free()


func _on_area_3d_body_part_hit(dam): # Receives signal from body part, takes damage 
	HP -= dam
	emit_signal("screen_shake")
	if HP<=0: # Death condition for state machine
		animation_tree.set("parameters/conditions/dead", true)
	
