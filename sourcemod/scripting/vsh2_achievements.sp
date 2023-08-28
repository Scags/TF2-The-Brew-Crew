#include <sourcemod>
#include <tf2_stocks>
#include <tf2items>
#include <morecolors>
#include <vsh2>
#include <vsh2_achievements>
#include <tbc>

#undef REQUIRE_PLUGIN
#include <tbc_stats>
#define REQUIRE_PLUGIN

#pragma semicolon			1
#pragma newdecls			required

#define PLUGIN_VERSION			"1.0.0"
#define ACHIEVEMENT_SOUND "misc/achievement_earned.wav"
#define ACHIEVEMENT_PARTICLE "Achieved"

public Plugin myinfo =  {
	name = "VSH2 Achievements",
	author = "Scag/Ragenewb", 
	description = "Achievements for VSH2", 
	version = PLUGIN_VERSION, 
	url = ""
};

Database
	hTheDB
;

ArrayList
	hAchievements
;

bool
	bConnected[34]
;

static const char strAchNames[MAX_ACHIEVEMENTS][] = {
	"Close Call",
	"Big Stun",
	"Ova 9000",
	"Soloer",
	"Invincible",
	"Hale Killer",
	"Hale Genocide",
	"Hale Extinction",
	"Merc Killer",
	"Merc Genocide",
	"Merc Extinction",
	"Telefragger",
	"Telefrag Machine",
	"Frog-Man",
	"Masterful Frog-Man",
	"Veteran",
	"Battlescarred",
	"Master",
	"Brew Master",
	"Rager",
	"E Masher",
	"Rage Newb",
	"Backstabber",
	"Gardener",
	"Point Whore",
	"Damager",
	"Damage King",
	"Beyond the Grave",
	"#1 Minion",
	"Alternate Targeting",
	"Beep Boop, Maggot",
	"Not OP at all",
	"And Lived to Tell About it",
	"De-Rage-Inator",
	"Embarrassed",
	"Overkill",
	"Hey Man, Big Fan",
	"My Back Hurts"
};

static const char strAchDescript[MAX_ACHIEVEMENTS][] = {
	"Win a match as a Boss with less than 100 health",
	"Stun over 15 players in a single rage",
	"Get over 9000 damage in a single round",
	"Kill a Boss as the last player alive",
	"Win a round as a Boss without taking any damage",
	"Kill a Boss a total of 10 times",
	"Kill a Boss a total of 100 times",
	"Kill a Boss a total of 1000 times",
	"Kill 100 total Mercenaries as a Boss",
	"Kill 1000 total Mercenaries as a Boss",
	"Kill 10000 total Mercenaries as a Boss",
	"Pull off a telefrag",
	"Pull off 10 total telefrags",
	"Pull off 100 total telefrags",
	"Pull off 1000 total telefrags",
	"Play 100 rounds of VSH",
	"Play 1000 rounds of VSH",
	"Play 10000 rounds of VSH",
	"Play 100000 rounds of VSH",
	"Rage a total of 100 times",
	"Rage a total of 1000 times",
	"Rage a total of 10000 times",
	"Rack up 100 total backstabs",
	"Rack up 100 total Market/Sticky Gardens",
	"Amass 1000000 career points as a Mercenary",
	"Amass 100000 career damage as a Mercenary",
	"Amass 10 million career damage as a Mercenary",
	"Kill a Boss posthumously",
	"As a minion, kill 5 players in a single round",
	"Slay 10 minions in a single lifetime",
	"Defeat the rare S@xt0n H@1e",
	"As a Mercenary, win and survive a round against at least 6 bosses",
	"Survive being single raged",
	"Remove 1000% total rage from Bosses",
	"Taunt kill a Mercenary as a Boss",
	"Taunt kill a Boss as a Mercenary",
	"Kill a Boss with the Fan o' War",
	"Deal more damage than the rest of the team combined"
};
/*
static const int iAward[MAX_ACHIEVEMENTS] = {
	100,
	150,
	50,
	50,
	1000,
	100,
	200,
	300,
	50,
	100,
	200,
	50,
	100,
	200,
	500,
	50,
	100,
	200,
	1000,
	50,
	100,
	200,
	100,
	100,
	200,
	200,
	500,
	200,
	100,
	50,
	50,
	50,
	50,
	100,
	100,
	100,
	100,
	100
};*/

