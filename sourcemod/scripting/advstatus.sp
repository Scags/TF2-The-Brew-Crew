#include <sourcemod>
#pragma semicolon	1
#pragma newdecls required
#define PLUGIN_VERSION "1.1"

public Plugin myinfo = 
{
	name = "Advanced Status",
	author = "Ragenewb",
	description = "Advanced concise status",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	RegAdminCmd("sm_advstatus", Command_Status_Full, ADMFLAG_BAN);
}

public Action Command_Status_Full(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	char strName[32], strID[32], strIP[32], strID3[32];
	int userid;
	if (!args)
	{
		PrintToConsole(client, "\nUsers:\n=========================================");
		for (int i = MaxClients; i; --i)
		{
			if (!IsClientConnected(i))
				continue;
			if (IsFakeClient(i))
				continue;

			userid = GetClientUserId(i);
			GetClientName(i, strName, sizeof(strName));
			if (!GetClientAuthId(i, AuthId_Steam2, strID, sizeof(strID)))
				strID = IsClientAuthorized(i) ? "INVALID???" : "Pending";

			if (!GetClientAuthId(i, AuthId_Steam3, strID3, sizeof(strID3)))
				strID3 = IsClientAuthorized(i) ? "INVALID???" : "Pending";

			if (!GetClientIP(i, strIP, sizeof(strIP)))
				strIP = IsClientAuthorized(i) ? "INVALID???" : "Pending";

			PrintToConsole(client, "\n#%d | %s\nSteam: %s\nSteam3: %s\nIP: %s\n", userid, strName, strID, strID3, strIP);
		}
		PrintToChat(client, "[SM] Check console for output.");
		return Plugin_Handled;
	}
	char strTarget[32];
	GetCmdArg(1, strTarget, sizeof(strTarget));
	int target = FindTarget(client, strTarget);
	if (!IsValidClient(target))
	{
		ReplyToCommand(client, "[SM] Client is no longer valid.");
		return Plugin_Handled;
	}
	char strID64[32];
	userid = GetClientUserId(target);
	if (!GetClientAuthId(target, AuthId_Steam2, strID, sizeof(strID)))
		strID = IsClientAuthorized(target) ? "INVALID???" : "Pending";

	if (!GetClientAuthId(target, AuthId_Steam3, strID3, sizeof(strID3)))
		strID3 = IsClientAuthorized(target) ? "INVALID???" : "Pending";

	if (!GetClientIP(target, strIP, sizeof(strIP)))
		strIP = IsClientAuthorized(target) ? "INVALID???" : "Pending";

	if (!GetClientAuthId(target, AuthId_SteamID64, strID64, sizeof(strID64)))
		strID64 = IsClientAuthorized(target) ? "INVALID???" : "Pending";

	PrintToConsole(client, "#%i | %N:\nSteam: %s\nSteam3: %s\nSteam Link: https://steamcommunity.com/profiles/%s\nIP: %s", userid, target, strID, strID3, strID64, strIP);
	PrintToChat(client, "[SM] Check console for output.");

	return Plugin_Handled;
}

stock bool IsValidClient(const int client, bool nobots = false)
{
	if (client <= 0 || client > MaxClients || (nobots && IsFakeClient(client)))
		return false;
	return IsClientInGame(client);
}