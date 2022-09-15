#include <tf2attributes>

float flEffect[MAXPLAYERS+1];
float flSheen[MAXPLAYERS+1];

public void OnPluginStart()
{
	RegAdminCmd("sm_addks", AddKs, ADMFLAG_ROOT);

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			OnClientPutInServer(i);

	HookEvent("player_spawn", OnNeedReset);
	HookEvent("post_inventory_application", OnNeedReset);
}

public void OnClientPutInServer(int client)
{
	flEffect[client] = 0.0;
	flSheen[client] = 0.0;
}

public void OnNeedReset(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	CreateTimer(0.2, GetWepsDelayed, client);
}

public Action GetWepsDelayed(Handle timer, any client)
{
	if (flEffect[client] != 0.0 && flSheen[client] != 0.0)
	{
		int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
		int weapon;
		for (int i = 0; i < 6; i++)
		{
			offset += 4;
			weapon = GetEntDataEnt2(client, offset);
			if (weapon == -1)
				continue;
			TF2Attrib_SetByDefIndex(weapon, 2013, flSheen[client]);
			TF2Attrib_SetByDefIndex(weapon, 2014, flEffect[client]);
			TF2Attrib_SetByDefIndex(weapon, 2025, 3.0)
		}
	}
	return Plugin_Continue;
}

public Action AddKs(int client, int args)
{
	if (!args)
	{
		EffectMenu(client);
		return Plugin_Handled;
	}
	if (args == 1)
	{
		char arg[8]; GetCmdArg(1, arg, 8);
		int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
		int weapon;
		float i2 = StringToFloat(arg);
		flEffect[client] = i2;
		for (int i = 0; i < 6; i++)
		{
			offset += 4;
			weapon = GetEntDataEnt2(client, offset);
			if (weapon == -1)
				continue;
			TF2Attrib_SetByDefIndex(weapon, 2013, i2);
		}
		SheenMenu(client);
		return Plugin_Handled;
	}
	if (args == 2)
	{
		char arg[8]; GetCmdArg(1, arg, 8);
		char arg2[8]; GetCmdArg(2, arg2, 8);
		int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
		int weapon;
		float i2 = StringToFloat(arg);
		float i3 = StringToFloat(arg2);
		flEffect[client] = i2;
		flSheen[client] = i3;
		for (int i = 0; i < 6; i++)
		{
			offset += 4;
			weapon = GetEntDataEnt2(client, offset);
			if (weapon == -1)
				continue;

			TF2Attrib_SetByDefIndex(weapon, 2013, i3);
			TF2Attrib_SetByDefIndex(weapon, 2014, i2);
			TF2Attrib_SetByDefIndex(weapon, 2025, 3.0)
		}
		PrintToChat(client, "[SM] Sheen set.");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public void EffectMenu(const int client)
{
	Menu menu = new Menu(HEffectMenu);
	menu.SetTitle("Effect List");
	menu.AddItem("2002", "Fire Horns");
	menu.AddItem("2003", "Cerebral Discharge");
	menu.AddItem("2004", "Tornado");
	menu.AddItem("2005", "Flames");
	menu.AddItem("2006", "Singularity");
	menu.AddItem("2007", "Incinerator");
	menu.AddItem("2008", "Hypno-Beam");
	menu.Display(client, -1);
}

public int HEffectMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char item[8]; menu.GetItem(select, item, 8);
		int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
		int weapon;
		float i2 = StringToFloat(item);
		flEffect[client] = i2;
		for (int i = 0; i < 6; i++)
		{
			offset += 4;
			weapon = GetEntDataEnt2(client, offset);
			if (weapon == -1)
				continue;
			TF2Attrib_SetByDefIndex(weapon, 2013, i2);
		}
		SheenMenu(client);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public void SheenMenu(const int client)
{
	Menu menu = new Menu(HSheenMenu);
	menu.SetTitle("Sheen List");
	menu.AddItem("1", "Team Shine");
	menu.AddItem("2", "Deadly Daffodil");
	menu.AddItem("3", "Manndarin");
	menu.AddItem("4", "Mean Green");
	menu.AddItem("5", "Agonizing Emerald");
	menu.AddItem("6", "Villainous Violet");
	menu.AddItem("7", "Hot Rod");
	menu.Display(client, -1);
}

public int HSheenMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char item[8]; menu.GetItem(select, item, 8);
		int offset = FindDataMapInfo(client, "m_hMyWeapons") - 4;
		int weapon;
		float i2 = StringToFloat(item);
		flSheen[client] = i2;
		for (int i = 0; i < 6; i++)
		{
			offset += 4;
			weapon = GetEntDataEnt2(client, offset);
			if (weapon == -1)
				continue;
			TF2Attrib_SetByDefIndex(weapon, 2014, i2);
			TF2Attrib_SetByDefIndex(weapon, 2025, 3.0)
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}