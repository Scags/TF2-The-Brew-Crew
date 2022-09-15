#pragma semicolon 1
#pragma newdecls required

#include <vsh2>
#include <scag>
#include <vsh2_achievements>

#define PLUGIN_VERSION 	"1.0.0"

public Plugin myinfo =  {
	name = "VSH2 Boss Streaks", 
	author = "Scag", 
	description = "Player winstreak tracker", 
	version = PLUGIN_VERSION, 
	url = ""
};

Database
	hTheDB
;

int
	iStreaks[34],
	iBestStreak[34]
;

bool
	bRegistered[34],
	bLate,
	bAch
;

#define DBPARAMS		Database db, DBResultSet results, const char[] error, any data
#define DECL_ERROR(%1)	if (!results) { LogError(#%1 ... ": %s", error); return; }

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	bLate = late;
}

public void OnPluginStart()
{
	Database.Connect(DBCB_Connect, "vsh2_bossstreaks");
	RegConsoleCmd("sm_moststreaks", MostStreaks);
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		VSH2_Hook(OnRoundEndInfo, fwdOnRoundEndInfo);
		VSH2_Hook(OnActualBossDeath, fwdOnBossDeath);
	}

	if (!strcmp(name, "VSH2Ach", false))
		bAch = true;
}

public void fwdOnRoundEndInfo(const VSH2Player player, bool won, char message[512])
{
	if (VSH2GameMode_GetProperty("iSpecialRound"))
		return;

	if (won && IsPlayerAlive(player.index))
	{
		if (++iStreaks[player.index] >= 3)
			Format(message, sizeof(message), "%s %d win streak!", message, iStreaks[player.index]);

		if (bAch && iStreaks[player.index] >= 20)
			VSH2Ach_AddTo(player.index, A_ProStreak, 1);
	}

	if (iStreaks[player.index] > iBestStreak[player.index])
		iBestStreak[player.index] = iStreaks[player.index];
}

public void fwdOnBossDeath(const VSH2Player player, const VSH2Player attacker, Event event)
{
	if (VSH2GameMode_GetProperty("iRoundState") == StateRunning && !(VSH2GameMode_GetProperty("iSpecialRound")))
	{
		iStreaks[player.index] = 0;
		char query[256];
		FormatEx(query, sizeof(query), "UPDATE vsh2_bossstreaks SET streaks = 0 WHERE steamid = %d", GetSteamAccountID(player.index));
		hTheDB.Query(CCB_Died, query);
	}
}

public void OnClientConnected(int client)
{
	bRegistered[client] = false;
	iStreaks[client] = 0;
	iBestStreak[client] = 0;
}

public void OnClientAuthorized(int client, const char[] id)
{
	if (IsFakeClient(client))
		return;

	if (!hTheDB)
	{
		CreateTimer(3.0, Check4DB, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return;
	}

	char query[256];
	FormatEx(query, sizeof(query), "SELECT * FROM vsh2_bossstreaks WHERE steamid = %d", GetSteamAccountID(client));
	hTheDB.Query(CCB_Connect, query, GetClientUserId(client));
}

public Action Check4DB(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client))
		return Plugin_Continue;

	if (!hTheDB)
	{
		CreateTimer(3.0, Check4DB, userid, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}

	char query[256];
	FormatEx(query, sizeof(query), "SELECT * FROM vsh2_bossstreaks WHERE steamid = %d", GetSteamAccountID(client));
	hTheDB.Query(CCB_Connect, query, GetClientUserId(client));
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client))
		return;

	if (VSH2GameMode_GetProperty("iRoundState") == StateRunning && VSH2Player(client).bIsBoss)
		iStreaks[client] = 0;

	if (!bRegistered[client])
		return;

	char query[256];
	hTheDB.Format(query, sizeof(query), "UPDATE vsh2_bossstreaks SET streaks = %d, beststreak = %d, playername = '%N' WHERE steamid = %d", 
		iStreaks[client], iBestStreak[client], client, GetSteamAccountID(client));
	hTheDB.Query(CCB_Disconnect, query);
}

public int DBCB_Query(DBPARAMS)
{
	DECL_ERROR(DBCB_Query)
}

