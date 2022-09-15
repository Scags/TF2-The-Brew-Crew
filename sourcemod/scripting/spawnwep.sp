#pragma semicolon 1

#define DEBUG

#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <tf2items>
#include <scag>
#include <morecolors>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Custom Weapon Spawner",
	author = "Ragenewb",
	description = "spawn some fucking weapons obviously",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_spawnwep", SpawnWep, ADMFLAG_VOTE);
	RegAdminCmd("sm_aspawnwep", ASpawnWep, ADMFLAG_VOTE);
}

public Action SpawnWep(int client, int args)
{
	if (!client)
		return Plugin_Handled;
	if (!args)
		WeaponMenu(client);
	/*if (args == 1)
	{
		char name[32]; GetCmdArg(1, name, sizeof(name));
		if (!strcmp(name, ""))
	}*/
	return Plugin_Handled;
}

public void WeaponMenu(const int client)
{
	Menu menu = new Menu(Weapons);
	menu.SetTitle("Weapon List");
	menu.AddItem("0", "The Kink");
	menu.AddItem("1", "Railgun");
	menu.AddItem("2", "Army of One");
	menu.AddItem("3", "Force-a-Hundred-Nature");
	menu.AddItem("4", "Dazzler");
	menu.AddItem("5", "Vertigo");
	menu.AddItem("6", "Accentus");
	menu.AddItem("7", "Auxilium");
	menu.AddItem("8", "Malitia");
	menu.AddItem("9", "Zavetska");
	/*menu.AddItem("10", "");
	menu.AddItem("11", "");
	menu.AddItem("12", "");
	menu.AddItem("13", "");
	menu.AddItem("14", "");
	menu.AddItem("15", "");
	menu.AddItem("16", "");
	menu.AddItem("17", "");
	menu.AddItem("18", "");
	menu.AddItem("19", "");
	menu.AddItem("20", "");*/
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Weapons(Menu menu, MenuAction action, int client, int select)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			int wep;
			switch(select)
			{
				case 0:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "396 ; 0.4 ; 251 ; 1");
					SetActive(client, wep);
				}
				case 1:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_sniperrifle", 526, 5, 10, "305 ; 1 ; 308 ; 1 ; 309 ; 1 ; 636 ; 1 ; 318 ; 0.01");
					FillReserves(wep, 0);
					SetActive(client, wep);
				}
				case 2:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 5, 10, "3 ; 0.25 ; 104 ; 0.2 ; 101 ; 5.0 ; 2 ; 5.0 ; 37 ; 0.0 ; 99 ; 3.0");
					FillReserves(wep, 0);
					SetActive(client, wep);
				}
				case 3:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_scattergun", 45, 5, 10, "4 ; 50.0 ; 6 ; 0.1 ; 37 ; 0.0");
					FillReserves(wep, 0);
					SetActive(client, wep);
				}
				case 4:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_handgun_scout_primary", 220, 5, 10, "280 ; 18 ; 6 ; 0.2 ; 4 ; 40.0 ; 37 ; 0.0 ; 103 ; 1000.0");
					FillReserves(wep, 0);
					SetActive(client, wep);
				}
				case 5:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_flamethrower", 40, 5, 10, "171 ; 10.0 ; 255 ; 30.0");
					FillReserves(wep, 0);
					SetActive(client, wep);
				}
				case 6:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_compound_bow", 1005, 5, 10, "196 ; 3.0 ; 101 ; 3.0 ; 103 ; 100.0 ; 2 ; 2.0");
					FillReserves(wep, 0);
					SetActive(client, wep);
					SetWeaponAmmo(wep, 25);
				}
				case 7:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_medigun", 411, 5, 10, "7 ; 0.5 ; 9 ; 0.5 ; 14 ; 1 ; 11 ; 2.0");
					FillReserves(wep, 1);
					SetActive(client, wep);
				}
				case 8:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					wep = TF2_SpawnWeapon(client, "tf_weapon_bonesaw", 173, 5, 10, "32 ; 1.0 ; 149 ; 5.0 ; 208 ; 1.0 ; 218 ; 1 ; 337 ; 0.25 ; 338 ; 0.25");
					SetActive(client, wep);
				}
				case 9:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					wep = TF2_SpawnWeapon(client, "tf_weapon_minigun", 41, 5, 10, "87 ; 0.75 ; 280 ; 2 ; 642 ; 1 ; 2 ; 3.0 ; 411 ; 4 ; 181 ; 2.0 ; 233 ; 1.25");
					FillReserves(wep, 0);
					SetActive(client, wep);
				}
				/*case 10:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
					SetActive(client, wep);
				}
				case 11:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
					FillReserves(wep);
					SetActive(client, wep);
				}
				case 12:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
					FillReserves(wep);
					SetActive(client, wep);
				}
				case 13:{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
					FillReserves(wep);
					SetActive(client, wep);
				}*/
			}
			SetWeaponAmmo(wep, 2000);
			CPrintToChat(client, "{green}[TBC]{default} Weapon enabled!");
		}
		case MenuAction_End:delete menu;
	}
}

