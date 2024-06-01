extends CharacterBody3D

var player = null

@export var player_path := "/root/World/Map/NavigationRegion3D/Player"
var state_machine

@onready var nav_agent = $NavigationAgent3D
@onready var animation_tree = $AnimationTree

const SPEED = 4.0
const gravity = 9.8
const RANGE = 2.5

func _ready():
	player = get_node(player_path)
	state_machine = animation_tree.get("parameters/playback")

func _physics_process(delta):
	
	apply_floor_snap()
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(player.global_transform.origin+velocity, Vector3.UP)
			#linear interpolation is janky when moving around the enemies, really jarring 
		"Rifle_stand":
			look_at(player.global_transform.origin, Vector3.UP)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	animation_tree.set("parameters/conditions/attack", _target_in_range())
	animation_tree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < RANGE
	
func _hit_finished():
	if global_position.distance_to(player.global_position) < RANGE + 1.0:
		player.hit()	
	