static const int iGoal[MAX_ACHIEVEMENTS] = {
	1,
	1,
	1,
	1,
	1,
	10,
	100,
	1000,
	100,
	1000,
	10000,
	1,
	10,
	100,
	1000,
	100,
	1000,
	10000,
	100000,
	100,
	1000,
	10000,
	100,
	100,
	1000000,
	100000,
	10000000,
	1,
	1,
	1,
	1,
	1,
	1,
	1000,
	1,
	1,
	1,
	1
};

int
	iProgress[34][MAX_ACHIEVEMENTS]
;

enum struct Achievement
{
	char name[32];
	char descript[128];
	int target;
}

float flCmdTime[34];
bool bLate;
bool bEnabled;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	bLate = late;
	CreateNative("VSH2Ach_AddTo", Native_AddTo);
	CreateNative("VSH2Ach_Toggle", Native_Toggle);

	MarkNativeAsOptional("TBC_GiveCredits");
	RegPluginLibrary("VSH2Ach");
	return APLRes_Success;
}

#define DEBUG 0

public void OnPluginStart()
{
#if DEBUG
	Database.Connect(DBCB_Connect, "vsh2_achievements_test");
#else
	Database.Connect(DBCB_Connect, "vsh2_achievements");
#endif

	bEnabled = true;

	RegConsoleCmd("sm_haleach", MyAchievements);
	RegConsoleCmd("sm_vshach", MyAchievements);
	RegConsoleCmd("sm_haleachievements", MyAchievements);
	RegConsoleCmd("sm_vshachievements", MyAchievements);

	Achievement ach;
	hAchievements = new ArrayList(sizeof(ach));
	for (int u = 0; u < MAX_ACHIEVEMENTS; u++)
	{
		strcopy(ach.name, 32, strAchNames[u]);
		strcopy(ach.descript, 128, strAchDescript[u]);
		ach.target = iGoal[u];
//		ach.reward = iAward[u];
		hAchievements.PushArray(ach, sizeof(ach));
	}
}

public void OnMapStart()
{
	PrecacheSound(ACHIEVEMENT_SOUND, true);
}

public void OnClientConnected(int client)
{
	bConnected[client] = false;
	for (int u = 0; u < MAX_ACHIEVEMENTS; ++u)
		iProgress[client][u] = 0;

	flCmdTime[client] = 0.0;
}

public void OnClientDisconnect(int client)
{
	if (IsFakeClient(client) || !bConnected[client])
		return;
	char query[1024];
	hTheDB.Format(query, sizeof(query), "UPDATE vsh2_achievements SET "
	... "playername = '%N', ", client);

	for (int i = 0; i < MAX_ACHIEVEMENTS; ++i)
		Format(query, sizeof(query), "%s `%s` = %d,", query, strAchNames[i], iProgress[client][i]);

	query[strlen(query)-1] = '\0';
	Format(query, sizeof(query), "%s WHERE accountid = %d", query, GetSteamAccountID(client));
	hTheDB.Query(CCB_Disconnect, query);
}

