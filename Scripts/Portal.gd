extends MeshInstance3D

# Define a custom class for a portal within the 3D scene.
class_name CamPortal

# Path to the other portal for transport
@export var other_portal_path: NodePath
# Helper node for assisting with portal rendering.
@onready var helper = $Helper
# Frame node for displaying the portal frame.
@onready var frame = $Frame

# Reference to the other portal object.
var other_portal: CamPortal = null

# Called when the node is added to the scene.
func _ready():
	# If the other portal path is set, attempt to find the other portal node.
	if not other_portal_path.is_empty():
		other_portal = get_node(other_portal_path)

func _process(delta):
	# Show the frame and sync helper position with the main camera.
	var main_cam = get_viewport().get_camera_3d()
	helper.global_transform = main_cam.global_transform
	# If there's another portal, synchronize helper transforms.
	if other_portal:
		other_portal.helper.transform = helper.transform
	g.portal_camera.global_transform = other_portal.helper.global_transform
	# Calculate near plane distance for rendering.
	var diff = global_transform.origin - main_cam.global_transform.origin
	var angle = main_cam.global_transform.basis.z.angle_to(diff)
	var near_plane = helper.transform.origin.length() * abs(cos(angle))
	g.portal_camera.near = max(0.1, near_plane - 4.2)

# Called when a body enters the portal for teleportation.
func _on_teleport_body_entered(body):
	if not body.is_in_group("player"):
		return
	# Initiate teleportation.
	helper.global_transform = body.global_transform
	other_portal.helper.transform = helper.transform
	body.global_transform = other_portal.helper.global_transform

# Called when a body exits the inside of the portal.
func _on_inside_body_exited(body):
	if not body.is_in_group("player"):
		return
