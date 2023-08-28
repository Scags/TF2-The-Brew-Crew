#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>
#include <tf2attributes>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Big Smoke", 
	author = "Scag", 
	description = "VSH2 boss Big Smoke", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;
#define EF_BONEMERGE                (1 << 0)
#define EF_PARENT_ANIMATES          (1 << 9)

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_bigsmoke");
		VSH2_AddToFwdC(Fwd_OnBossTakeDamage, ThisPluginIndex);
		VSH2_AddToFwdC(Fwd_OnBossDealDamage, ThisPluginIndex);
		VSH2_AddToFwdC(Fwd_OnSoundHook, ThisPluginIndex);
		VSH2_Hook(OnCallDownloads, fwdOnDownloadsCalled);
		VSH2_Hook(OnBossSelected, fwdBossSelected);
		VSH2_Hook(OnBossThink, fwdOnBossThink);
		VSH2_Hook(OnBossModelTimer, fwdOnBossModelTimer);
		VSH2_Hook(OnBossEquipped, fwdOnBossEquipped);
		VSH2_Hook(OnBossInitialized, fwdOnBossInitialized);
		VSH2_Hook(OnBossPlayIntro, fwdOnBossPlayIntro);
		VSH2_Hook(OnBossTaunt, fwdOnBossTaunt);
		VSH2_Hook(OnMusic, fwdOnMusic);
		VSH2_Hook(OnBossMenu, fwdOnBossMenu);
		VSH2_Hook(OnPlayerKilled, fwdOnPlayerKilled);
		VSH2_Hook(OnBossBackstabbed, fwdOnBossBackstabbed);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define BigSmokeModel			"models/freak_fortress_2/bigsmoke/bigsmoke.mdl"

#define BigSmokeKill			"tbc/saxtonhale/bigsmoke/kill" //6
#define BigSmokeTrainKill 		"tbc/saxtonhale/bigsmoke/trainkill"//3
#define BigSmokeStart			"tbc/saxtonhale/bigsmoke/start"//2
#define BigSmokeFail			"tbc/saxtonhale/bigsmoke/dead" //3
#define BigSmokeJump			"tbc/saxtonhale/bigsmoke/jump"	//3
#define BigSmokeRage			"ambient/train.wav"
#define AllWeHadToDo			"tbc/saxtonhale/bigsmoke/allwehadtodo.mp3"
#define BigSmokeWin				"tbc/saxtonhale/bigsmoke/win"	//2
#define BigSmokeStab			"tbc/saxtonhale/bigsmoke/stab"	//3
#define BigSmokeTheme			"tbc/saxtonhale/bigsmoke/theme.mp3"

public void fwdOnDownloadsCalled()
{
	PrepareModel(BigSmokeModel);

	PrepareMaterial("materials/freak_fortress_2/bigsmoke/hvyweapon_red");
	PrepareMaterial("materials/models/player/bs/hvyweapon_red");

	char s[PLATFORM_MAX_PATH];
	int i;

	for (i = 1; i <= 6; ++i)
	{
		FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeKill, i);
		PrepareSound(s);

		if (i <= 3)
		{
			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeFail, i);
			PrepareSound(s);

			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeJump, i);
			PrepareSound(s);

			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeStab, i);
			PrepareSound(s);

			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeTrainKill, i);
			PrepareSound(s);
		}

		if (i <= 2)
		{
			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeStart, i);
			PrepareSound(s);

			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeWin, i);
			PrepareSound(s);
		}
	}
	PrepareSound(AllWeHadToDo);
	PrepareSound(BigSmokeTheme);

	PrecacheSound(BigSmokeRage, true);
	PrecacheModel("models/props_vehicles/train_enginecar.mdl", true);
	PrecacheModel("models/props_interiors/vendingmachinesoda01a.mdl", true);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Big Smoke:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Choo Choo): Call for medic (e) when Rage is full.\nYou bring out a train!");
	panel.DrawItem( "Exit" );
	panel.Send(Player.index, PANEL, 10);
	delete (panel);
}
public int PANEL(Menu menu, MenuAction action, int client, int select)
{
	return 0;
}
public void fwdOnBossThink(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.DoGenericThink(true, true, BigSmokeJump, 3);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(BigSmokeModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 214 ; %i", GetRandomInt(9999, 99999));
	int assbeater = Player.SpawnWeapon("tf_weapon_fists", 5, 100, 5, attribs);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", assbeater);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Heavy, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeStart, GetRandomInt(1, 2));
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	if (player.hSpecial)
		TriggerTimer(view_as< Handle >(player.hSpecial));

	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	EmitSoundToAll(BigSmokeRage);
	MakeTrain(player);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	strcopy(song, sizeof(song), BigSmokeTheme);
	time = 80.0;
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Big Smoke");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	char s[PLATFORM_MAX_PATH];
	if (event.GetInt("damagebits") & (DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE) == (DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE))
	{
		if (GetRandomInt(0, 10))
			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeTrainKill, GetRandomInt(1, 3));
		else strcopy(s, sizeof(s), AllWeHadToDo);
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
	else if (!GetRandomInt(0, 1))
	{
		FormatEx(s, PLATFORM_MAX_PATH, "%s%i.mp3", BigSmokeKill, GetRandomInt(1, 6));
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", BigSmokeFail, GetRandomInt(1, 3));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeStab, GetRandomInt(1, 3));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeWin, GetRandomInt(1, 2));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Big Smoke");
}

public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Big Smoke", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Big Smoke");
	}
}

