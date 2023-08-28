#include <vsh2>

#define PLUGIN_VERSION 	"1.0.0"

public Plugin myinfo =  {
	name = "VSH2 Boss Tracker", 
	author = "Scag", 
	description = "Tracks boss selection", 
	version = PLUGIN_VERSION, 
	url = ""
};

Database hTheDB;

#define DBPARAMS		Database db, DBResultSet results, const char[] error, any data
#define DECL_ERROR(%1)	if (!results) { LogError(#%1 ... ": %s", error); return 0; }

public void OnPluginStart()
{
	Database.Connect(DBCB_Connect, "vsh2_bosstracker");
	HookEvent("arena_round_start", OnRoundStart);
}

public void OnRoundStart(Event event, const char[] n, bool dontBroadcast)
{
	VSH2Player player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		player = VSH2Player(i);
		if (player.bIsBoss)
		{
			char name[64];
			char query[256];
			player.hMap.GetString("strBossName", name, 64);
			if (name[1] == '@')
				name = "Saxton Hale";
			else if (name[0] == '\0')
				continue;

			FormatEx(query, sizeof(query), "SELECT `count` FROM vsh2_bosstracker WHERE bossname = '%s'", name);
			DataPack pack = new DataPack();
			pack.WriteString(name);
			hTheDB.Query(DBCB_Query, query, pack);
		}
	}
}

public int DBCB_Query(DBPARAMS)
{
	DECL_ERROR(DBCB_Query)

	DataPack pack = view_as< DataPack >(data);
	pack.Reset();
	char query[256];
	if (!results.RowCount)
	{
		pack.ReadString(query, 64);
		Format(query, sizeof(query), "INSERT INTO vsh2_bosstracker (bossname, `count`) VALUES ('%s', 1)", query);
		hTheDB.Query(DBCB_Query2, query);
	}
	else
	{
		pack.ReadString(query, 64);
		Format(query, sizeof(query), "UPDATE vsh2_bosstracker SET `count` = `count` + 1 WHERE bossname = '%s'", query);
		hTheDB.Query(DBCB_Query2, query);
	}
	delete pack;
	return 0;
}

public int DBCB_Connect(Database db, const char[] error, any data)
{
	if (!db)
	{
		LogError("DBCB_Connect: %s", error);
		return 0;
	}

	if (hTheDB)
	{
		delete db;
		return 0;
	}

	hTheDB = db;

	db.Query(DBCB_Create, "CREATE TABLE IF NOT EXISTS vsh2_bosstracker ("
		... "bossname VARCHAR(64),"
		... "count INT NOT NULL DEFAULT 0)");
	return 0;
}

public int DBCB_Create(DBPARAMS)
{
	DECL_ERROR(DBCB_Create)
	return 0;
}

public int DBCB_Query2(DBPARAMS)
{
	DECL_ERROR(DBCB_Query2)
	return 0;
}