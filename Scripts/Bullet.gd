extends Node3D

@export var SPEED := 90.0 # Used for player, altered by turret when fired in turret.gd

@onready var mesh = $Node3D/MeshInstance3D
@onready var ray = $RayCast3D # Uses raycast for shooting
@onready var particles = $GPUParticles3D
@onready var node_mesh = $Node3D

var player: Node = null

func _ready():
	pass

func _process(delta):
	
	position += transform.basis * Vector3(0,0,-SPEED) * delta # Fires with velocity

	if ray.is_colliding():
		node_mesh.visible = false
		particles.emitting = true
		ray.enabled = false 
		#print(ray.get_collider()) # Debug statement
		if ray.get_collider().has_method("hit"):  # Only destroyer and player, simpler than using groups
			ray.get_collider().hit()
			if player != null: # Player fires it and not turret
				player.shake()	
		if ray.get_collider().is_in_group("projectile"):
			ray.enabled = false # Visual effect
		await get_tree().create_timer(3.0).timeout
		queue_free()
		
func set_player(player_node: Node): # When instantiated by player, allows for screen shake by signal
	player = player_node

func _on_timer_timeout():
	queue_free()
