#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <sdktools>
#include <vsh2>
#include <scag>
#include <tf2attributes>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Genos", 
	author = "Scag", 
	description = "VSH2 boss Genos", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;
//int g_iTrail;
int iLaserBeam, iHalo;
float g_vecEndPos[MAXPLAYERS + 1][3];

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_genos");
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
		VSH2_Hook(OnBossKillBuilding, fwdOnBossKillBuilding);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
	}
}

#define GenosModel			"models/freak_fortress_2/genos/genos.mdl"

#define GenosKill			"tbc/saxtonhale/genos/kill" //1-6
#define GenosStart			"tbc/saxtonhale/genos/start1.mp3"
#define GenosFail			"tbc/saxtonhale/genos/dead1.mp3"
#define GenosJump			"tbc/saxtonhale/genos/jump"//2
#define GenosRage			"tbc/saxtonhale/genos/rage.mp3"
#define GenosWin			"tbc/saxtonhale/genos/win"//2
#define GenosTheme			"tbc/saxtonhale/genos/theme1.mp3"

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;

	for (i = 1; i <= 6; i++) 
	{
		if (i <= 2)
		{
			FormatEx(s, PLATFORM_MAX_PATH, "%s%i.mp3", GenosJump, i);
			PrepareSound(s);

			FormatEx(s, PLATFORM_MAX_PATH, "%s%i.mp3", GenosWin, i);
			PrepareSound(s);
		}
		FormatEx(s, PLATFORM_MAX_PATH, "%s%i.mp3", GenosKill, i);
		PrepareSound(s);
	}

	PrepareSound(GenosStart);
	PrepareSound(GenosFail);
	PrepareSound(GenosTheme);
	PrepareSound(GenosRage);

	PrepareModel(GenosModel);

