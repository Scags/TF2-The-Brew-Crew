#include <sdktools>
#include <sdkhooks>
#include <tbc>
#include <morecolors>
#include <tf2_stocks>
#include <tbc_stats>

#undef REQUIRE_PLUGIN
#include <vsh2>

Database
	hTheDB
;

bool
	bRegistered[MAXPLAYERS+1],
	bPlayed[MAXPLAYERS+1],
	bEnabled,
	bVSH2
;

int
//	iGimgims[MAXPLAYERS+1],
//	iGimgimsMonthly[MAXPLAYERS+1],
	iId[MAXPLAYERS+1],
	iPlayTime[MAXPLAYERS+1]
;

int iGivenBounty[MAXPLAYERS+1][MAXPLAYERS+1];
int iBounty[MAXPLAYERS+1];

float
	flCmdTime[MAXPLAYERS+1]
;

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int max)
{
	CreateNative("TBC_GiveCredits", Native_GiveCredits);
	RegPluginLibrary("tbc_stats");
	return APLRes_Success;
}

public void OnPluginStart()
{
	for (int i = MaxClients; i; --i)
		if (IsClientConnected(i))
			OnClientConnected(i);

	LoadTranslations("common.phrases");

	RegConsoleCmd("sm_stats", CmdStats);
	RegConsoleCmd("sm_top10", CmdTop);
	RegConsoleCmd("sm_top", CmdTop);
	RegConsoleCmd("sm_top10m", CmdTopM);
	RegConsoleCmd("sm_topm", CmdTopM);
	RegConsoleCmd("sm_gimgims", CmdGimgims);
	RegConsoleCmd("sm_rank", CmdRank);
//	RegConsoleCmd("sm_bounty", AddBounty);

	HookEvent("player_death", 			 	OnPlayerDeath);
//	HookEvent("object_destroyed", 			OnObjectDestroyed);
//	HookEvent("player_builtobject", 	 	OnPlayerBuiltObject);
//	HookEvent("teamplay_round_win",    		OnRoundEnd);
	HookEvent("arena_round_start", 			OnArenaRoundStart);
//	HookEvent("player_teleported",       	OnPlayerTeleported);
//	HookEvent("object_deflected", 			OnObjectDeflected);
//	HookEvent("player_stunned",          	OnStunned);
//	HookEvent("deploy_buff_banner",      	OnDeployBuffBanner);
//	HookEvent("player_chargedeployed", 		OnUbercharge);
	
//	HookUserMessage(GetUserMessageId("PlayerJarated"),       OnJarated);
//	HookUserMessage(GetUserMessageId("PlayerExtinguished"),  OnExtinguish);

	Database.Connect(DBCB_Connect, "tbc_stats");
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", false))
		bVSH2 = true;
}

public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "VSH2", false))
		bVSH2 = false;	
}

public void OnMapStart()
{
	CreateTimer(60.0, Timer_Playtime, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(180.0, Timer_GiveGimgim, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
//	CreateTimer(600.0, Timer_Fuck, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnGameFrame()
{
	int count = GetClientCount();
	if (count >= 8 && !bEnabled)
	{
		bEnabled = true;
		CPrintToChatAll(TBC_TAG ... "Gimgim gaining has been reenabled due to player count.");
	}
	else if (count < 8 && bEnabled)
	{
		bEnabled = false;
		CPrintToChatAll(TBC_TAG ... "Gimgim gaining has been disabled due to player count.");		
	}
}

public Action Timer_Playtime(Handle timer)
{
	if (!bEnabled)
		return Plugin_Continue;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !bRegistered[i])
			continue;

		++iPlayTime[i];
	}
	return Plugin_Continue;
}

public Action Timer_GiveGimgim(Handle timer)
{
	if (!bEnabled)
		return Plugin_Continue;

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !bRegistered[i])
			continue;

		if (GetClientTeam(i) <= 1)
			continue;

		AddGims(i, 6);
		CPrintToChat(i, TBC_TAG ... "You just gained {unique}6{default} Gimgims!");
	}
	return Plugin_Continue;
}