public int CCB_Disconnect(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("CCB_Disconnect: %s", error);
	return 0;
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if (IsFakeClient(client))
		return;

	flCmdTime[client] = 0.0;
	if (!hTheDB)
	{
		CreateTimer(3.0, Check4DB, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return;
	}

	char query[256];
	Format(query, sizeof(query), 
			"SELECT * "
		...	"FROM vsh2_achievements "
		...	"WHERE accountid = %d;",
			GetSteamAccountID(client));

	hTheDB.Query(CCB_OnConnect, query, GetClientUserId(client));
}

public void OnPluginEnd()
{
	for (int i = MaxClients; i; --i)
		if (IsClientAuthorized(i))
			OnClientDisconnect(i);
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
	Format(query, sizeof(query), 
			"SELECT * "
		...	"FROM vsh2_achievements "
		...	"WHERE accountid = %d;",
			GetSteamAccountID(client));

	hTheDB.Query(CCB_OnConnect, query, GetClientUserId(client));
	return Plugin_Continue;
}

public void GiveAchievement(const int client, Achievement ach)
{
	char s[128]; FormatEx(s, sizeof(s), "\x03%N\x01 has earned the \x05VSH\x01 achievement \x05%s\x01.", client, ach.name);
	SayText2(client, s);
	AchievementEffect(client);

	char query[256];
	hTheDB.Format(query, sizeof(query), "UPDATE vsh2_achievements SET `%s` = %d WHERE accountid = %d", ach.name, ach.target, GetSteamAccountID(client));
	hTheDB.Query(CCB_Ach, query);
	hTheDB.Format(query, sizeof(query), "UPDATE vsh2_achievements_timestamp SET `%s` = %d WHERE accountid = %d", ach.name, GetTime(), GetSteamAccountID(client));
	hTheDB.Query(CCB_Ach, query);

//	DataPack pack;
//	CreateDataTimer(3.0, GiveTheseCredits, pack, TIMER_FLAG_NO_MAPCHANGE);
//	pack.WriteCell(GetClientUserId(client));
//	pack.WriteCell(GetSteamAccountID(client));
//	pack.WriteCell(ach.reward);
}

/*public Action GiveTheseCredits(Handle timer, DataPack pack)
{
	pack.Reset();

	int client = GetClientOfUserId(pack.ReadCell());
//	int accid = pack.ReadCell();
	int reward = pack.ReadCell();

	if (LibraryExists("store"))
	{
		TBC_GiveCredits(client, reward);
		if (client)
			CPrintToChat(client, TBC_TAG ... "You have recieved %d Gimgims!", reward);
	}
}*/

public int CCB_Ach(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("CCB_Ach: %s", error);
	return 0;
}

stock void SayText2(int author_index , const char[] message)
{
	BfWrite buffer = UserMessageToBfWrite(StartMessageAll("SayText2"));
	if (buffer)
	{
		buffer.WriteByte(author_index);
		buffer.WriteByte(true);
		buffer.WriteString(message);
		EndMessage();
    }
}

stock void AchievementEffect(int argClient)
{
	float strflVec[3];
	GetClientEyePosition(argClient, strflVec);

	EmitSoundToAll(ACHIEVEMENT_SOUND, argClient);

	int strIParticle = CreateEntityByName("info_particle_system");
	char strName[128];
	if (IsValidEntity(strIParticle))
	{
		float strflPos[3];
		GetEntPropVector(argClient, Prop_Send, "m_vecOrigin", strflPos);
		TeleportEntity(strIParticle, strflPos, NULL_VECTOR, NULL_VECTOR);

		Format(strName, sizeof(strName), "target%i", argClient);
		DispatchKeyValue(argClient, "targetname", strName);

		DispatchKeyValue(strIParticle, "targetname", "tf2particle");
		DispatchKeyValue(strIParticle, "parentname", strName);
		DispatchKeyValue(strIParticle, "effect_name", ACHIEVEMENT_PARTICLE);
		DispatchSpawn(strIParticle);
		SetVariantString(strName);
		AcceptEntityInput(strIParticle, "SetParent", strIParticle, strIParticle, 0);
		SetVariantString("head");
		AcceptEntityInput(strIParticle, "SetParentAttachment", strIParticle, strIParticle, 0);
		ActivateEntity(strIParticle);
		AcceptEntityInput(strIParticle, "start");

		CreateTimer(5.0, Timer_DeleteParticles, EntIndexToEntRef(strIParticle));
	}
}

public Action Timer_DeleteParticles(Handle argTimer, any ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

public Action MyAchievements(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	float currtime = GetGameTime();
	if (flCmdTime[client] > currtime)
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Please wait before issuing more achievement commands.");
		return Plugin_Handled;
	}

	flCmdTime[client] = currtime + 5.0;
	if (!bConnected[client])
		CPrintToChat(client, "{olive}[VSH 2]{red} Warning: Unable to connect to Database. Your results may vary.");

	if (!args)
	{
		Menu menu = new Menu(AchMenu);
		menu.SetTitle("VSH 2 Achievements");
		menu.AddItem("0", "My Achievement List\nView your achievements!");
		menu.AddItem("1", "Another Player's Achievement List\nView someone else's achievements!");
		menu.AddItem("2", "Offline Player's Achievement List\nView someone's achievements by name or SteamID.");
		menu.Display(client, 0);
		return Plugin_Handled;
	}
	char arg[32]; GetCmdArgString(arg, sizeof(arg));
	char arg2[32]; strcopy(arg2, sizeof(arg2), arg);
	char query[256];

	if (!StrContains(arg, "STEAM_", false))
	{
		hTheDB.Format(query, sizeof(query), "SELECT * FROM vsh2_achievements WHERE steamid = '%s'", arg);
		hTheDB.Query(CCB_Achievements, query, GetClientUserId(client));
		return Plugin_Handled;
	}

	char target_name[32];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;
	if ( (ProcessTargetString(
		arg,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_BOTS,
		target_name,
		sizeof(target_name),
		tn_is_ml)) != 1 || IsFakeClient(target_list[0]))
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Invalid target or too many targets. Querying for players with names that contain '%s'", arg2);
		hTheDB.Format(query, sizeof(query), "SELECT * FROM vsh2_achievements WHERE playername LIKE '%%%s%%'", arg2);
		hTheDB.Query(CCB_Achievements_Name, query, GetClientUserId(client));

		return Plugin_Handled;
	}

	Format(query, sizeof(query), "VSH 2 Achievements | %N", target_list[0]);
	Menu menu = new Menu(OtherAchievements);
	menu.SetTitle(query);
	IntToString(GetSteamAccountID(target_list[0]), target_name, sizeof(target_name));

	for (int i = 0; i < MAX_ACHIEVEMENTS; ++i)
	{
		strcopy(query, sizeof(query), strAchNames[i]);

		if (iProgress[target_list[0]][i] >= iGoal[i])
			StrCat(query, sizeof(query), " (c)");

		menu.AddItem(target_name, query);
	}
	menu.Display(client, 0);

	return Plugin_Handled;
}

