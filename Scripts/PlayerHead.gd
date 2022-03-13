extends Node3D

@export_node_path(Camera3D) var PlayerCamera_path;
@onready var playerCamera = get_node(PlayerCamera_path);

const max_y_angle = PI;
const max_x_angle = PI/10;

func _input(event):
	#if event is InputEventMouseMotion:
		#print(playerCamera.get_parent().rotation.x);
		#global_transform.y = max(min(playerCamera.get_parent().rotation.y, max_y_angle), -max_y_angle);
		#global_rotation.x = max(min(playerCamera.get_parent().rotation.x, max_x_angle), -max_x_angle);
	pass