public void MakeTrain(const VSH2Player player)
{
	float pos[3], ang[3];

	GetClientEyeAngles(player.index, ang);
	if (!GetAimPos(player.index, pos))
		GetClientAbsOrigin(player.index, pos);
	pos[2] += 10.0;

	ang[0] = 0.0;
//	bool negate = !!GetRandomInt(0, 1);

	ang[1] += 90.0;// negate ? 90.0 : -90.0;
	if (ang[1] > 180.0) ang[1] -= 360.0;
	else if (ang[1] < -180.0) ang[1] += 360.0;

	float dir[3];
	GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);

	float pos1[3], pos2[3];
	pos1 = dir;
	pos2 = dir;

	ScaleVector(pos1, 4000.0);
	ScaleVector(pos2, -4000.0);

	AddVectors(pos, pos1, pos1);
	AddVectors(pos, pos2, pos2);

	char s[32]; 
	int track1 = CreateEntityByName("path_track");
	FormatEx(s, sizeof(s), "Track1%d", player.index);
	DispatchKeyValue(track1, "targetname", s);
	int track2 = CreateEntityByName("path_track");
	FormatEx(s, sizeof(s), "Track2%d", player.index);
	DispatchKeyValue(track2, "targetname", s);

	TeleportEntity(track1, pos1);
	TeleportEntity(track2, pos2);

	DispatchKeyValue(track1, "target", s);
//	DispatchKeyValue(track1, "spawnflags", "16");
	DispatchKeyValue(track1, "speed", "1500");

	//	float hurtmin[3] = { -10.0, -80.0, -305.65 };
	//	float hurtmax[3] = { 210.7, 80.0, -195.65 };

	int train = CreateEntityByName("func_tracktrain");
//	DispatchKeyValue(train, "spawnflags", "512");
	DispatchKeyValue(train, "solid", "2");
//	DispatchKeyValue(train, "dmg", "500");
	DispatchKeyValueVector(train, "origin", pos1);
	DispatchKeyValue(train, "speed", "1500");
	DispatchKeyValue(train, "startspeed", "1500");
	FormatEx(s, sizeof(s), "Track1%d", player.index);
	DispatchKeyValue(train, "target", s);
	char smoketrain[32];
	FormatEx(smoketrain, sizeof(smoketrain), "SmokeTrain%d", player.index);
	DispatchKeyValue(train, "targetname", smoketrain);

	TeleportEntity(train, pos1);

	char buf[128]; FormatEx(buf, sizeof(buf), "OnPass %s:Stop::0.0:-1", s);
	SetVariantString(buf);
	AcceptEntityInput(track2, "AddOutput");
//	FormatEx(buf, sizeof(buf), "OnPass %s:FireUser3::0.0:-1", s);
//	SetVariantString(buf);
//	AcceptEntityInput(track2, "AddOutput");

//	HookSingleEntityOutput(train, "OnFireUser3", OnTrainReset);

	DispatchSpawn(track1);
	ActivateEntity(track1);
	DispatchSpawn(track2);
	ActivateEntity(track2);
	TeleportEntity(track1, pos1);
	TeleportEntity(track2, pos2);

	DispatchSpawn(train);
	ActivateEntity(train);
	TeleportEntity(train, pos1);

	SetEntProp(train, Prop_Send, "m_iTeamNum", GetClientTeam(player.index));
	SetEntPropEnt(train, Prop_Send, "m_hOwnerEntity", player.index);

	FormatEx(s, sizeof(s), "Track1%d", player.index);
	SetVariantString(s);
	AcceptEntityInput(train, "TeleportToPathTrack");
	AcceptEntityInput(train, "StartForward");

	float actualpos[3]; GetEntPropVector(train, Prop_Data, "m_vecAbsOrigin", actualpos);

	int ent = CreateEntityByName("prop_dynamic");