public int AchMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char s[4]; menu.GetItem(select, s, sizeof(s));
			switch (StringToInt(s))
			{
				case 0:
				{
					flCmdTime[client] = 0.0;
					FakeClientCommandEx(client, "sm_haleach @me");
				}
				case 1:
				{
					char id[8], name[32];
					Menu menu2 = new Menu(InGameAchMenu);
					menu2.SetTitle("Select a Player");
					int count;
					for (int i = MaxClients; i; --i)
					{
						if (!IsClientAuthorized(i) || i == client)
							continue;

						if (IsFakeClient(i))
							continue;

						IntToString(GetClientUserId(i), id, sizeof(id));
						GetClientName(i, name, sizeof(name));
						menu2.AddItem(id, name);
						++count;
					}

					if (!count)
					{
						CPrintToChat(client, "{olive}[VSH 2]{default} No targets found.");
						delete menu2;
						return 0;
					}

					menu2.Display(client, 0);
				}
				case 2:CPrintToChat(client, "{olive}[VSH 2]{default} Usage: sm_haleach <steamid/name>.");
			}
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public int InGameAchMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char id[8]; menu.GetItem(select, id, sizeof(id));
			if (!GetClientOfUserId(StringToInt(id)))
			{
				CPrintToChat(client, "{olive}[VSH 2]{default} Client is no longer in-game.");
				return 0;
			}
			flCmdTime[client] = 0.0;
			FakeClientCommand(client, "sm_haleach #%d", StringToInt(id));
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public int DBCB_Connect(Database db, const char[] error, any data)
{
	if (!db)
	{
		LogError("[VSH2ACH] Induction error: %s", error);
		return 0;
	}

	if (hTheDB)
	{
		delete db;
		return 0;
	}

	hTheDB = db;
	char query[2048];
	strcopy(query, sizeof(query), 
		"CREATE TABLE IF NOT EXISTS vsh2_achievements "
	... "(accountid INT, "
	... "steamid VARCHAR(32), "
	... "playername VARCHAR(32), ");

	int i;
	for (i = 0; i < MAX_ACHIEVEMENTS; ++i)
		Format(query, sizeof(query), "%s `%s` INT NOT NULL DEFAULT 0,", query, strAchNames[i]);

	StrCat(query, sizeof(query), " PRIMARY KEY (accountid))");

	db.Query(DBCB_Create, query);
	ReplaceStringEx(query, sizeof(query), "vsh2_achievements", "vsh2_achievements_timestamp");
	db.Query(DBCB_Create, query);
	return 0;
}