//	g_iTrail = PrecacheModel("materials/effects/beam_blue.vmt", true);
	iLaserBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	iHalo = PrecacheModel("materials/sprites/glow01.vmt", true);

	PrepareMaterialDir(false, "materials/models/yourtoast4/onepunchman/genos");
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Genos:\nSuper Jump: Look up and right click.\nYou can chain your jumps together!\nWeigh-down: After 5 seconds in midair, look down and hold crouch\nRage (Spiral Incineration Cannon): Call for medic (e) when Rage is full.\nLaunch a controllable beam!");
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

	Player.DoGenericThink(.showhud = false, .jump = false);

	if (Player.flCharge < 0.0)
	{
		float scale = Player.iDifficulty <= 3 ? 1.5 : 1.0;
		Player.flCharge += scale;
	}

	if (Player.iClimbs >= 3)
		Player.flCharge = -100.0;
	else if (Player.flCharge >= 0.0)
	{
		Player.flCharge = -100.0;
		++Player.iClimbs;
	}

	Handle hud = VSH2_BossHud();
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	char jumpstr[32];
	IntToString(RoundFloat(100.0 + Player.flCharge), jumpstr, sizeof(jumpstr));

	if (Player.flRAGE >= 100.0)
		ShowSyncHudText(Player.index, hud, "Jumps: %d | Jump: %s | Rage: FULL - Call Medic (default: E) to activate", Player.iClimbs, jumpstr);
	else ShowSyncHudText(Player.index, hud, "Jumps: %d | Jump: %s | Rage: %0.1f", Player.iClimbs, jumpstr, Player.flRAGE);
}
public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	if (!IsPlayerAlive(client))
		return Plugin_Continue;

	VSH2Player player = VSH2Player(client);
	if (player.iType != ThisPluginIndex)
		return Plugin_Continue;

	if (buttons & IN_ATTACK2 && !(GetEntProp(client, Prop_Data, "m_nOldButtons") & IN_ATTACK2))
	{
		float EyeAngles[3]; GetClientEyeAngles(client, EyeAngles);
		if ( player.iClimbs > 0 && EyeAngles[0] < -5.0 )
		{
			float vLoc[3]; //position
			float vAng[3]; //angle
			float vVel[3]; //velocity

			GetEntPropVector(client, Prop_Send, "m_vecOrigin", vLoc);
			vLoc[2] += GetEntityHeight(client, 0.25);
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
			GetClientEyeAngles(client, vAng);
			GetAngleVectors(vAng, vAng, NULL_VECTOR, NULL_VECTOR);
			vVel[0] = vAng[0]*700.0;
			vVel[1] = vAng[1]*700.0;
			vVel[2] = 200.0 + vAng[2]*800.0;

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
			player.flWeighDown = 0.0;
			SetPawnTimer(RemoveEnt, 1.2, EntIndexToEntRef(CreateRocketTrail(client, "rockettrail")));
			SetPawnTimer(RemoveEnt, 2.0, EntIndexToEntRef(CreateParticleBlast(client, "heavy_ring_of_fire", vLoc)));

			char s[PLATFORM_MAX_PATH];
			FormatEx(s, sizeof(s), "%s%i.mp3", GenosJump, GetRandomInt(1, 2));
			float pos[3]; GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_DISHWASHER, SND_CHANGEVOL, 0.5, 100, player.index, pos, NULL_VECTOR, false, 0.0);
			EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_DISHWASHER, SND_CHANGEVOL, 0.5, 100, player.index, pos, NULL_VECTOR, false, 0.0);
			--player.iClimbs;
		}
	}
	if (buttons & IN_ATTACK)
	{
		if (player.flSpecial2 > GetGameTime())
		{
			buttons &= ~IN_ATTACK;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(GenosModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];

	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.7 ; 214 ; %i", GetRandomInt(9999, 99999));
	int assbeater = Player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", assbeater);
	Player.iSpecial = -1;
	Player.iSpecial2 = -1;
	Player.flSpecial2 = 0.0;
	Player.iClimbs = 0;	
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Spy, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		strcopy(s, PLATFORM_MAX_PATH, GenosStart);
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	float pos[3]; GetClientAbsOrigin(player.index, pos);
//	EmitSoundToAll(GenosRage);
	EmitSoundToAll(GenosRage);

	TF2_AddCondition(player.index, TFCond_PasstimeInterception, 10.0);
	SetEntityMoveType(player.index, MOVETYPE_NONE);
	SetPawnTimer(GenosFire, 4.3, player);
	SetPawnTimer(GenosReset, 10.0, player);
	player.flSpecial2 = GetGameTime() + 10.0;
}
public void GenosFire(VSH2Player player)
{
	if (IsClientValid(player.index) && IsPlayerAlive(player.index))
		Kamehameha(player);
}

public void GenosReset(VSH2Player player)
{
	if (IsClientValid(player.index))
	{
		TF2_RemoveCondition(player.index, TFCond_PasstimeInterception);
		SetEntityMoveType(player.index, MOVETYPE_WALK);
	}
}
public void fwdOnMusic(char song[FULLPATH], float &time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	strcopy(song, sizeof(song), GenosTheme);
	time = 128.0;
}
public void fwdOnBossMenu(Menu &menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Genos");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	if (event.GetInt("customkill") != TF_CUSTOM_BOOTS_STOMP)
	{
		if (event.GetInt("damagebits") & (DMG_PREVENT_PHYSICS_FORCE|DMG_BURN|DMG_DISSOLVE) == (DMG_PREVENT_PHYSICS_FORCE|DMG_BURN|DMG_DISSOLVE))
		{
			event.SetString("weapon", "tf_pumpkin_bomb");
			event.SetInt("customkill", TF_CUSTOM_PUMPKIN_BOMB);
		}
		else event.SetString("weapon", "fists");
	}

	if (Victim.index == Attacker.index)
	{
		event.SetString("weapon", "fists");
		return;
	}

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", GenosKill, GetRandomInt(1, 6));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	EmitSoundToAll(GenosFail, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(GenosFail, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

//	char s[PLATFORM_MAX_PATH];
//	strcopy(s, FULLPATH, GenosStab);
//	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	FormatEx(s, sizeof(s), "%s%i.mp3", GenosWin, GetRandomInt(1, 2));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Genos");
}
public void fwdOnBossKillBuilding(const VSH2Player player, int building, Event event)
{
	if (player.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
}

public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Genos", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Genos");
	}
}

stock int CreateRocketTrail(int client, const char[] particlename)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "angles", "-90.0, 0.0, 0.0"); 
		DispatchSpawn(particle);

		float pos[3]; GetClientAbsOrigin(client, pos);
		TeleportEntity(particle, pos);

		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", client);
		ActivateEntity(particle);
		SetVariantString("flag");
		AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset");

		AcceptEntityInput(particle, "start");
	}
	return particle;
}

