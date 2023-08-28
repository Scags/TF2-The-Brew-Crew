#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <morecolors>
#include <clientprefs>
#include <vsh2>

int RGBA[MAXPLAYERS + 1][4];
int damageTracker[MAXPLAYERS + 1];
float COORDS[MAXPLAYERS+1][2];
Handle damageHUD, ckTracker, ckTrackerrgb, ckTrackerxy;

#define RED	0
#define GREEN	1
#define BLUE	2
#define ALPHA	3

#define X 0
#define Y 1

public Plugin myinfo =  {
	name = "VSH2 dmg tracker", 
	author = "Nergal, all props to Aurora", 
	description = "", 
	version = "1.0", 
	url = "http://uno-gamer.com"
};

public void OnPluginStart()
{
	RegConsoleCmd("haledmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	RegConsoleCmd("vsh2dmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	RegConsoleCmd("ff2dmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	RegConsoleCmd("haledmgxy", Command_damagetrackerxy, "haledmg - Change coordinates the for the damage tracker.");
	RegConsoleCmd("vsh2dmgxy", Command_damagetrackerxy, "haledmg - Change coordinates the for the damage tracker.");
	RegConsoleCmd("ff2dmgxy", Command_damagetrackerxy, "haledmg - Change coordinates the for the damage tracker.");

	damageHUD = CreateHudSynchronizer();
	ckTracker = RegClientCookie("sm_vsh2_tracker", "Damage tracker cookie", CookieAccess_Protected);
	ckTrackerrgb = RegClientCookie("sm_vsh2_tracker_rgb", "Damage tracker cookie RGB values", CookieAccess_Protected);
	ckTrackerxy = RegClientCookie("sm_vsh2_tracker_xy", "Damage tracker cookie coordinates", CookieAccess_Protected);

	for (int i = MaxClients; i; --i)
		if (AreClientCookiesCached(i))
			OnClientCookiesCached(i);
}

public void OnMapStart()
{
	CreateTimer(0.1, Timer_Millisecond, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Command_damagetracker(int client, int args)
{
	if (client == 0) {
		PrintToServer("[VSH 2] The damage tracker cannot be enabled by Console.");
		return Plugin_Handled;
	}
	if (args == 0) {
		char playersetting[4];
		if (damageTracker[client] == 0) playersetting = "Off";
		if (damageTracker[client] > 0) playersetting = "On";

		Menu menu = new Menu(TrackerMenu);
		menu.SetTitle("VSH 2 Damage Tracker\nSelect an item to see its command.");

		char check[32];
		FormatEx(check, sizeof(check), "Current status: %s; Value: %d", playersetting, damageTracker[client]);
		menu.AddItem("0", check);
		FormatEx(check, sizeof(check), "Current RGB: %d,%d,%d", RGBA[client][RED], RGBA[client][GREEN], RGBA[client][BLUE]);
		menu.AddItem("1", check);
		FormatEx(check, sizeof(check), "Current Coordinates: %.2fx%.2f", COORDS[client][X], COORDS[client][Y]);
		menu.AddItem("2", check);
		menu.Display(client, -1);
	}
	else
	{
		char arg1[64];
		int newval;
		GetCmdArg(1, arg1, sizeof(arg1));
		if (StrEqual(arg1,"off",false))
			damageTracker[client] = 0;
		else if (StrEqual(arg1,"on",false))
			damageTracker[client] = 3;
		else if (StrEqual(arg1,"0",false))
			damageTracker[client] = 0;
		else if (StrEqual(arg1,"of",false))
			damageTracker[client] = 0;
		else if (!StrEqual(arg1, "_", false))
		{
			newval = StringToInt(arg1);
			char newsetting[4] = "on";
			if (newval > 7)
				newval = 7;
			if (newval != 0)
				damageTracker[client] = newval;
			if (newval != 0 && damageTracker[client] == 0)
				newsetting = "off";
			if (newval != 0 && damageTracker[client] > 0)
				newsetting = "on";
			CPrintToChat(client, "{olive}[VSH 2]{default} The damage tracker is now {lightgreen}%s{default}!", newsetting);
		}
		char r[4], g[4], b[4], a[4];
		
		if(args >= 2) {
			GetCmdArg(2, r, sizeof(r));
			if(!StrEqual(r, "_"))
				RGBA[client][RED] = StringToInt(r);
		}
		
		if(args >= 3) {
			GetCmdArg(3, g, sizeof(g));
			if(!StrEqual(g, "_"))
				RGBA[client][GREEN] = StringToInt(g);
		}
		
		if(args >= 4) {
			GetCmdArg(4, b, sizeof(b));
			if(!StrEqual(b, "_"))
				RGBA[client][BLUE] = StringToInt(b);
		}
		
		if(args >= 5) {
			GetCmdArg(5, a, sizeof(a));
			if(!StrEqual(a, "_"))
				RGBA[client][ALPHA] = StringToInt(a);
		}
	}
	if (damageTracker[client] > 7)
		damageTracker[client = 7];

	char rgba[32]; Format(rgba, sizeof(rgba), "%d,%d,%d,%d", RGBA[client][RED], RGBA[client][GREEN], RGBA[client][BLUE], RGBA[client][ALPHA]);
	SetClientCookie(client, ckTrackerrgb, rgba);
	char ck[4];
	IntToString(damageTracker[client], ck, 4);
	SetClientCookie(client, ckTracker, ck);
	return Plugin_Handled;
}

public Action Command_damagetrackerxy(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	if (!args)
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Current Tracker Coordinates are {lightgreen}%0.2fx%0.2f{default}.", COORDS[client][X], COORDS[client][Y]);
		return Plugin_Handled;
	}

	char arg[16]; GetCmdArg(1, arg, sizeof(arg));
	float val = StringToFloat(arg);
	if (val < 0.0 && val != -1.0) val = 0.0;
	if (val > 1.0) val = 1.0;
	COORDS[client][X] = StringToFloat(arg);

	if (args == 2)
	{
		GetCmdArg(2, arg, sizeof(arg));
		if (val < 0.0 && val != -1.0) val = 0.0;
		if (val > 1.0) val = 1.0;
		COORDS[client][Y] = StringToFloat(arg);
	}

	CPrintToChat(client, "{olive}[VSH 2]{default} Current Tracker Coordinates are now {lightgreen}%0.2fx%0.2f{default}.", COORDS[client][X], COORDS[client][Y]);
	FormatEx(arg, sizeof(arg), "%0.2f,%0.2f", COORDS[client][X], COORDS[client][Y]);
	SetClientCookie(client, ckTrackerxy, arg);
	return Plugin_Handled;
}

public int TrackerMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char val[4]; menu.GetItem(select, val, sizeof(val));
			char s[128];
			switch (StringToInt(val))
			{
				case 0:s = "{unique}/haledmg <on/off/n>{default} where {unique}n{default} is the number of players to track.";
				case 1:s = "{unique}/haledmg <on/off/n> R G B{default}.";
				case 2:s = "{unique}/haledmgxy X Y{default} where {unique}X{default} and {unique}Y{default} are coordinates between 0 and 1.0 (inclusive).";
			}
			CPrintToChat(client, "{olive}[VSH 2]{default} Usage: %s", s);
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public void OnClientCookiesCached(int client)
{
	char ck[32];
	GetClientCookie(client, ckTracker, ck, 4);
	damageTracker[client] = StringToInt(ck);

	GetClientCookie(client, ckTrackerrgb, ck, 32);
	if (ck[0] == '\0')
	{
		strcopy(ck, sizeof(ck), "255,90,30,255");
		SetClientCookie(client, ckTrackerrgb, ck);
	}
	char rgb[4][8];

	ExplodeString(ck, ",", rgb, 4, 4);
	RGBA[client][RED] = StringToInt(rgb[0]);
	RGBA[client][GREEN] = StringToInt(rgb[1]);
	RGBA[client][BLUE] = StringToInt(rgb[2]);
	RGBA[client][ALPHA] = StringToInt(rgb[3]);

	GetClientCookie(client, ckTrackerxy, ck, 32);
	if (ck[0] == '\0')
	{
		strcopy(ck, sizeof(ck), "0.0,0.1");
		SetClientCookie(client, ckTrackerxy, ck);
	}

	ExplodeString(ck, ",", rgb, 2, 8);
	COORDS[client][X] = StringToFloat(rgb[0]);
	COORDS[client][Y] = StringToFloat(rgb[1]);
}

public Action Timer_Millisecond(Handle timer)
{
	int i;

	VSH2Player hTop[8];

	VSH2Player(0).iDamage = 0;
	VSH2Player player;
	int damage;
	for (i = MaxClients; i; --i) {
		if (!IsClientInGame(i))
			continue;

		if (GetClientTeam(i) < 2)
			continue;

		player = VSH2Player(i);
		if (player.bIsBoss)
			continue;

		damage = player.iDamage;
		if (!damage)
			continue;

		if (damage >= hTop[0].iDamage) {
			hTop[7] = hTop[6];
			hTop[6] = hTop[5];
			hTop[5] = hTop[4];
			hTop[4] = hTop[3];
			hTop[3] = hTop[2];
			hTop[2] = hTop[1];
			hTop[1] = hTop[0];
			hTop[0] = player;
		}
		else if (damage >= hTop[1].iDamage) {
			hTop[7] = hTop[6];
			hTop[6] = hTop[5];
			hTop[5] = hTop[4];
			hTop[4] = hTop[3];
			hTop[3] = hTop[2];
			hTop[2] = hTop[1];
			hTop[1] = player;
		}
		else if (damage >= hTop[2].iDamage) {
			hTop[7] = hTop[6];
			hTop[6] = hTop[5];
			hTop[5] = hTop[4];
			hTop[4] = hTop[3];
			hTop[3] = hTop[2];
			hTop[2] = player;
		}
		else if (damage >= hTop[3].iDamage) {
			hTop[7] = hTop[6];
			hTop[6] = hTop[5];
			hTop[5] = hTop[4];
			hTop[4] = hTop[3];
			hTop[3] = player;
		}
		else if (damage >= hTop[4].iDamage) {
			hTop[7] = hTop[6];
			hTop[6] = hTop[5];
			hTop[5] = hTop[4];
			hTop[4] = player;
		}
		else if (damage >= hTop[5].iDamage) {
			hTop[7] = hTop[6];
			hTop[6] = hTop[5];
			hTop[5] = player;
		}
		else if (damage >= hTop[6].iDamage) {
			hTop[7] = hTop[6];
			hTop[6] = player;
		}
		else if (damage >= hTop[7].iDamage) {
			hTop[7] = player;
		}
	}

	char send[256];
	int u;
	for (int z = MaxClients; z; --z) {
		if (!IsClientInGame(z) || IsFakeClient(z))
			continue;

		if (damageTracker[z] > 0)
		{
			if (!(GetClientButtons(z) & IN_SCORE))
			{
				send[0] = '\0';
				SetHudTextParams(COORDS[z][X], COORDS[z][Y], 0.2, RGBA[z][RED], RGBA[z][GREEN], RGBA[z][BLUE], 255);
				for (u = 0; u < damageTracker[z]; ++u)
				{
					if (IsValidClient(hTop[u].index))
						Format(send, sizeof(send), "%s[%d] %N - %d\n", send, u+1, hTop[u].index, hTop[u].iDamage);
					else Format(send, sizeof(send), "%s[%d] N/A - 0\n", send, u+1);
				}

				ShowSyncHudText(z, damageHUD, "%s", send);
			}
		}
	}
	return Plugin_Handled;
}

stock bool IsValidClient(const int client, bool nobots = false)
{
	if (client <= 0 || client > MaxClients || (nobots && IsFakeClient(client)))
		return false;
	return IsClientInGame(client);
} 