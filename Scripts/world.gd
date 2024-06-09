extends Node3D

@onready var navigation_region = $Map/NavigationRegion3D
@onready var black_screen = $UI/BlackScreen
@onready var spawns = $Map/Spawns
@onready var crosshair = $UI/Crosshair


var turret = load("res://Scenes/Turret.tscn")
var destroyer = load("res://Scenes/Destroyer.tscn")
var instance

# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair.position.x = get_viewport().get_visible_rect().size.x / 2 - 32
	crosshair.position.y = get_viewport().get_visible_rect().size.y / 2 - 32


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#instance = turret.instantiate()
#instance.position = helperMazeFn

func _on_player_player_dead():
	pass#black_screen.visible = true
	#make game over scene
