extends CharacterBody3D

var player = null

@export var player_path := "/root/World/Map/NavigationRegion3D/Player"
var state_machine
var bullet = load("res://Scenes/Bullet.tscn")
var instance
@onready var barrel := $RayCast3D as RayCast3D

@onready var nav_agent = $NavigationAgent3D

var timeDelta := 0.0

const ShootFrequency := 0.5
const ShootSpeed := 23.0
const gravity := 9.8
const RANGE := 7

func _ready():
	player = get_node(player_path)

func _physics_process(delta):
	
	apply_floor_snap()
	velocity = Vector3.ZERO
	
	if _target_in_range():
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		nav_agent.set_target_position(player.global_transform.origin)
		timeDelta+=delta
		if timeDelta>=0.5:
			instance = bullet.instantiate()
			instance.SPEED = ShootSpeed
			instance.position = barrel.global_position
			instance.transform.basis = barrel.global_transform.basis
			get_parent().add_child(instance)
			timeDelta = 0.0
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < RANGE
	
func _hit_finished():
	if global_position.distance_to(player.global_position) < RANGE + 1.0:
		player.hit()	



func _on_timer_timeout():
	pass # Replace with function body.
