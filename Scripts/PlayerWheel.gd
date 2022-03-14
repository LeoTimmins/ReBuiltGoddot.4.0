extends Node3D

var wobble_speed = 1;
var spin_speed = 1;
var wobble_angle = PI/40;

func normalize_angle(angle: float):
	if angle > 2*PI:
		return 0;
	elif angle < 0:
		return 2*PI
	else:
		return angle;

var wobble_right = true;



func Wheel1(delta):
	if Input.is_action_pressed("move_forward") || Input.is_action_pressed("move_back"):
		rotation.x = normalize_angle(rotation.x + spin_speed * delta);
		if wobble_right:
			rotation.z += wobble_speed * delta;
			if rotation.z >= wobble_angle:
				wobble_right = false;
		else:
			rotation.z -= wobble_speed * delta;
			if rotation.z <= -wobble_angle:
				wobble_right = true;
	