//	DispatchKeyValue(ent, "parentname", s);
	SetVariantEntity(train);
	AcceptEntityInput(ent, "SetParent");
	SetEntProp(ent, Prop_Send, "m_fEffects", GetEntProp(ent, Prop_Send, "m_fEffects")|EF_BONEMERGE|EF_PARENT_ANIMATES|16);
	char name[32];
	FormatEx(name, sizeof(name), "TrainRainProp%d", player.index);
	DispatchKeyValue(ent, "targetname", name);
	DispatchKeyValue(ent, "solid", "0");
	DispatchKeyValueVector(ent, "angles", ang);
	SetEntityModel(ent, "models/props_vehicles/train_enginecar.mdl");
	TeleportEntity(ent, actualpos, ang, NULL_VECTOR);
	DispatchSpawn(ent);
	TeleportEntity(ent, actualpos, ang, NULL_VECTOR);
	ActivateEntity(ent);

	//	float maxs[3], mins[3];
	//	GetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxs);
	//	GetEntPropVector(ent, Prop_Send, "m_vecMins", mins);
	//	PrintToChatAll("%.1f, %.1f, %.1f", mins[0], mins[1], mins[2]);
	//	PrintToChatAll("%.1f, %.1f, %.1f", maxs[0], maxs[1], maxs[2]);

	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", player.index);
	SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(player.index));

//		float clipmin[3] = { 0.0, -70.0, -205.65 };
//		float clipmax[3] = { 206.7, 70.0, 305.65 };

//		int clip = CreateEntityByName("func_brush");
//		SetVariantEntity(ent);
//		AcceptEntityInput(clip, "SetParent");
//		FormatEx(name, sizeof(name), "TrainRainClip%d", player.index);
//		DispatchKeyValue(clip, "parentname", smoketrain);
//		DispatchKeyValue(clip, "targetname", name);
//		DispatchSpawn(clip);
//		ActivateEntity(clip);
//		TeleportEntity(clip, pos, NULL_VECTOR, NULL_VECTOR);
//		SetEntityModel(clip, "models/props_interiors/vendingmachinesoda01a.mdl");
//		SetEntPropVector(clip, Prop_Send, "m_vecMins", clipmin);
//		SetEntPropVector(clip, Prop_Send, "m_vecMaxs", clipmax);
//		SetEntProp(clip, Prop_Send, "m_nSolidType", 2);
//		int enteffects = GetEntProp(clip, Prop_Send, "m_fEffects");
//		enteffects |= 32;
//		SetEntProp(clip, Prop_Send, "m_fEffects", enteffects);

//		float hurtmin[3] = { -10.0, -80.0, -305.65 };
//		float hurtmax[3] = { 210.7, 80.0, -195.65 };

//		int hurt = CreateEntityByName("trigger_hurt");
//		DispatchKeyValue(hurt, "damage", "500");
//		DispatchKeyValue(hurt, "damagetype", "16");
//		DispatchKeyValue(hurt, "parentname", smoketrain);
//		SetVariantEntity(ent);
//		AcceptEntityInput(hurt, "SetParent");
//		DispatchKeyValue(hurt, "spawnflags", "1097");
//		FormatEx(s, sizeof(s), "TrainRainHurt%d", player.index);
//		DispatchKeyValue(hurt, "targetname", s);
//		DispatchSpawn(hurt);
//		ActivateEntity(hurt);
//		TeleportEntity(hurt, pos1, NULL_VECTOR, NULL_VECTOR);
//		SetEntityModel(hurt, "models/props_interiors/vendingmachinesoda01a.mdl");
//		SetEntPropVector(hurt, Prop_Send, "m_vecMins", hurtmin);
//		SetEntPropVector(hurt, Prop_Send, "m_vecMaxs", hurtmax);
//		SetEntProp(hurt, Prop_Send, "m_nSolidType", 2);
//		enteffects = GetEntProp(hurt, Prop_Send, "m_fEffects");
//		enteffects |= 32;
//		SetEntProp(hurt, Prop_Send, "m_fEffects", enteffects);
//	//	SetEntProp(hurt, Prop_Send, "m_iTeamNum", GetClientTeam(player.index));
//	//	SetEntPropEnt(hurt, Prop_Send, "m_hOwnerEntity", player.index);
//	//	SDKHook(hurt, SDKHook_Think, OnHurtThink);

	DataPack pack;
	CreateDataTimer(0.1, Timer_Fuck, pack, TIMER_REPEAT);
	pack.WriteFloat(actualpos[0]);
	pack.WriteFloat(actualpos[1]);
	pack.WriteFloat(actualpos[2]);
	pack.WriteCell(EntIndexToEntRef(train));