public int DBCB_Connect(Database db, const char[] error, any data)
{
	if (!db)
	{
		LogError("DBCB_Connect: %s", error);
		return;
	}

	delete hTheDB;
	hTheDB = db;

	db.Query(DBCB_Create, "CREATE TABLE IF NOT EXISTS vsh2_bossstreaks ("
		... "id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,"
		... "steamid INT NOT NULL DEFAULT 0,"
		... "streaks INT NOT NULL DEFAULT 0,"
		... "beststreak INT NOT NULL DEFAULT 0,"
		... "playername VARCHAR(32))");

	if (bLate)for (int i = MaxClients; i; --i)
	{
		if (IsClientConnected(i))
			OnClientConnected(i);
		if (IsClientAuthorized(i))
			OnClientAuthorized(i, "");
	}
	bLate = false;
}

public int DBCB_Create(DBPARAMS)
{
	DECL_ERROR(DBCB_Create)
}

public int CCB_Connect(DBPARAMS)
{
	DECL_ERROR(CCB_Connect)

	int client = GetClientOfUserId(data);
	if (!client)
		return;

	bRegistered[client] = true;

	if (!results.FetchRow())
	{
		char query[256];
		hTheDB.Format(query, sizeof(query), "INSERT INTO vsh2_bossstreaks (steamid, playername) VALUES (%d, '%N')", GetSteamAccountID(client), client);
		hTheDB.Query(CCB_Induct, query);
	}
	else
	{
		iStreaks[client] = results.FetchInt(2);
		iBestStreak[client] = results.FetchInt(3);
	}
}

public int CCB_Induct(DBPARAMS)
{
	DECL_ERROR(CCB_Induct)
}

public int CCB_Disconnect(DBPARAMS)
{
	DECL_ERROR(CCB_Disconnect)
}

public int CCB_Died(DBPARAMS)
{
	DECL_ERROR(CCB_Died)
}

public Action MostStreaks(int client, int args)
{
	Menu menu = new Menu(StreakMenu);
	menu.SetTitle("VSH2 Boss Streaks");
	menu.AddItem("0", "Greatest win streak");
	menu.AddItem("1", "Greatest current win streak");
	menu.Display(client, 0);
	return Plugin_Handled;
}

public int StreakMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[2]; menu.GetItem(select, item, sizeof(item));
			if (!StringToInt(item))
				hTheDB.Query(CCB_Best, "SELECT * FROM vsh2_bossstreaks ORDER BY beststreak DESC LIMIT 10", GetClientUserId(client));
			else hTheDB.Query(CCB_Most, "SELECT * FROM vsh2_bossstreaks ORDER BY streaks DESC LIMIT 10", GetClientUserId(client));
		}
		case MenuAction_End:delete menu;
	}
}

public int CCB_Most(DBPARAMS)
{
	DECL_ERROR(CCB_Most)

	int client = GetClientOfUserId(data);
	if (!client)
		return;
	if (!results.RowCount)
		return;

	Menu menu = new Menu(DelMenu);
	menu.SetTitle("VSH2 Best Current Streaks");
	int streak;
	char name[64];

	while (results.FetchRow())
	{
		streak = results.FetchInt(2);
		if (!streak)
			break;

		results.FetchString(4, name, sizeof(name));
		Format(name, sizeof(name), "%s | %d", name, streak);
		menu.AddItem("", name);
	}

	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public int CCB_Best(DBPARAMS)
{
	DECL_ERROR(CCB_Best)

	int client = GetClientOfUserId(data);
	if (!client)
		return;

	Menu menu = new Menu(DelMenu);
	menu.SetTitle("VSH2 Best Streaks");
	int streak;
	char name[64];
	if (!results.RowCount)
		return;

	while (results.FetchRow())
	{
		streak = results.FetchInt(3);
		if (!streak)
			break;

		results.FetchString(4, name, sizeof(name));
		Format(name, sizeof(name), "%s | %d", name, streak);
		menu.AddItem("", name);
	}

	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public int DelMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
		FakeClientCommandEx(client, "sm_moststreaks");
	else if (action == MenuAction_Cancel)
	{
		if (select == MenuCancel_ExitBack)
			FakeClientCommandEx(client, "sm_moststreaks");
	}
	else if (action == MenuAction_End)
		delete menu;
}