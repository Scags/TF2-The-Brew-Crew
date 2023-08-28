#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Obama", 
	author = "Scag", 
	description = "VSH2 boss Obama", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_obama");
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
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define ObamaModel			"models/player/obama/obama.mdl"
#define ObamaModelPrefix	"models/player/obama/obama"
#define ObamaTheme1			"saxton_hale/obama/mormonjesus.mp3"
#define ObamaTheme2			"saxton_hale/obama/udidntbuildthat.mp3"

#define ObamaKill			"saxton_hale/obama/kill" //1-5
#define ObamaFail			"saxton_hale/obama/dead" //1-5
#define ObamaIntro			"saxton_hale/obama/intro" //1-3
#define ObamaJump			"saxton_hale/obama/jump.mp3"
#define ObamaRage			"saxton_hale/obama/rage" //1-2
#define ObamaSpree			"saxton_hale/obama/spree" //1-3
#define ObamaBStab			"saxton_hale/obama/stab" //1-2
#define ObamaWin			"saxton_hale/obama/win" //1-3
#define SOUND_LAUNCH		"misc/doomsday_missile_launch.wav"
#define SOUND_EXPLODE		"misc/doomsday_missile_explosion.wav"
#define ROCKET_MODEL 		"models/props_doomsday/rocket_flight_doomsday.mdl"

public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	if (IsPlayerAlive(client) && VSH2GameMode_GetProperty("iRoundState") == StateRunning)
	{
		VSH2Player player = VSH2Player(client);
		if (player.iType == ThisPluginIndex && (buttons & (IN_RELOAD|IN_ATTACK3)) && player.flRAGE >= 100.0)
		{
			DoRage(player, true);
			player.flRAGE = 0.0;
		}
	}
	return Plugin_Continue;
}

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;

	PrepareMaterial("materials/models/player/obama/eyeball_l");
	PrepareMaterial("materials/models/player/obama/eyeball_r");
	PrepareMaterial("materials/models/player/obama/obama");
	PrepareMaterial("materials/models/player/obama/obama_blue");
	PrepareMaterial("materials/models/player/obama/obama_normals");
	
	PrepareModel(ObamaModel);
	
	for (i = 0; i <= 5; i++)
	{
		if (i <= 2) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaRage, i);
			PrepareSound(s);
			
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaBStab, i);
			PrepareSound(s);
		}
		if (i <= 3) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaSpree, i);
			PrepareSound(s);
			
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaWin, i);
			PrepareSound(s);
			
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaIntro, i);
			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaKill, i);
		PrepareSound(s);
			
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaFail, i);
		PrepareSound(s);
	}
	
	PrepareSound(ObamaJump);
	PrepareSound(ObamaTheme1);
	PrepareSound(ObamaTheme2);

	PrecacheSound(SOUND_LAUNCH);
	PrecacheSound(SOUND_EXPLODE);
	
	PrecacheGeneric("dooms_nuke_collumn");
	PrecacheGeneric("base_destroyed_smoke_doomsday");
	PrecacheGeneric("flash_doomsday");
	PrecacheGeneric("ping_circle");
	PrecacheGeneric("smoke_marker");

	PrecacheModel(ROCKET_MODEL);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle ("Barack Obama:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Nuke): Call for medic (e) or Reload (r) when Rage is full.\nReloading spawns a nuke where you are aiming.\nCalling for medic spawns a nuke at your location.");
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

	Player.DoGenericThink(true, true, ObamaJump);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(ObamaModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %i", GetRandomInt(9999, 99999));
	int assbeater = Player.SpawnWeapon("tf_weapon_club", 880, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", assbeater);
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
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaIntro, GetRandomInt(1, 3));
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	DoRage(player, false);
}
public void DoRage(const VSH2Player player, bool other)
{
	int client = player.index;

	float Position[3];
	if (other)
	{
		if(!SetTeleportEndPoint(client, Position))
		{
			PrintCenterText(client, "You missed.");
			VSH2GameMode_GiveBackRage(player.userid);
			return;
		}
	}
	else GetClientAbsOrigin(client, Position);

	int shaker = CreateEntityByName("env_shake");
	if(shaker != -1)
	{
		DispatchKeyValue(shaker, "amplitude", "16");
		DispatchKeyValue(shaker, "radius", "8000");
		DispatchKeyValue(shaker, "duration", "4");
		DispatchKeyValue(shaker, "frequency", "20");
		DispatchKeyValue(shaker, "spawnflags", "4");
		
		TeleportEntity(shaker, Position, NULL_VECTOR, NULL_VECTOR);
		
		DispatchSpawn(shaker);
		AcceptEntityInput(shaker, "StartShake");
		CreateTimer(10.0, Timer_Delete, EntIndexToEntRef(shaker)); 
	}

	EmitSoundToAll(SOUND_LAUNCH);
	ShowParticle(Position, "ping_circle", 5.0);
	ShowParticle(Position, "smoke_marker", 5.0);

	DataPack pack;
	CreateDataTimer(6.1, Timer_NukeHitsHere, pack);
	pack.WriteFloat(Position[0]);	//Position of effects
	pack.WriteFloat(Position[1]);
	pack.WriteFloat(Position[2]);
	pack.WriteCell(player.userid);

	MakeNuke(Position);

	TF2_AddCondition(client, TFCond_MegaHeal, 4.0);
	if ( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaRage, GetRandomInt(1, 2));
	float pos[3]; GetClientAbsOrigin(client, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, false, 0.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(1, 2))
	{
		case 1: {
			strcopy(song, sizeof(song), ObamaTheme1);
			time = 121.0;
		}
		case 2: {
			strcopy(song, sizeof(song), ObamaTheme2);
			time = 195.0;
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Barack Obama");
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
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaKill, GetRandomInt(1, 5));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	Attacker.iKills++;

	if (!(Attacker.iKills % 3)) {
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaSpree, GetRandomInt(1, 3));
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		Attacker.iKills = 0;
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ObamaFail, GetRandomInt(1, 5));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	Format(s, FULLPATH, "%s%i.mp3", ObamaBStab, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	Format(s, PLATFORM_MAX_PATH, "%s%d.mp3", ObamaWin, GetRandomInt(1, 3));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Barack Obama");
}


public Action Timer_NukeHitsHere(Handle timer, DataPack pack)
{
	pack.Reset();

	float pos[3], Flash[3], Collumn[3];
	pos[0] = pack.ReadFloat();
	pos[1] = pack.ReadFloat();
	pos[2] = pack.ReadFloat();
	
	Flash[0] = pos[0];
	Flash[1] = pos[1];
	Flash[2] = pos[2];
	
	Collumn[0] = pos[0];
	Collumn[1] = pos[1];
	Collumn[2] = pos[2];
	
	pos[2] += 6.0;
	Flash[2] += 236.0;
	Collumn[2] += 1652.0;

	EmitSoundToAll(SOUND_EXPLODE);

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
		
		CreateTimer(10.0, Timer_Delete, EntIndexToEntRef(shaker)); 
	}

	float pos2[3];
	VSH2Player player = VSH2Player(pack.ReadCell(), true);
	if (!player)
		return Plugin_Continue;

	int i;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == GetClientTeam(player.index))
			continue;

		GetClientAbsOrigin(i, pos2);
		if (GetVectorDistance(pos2, pos) > 800.0)
			continue;

		SDKHooks_TakeDamage(i, 0, player.index, 449.0, DMG_BLAST, _, _, pos);
	}

	for (i = -1; (i = FindEntityByClassname(i, "obj_*")) != -1;)
	{
		if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(player.index))
			continue;
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		if (GetVectorDistance(pos2, pos) > 800.0)
			continue;

		SDKHooks_TakeDamage(i, 0, player.index, 449.0, DMG_BLAST, _, _, pos);
	}
	return Plugin_Continue;
}
public Action Timer_Delete(Handle hTimer, any iRefEnt) 
{ 
	int iEntity = EntRefToEntIndex(iRefEnt); 
	if(iEntity > MaxClients) 
	{
		AcceptEntityInput(iEntity, "Kill"); 
		AcceptEntityInput(iEntity, "StopShake");
	}
	 
	return Plugin_Handled; 
}