stock int CreateParticleBlast(int entity, const char[] particlename, float vloc[3])
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		char tName[32];
		Format(tName, sizeof(tName), "target%i", entity);
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, vloc, NULL_VECTOR, NULL_VECTOR);
	}
	return particle;
}

public void Kamehameha(VSH2Player player)
{
	int client = player.index;
	float vecView[3], vecFwd[3], vecPos[3];

	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);

	vecPos[0] += vecFwd[0] * 50.0;
	vecPos[1] += vecFwd[1] * 50.0;
	vecPos[2] += vecFwd[2] * 50.0;
	
	int prop = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(prop, "targetname", "kamehameha"); 
	DispatchKeyValue(prop, "spawnflags", "4"); 
	DispatchKeyValue(prop, "model", "models/player/sniper.mdl");
	DispatchKeyValueFloat(prop, "modelscale", 0.1);
	TeleportEntity(prop, vecPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(prop);
	ActivateEntity(prop);
	SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(prop, Prop_Send, "m_fEffects", 32); //EF_NODRAW
	player.iSpecial = EntIndexToEntRef(prop);

	int ent = CreateEntityByName("env_sprite_oriented");
	DispatchKeyValue(ent, "spawnflags", "1");
	float fscale = 127.0;
	DispatchKeyValueFloat(ent, "scale", fscale);
	DispatchKeyValue(ent, "model", "materials/effects/beam_blue.vmt");
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
	TeleportEntity(ent, vecPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(ent);
	player.iSpecial2 = EntIndexToEntRef(ent);

	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", prop);
	player.flSpecial = GetGameTime() + 0.5;

	CreateTimer(0.1, Timer_Beam, player, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Beam(Handle timer, VSH2Player player)
{
	if (!IsClientValid(player.index))
		return Plugin_Stop;

	int entity = EntRefToEntIndex(player.iSpecial);
	if (entity == INVALID_ENT_REFERENCE)
		return Plugin_Stop;
	
	if (!IsPlayerAlive(player.index))
	{
		EndKameBeam(player.index, entity);
		return Plugin_Stop;
	}

	int client = player.index;
	float entityPos[3];
	float eyeAngles[3], eyePos[3];
	GetClientEyeAngles(client, eyeAngles);
	GetClientEyePosition(client, eyePos);
	
	//Allow steering kamehameha with no weapon at all
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAngles, MASK_SHOT & (~CONTENTS_HITBOX), RayType_Infinite, TraceFilterNotSelf, client);
	if(TR_DidHit(trace))
		TR_GetEndPosition(g_vecEndPos[client], trace);
	CloseHandle(trace);

	float entityVel[3];

	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);
	float distance = GetVectorDistance(g_vecEndPos[client], entityPos);
	float time = distance / 1500.0;

	entityVel[0] = (g_vecEndPos[client][0] - entityPos[0]) / time;
	entityVel[1] = (g_vecEndPos[client][1] - entityPos[1]) / time;
	entityVel[2] = (g_vecEndPos[client][2] - entityPos[2]) / time;
	
	TeleportEntity(entity, NULL_VECTOR, view_as<float>({0.0,0.0,0.0}), entityVel);
	int color[4] =  { 0, 230, 230, 200 };

	float scale = 127.0;
	TE_SetupBeamFollow(entity, iHalo, iLaserBeam, 3.0, scale, scale+0.1, 0, color);
	TE_SendToAll();
	
	float vecMins[3], vecMaxs[3];
	vecMins[0] = -20.0;
	vecMins[1] = -20.0;
	vecMins[2] = -20.0;
	
	vecMaxs[0] = 20.0;
	vecMaxs[1] = 20.0;
	vecMaxs[2] = 20.0;
	entityPos[2] += 10.0;
//	PrintToChatAll("%d {%.1f %.1f %.1f}", entity, entityPos[0], entityPos[1], entityPos[2]);
//	TE_DrawBox(client, entityPos, vecMins, vecMaxs, _, color);

	if (player.flSpecial < GetGameTime())
	{
		TR_TraceHullFilter(entityPos, entityPos, vecMins, vecMaxs, MASK_PLAYERSOLID, TraceFilterWorldPlayers, client);
		if (TR_DidHit())
		{
			EndKameBeam(client, entity);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public void EndKameBeam(int client, int entity)
{
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteFloat(pos[0]);
	pack.WriteFloat(pos[1]);
	pack.WriteFloat(pos[2]);
	RequestFrame(DoDoExplosion, pack);

//	DoExplosion(client, 500, 500, pos);
	float Flash[3], Collumn[3];
	
	Flash[0] = pos[0];
	Flash[1] = pos[1];
	Flash[2] = pos[2];
	
	Collumn[0] = pos[0];
	Collumn[1] = pos[1];
	Collumn[2] = pos[2];
	
	pos[2] += 6.0;
	Flash[2] += 236.0;
	Collumn[2] += 1652.0;

	EmitSoundToAll("misc/doomsday_missile_explosion.wav");

//	ShowParticle(pos, "base_destroyed_smoke_doomsday", 30.0);
	ShowParticle(Flash, "flash_doomsday", 10.0);
	ShowParticle(Collumn, "dooms_nuke_collumn", 30.0);

	int shaker = CreateEntityByName("env_shake");
	if(shaker != -1)
	{
		DispatchKeyValue(shaker, "amplitude", "50");
		DispatchKeyValue(shaker, "radius", "8000");
		DispatchKeyValue(shaker, "duration", "4");
		DispatchKeyValue(shaker, "frequency", "50");
		DispatchKeyValue(shaker, "spawnflags", "4");

		TeleportEntity(shaker, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(shaker, "StartShake");
		DispatchSpawn(shaker);
		
		SetPawnTimer(RemoveEnt, 10.0, EntIndexToEntRef(shaker)); 
	}

	RemoveEntity(entity);
	VSH2Player(client).iSpecial = -1;
	VSH2Player(client).iSpecial2 = -1;
	VSH2Player(client).flSpecial2 = 0.0;
	SetEntityMoveType(client, MOVETYPE_WALK);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, view_as< float >({0.0, 0.0, 0.0}));
}

public void DoDoExplosion(DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	float pos[3];
	pos[0] = pack.ReadFloat();
	pos[1] = pack.ReadFloat();
	pos[2] = pack.ReadFloat();
	delete pack;
	float otherpos[3];

//	TE_DrawBox(client, pos, view_as< float >({-75.0, -75.0, -75.0}), view_as< float >({75.0, 75.0, 75.0}), 2.0, {255, 255, 255, 255});

	int i;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == GetClientTeam(client))
			continue;

		if (!TF2_IsKillable(i))
			continue;

		GetClientAbsOrigin(i, otherpos);

		if (GetVectorDistance(pos, otherpos) > 500.0)
			continue;

		TR_TraceRayFilter(pos, otherpos, MASK_SHOT|CONTENTS_GRATE, RayType_EndPoint, RockTrace, i);
		if (TR_DidHit())
			continue;

		SDKHooks_TakeDamage(i, client, client, 500.0, DMG_PREVENT_PHYSICS_FORCE|DMG_BURN|DMG_DISSOLVE);
	}

	i = -1;
	while ((i = FindEntityByClassname(i, "obj_*")) != -1)
	{
		if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(client))
			continue;

		GetEntPropVector(i, Prop_Send, "m_vecOrigin", otherpos);
		if (GetVectorDistance(pos, otherpos) > 500.0)
			continue;

		TR_TraceRayFilter(pos, otherpos, MASK_SHOT|CONTENTS_GRATE, RayType_EndPoint, RockTrace, i);
		if (TR_DidHit())
			continue;

		SDKHooks_TakeDamage(i, client, client, 500.0, DMG_PREVENT_PHYSICS_FORCE|DMG_BURN|DMG_DISSOLVE);
	}
}

stock float GetEntityHeight(int entity, float mult)
{
	if(IsValidEntity(entity))
	{
		if(HasEntProp(entity, Prop_Send, "m_vecMaxs"))
		{
			float height[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", height);
			return height[2]*mult;
		}
	}
	return -1.0;
}
public void RemoveEnt(any data)
{
	if (IsValidEntity(data))
		RemoveEntity(data);
}
public bool TraceFilterNotSelf(int entityhit, int mask, any entity)
{
	if(entity == 0 && entityhit != entity)
		return true;
	
	return false;
}

public bool TraceFilterWorldPlayers(int entityhit, int mask, any entity)
{
	if (0 < entityhit <= MaxClients && GetClientTeam(entityhit) != GetClientTeam(entity))
		SDKHooks_TakeDamage(entityhit, entity, entity, 100.0, DMG_PREVENT_PHYSICS_FORCE|DMG_BURN|DMG_DISSOLVE);

	char cls[32]; GetEntityClassname(entityhit, cls, sizeof(cls));
	if (StrEqual(cls, "worldspawn") || !strncmp(cls, "prop_", 5))
		if (entityhit != EntRefToEntIndex(VSH2Player(entity).iSpecial))
			return true;
	return false;
}
stock bool TE_DrawBox(int client, float m_vecOrigin[3], float m_vecMins[3], float m_vecMaxs[3], float flDur = 0.1, int color[4])
{
	//Trace top down
	float tStart[3]; tStart = m_vecOrigin;
	float tEnd[3];   tEnd = m_vecOrigin;
	
	tStart[2] = (tStart[2] + m_vecMaxs[2]);
	
//	TE_ShowPole(tStart, view_as<int>( { 255, 0, 255, 255 } ));
//	TE_ShowPole(tEnd, view_as<int>( { 0, 255, 255, 255 } ));
	
	Handle trace = TR_TraceHullFilterEx(tStart, tEnd, m_vecMins, m_vecMaxs, MASK_SHOT|CONTENTS_GRATE, WorldOnly, client);
	bool bDidHit = TR_DidHit(trace);
	delete trace;
	
	if( m_vecMins[0] == m_vecMaxs[0] && m_vecMins[1] == m_vecMaxs[1] && m_vecMins[2] == m_vecMaxs[2] )
	{
		m_vecMins = view_as<float>({-15.0, -15.0, -15.0});
		m_vecMaxs = view_as<float>({15.0, 15.0, 15.0});
	}
	else
	{
		AddVectors(m_vecOrigin, m_vecMaxs, m_vecMaxs);
		AddVectors(m_vecOrigin, m_vecMins, m_vecMins);
	}
	
	float vPos1[3], vPos2[3], vPos3[3], vPos4[3], vPos5[3], vPos6[3];
	vPos1 = m_vecMaxs;
	vPos1[0] = m_vecMins[0];
	vPos2 = m_vecMaxs;
	vPos2[1] = m_vecMins[1];
	vPos3 = m_vecMaxs;
	vPos3[2] = m_vecMins[2];
	vPos4 = m_vecMins;
	vPos4[0] = m_vecMaxs[0];
	vPos5 = m_vecMins;
	vPos5[1] = m_vecMaxs[1];
	vPos6 = m_vecMins;
	vPos6[2] = m_vecMaxs[2];

	TE_SendBeam(client, m_vecMaxs, vPos1, flDur, color);
	TE_SendBeam(client, m_vecMaxs, vPos2, flDur, color);
	TE_SendBeam(client, m_vecMaxs, vPos3, flDur, color);
	TE_SendBeam(client, vPos6, vPos1, flDur, color);
	TE_SendBeam(client, vPos6, vPos2, flDur, color);
	TE_SendBeam(client, vPos6, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos4, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos5, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos5, vPos1, flDur, color);
	TE_SendBeam(client, vPos5, vPos3, flDur, color);
	TE_SendBeam(client, vPos4, vPos3, flDur, color);
	TE_SendBeam(client, vPos4, vPos2, flDur, color);
		
	return bDidHit;
}

public bool WorldOnly(int ent, int mask, any data)
{
	return ent <= 0;
}

stock void TE_SendBeam(int client, float m_vecMins[3], float m_vecMaxs[3], float flDur = 0.1, int color[4])
{
	TE_SetupBeamPoints(m_vecMins, m_vecMaxs, iLaserBeam, iHalo, 0, 0, flDur, 1.0, 1.0, 1, 0.0, color, 0);
	TE_SendToClient(client);
}
public void ShowParticle(float pos[3], char[] particlename, float time)
{
    int particle = CreateEntityByName("info_particle_system");
    if (IsValidEdict(particle))
    {
        TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(particle, "effect_name", particlename);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "start");
        SetPawnTimer(RemoveEnt, time, EntIndexToEntRef(particle));
    }
}

public bool RockTrace(int ent, int mask, any data)
{
	return ent <= 0;
}
