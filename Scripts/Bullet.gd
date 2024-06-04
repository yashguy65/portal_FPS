extends Node3D

@export var SPEED := 90.0

@onready var mesh = $Node3D/MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var node_mesh = $Node3D

func _ready():
	pass

#func emit_bullet():
#	particles.emitting = false
#	particles.amount = 1
#	particles.one_shot = true
#	particles.lifetime = 1.0
#	particles.preprocess = 0
#	particles.emitting = true

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		pass#emit_bullet()
	
	position += transform.basis * Vector3(0,0,-SPEED) * delta

	if ray.is_colliding():
		node_mesh.visible = false
		particles.emitting = true
		ray.enabled = false 
		print(ray.get_collider())
		if ray.get_collider().has_method("hit"):
			ray.get_collider().hit()
		if ray.get_collider().is_in_group("projectile"):
			ray.enabled = false
		await get_tree().create_timer(3.0).timeout
		queue_free()

func _on_timer_timeout():
	queue_free()
