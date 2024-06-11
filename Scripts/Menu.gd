extends VBoxContainer

@onready var controls = $"../Controls"
@onready var title = $"../Title"
var OptionsPressed = false

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_easy_mode_pressed():
	g.difficulty = 1
	get_tree().change_scene_to_file("res://World.tscn")

func _on_hard_mode_pressed():
	g.difficulty = 2
	get_tree().change_scene_to_file("res://World.tscn")

func _on_controls_pressed():
	if OptionsPressed:
		controls.visible = false
		title.visible = true
	else:
		controls.visible = true
		title.visible = false
	OptionsPressed = not OptionsPressed


func _on_lol_pressed():
	g.difficulty = 1
	g.game_journalist = true
	get_tree().change_scene_to_file("res://World.tscn")
	
