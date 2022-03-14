extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera = get_node("CameraPivot/PlayerCamera");
@onready var camera_pivot = get_node("CameraPivot");
@onready var mesh = get_node("PlayerMesh");
@onready var collision = get_node("CollisionBox");
@onready var ray_cast = get_node("CameraPivot/PlayerCamera/RayCast3D");
@onready var AmmoLabel = get_node("HUD/AmmoCounter/AmmoLabel");
@onready var RecourcesLabel = get_node("HUD/RecourcesTxt/RecourcesLabel");
@onready var  wheel = get_node("PlayerMesh/Wheel");
@onready var  HUD = get_node("HUD");
@onready var  Menu = get_node("Menu");
@onready var  ExitGameButton = get_node("Menu/Exit/Button");

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var GamePaused = false;

#Weapon configuration
var Weapon_Type = "NailGun";
var Weapon_Damage = 0;
var TotalAmmo = 1000;
var LoadedAmmo = 15;
var MaxAmmoInMag = 15;

#Mining Configuration
var Weapon_MiningRate = 0;
var Recources_Steel=0;
var Recources_Silicone=0;
var Recources_Rubber=0;
var Recources_Gold=0;
var Recources_Copper=0;

func ResetAmmoText():
	if TotalAmmo > 999:
		AmmoLabel.text = str(LoadedAmmo) + "/999+";
	else:
		AmmoLabel.text = str(LoadedAmmo) + "/" + str(TotalAmmo);
		
func WeaponFramework():
	if Input.is_action_pressed("left_click") and $WeaponCooldown.is_stopped():
		
		if Weapon_Type == "NailGun" and LoadedAmmo != 0:
			$WeaponCooldown.wait_time = 0.3
			ray_cast.set_target_position(Vector3(0,0,-100));
			$PlayerSoundNailGun.play();
			LoadedAmmo -= 1;
			Weapon_Damage=40;
			Weapon_MiningRate = 30; 
			ResetAmmoText();
		elif Weapon_Type == "Drill": 
			$WeaponCooldown.wait_time = 0.01
			ray_cast.set_target_position(Vector3(0,0,-20));
			AmmoLabel.text = "";
			Weapon_Damage=2
			Weapon_MiningRate = 0.9;
		elif Weapon_Type == "Magnet":
			$WeaponCooldown.wait_time = 0.01;
			ray_cast.set_target_position(Vector3(0,0,-30));
			AmmoLabel.text = "";
			Weapon_Damage=0
			Weapon_MiningRate = 0;
			
		var RayTarget = ray_cast.get_collider();
		
		if RayTarget != null:
			var RayTarget_Name = str(RayTarget.name);
			
			if "Enemy_" in RayTarget_Name:
				RayTarget.Health -= Weapon_Damage;
				RayTarget.HealthBar.scale = Vector3(8*(RayTarget.Health/RayTarget.MaxHealth),1,1)
				
				if RayTarget.Health < 0:
					RayTarget.queue_free()
			elif "RecourceContainer_" in RayTarget_Name:
				RayTarget.MineRecource(Weapon_MiningRate);
		
		$WeaponCooldown.start()


func _ready():
	Menu.visible = false
	HUD.visible = true;
	Input.set_custom_mouse_cursor(load("res://Assets/Images/BlackSqr.png"))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	ResetAmmoText()

func _input(event):
	
	if event is InputEventMouseMotion && !GamePaused:
		camera.setpos(event)
		
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			
			GamePaused = !GamePaused;
			if !GamePaused:
				Menu.visible = false
				HUD.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
			else:
				Menu.visible = true
				HUD.visible = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
				
		if !GamePaused && Input.is_action_just_pressed("Reload") and LoadedAmmo != MaxAmmoInMag and TotalAmmo != 0 and Weapon_Type == "NailGun":
			#checks if there isn't enough ammo to fill magazine
			if MaxAmmoInMag - LoadedAmmo > TotalAmmo:
				LoadedAmmo += TotalAmmo;
				TotalAmmo = 0; 
			else: # standard fill magazine
				TotalAmmo -= MaxAmmoInMag - LoadedAmmo;
				LoadedAmmo = MaxAmmoInMag;
			ResetAmmoText();

func _physics_process(delta):
	if ExitGameButton.button_pressed:
		get_tree().quit()
	
	# Add the gravity.
	if !GamePaused and not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if !GamePaused && Input.is_action_just_pressed("jump") and is_on_floor() and $JumpCooldown.is_stopped():
		velocity.y = JUMP_VELOCITY
		$PlayerSoundJump.play();
		$JumpCooldown.start();
		$AnimationPlayer.play("Jump");
	
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
	if !GamePaused:
		#this has to be in physics process, ask me if you want to know why. DONT MOVE IT
		if Weapon_Type == "NailGun":
			if LoadedAmmo != 0:
				WeaponFramework();
		else:
			WeaponFramework();
		wheel.Wheel1(delta)
		move_and_slide()
