extends Label

func _ready():
	pass 

func _process(delta):
	var FPS = Engine.get_frames_per_second() # Uses inbuilt function to get FPS
	text = str(FPS)+" FPS" # Displayed on top left by default