public void OnClientConnected(int client)
{
	bRegistered[client] = false;
	iId[client] = 0;
	bPlayed[client] = false;
	flCmdTime[client] = 0.0;
	iPlayTime[client] = 0;

	iBounty[client] = 0;
	for (int i = MaxClients; i; --i)
	{
		iGivenBounty[client][i] = 0;
		iGivenBounty[i][client] = 0;
	}
}

public void OnClientDisconnect(int client)
{
	if (!bRegistered[client])
		return;

//	int id = iId[client];
//
//	DataPack pack = new DataPack();
//	pack.WriteCell(id);
//	pack.WriteCell(iGimgims[client]);
//
//	pack.WriteString(name);
//	pack.WriteString("tbc_stats");
//
//	FormatEx(query, sizeof(query), "SELECT gimgims FROM tbc_stats WHERE authid = %d", id);
//	hTheDB.Query(CCB_Update, query, pack);
//
//	pack = new DataPack();
//	pack.WriteCell(id);
//	pack.WriteCell(iGimgimsMonthly[client]);
//	pack.WriteString(name);
//	pack.WriteString("tbc_stats_monthly");
//
//	ReplaceStringEx(query, sizeof(query), "tbc_stats", "tbc_stats_monthly");
//	hTheDB.Query(CCB_Update, query, pack);

	char query[256];

	hTheDB.Format(query, sizeof(query), "UPDATE tbc_playtime SET playtime = playtime + %d, last_played = %d, playername = '%N' WHERE authid = %d", 
		iPlayTime[client], GetTime(), client, iId[client]);
	hTheDB.Query(CCB_Updated, query);
}

public void OnPluginEnd()
{
	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			OnClientDisconnect(i);
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if (IsFakeClient(client) || bRegistered[client])
		return;

	iId[client] = GetSteamAccountID(client);
	if (!hTheDB)
	{
		CreateTimer(5.0, Timer_CheckAgain, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return;
	}
	char query[256];

	Transaction txn = new Transaction();
	int id = iId[client];

	FormatEx(query, sizeof(query), "SELECT gimgims FROM tbc_stats WHERE authid = %d", id);
	txn.AddQuery(query);

	ReplaceStringEx(query, sizeof(query), "tbc_stats", "tbc_stats_monthly");
	txn.AddQuery(query);

	FormatEx(query, sizeof(query), "SELECT 1 + COUNT(*) AS rank FROM tbc_stats WHERE gimgims > (SELECT gimgims FROM tbc_stats WHERE authid = %d)", id);
	txn.AddQuery(query);

	ReplaceString(query, sizeof(query), "tbc_stats", "tbc_stats_monthly");
	txn.AddQuery(query);

	FormatEx(query, sizeof(query), "SELECT * FROM tbc_playtime WHERE authid = %d", id);
	txn.AddQuery(query);

	hTheDB.Execute(txn, CCB_Connect_Success, CCB_Connect_Failure, GetClientUserId(client));
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client))
		return;

	char query[256];
	FormatEx(query, sizeof(query), "UPDATE tbc_stats_monthly SET isdonor = %d WHERE authid = %d", CheckCommandAccess(client, "sm_donor", ADMFLAG_RESERVATION, true), GetSteamAccountID(client));
	hTheDB.Query(CCB_Updated, query);
}

public Action Timer_CheckAgain(Handle timer, any data)
{
	int client = GetClientOfUserId(data);
	if (client)
		OnClientAuthorized(client, "");
	return Plugin_Continue;
}