public int DBCB_Create(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("[VSH2ACH] DBCB_Create: %s", error);

	if (bLate)
	{
		int i, u;
		for (i = MaxClients; i; --i)
		{
			for (u = 0; u < MAX_ACHIEVEMENTS; ++u)
				iProgress[i][u] = 0;
			if (IsClientAuthorized(i))
			{
				char id[32]; GetClientAuthId(i, AuthId_Steam2, id, sizeof(id));		
				OnClientAuthorized(i, id);
			}
		}
	}
	bLate = false;
	return 0;
}

public int CCB_Achievements(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if (!client)
		return 0;

	if (!results)
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Unable to find client. Invalid steamid or Database failure.");
		LogError("CCB_Achievements: %s", error);
		return 0;
	}

	if (!results.FetchRow())
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Unable to fetch DB row. Invalid steamid or Database failure.");
		return 0;
	}

	char accountid[32]; IntToString(results.FetchInt(0), accountid, sizeof(accountid));
	char s[64]; results.FetchString(2, s, sizeof(s));
	int val;

	Format(s, sizeof(s), "VSH 2 Achievements | %s", s);
	Menu menu = new Menu(OtherAchievements);
	menu.SetTitle(s);

	for (int i = 0; i < MAX_ACHIEVEMENTS; ++i)
	{
		strcopy(s, sizeof(s), strAchNames[i]);

		val = results.FetchInt(i+3);
		if (val >= iGoal[i])
			StrCat(s, sizeof(s), " (c)");

		menu.AddItem(accountid, s);
	}
	menu.Display(client, 0);
	return 0;
}

public int CCB_Achievements_Name(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if (!client)
		return 0;

	if (!results)
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Database failure. Try again?");
		LogError("CCB_Achievements: %s", error);
		return 0;
	}

	int rowcount = results.RowCount;
	if (!results.FetchRow() || !rowcount)
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Unable to fetch. Invalid name?");
		return 0;
	}

	if (rowcount > 1)
	{
		char s[64];
		if (rowcount > 10)
		{
			strcopy(s, sizeof(s), ", clamping to 10");
			rowcount = 10;
		}

		CPrintToChat(client, "{olive}[VSH 2]{default} Multiple entries found%s.", s);

		Menu menu = new Menu(ClientsOtherAchievements);
		menu.SetTitle("Select a player to view");
		char send[64], name[32], id[32], id2[4];

		for (int i = 0; i < rowcount; ++i)
		{
			IntToString(i, id2, sizeof(id2));
			results.FetchString(1, id, sizeof(id));
			results.FetchString(2, name, sizeof(name));

			FormatEx(send, sizeof(send), "%s | %s", name, id);
			menu.AddItem(id2, send);

			if (!results.FetchRow())
				break;
		}

		menu.Display(client, 0);
		return 0;
	}

	char accountid[32]; IntToString(results.FetchInt(0), accountid, sizeof(accountid));
	char s[64]; results.FetchString(2, s, sizeof(s));
	int val;

	Format(s, sizeof(s), "VSH 2 Achievements | %s", s);
	Menu menu = new Menu(OtherAchievements);
	menu.SetTitle(s);

	for (int i = 0; i < MAX_ACHIEVEMENTS; ++i)
	{
		strcopy(s, sizeof(s), strAchNames[i]);

		val = results.FetchInt(i+3);
		if (val >= iGoal[i])
			StrCat(s, sizeof(s), " (c)");

		menu.AddItem(accountid, s);
	}
	menu.Display(client, 0);
	return 0;
}

