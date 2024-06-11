extends Area3D

@export var damage := 15 # Damage taken on each hit

signal body_part_hit(dam) # Signal to be sent to actual destroyer

func _ready():
	pass 

func _process(delta):
	pass

func hit():
	emit_signal("body_part_hit", damage) # Sends signal to body
	