//	player.iSpecial = EntIndexToEntRef(ent);

	DataPack pack2;
	player.hSpecial = view_as< ArrayList >(CreateDataTimer(6.0, ForceFix, pack2, TIMER_FLAG_NO_MAPCHANGE));
	pack2.WriteCell(track1 < 0 ? track1 : EntIndexToEntRef(track1));
	pack2.WriteCell(track2 < 0 ? track2 : EntIndexToEntRef(track2));
	pack2.WriteCell(EntIndexToEntRef(train));
	pack2.WriteCell(player);
}

public Action Timer_Fuck(Handle timer, DataPack pack)
{
	pack.Reset();
	float oldpos[3];
	oldpos[0] = pack.ReadFloat();
	oldpos[1] = pack.ReadFloat();
	oldpos[2] = pack.ReadFloat();
	int ent = pack.ReadCell();

	if (!IsValidEntity(ent))
		return Plugin_Stop;

//	float hurtmin[3] = { -305.6, -70.0, -0.2 };
//	float hurtmax[3] = { 305.6, 70.0, 206.4 };
	float hurtmin[3] = { -70.0, -70.0, -0.2 };
	float hurtmax[3] = { 70.0, 70.0, 206.4 };
	float pos[3]; GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", pos);

	float ang[3]; GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
	float fwd[3];
	GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(fwd, 305.6/2.0);
	AddVectors(fwd, pos, pos);

	TR_EnumerateEntitiesHull(oldpos, pos, hurtmin, hurtmax, PARTITION_SOLID_EDICTS, TrainTrace, ent);
	float pos1[3]; AddVectors(pos, hurtmin, pos1);
	float pos2[3]; AddVectors(pos, hurtmax, pos2);
	//	TE_SendBeamBoxToAll(pos1, pos2, PrecacheModel("sprites/laser.vmt", true), PrecacheModel("sprites/laser.vmt", true), 1, 1, 5.0, 8.0, 8.0, 5, 2.0, {255, 255, 255, 255}, 0);
	pack.Reset(true);
	pack.WriteFloat(pos[0]);
	pack.WriteFloat(pos[1]);
	pack.WriteFloat(pos[2]);
	pack.WriteCell(ent);

	return Plugin_Continue;
}

public Action ForceFix(Handle timer, DataPack pack)
{
	pack.Reset();

	int track1 = pack.ReadCell();
	int track2 = pack.ReadCell();
	int train = pack.ReadCell();

	if (IsValidEntity(track1))
		RemoveEntity(track1);
	if (IsValidEntity(track2))
		RemoveEntity(track2);
	if (IsValidEntity(train))
		AcceptEntityInput(train, "KillHierarchy");

	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		StopSound(i, SNDCHAN_AUTO, BigSmokeRage);
	}

	VSH2Player player = pack.ReadCell();
	if (player.index)
		player.hSpecial = null;
	return Plugin_Continue;
}

public bool TrainTrace(int ent, int data)
{
	if (ent == data || !IsValidEntity(ent))
		return true;
	//	PrintToChatAll("tracing %d %d", ent, data & 0xFFF);
	if (!(0 < ent <= MaxClients))
	{
		char cls[32]; GetEntityClassname(ent, cls, sizeof(cls));
		if (strncmp(cls, "obj_", 4, false))
			return true;
	}

	if (GetEntProp(ent, Prop_Send, "m_iTeamNum") == GetEntProp(data, Prop_Send, "m_iTeamNum"))
		return true;

	TR_ClipCurrentRayToEntity(MASK_ALL, ent);
	if (!TR_DidHit())
		return true;

	int boss = GetEntPropEnt(data, Prop_Send, "m_hOwnerEntity");
	if (boss == -1)
		boss = 0;

	SDKHooks_TakeDamage(ent, data, boss, 300.0, DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE);
	//	if (ent <= MaxClients && boss)
	//	{
	//		char s[PLATFORM_MAX_PATH];
	//		if (GetRandomInt(0, 10))
	//			FormatEx(s, sizeof(s), "%s%d.mp3", BigSmokeTrainKill, GetRandomInt(1, 3));
	//		else strcopy(s, sizeof(s), AllWeHadToDo);
	//		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, boss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	//		EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, boss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	//	}

	return true;
}