public int DBCB_Connect(Database db, const char[] error, any data)
{
	if (db == null)
	{
		LogError("DBCB_Connect: %s", error);
		return 0;
	}

	delete hTheDB;

	hTheDB = db;

	db.Query(DBCB_Query, "CREATE TABLE IF NOT EXISTS tbc_stats (id INT(64) NOT NULL AUTO_INCREMENT, playername VARCHAR(32), authid INT(32), gimgims INT(32), PRIMARY KEY(id))");
	db.Query(DBCB_Query, "CREATE TABLE IF NOT EXISTS tbc_stats_monthly (id INT(64) NOT NULL AUTO_INCREMENT, playername VARCHAR(32), authid INT(32), gimgims INT(32), isdonor TINYINT NOT NULL DEFAULT 0, PRIMARY KEY(id))");
	db.Query(DBCB_Query, "CREATE TABLE IF NOT EXISTS tbc_playtime (id INT(64) NOT NULL AUTO_INCREMENT, playername VARCHAR(32), authid INT(32), playtime INT(32) NOT NULL, first_played INT(32), last_played INT(32), PRIMARY KEY(id))");

	for (int i = MaxClients; i; --i)
		if (IsClientAuthorized(i))
		{
			OnClientAuthorized(i, "");
			OnClientPostAdminCheck(i);
		}
	return 0;
}

public int DBCB_Query(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("DBCB_Query: %s", error);
	return 0;
}

public void CCB_Connect_Success(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	int client = GetClientOfUserId(data);
	if (!client)
		return;

	char query[256];
	int rank, rankmonthly, gimgims, gimgimsmonthly;
	if (results[0].FetchRow() && results[0].RowCount)
		gimgims = results[0].FetchInt(0);
	else
	{
		hTheDB.Format(query, sizeof(query), "INSERT INTO tbc_stats (playername, authid, gimgims) VALUES ('%N', %d, 0)", client, iId[client])
		hTheDB.Query(CCB_Updated, query);
		rank = -1;
	}

	if (results[1].FetchRow() && results[1].RowCount)
		gimgimsmonthly = results[1].FetchInt(0);
	else
	{
		hTheDB.Format(query, sizeof(query), "INSERT INTO tbc_stats_monthly (playername, authid, gimgims) VALUES ('%N', %d, 0)", client, iId[client])
		hTheDB.Query(CCB_Updated, query);
		rankmonthly = -1;
	}

	if (rank != -1 && results[2].FetchRow() && results[2].RowCount)
		rank = results[2].FetchInt(0);

	if (rankmonthly != -1 && results[3].FetchRow() && results[3].RowCount)
		rankmonthly = results[3].FetchInt(0);

	if (results[4].FetchRow() && results[4].RowCount)
		hTheDB.Format(query, sizeof(query), "UPDATE tbc_playtime SET playername = '%N', last_played = %d WHERE authid = %d", client, GetTime(), iId[client]);
	else hTheDB.Format(query, sizeof(query), "INSERT INTO tbc_playtime (playername, authid, first_played, playtime, last_played) VALUES ('%N', %d, %d, 0, %d)", client, iId[client], GetTime(), GetTime());

	hTheDB.Query(CCB_Updated, query);

	char id[32]; GetClientAuthId(client, AuthId_Steam2, id, sizeof(id));
	FormatEx(query, sizeof(query), "{lawngreen}%N{default} ({palegreen}%s{default}) Connected.", client, id);

	if (rank > 0)
		Format(query, sizeof(query), "%s Rank {green}%d{default} with {lawngreen}%d{default} Gimgims.", query, rank, gimgims);
	if (rankmonthly > 0)
		Format(query, sizeof(query), "%s Monthly Rank {green}%d{default} with {lawngreen}%d{default} Gimgims.", query, rankmonthly, gimgimsmonthly);

	CPrintToChatAll("%s", query);
	bRegistered[client] = true;
}

public void CCB_Connect_Failure(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("CCB_Connect_Failure (%d): %s", failIndex, error);
}

public void CCB_Rank_Fail(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("CCB_Rank_Failure (%d): %s", failIndex, error);
}

