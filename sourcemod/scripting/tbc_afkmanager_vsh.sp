#include <sourcemod>
#include <morecolors>

float flAFKTime[MAXPLAYERS+1];
bool bAFK[MAXPLAYERS+1];
bool bIsAdmin[MAXPLAYERS+1];
int iLevel[MAXPLAYERS+1]
int iOldMouse[MAXPLAYERS+1][2];
int iSpecTime[MAXPLAYERS+1];
ConVar cvTime;

public void OnPluginStart()
{
	cvTime = CreateConVar("sm_afkmgr_time", "120", "Time in seconds a player must be afk for the manager to kick them", FCVAR_NOTIFY, true, 0.0);
	AutoExecConfig(true, "tbcafkmgr");
	CreateTimer(1.0, SpecTimer, _, TIMER_REPEAT);
	for (int i = MaxClients; i; --i)
	{
		if (IsClientConnected(i))
			OnClientConnected(i);
		if (IsClientAuthorized(i))
			OnClientPostAdminCheck(i);
	}
}

public Action SpecTimer(Handle timer)
{
	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i) && !IsPlayerAlive(i) && GetClientTeam(i) <= 1)
			if (++iSpecTime[i] > 600 && !bIsAdmin[i])
				KickClient(i, "You have been kicked due to inactivity.");
	return Plugin_Continue;
}

public void OnClientConnected(int client)
{
	flAFKTime[client] = 0.0;
	bAFK[client] = false;
	iLevel[client] = 0;
	iSpecTime[client] = 0;
	iOldMouse[client][0] = 0;
	iOldMouse[client][1] = 0;	
}

public void OnClientPostAdminCheck(int client)
{
	bIsAdmin[client] = CheckCommandAccess(client, "sm_afkmgr", ADMFLAG_GENERIC);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (IsFakeClient(client))
		return Plugin_Continue;

	float currtime = GetGameTime();
	if (iOldMouse[client][0] != mouse[0] || iOldMouse[client][1] != mouse[1] || buttons != GetEntProp(client, Prop_Data, "m_nOldButtons") || bIsAdmin[client] || !IsPlayerAlive(client))
	{
		flAFKTime[client] = 0.0;
		bAFK[client] = false;
		iLevel[client] = 0;
	}
	else
	{
		if (!bAFK[client])
		{
			bAFK[client] = true;
			flAFKTime[client] = currtime + cvTime.FloatValue-0.1;
		}
		else
		{
			if (flAFKTime[client] <= currtime)
				KickClient(client, "You have been kicked due to inactivity.");
			else 
			{
				int icurrtime = RoundFloat(flAFKTime[client] - currtime);
				char s[32];
				switch (icurrtime)
				{
					case 60:if (iLevel[client] == 0) s = "60 seconds";
					case 30:if (iLevel[client] == 1) s = "30 seconds";
					case 10:if (iLevel[client] == 2) s = "10 seconds";
				}
				if (s[0] != '\0')
				{
					++iLevel[client];
					CPrintToChat(client, "{red}[TBC] Warning: {lightcoral}If you do not move in {default}%s{lightcoral}, you will be disconnected.", s);
				}
			}
		}
	}

	iOldMouse[client][0] = mouse[0];
	iOldMouse[client][1] = mouse[1];

	return Plugin_Continue;
}