extends MeshInstance3D

class_name CamPortal

@export var current = false
@export var other_portal_path: NodePath
@onready var helper = $Helper
@onready var frame = $Frame

var other_portal: CamPortal = null

func _ready():
	while (other_portal_path.is_empty()):
		pass
	if not other_portal_path.is_empty():
		other_portal = get_node(other_portal_path)
		if other_portal == null:
			print("Failed to find other portal at path:", other_portal_path)
		else:
			print("Other portal found at path:", other_portal_path)
	else:
		print("No other_portal_path set.")
	
	if current:
		$Inside.visible = true
	print("Path:", self.get_path())
	print("Other portal path:", other_portal_path)

func _process(delta):
	if current:
		frame.visible = true
		var main_cam = get_viewport().get_camera_3d()
		helper.global_transform = main_cam.global_transform
		if other_portal:
			other_portal.helper.transform = helper.transform
		else:
			print("Other portal is null. self: ", self.get_path())
		other_portal.helper.transform = helper.transform
		g.portal_camera.global_transform = other_portal.helper.global_transform
		var diff = global_transform.origin - main_cam.global_transform.origin
		var angle = main_cam.global_transform.basis.z.angle_to(diff)
		var near_plane = helper.transform.origin.length()*abs(cos(angle))
		g.portal_camera.near = max(0.1, near_plane-4.2)
		if not visible:
			visible = true
	else:
		frame.visible = false
		if visible:
			visible=false

func _on_teleport_body_entered(body):
	if not body.is_in_group("player"):
		return
	if not current:
		current = true
		visible = true
		frame.visible = true
	if current and $Inside.visible:
		helper.global_transform = body.global_transform
		other_portal.helper.transform = helper.transform
		body.global_transform = other_portal.helper.global_transform
		current = false
		$Inside.visible = false

func _on_inside_body_exited(body):
	if not body.is_in_group("player"):
		return
	if current and not $Inside.visible:
		$Inside.visible = true
		
func set_other_portal_path(path: NodePath):
	other_portal_path = path
	print("Setting other_portal_path:", path)