public int ClientsOtherAchievements(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char s[64]; menu.GetItem(select, "", 0, _, s, 64);
			strcopy(s, sizeof(s), s[FindCharInString(s, '|')+1]);
			flCmdTime[client] = 0.0;
			FakeClientCommandEx(client, "sm_haleach %s", s);
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public int OtherAchievements(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char accid[32];
			char name[32]; menu.GetItem(select, accid, 32, _, name, 32);
			int comp = ReplaceStringEx(name, sizeof(name), " (c)", "");
			int id = StringToInt(accid);
			char query[256];

			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(select);
			pack.WriteString(name);

			if (comp)
			{
				Transaction txn = new Transaction();

				FormatEx(query, sizeof(query), "SELECT `%s` FROM vsh2_achievements WHERE accountid = %d;", name, id);
				txn.AddQuery(query);
				FormatEx(query, sizeof(query), "SELECT `%s` FROM vsh2_achievements_timestamp WHERE accountid = %d;", name, id);
				txn.AddQuery(query);
				hTheDB.Execute(txn, TXN_OnGetAch, TXN_OnFailAch, pack);
			}
			else
			{
				bool found;
				for (int i = MaxClients; i; --i)
				{
					if (!IsClientInGame(i))
						continue;

					if (GetSteamAccountID(i) == id)
					{
						found = true;
						comp = i;
						break;
					}
				}
				if (found)
				{
					Format(query, sizeof(query), "%s\n%s\nProgress: %d/%d", strAchNames[select], strAchDescript[select], iProgress[comp][select], iGoal[select]);
					Panel panel = new Panel();
					panel.SetTitle(query);
					panel.DrawItem("Back");
					panel.DrawItem("Exit");
					panel.Send(client, ViewAchPanel, 9001);
					delete panel;
					delete pack;
				}
				else
				{
					FormatEx(query, sizeof(query), "SELECT `%s` FROM vsh2_achievements WHERE accountid = %d;", name, id);
					hTheDB.Query(CCB_OnGetMyAch, query, pack);
				}
			}
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public void TXN_OnFailAch(Database db, DataPack pack, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if (client)
		CPrintToChat(client, "{olive}[VSH 2]{default} Achievement transaction failure. This incident has been reported. Try again?");

	LogError("TXN_OnFailAch (%d): %s", failIndex, error);
	delete pack;
}

public void TXN_OnGetAch(Database db, DataPack pack, int numQueries, DBResultSet[] results, any[] queryData)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if (!client)
	{
		delete pack;
		return;
	}

	int curr;
	if (results[0].FetchRow()) curr = results[0].FetchInt(0);
	else
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Error while trying to get achievement data.");
		LogError("CCB_OnGetMyAch fetch error???");
		delete pack;
		return;
	}

	Achievement ach;
	hAchievements.GetArray(pack.ReadCell(), ach, sizeof(Achievement));

	char name[32], s[256];
	pack.ReadString(name, sizeof(name));
	delete pack;

	results[1].FetchRow();
	char timestamp[64]; FormatTime(timestamp, sizeof(timestamp), "%c", results[1].FetchInt(0));

	Format(s, sizeof(s), "%s\n%s\nProgress: %d/%d\nCompleted: %s", ach.name, ach.descript, curr, ach.target, timestamp);
	Panel panel = new Panel();
	panel.SetTitle(s);
	panel.DrawItem("Back");
	panel.DrawItem("Exit");
	panel.Send(client, ViewAchPanel, 9001);
	delete panel;
}

public int MyAchMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char accid[32];
			char name[32]; menu.GetItem(select, accid, 32, _, name, 32);
			int comp = ReplaceStringEx(name, sizeof(name), " (c)", "");
			int id = StringToInt(accid);
			char query[256];

			DataPack pack = new DataPack();
			pack.WriteCell(GetClientUserId(client));
			pack.WriteString(name);

			if (comp)
			{
				Transaction txn = new Transaction();

				FormatEx(query, sizeof(query), "SELECT `%s` FROM vsh2_achievements WHERE accountid = %d;", name, id);
				txn.AddQuery(query);
				FormatEx(query, sizeof(query), "SELECT `%s` FROM vsh2_achievements_timestamp WHERE accountid = %d;", name, id);
				txn.AddQuery(query);
				hTheDB.Execute(txn, TXN_OnGetAch, TXN_OnFailAch, pack);
			}
			else
			{
				FormatEx(query, sizeof(query), "SELECT `%s` FROM vsh2_achievements WHERE accountid = %d;", name, id);
				hTheDB.Query(CCB_OnGetMyAch, query, pack);
			}
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public int CCB_OnGetMyAch(Database db, DBResultSet results, const char[] error, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());

	if (!client)
	{
		delete pack;
		return 0;
	}

	int curr;
	if (!results)
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Error while trying to get achievement data.");
		LogError("CCB_OnGetMyAch: %s", error);
		delete pack;
		return 0;
	}
	else if (results.FetchRow()) curr = results.FetchInt(0);
	else
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Error while trying to fetch achievement data?");
		LogError("CCB_OnGetMyAch fetch error???");
		delete pack;
		return 0;
	}

	Achievement ach;
	hAchievements.GetArray(pack.ReadCell(), ach, sizeof(Achievement));

	char name[32], s[256];
	pack.ReadString(name, sizeof(name));
	delete pack;

	Format(s, sizeof(s), "%s\n%s\nProgress: %d/%d", ach.name, ach.descript, curr, ach.target);
	Panel panel = new Panel();
	panel.SetTitle(s);
	panel.DrawItem("Back");
	panel.DrawItem("Exit");
	panel.Send(client, ViewAchPanel, 9001);
	delete panel;
	return 0;
}

