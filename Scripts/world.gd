extends Node3D

# Load UI elements to de/activate
@onready var navigation_region = $Map/NavigationRegion3D
@onready var black_screen = $UI/BlackScreen
@onready var crosshair = $UI/Crosshair
@onready var youwin = $UI/YouWin
@onready var youlose = $UI/YouLose
@onready var bg = $UI/Bg

func _ready():
	bg.visible = true
	await get_tree().create_timer(3.0).timeout  # Waits for 1 second
	bg.visible = false
	# Centre the crosshair
	crosshair.position.x = get_viewport().get_visible_rect().size.x / 2 - 32
	crosshair.position.y = get_viewport().get_visible_rect().size.y / 2 - 32

func _process(_delta):
	pass

func _on_player_player_dead(): # 'YOU DIED' screen and quits game 8s later
	bg.visible = true
	youlose.visible = true
	await get_tree().create_timer(8.0).timeout  
	get_tree().quit()

func _on_player_game_win(): # 'YOU WON' screen and quits game 8s later
	youwin.visible = true
	bg.visible = true
	await get_tree().create_timer(8.0).timeout  
	get_tree().quit()
