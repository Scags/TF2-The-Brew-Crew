#include <sdktools>

int g_iStringTable;
Menu g_TheMenu;
public void OnPluginStart()
{
	g_TheMenu = new Menu(PropMenuHandler);
	g_TheMenu.SetTitle("Prop Spawner");
	RegAdminCmd("sm_props", CmdProps, ADMFLAG_ROOT);
}

public void OnConfigsExecuted()
{
	g_iStringTable = FindStringTable("modelprecache");
	g_TheMenu.RemoveAllItems();

	int len = GetStringTableNumStrings(g_iStringTable);
	char buffer[256];
	char id[8];
	for (int i = 0; i < len; ++i)
	{
		ReadStringTable(g_iStringTable, i, buffer, sizeof(buffer));
		if (StrContains(buffer, ".mdl") == -1)
			continue;
		IntToString(i, id, sizeof(id));
		g_TheMenu.AddItem(id, buffer);
	}
}

public Action CmdProps(int client, int args)
{
	PropMenu(client);
	return Plugin_Handled;
}

public void PropMenu(int client)
{
	g_TheMenu.Display(client, 0);
}

public int PropMenuHandler(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (!IsPlayerAlive(client))
				return 0;

			char item[256], id[8];
			menu.GetItem(select, id, sizeof(id), _, item, sizeof(item));
			int numid = StringToInt(id);

			int ent = CreateEntityByName("prop_dynamic_override");
			if (IsModelPrecached(item))
			{
				DispatchKeyValue(ent, "solid", "6");
				SetEntityModel(ent, item);
				DispatchSpawn(ent);

				float pos[3]; GetAimPos(client, pos);
				TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);

				SetEntityMoveType(ent, MOVETYPE_NONE);

				SetEntProp(ent, Prop_Data, "m_nModelIndex", numid);
				SetEntProp(ent, Prop_Send, "m_nSkin", 0);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", 6);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", GetEntProp(ent, Prop_Send, "m_usSolidFlags") & ~4);
			} else PrintToChat(client, "[SM] Invalid Model");

			menu.DisplayAt(client, select - select % 7, 0);
		}
	}
	return 0;
}

stock bool GetAimPos(const int client, float vecPos[3])
{
	float StartOrigin[3], Angles[3];
	GetClientEyeAngles(client, Angles);
	GetClientEyePosition(client, StartOrigin);

	Handle trace = TR_TraceRayFilterEx(StartOrigin, Angles, MASK_NPCSOLID | MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	bool r;
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vecPos, trace);
		r = true;
	}

	delete trace;
	return r;
}

public bool TraceRayDontHitSelf(int ent, int mask, any data)
{
	return ent != data;
}