public int CCB_OnConnect(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if (!client)
		return 0;

	if (!results)
	{
		LogError("CCB_OnConnect: %s", error);
		return 0;
	}

	bConnected[client] = true;

	if (!results.FetchRow())
	{
		char query[1024];
		char id[32]; GetClientAuthId(client, AuthId_Steam2, id, sizeof(id));

		hTheDB.Format(query, sizeof(query), "INSERT INTO vsh2_achievements (accountid, steamid, playername) VALUES (%d, '%s', '%N')", GetSteamAccountID(client), id, client);
		hTheDB.Query(CCB_Create, query);
		ReplaceStringEx(query, sizeof(query), "vsh2_achievements", "vsh2_achievements_timestamp");
		hTheDB.Query(CCB_Create, query);
		for (int i = 0; i < MAX_ACHIEVEMENTS; ++i)
			iProgress[client][i] = 0;
		return 0;
	}

	for (int i = 0; i < MAX_ACHIEVEMENTS; ++i)
		iProgress[client][i] = results.FetchInt(i+3);
	return 0;
}

public int CCB_Create(Database db, DBResultSet results, const char[] error, any data)
{
	if (!results)
		LogError("CCB_Create: %s", error);
	return 0;
}

public int ViewAchPanel(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
		if (select == 1)
		{
			flCmdTime[client] = 0.0;
			FakeClientCommandEx(client, "sm_haleach @me");
		}
	return 0;
}

stock int CountCharInString(const char[] str, int c) {
    int i = 0, count = 0;

    while (str[i] != '\0') {
        if (str[i++] == c) {
            count++;
        }
    }

    return count;
}

stock bool PushMenuString(Menu menu, const char[] id, const char[] value)
{
	if (menu == null || id[0] == '\0')
		return false;
	
	return menu.AddItem(id, value, ITEMDRAW_IGNORE);
}

stock bool GetMenuString(Menu menu, const char[] id, char[] buffer, int size)
{
	if (menu == null || id[0] == '\0')
		return false;
	
	char info[128]; char data[128];
	for (int i = 0; i < menu.ItemCount; i++)
	{
		if (menu.GetItem(i, info, sizeof(info), _, data, sizeof(data)) && StrEqual(info, id))
		{
			strcopy(buffer, size, data);
			return true;
		}
	}
	
	return false;
}

public any Native_AddTo(Handle plugin, int numParams)
{
	if (!bEnabled || !hTheDB)
		return 0;

	int client = GetNativeCell(1);
	if (!bConnected[client])
		return 0;

	int idx = GetNativeCell(2);
	int amt = GetNativeCell(3);
	if (iProgress[client][idx] >= iGoal[idx])
		return 0;

	iProgress[client][idx] += amt;
	if (iProgress[client][idx] >= iGoal[idx])
	{
		iProgress[client][idx] = iGoal[idx];
		Achievement ach;
		hAchievements.GetArray(idx, ach, sizeof(ach));
		GiveAchievement(client, ach);
	}
	return 0;
}

public any Native_Toggle(Handle plugin, int numParams)
{
	bEnabled = !!GetNativeCell(1);
	return 0;
}