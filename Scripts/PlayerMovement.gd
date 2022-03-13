extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera = get_node("CameraPivot/PlayerCamera");
@onready var camera_pivot = get_node("CameraPivot");
@onready var mesh = get_node("PlayerMesh");
@onready var collision = get_node("CollisionBox");
@onready var ray_cast = get_node("CameraPivot/PlayerCamera/RayCast3D");

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var HideMouse = true;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
func _input(event):
	if Input.is_action_just_pressed("left_click"):
			print(ray_cast.get_collider())
			
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			HideMouse = !HideMouse;
			if HideMouse:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and $JumpCooldown.is_stopped():
		velocity.y = JUMP_VELOCITY
		$PlayerSound.play();
		$JumpCooldown.start();

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = -(camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var rotation_tween = get_tree().create_tween()
		rotation_tween.tween_property(mesh, "rotation", camera_pivot.rotation * Vector3(0, 1, 0), 0.2);
		velocity.x = direction.x * SPEED;
		velocity.z = direction.z * SPEED;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