public int CCB_Update(Database db, DBResultSet results, const char[] error, DataPack pack)
{
	pack.Reset();
	if (!results)
	{
		delete pack;
		LogError("CCB_Update: %s", error);
		return 0;
	}

	int id = pack.ReadCell();
	int gimgims = pack.ReadCell();
	char name[32];
	pack.ReadString(name, sizeof(name));
	char table[32];
	pack.ReadString(table, sizeof(table));

	delete pack;

	char query[256];
	if (results.FetchRow() && results.RowCount)
		hTheDB.Format(query, sizeof(query), "UPDATE %s SET gimgims = %d, playername = '%s' WHERE authid = %d", table, gimgims, name, id);
	else hTheDB.Format(query, sizeof(query), "INSERT INTO %s (playername, authid, gimgims) VALUES ('%s', %d, %d)", table, name, id, gimgims);

	hTheDB.Query(CCB_Updated, query);
	return 0;
}

public int CCB_Updated(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("CCB_Updated: %s", error);
	return 0;
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled)
		return;

	int death_flags = event.GetInt("death_flags");
	if (death_flags & TF_DEATHFLAG_DEADRINGER)
		return;

	if (event.GetBool("sourcemod"))
		return;

	if (bVSH2 && VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim   = GetClientOfUserId(event.GetInt("userid"));

//	int sub = 4;
	if (0 < attacker <= MaxClients)
	{
		if (attacker != victim)
		{
			if (VSH2GameMode_GetProperty("iSpecialRound") & ROUND_SURVIVAL)
				return;

			AddGims(attacker, 1);
			CPrintToChat(attacker, TBC_TAG ... "You gained {unique}1{default} Gimgim for killing {unique}%N{default}.", victim);

			int total;
			for (int i = MaxClients; i; --i)
			{
				total += iGivenBounty[i][victim];
				iGivenBounty[i][victim] = 0;
			}
			if (total)
			{
				AddGims(attacker, total);
				CPrintToChatAll(TBC_TAG ... "{olive}%N{default} claimed the {lightgreen}%d{default} Gimgim bounty on {olive}%N{default}.", attacker, total, victim);
			}
		}
	}
}
public void OnObjectDestroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled)
		return;

//	int obj = event.GetInt("index");
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));

	TFObjectType type = view_as< TFObjectType >(event.GetInt("objecttype"));
	char buffer[16];
	switch (type)
	{
		case TFObject_Sentry:
			buffer = "Sentry";
		case TFObject_Dispenser:
			buffer = "Dispenser";
		case TFObject_Teleporter:
			buffer = "Teleporter";
	}
	if (0 < attacker <= MaxClients && attacker != victim)
	{
		AddGims(attacker, 3);
		CPrintToChat(attacker, TBC_TAG ... "You gained {unique}3{default} Gimgims for destroying a %s.", buffer);
	}
}
public void OnArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	int count;
	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			++count;
			bPlayed[i] = true;
		}
	}

	if (count < 8)
	{
		CPrintToChatAll(TBC_TAG ... "{unique}Warning: Stats are disabled due to low player count.");
		bEnabled = false;
	} 
	else bEnabled = true;
}
public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled)
		return;
	int team = event.GetInt("team");
	int add = 8;
	VSH2Player player;
	for (int i = MaxClients; i; --i)
	{
		add = 8;
		if (IsClientInGame(i) && bPlayed[i] && GetClientTeam(i) == team)
		{
			if (bVSH2)
			{
				player = VSH2Player(i);
				if (player.bIsBoss)
				{
					int diff = player.iDifficulty;
					if (!diff)
						diff = 1;
					else if (diff <= -1)
						diff = 2;

					add *= diff;
				}
				else if (player.bIsMinion)
					continue;
			}

			AddGims(i, add);
			CPrintToChat(i, TBC_TAG ... "You gained {unique}%d{default} Gimgims for winning.", add);
		}
		bPlayed[i] = false;
	}
}
public void OnPlayerTeleported(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled)
		return;
	int client = GetClientOfUserId(event.GetInt("userid"));
	int builder = GetClientOfUserId(event.GetInt("builderid"));
	if (client != builder)
	{
		AddGims(builder, 2);
		CPrintToChat(builder, TBC_TAG ... "You gained {unique}2{default} Gimgims for teleporting {unique}%N{default}.", client);
	}
}

