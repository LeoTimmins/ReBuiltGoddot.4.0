extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera = get_node("CameraPivot/PlayerCamera");
@onready var camera_pivot = get_node("CameraPivot");
@onready var mesh = get_node("PlayerMesh");
@onready var collision = get_node("CollisionBox");
@onready var ray_cast = get_node("CameraPivot/PlayerCamera/RayCast3D");
@onready var AmmoLabel = get_node("HUD/AmmoCounter/AmmoLabel");

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var HideMouse = true;

#Weapon configuration
var Weapon_Type = "NailGun";
var Weapon_Damage = 0;
var Weapon_MiningRate = 0;
var TotalAmmo = 10;
var LoadedAmmo = 15;
var MaxAmmoInMag = 15;

func ResetAmmoText():
	if TotalAmmo > 999:
		AmmoLabel.text = str(LoadedAmmo) + "/999+";
	else:
		AmmoLabel.text = str(LoadedAmmo) + "/" + str(TotalAmmo);


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	ResetAmmoText()
	
func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			HideMouse = !HideMouse;
			if HideMouse:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
				
		if Input.is_action_just_pressed("Reload") and LoadedAmmo != MaxAmmoInMag and TotalAmmo != 0 and Weapon_Type == "NailGun":
			#checks if there isn't enough ammo to fill magazine
			if MaxAmmoInMag - LoadedAmmo > TotalAmmo:
				LoadedAmmo += TotalAmmo;
				TotalAmmo = 0; 
			else: # standard fill magazine
				TotalAmmo -= MaxAmmoInMag - LoadedAmmo;
				LoadedAmmo = MaxAmmoInMag;
			ResetAmmoText();

func _physics_process(delta):
	
	#this has to be in physics process, ask me if you want to know why. DONT MOVE IT
	
	if Input.is_action_pressed("left_click") and $WeaponCooldown.is_stopped():
		var RayTarget = ray_cast.get_collider();
		
		if Weapon_Type == "NailGun" and LoadedAmmo != 0:
			$WeaponCooldown.wait_time = 0.3
			ray_cast.set_target_position(Vector3(0,0,100));
			$PlayerSoundNailGun.play();
			LoadedAmmo -= 1;
		elif Weapon_Type == "Drill": 
			$WeaponCooldown.wait_time = 0.01
			ray_cast.set_target_position(Vector3(0,0,10));
			AmmoLabel.text = "";
		elif Weapon_Type == "Magnet":
			$WeaponCooldown.wait_time = 0.01;
			ray_cast.set_target_position(Vector3(0,0,30));
			AmmoLabel.text = "";
		
		$WeaponCooldown.start()
		ResetAmmoText()
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and $JumpCooldown.is_stopped():
		velocity.y = JUMP_VELOCITY
		$PlayerSoundJump.play();
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
