extends VBoxContainer

@onready var controls = $"../Controls"
@onready var title = $"../Title"
var OptionsPressed = false

func _ready():
	pass 

func _process(delta):
	pass


func _on_easy_mode_pressed(): # The mode for normal people
	g.difficulty = 1
	get_tree().change_scene_to_file("res://World.tscn")

func _on_hard_mode_pressed(): # RIPBOZO Enjoy suffering
	g.difficulty = 2
	get_tree().change_scene_to_file("res://World.tscn")

func _on_controls_pressed(): # Show and hide 'HOW TO PLAY' on press
	if OptionsPressed:
		controls.visible = false
		title.visible = true
	else:
		controls.visible = true
		title.visible = false
	OptionsPressed = not OptionsPressed


func _on_lol_pressed(): # Good for testing and memeing
	g.difficulty = 1
	g.game_journalist = true
	get_tree().change_scene_to_file("res://World.tscn")
	