stock void AddGims(int client, int gims)
{
	if (!bRegistered[client])
		return;

	char query[512];
	hTheDB.Format(query, sizeof(query), 
			"UPDATE tbc_stats AS t1, tbc_stats_monthly AS t2 "
		...	"SET t1.gimgims = t1.gimgims + %d, t1.playername = '%N', t2.gimgims = t2.gimgims + %d, t2.playername = '%N' "
		...	"WHERE t1.authid = %d AND t2.authid = t1.authid;",
			gims, client, gims, client, iId[client]);
	hTheDB.Query(CCB_Updated, query);
//	iGimgims[client] += gims;
//	iGimgimsMonthly[client] += gims;
}

public Action CmdStats(int client, int args)
{
	Menu menu = new Menu(StatsMenu);
	menu.SetTitle("[TBC] Stats");
	menu.AddItem("0", "View your stats");
	menu.AddItem("1", "View the Top 10 monthly players");
	menu.AddItem("2", "View the Top 10 overall players");
	menu.Display(client, 0);
	return Plugin_Handled;
}

public int StatsMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[4]; menu.GetItem(select, item, sizeof(item));
			switch (StringToInt(item))
			{
				case 0:FakeClientCommandEx(client, "sm_rank");
				case 1:FakeClientCommandEx(client, "sm_top10m");
				case 2:FakeClientCommandEx(client, "sm_top10");
			}
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}
public Action CmdTop(int client, int args)
{
	if (flCmdTime[client] > GetGameTime())
	{
		CPrintToChat(client, TBC_TAG ... "Please wait before issuing more stat commands.");
		return Plugin_Handled;
	}

	hTheDB.Query(CCB_Top, "SELECT playername, gimgims FROM tbc_stats ORDER BY gimgims DESC LIMIT 10", GetClientUserId(client));
	flCmdTime[client] = GetGameTime()+3.0;
	return Plugin_Handled;
}
public Action CmdTopM(int client, int args)
{
	if (flCmdTime[client] > GetGameTime())
	{
		CPrintToChat(client, TBC_TAG ... "Please wait before issuing more stat commands.");
		return Plugin_Handled;
	}

	hTheDB.Query(CCB_TopM, "SELECT playername, gimgims FROM tbc_stats_monthly ORDER BY gimgims DESC LIMIT 10", GetClientUserId(client));
	flCmdTime[client] = GetGameTime()+3.0;
	return Plugin_Handled;
}
public Action CmdGimgims(int client, int args)
{
	if (!bRegistered[client])
		return Plugin_Handled;

	if (flCmdTime[client] > GetGameTime())
	{
		CPrintToChat(client, TBC_TAG ... "Please wait before issuing more stat commands.");
		return Plugin_Handled;
	}

	char query[256];
	FormatEx(query, sizeof(query), 
			"SELECT gimgims FROM tbc_stats WHERE authid = %d "
		... "UNION "
		... "SELECT gimgims FROM tbc_stats_monthly WHERE authid = %d", iId[client], iId[client]);

	hTheDB.Query(CCB_CmdGimgims, query, GetClientUserId(client));

	flCmdTime[client] = GetGameTime() + 2.0;

	return Plugin_Handled;
}
public int CCB_CmdGimgims(Database db, DBResultSet results, char[] error, any data)
{
	if (!results)
	{
		LogError("CCB_CmdGimgims: %s", error);
		return 0;
	}

	int client = GetClientOfUserId(data);
	if (!client)
		return 0;

	if (results.FetchRow() && results.RowCount)
	{
		int gimgims = results.FetchInt(0);
		if (results.FetchRow())
		{
			int gimgimsmonthly = results.FetchInt(0);
			Panel panel = new Panel();
			char buffer[128];
			FormatEx(buffer, sizeof(buffer), "This month's Gimgims: %d\nTotal Gimgims: %d", gimgimsmonthly, gimgims);

			panel.SetTitle(buffer);
			panel.DrawItem("Exit");
			panel.Send(client, PanelPanel, 9001);

			delete panel;
		}
	}
	return 0;
}
public Action CmdRank(int client, int args)
{
	if (flCmdTime[client] > GetGameTime())
	{
		CPrintToChat(client, TBC_TAG ... "Please wait before issuing more stat commands.");
		return Plugin_Handled;
	}

	char buffer[512];
	FormatEx(buffer, sizeof(buffer), 
			"SELECT "
		...		"(SELECT 1 + COUNT(*) AS rank FROM scag_stats.tbc_stats WHERE gimgims > ("
		...			"SELECT gimgims FROM scag_stats.tbc_stats WHERE authid = %d)) as t1,"
        ...		"(SELECT 1 + COUNT(*) AS rank FROM scag_stats.tbc_stats_monthly WHERE gimgims > ("
		...			"SELECT gimgims FROM scag_stats.tbc_stats_monthly WHERE authid = %d)) as t2",
		iId[client], iId[client]);


	hTheDB.Query(CCB_Rank, buffer, GetClientUserId(client));
	flCmdTime[client] = GetGameTime()+3.0;
	return Plugin_Handled;
}

