extends MeshInstance3D

class_name CamPortal

@export var current = false
@export var other_portal_path: NodePath
@onready var helper = $Helper
@onready var frame = $Frame

var other_portal: CamPortal = null

func _ready():
	if not other_portal_path.is_empty():
		other_portal = get_node_or_null(other_portal_path)
	if current:
		$Inside.visible = true

func _process(delta):
	if current:
		frame.visible = true
		var main_cam = get_viewport().get_camera_3d()
		helper.global_transform = main_cam.global_transform
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
