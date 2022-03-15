extends Node;

func _ready():
	randomize()

var RecourceContainer_TotalRecources = randi_range(50,150);
@onready var Player = get_parent().get_parent().get_parent().get_node("Player");

func MineRecource(Weapon_MiningRate):
	if RecourceContainer_TotalRecources < Weapon_MiningRate:
		Player.Recources_Gold += RecourceContainer_TotalRecources;
		RecourceContainer_TotalRecources = 0;
		
		#placeholder, In future we will have a breaking apart animation
		queue_free()
	else:
		RecourceContainer_TotalRecources -= Weapon_MiningRate;
		Player.Recources_Gold += Weapon_MiningRate; #Change Player.___ according to recource type
	
	Player.RecourcesLabel.text = "Steel           - "+ str(Player.Recources_Steel) +"\nSilicone     - "+ str(Player.Recources_Silicone) +"\nRubber       - "+ str(Player.Recources_Rubber) +"\nGold            - "+ str(Player.Recources_Gold) +"\nCopper       - "+ str(Player.Recources_Copper);
	
	