public int CCB_Top(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
	{
		LogError("CCB_Top: %s", error);
		return 0;
	}

	int client = GetClientOfUserId(data);
	if (!client)
		return 0;

	Menu menu = new Menu(Top10Menu);
	menu.SetTitle("[TBC] Overall Top 10");

	char buffer[64];
	char name[32];
	int gims;
	while (results.FetchRow())
	{
		results.FetchString(0, name, sizeof(name));
		gims = results.FetchInt(1);

		FormatEx(buffer, sizeof(buffer), "%s | %d Gimgims", name, gims);
		menu.AddItem("", buffer);
	}

	menu.ExitBackButton = true;
	menu.Display(client, 0);
	return 0;
}

public int Top10Menu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{

		}
		case MenuAction_Cancel:
			if (select == MenuCancel_ExitBack)
				FakeClientCommandEx(client, "sm_top10");
		case MenuAction_End:delete menu;
	}
	return 0;
}

public int CCB_TopM(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
	{
		LogError("CCB_TopM: %s", error);
		return 0;
	}

	int client = GetClientOfUserId(data);
	if (!client)
		return 0;

	Menu menu = new Menu(Top10MMenu);
	menu.SetTitle("[TBC] Monthly Top 10");

	char buffer[64];
	char name[32];
	int gims;
	while (results.FetchRow())
	{
		results.FetchString(0, name, sizeof(name));
		gims = results.FetchInt(1);

		FormatEx(buffer, sizeof(buffer), "%s | %d Gimgims", name, gims);
		menu.AddItem("", buffer);
	}

	menu.ExitBackButton = true;
	menu.Display(client, 0);
	return 0;
}

public int Top10MMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{

		}
		case MenuAction_Cancel:
			if (select == MenuCancel_ExitBack)
				FakeClientCommandEx(client, "sm_top10m");
		case MenuAction_End:delete menu;
	}
	return 0;
}

public void CCB_Rank(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
	{
		LogError("CCB_Rank: %s", error);
		return;
	}

	int client = GetClientOfUserId(data);
	if (!client)
		return;

	if (results.FetchRow() && results.RowCount)
	{
		Panel panel = new Panel();
		char buffer[128];
		FormatEx(buffer, sizeof(buffer), "Monthly Rank: %d\nOverall Rank: %d", 
			results.FetchInt(1), results.FetchInt(0));
		panel.SetTitle(buffer);
		panel.DrawItem("Exit");

		panel.Send(client, PanelPanel, 9001);
		delete panel;
	}
}

#if 0

