extends Node3D

@onready var damage_indicator =  $UI/ColorRect
@onready var navigation_region = $Map/NavigationRegion3D
@onready var spawns = $Map/Spawns

var future_soldier = load("res://Scenes/future_soldier.tscn")
var instance

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_player_hit():
	damage_indicator.visible = true
	await get_tree().create_timer(0.2).timeout
	damage_indicator.visible = false

#instance = future_soldier.instantiate()
#instance.position = helperMazeFn