public Action ASpawnWep(int client, int args)
{
	if (!client)
		return Plugin_Handled;
	if (!args)
		AWeaponMenu(client);
	/*if (args == 1)
	{
		char name[32]; GetCmdArg(1, name, sizeof(name));
		if (!strcmp(name, ""))
	}*/
	return Plugin_Handled;
}

public void AWeaponMenu(const int client)
{
	Menu menu = new Menu(AWeapons);
	menu.SetTitle("Weapon List");
	menu.AddItem("0", "The Kink");
	menu.AddItem("1", "Railgun");
	menu.AddItem("2", "Army of One");
	menu.AddItem("3", "Force-a-Hundred-Nature");
	menu.AddItem("4", "Dazzler");
	menu.AddItem("5", "Vertigo");
	menu.AddItem("6", "Accentus");
	menu.AddItem("7", "Auxilium");
	menu.AddItem("8", "Malitia");
	menu.AddItem("9", "Zavetska");
	/*menu.AddItem("10", "");
	menu.AddItem("11", "");
	menu.AddItem("12", "");
	menu.AddItem("13", "");
	menu.AddItem("14", "");
	menu.AddItem("15", "");
	menu.AddItem("16", "");
	menu.AddItem("17", "");
	menu.AddItem("18", "");
	menu.AddItem("19", "");
	menu.AddItem("20", "");*/
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int AWeapons(Menu menu, MenuAction action, int i, int select)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			int wep;
			for (int client = MaxClients; client; --client)
			{
				if (!IsClientInGame(client) || !IsPlayerAlive(client))
					continue;

				switch(select)
				{
					case 0:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
						wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "396 ; 0.4 ; 251 ; 1");
						SetActive(client, wep);
					}
					case 1:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_sniperrifle", 526, 5, 10, "305 ; 1 ; 308 ; 1 ; 309 ; 1 ; 636 ; 1 ; 318 ; 0.01");
						FillReserves(wep, 0);
						SetActive(client, wep);
					}
					case 2:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 5, 10, "3 ; 0.25 ; 104 ; 0.2 ; 101 ; 5.0 ; 2 ; 5.0 ; 37 ; 0.0 ; 99 ; 3.0");
						FillReserves(wep, 0);
						SetActive(client, wep);
					}
					case 3:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_scattergun", 45, 5, 10, "4 ; 50.0 ; 6 ; 0.1 ; 37 ; 0.0");
						FillReserves(wep, 0);
						SetActive(client, wep);
					}
					case 4:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_handgun_scout_primary", 220, 5, 10, "280 ; 18 ; 6 ; 0.2 ; 4 ; 40.0 ; 37 ; 0.0 ; 103 ; 1000.0");
						FillReserves(wep, 0);
						SetActive(client, wep);
					}
					case 5:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_flamethrower", 40, 5, 10, "171 ; 10.0 ; 255 ; 30.0");
						FillReserves(wep, 0);
						SetActive(client, wep);
					}
					case 6:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_compound_bow", 1005, 5, 10, "196 ; 3.0 ; 101 ; 3.0 ; 103 ; 100.0 ; 2 ; 2.0");
						FillReserves(wep, 0);
						SetActive(client, wep);
						SetWeaponAmmo(wep, 25);
					}
					case 7:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_medigun", 411, 5, 10, "7 ; 0.5 ; 9 ; 0.5 ; 14 ; 1 ; 11 ; 2.0");
						FillReserves(wep, 1);
						SetActive(client, wep);
					}
					case 8:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
						wep = TF2_SpawnWeapon(client, "tf_weapon_bonesaw", 173, 5, 10, "32 ; 1.0 ; 149 ; 5.0 ; 208 ; 1.0 ; 218 ; 1 ; 337 ; 0.25 ; 338 ; 0.25");
						SetActive(client, wep);
					}
					case 9:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						wep = TF2_SpawnWeapon(client, "tf_weapon_minigun", 41, 5, 10, "87 ; 0.75 ; 280 ; 2 ; 642 ; 1 ; 2 ; 3.0 ; 411 ; 4 ; 181 ; 2.0 ; 233 ; 1.25");
						FillReserves(wep, 0);
						SetActive(client, wep);
					}
					/*case 10:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
						wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
						SetActive(client, wep);
					}
					case 11:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
						wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
						FillReserves(wep);
						SetActive(client, wep);
					}
					case 12:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
						wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
						FillReserves(wep);
						SetActive(client, wep);
					}
					case 13:{
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
						wep = TF2_SpawnWeapon(client, "tf_weapon_shovel", 447, 5, 10, "");
						FillReserves(wep);
						SetActive(client, wep);
					}*/
				}
				SetWeaponAmmo(wep, 2000);
				CPrintToChat(client, "{green}[TBC]{default} Weapon enabled!");
			}
		}
		case MenuAction_End:delete menu;
	}
}