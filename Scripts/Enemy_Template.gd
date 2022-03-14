extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var HealthBar = get_node("OverHead/HealthBar");

const MaxHealth = 100;
var Health = 100.00;


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if false: #jump 
		velocity.y = JUMP_VELOCITY

	var direction = (transform.basis * Vector3(0, 0, 0)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