public void MakeNuke(float pos[3])
{
	int nuke = CreateEntityByName("prop_dynamic_override");
	if (nuke == -1)
		return;

	char strName[32]; Format(strName, sizeof(strName), "trump_nuke_%d", GetRandomInt(0, 9999999));
	pos[1] -= 3000.0;

	DispatchKeyValue(nuke, "targetname", strName);
	SetEntProp(nuke, Prop_Send, "m_iTeamNum", 3);
	DispatchKeyValue(nuke, "skin", "1");
	SetEntityModel(nuke, ROCKET_MODEL);
	DispatchSpawn(nuke);
	TeleportEntity(nuke, pos, NULL_VECTOR, NULL_VECTOR);
	ActivateEntity(nuke);
	SetVariantString("blue_flight");
	AcceptEntityInput(nuke, "SetAnimation");

	CreateTimer(6.1, RemoveEnt, EntIndexToEntRef(nuke));
}

bool SetTeleportEndPoint(int client, float Position[3])
{
	float vAngles[3];
	float vOrigin[3];
	float vBuffer[3];
	float vStart[3];
	float Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
    //get endpoint for teleport
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer2);

	if (TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		Position[0] = vStart[0] + (vBuffer[0]*Distance);
		Position[1] = vStart[1] + (vBuffer[1]*Distance);
		Position[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		CloseHandle(trace);
		return false;
	}
	
	CloseHandle(trace);
	return true;
}

public bool TraceEntityFilterPlayer2(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
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
        CreateTimer(time, DeleteParticles, EntIndexToEntRef(particle));
    }
}
public Action DeleteParticles(Handle timer, any particle)
{
	int ent = EntRefToEntIndex(particle);

	if (ent != INVALID_ENT_REFERENCE)
	{
		char classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
			AcceptEntityInput(ent, "kill");
	}
	return Plugin_Continue;
}
public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Barack Obama", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Barack Obama");
	}
}