stock void AddBounty(int client, int args)
{
	if (!bRegistered[client])
		return Plugin_Handled;

	if (flCmdTime[client] > GetGameTime())
	{
		CReplyToCommand(client, TBC_TAG ... "Please wait before issuing more bounty commands.");
		return Plugin_Handled;
	}

	if (!args)
	{
		BountyMenu(client);
		return Plugin_Handled;
	}
	if (args == 1)
	{
		CReplyToCommand(client, TBC_TAG ... "Usage: sm_bounty <client> <amount>.");
		return Plugin_Handled;
	}

	char arg2[32]; GetCmdArg(2, arg2, 32);
	char arg[32]; GetCmdArg(1, arg, 32);
	char clientName[32];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;
	
	int target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_IMMUNITY, clientName, sizeof(clientName), tn_is_ml);
	
	if (target_count != 1)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	int amount = StringToInt(arg2);

	if (amount <= 0)
	{
		CPrintToChat(client, TBC_TAG ... "Invalid amount specified.");
		return Plugin_Handled;
	}

	if (iGimgims[client] < amount)
	{
		CPrintToChat(client, TBC_TAG ... "You don't have enough Gimgims!");
		return Plugin_Handled;
	}
	if (iGimgimsMonthly[client] < amount)
	{
		CPrintToChat(client, TBC_TAG ... "You don't have enough Gimgims for this month!");
		return Plugin_Handled;			
	}

	flCmdTime[client] = GetGameTime()+3.0;
	CreateBounty(target_list[0], client, amount);
	iBounty[client] = 0;

	return Plugin_Handled;
}

public void CreateBounty(const int target, const int client, const int amount)
{
	if (amount <= 0 || GetSteamAccountID(client) == 0)
		return;

	iGivenBounty[client][target] += amount;
	int total;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		total += iGivenBounty[i][target];
	}
	CPrintToChatAll(TBC_TAG ... "{unique}%N{default} has placed a {unique}%d{default} Gimgim bounty on {unique}%N{default} for a total of {unique}%d{default} Gimgims.",
					client, amount, target, total);
	AddGims(client, -amount);
}

public void BountyMenu(const int client)
{
	Menu menu = new Menu(HBountyMenu);
	menu.SetTitle("Select a player to place a bounty on");
	char id[8]; char name[32];
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		IntToString(GetClientUserId(i), id, sizeof(id));
		GetClientName(i, name, sizeof(name));
		menu.AddItem(id, name);
	}
	menu.Display(client, -1);
}

public int HBountyMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char item[8]; menu.GetItem(select, item, 8);
		int target = GetClientOfUserId(StringToInt(item));
		if (!target || !IsClientInGame(target) || !IsPlayerAlive(target))
		{
			CPrintToChat(client, TBC_TAG ... "Could not target player.");
			BountyMenu(client);
			return;
		}

		iBounty[client] = GetClientUserId(target);
		CPrintToChat(client, TBC_TAG ... "Type in chat how many Gimgims you would like to place in the bounty of {unique}%N{default}.", target);
	}
	else if (action == MenuAction_End)
		delete menu;
	return 0;
}

stock Action OnClientSayCommand_NO(int client, const char[] command, const char[] sArgs)
{
	if (iBounty[client])
	{
		iBounty[client] = 0;

		int amount = StringToInt(sArgs);
		if (amount <= 0)
		{
			CPrintToChat(client, TBC_TAG ... "Invalid amount specified.");
			return Plugin_Handled;
		}

		if (iGimgims[client] < amount)
		{
			CPrintToChat(client, TBC_TAG ... "You don't have enough Gimgims!");
			return Plugin_Handled;
		}
		if (iGimgimsMonthly[client] < amount)
		{
			CPrintToChat(client, TBC_TAG ... "You don't have enough Gimgims for this month!");
			return Plugin_Handled;
		}

		int target = GetClientOfUserId(iBounty[client]);

		if (!target)
		{
			CPrintToChat(client, TBC_TAG ... "Target is no longer valid.");
			return Plugin_Handled;			
		}

		CreateBounty(target, client, amount);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
#endif

public int Native_GiveCredits(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int amount = GetNativeCell(2);

	if (!(0 < client <= MaxClients) || !IsClientInGame(client))
		return 0;

	if (!bRegistered[client])
	{
		LogError("Client %d (%N) is not registered!", client, client);
		return 0;
	}

	AddGims(client, amount);
	return 0;
}

public int PanelPanel(Menu menu, MenuAction action, int client, int select)
{
	return 0;
}