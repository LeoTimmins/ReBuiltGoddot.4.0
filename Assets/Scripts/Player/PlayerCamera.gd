extends Camera3D

const max_tilt_up = 0.8;
const max_tilt_down = 0.5;
func normalize_angle(angle: float):
	if angle > PI:
		return -PI;
	elif angle < -PI:
		return PI;
	else:
		return angle;

func setpos(event):

	var mouse_speed = event.get_relative();
	get_parent().rotation.y = normalize_angle(get_parent().rotation.y - mouse_speed.x / 200);
	get_parent().rotation.x = max(min(get_parent().rotation.x + mouse_speed.y / 200, max_tilt_down), -max_tilt_up);
