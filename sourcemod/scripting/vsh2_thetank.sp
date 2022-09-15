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
	name = "VSH2 - The Tank", 
	author = "Scag", 
	description = "VSH2 boss The Tank", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnPluginStart()
{
	AddNormalSoundHook(SoundHook);
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_thetank");
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
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define TankModel				"models/freak_fortress_2/tank/tank_v1.mdl"

#define TankKill			"opst/saxtonhale/thetank/kill" //1-6
#define TankStart			"opst/saxtonhale/thetank/intro.mp3"
#define TankFail			"opst/saxtonhale/thetank/lost" //1-2
#define TankJump			"opst/saxtonhale/thetank/jump" //1-3
#define TankRage			"opst/saxtonhale/thetank/rage" //1-2
#define TankWin				"opst/saxtonhale/thetank/win1.mp3"
#define TankStab			"opst/saxtonhale/thetank/stab.mp3"
#define TankTheme			"opst/saxtonhale/thetank/theme1.mp3"
#define TankThrow			"opst/saxtonhale/thetank/rockthrow.mp3"
#define TankRockLand		"opst/saxtonhale/thetank/rockland" //1-3

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;
	PrepareModel(TankModel);
	PrepareMaterial("materials/freak_fortress_2/tank/tank_t");

	for (i = 1; i <= 6; i++) 
	{
		if (i <= 2) 
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankRage, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankFail, i);
			PrepareSound(s);
		}

		if (i <= 3)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankJump, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankRockLand, i);
			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankKill, i);
		PrepareSound(s);
	}

	PrepareSound(TankStart);
	PrepareSound(TankJump);
	PrepareSound(TankWin);
	PrepareSound(TankTheme);
	PrepareSound(TankStab);

	PrecacheModel("models/props_coalmines/boulder1.mdl", true);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("The Tank:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Rock Throw): Call for medic (e) when Rage is full.\nThrow a boulder at players!");
	panel.DrawItem( "Exit" );
	panel.Send(Player.index, PANEL, 10);
	delete (panel);
}
public int PANEL(Menu menu, MenuAction action, int client, int select)
{
	return;
}
public void fwdOnBossThink(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.DoGenericThink(true, true, TankJump, 3);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(TankModel);
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
		strcopy(s, PLATFORM_MAX_PATH, TankStart);
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	TF2_AddCondition(player.index, TFCond_DefenseBuffNoCritBlock, 4.0);
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", TankRage, GetRandomInt(1, 2));
	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);

	int wep = player.SpawnWeapon("tf_weapon_cleaver", 812, 100, 5, "");
	SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
	SetWeaponAmmo(wep, 1);
	SetEntityModel(wep, "models/props_coalmines/boulder1.mdl");
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	strcopy(song, sizeof(song), TankTheme);
	time = 80.0;
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "The Tank");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	if (event.GetInt("damagebits") & DMG_SLASH)
	{
		event.SetString("weapon", "tf_pumpkin_bomb");
		event.SetInt("customkill", TF_CUSTOM_PUMPKIN_BOMB);
	}

	if (!GetRandomInt(0, 1))
	{
		char s[PLATFORM_MAX_PATH];
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankKill, GetRandomInt(1, 6));
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankFail, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, FULLPATH, TankStab);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, sizeof(s), TankWin);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iType == ThisPluginIndex)
		strcopy(s, sizeof(s), "The Tank");
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("The Tank", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Tank");
	}
}

public void OnEntityCreated(int ent, const char[] classname)
{
	if (!strcmp(classname, "tf_projectile_cleaver"))
		SDKHook(ent, SDKHook_SpawnPost, CleaverSpawnPost);
}

public void CleaverSpawnPost(int ent)
{
	int owner = GetOwner(ent);
	if (IsClientValid(owner) && VSH2Player(owner).iType == ThisPluginIndex)
	{
		SetEntityModel(ent, "models/props_coalmines/boulder1.mdl");
		SetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(owner, 2));
	}
}

/*public void CleaverThink(int ent)
{
	float maxs[3], mins[3];
	GetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxs);
	GetEntPropVector(ent, Prop_Send, "m_vecMins", mins);
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hThrower");
	TR_TraceHullFilter(pos, pos, mins, maxs, MASK_ALL, RockTrace, owner);

	if (TR_DidHit())
		return;

	int other = TR_GetEntityIndex();
	if (other == owner || other > MaxClients)
		return;

	ExplodeRock(ent, owner, other, pos);
}*/

public void ExplodeRock(int ent, int owner)
{
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	float otherpos[3];
	float dist;
	int i;

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == GetClientTeam(owner))
			continue;

		if (!TF2_IsKillable(i))
			continue;

		GetClientAbsOrigin(i, otherpos);

		if ((dist = GetVectorDistance(pos, otherpos)) > 400.0)
			continue;

		TR_TraceRayFilter(pos, otherpos, MASK_SHOT|CONTENTS_GRATE, RayType_EndPoint, RockTrace, i);
		if (TR_DidHit())
			continue;

		float mult = (1 - dist / 400.0);
		SDKHooks_TakeDamage(i, owner, owner, 100.0*mult, DMG_SLASH|DMG_PREVENT_PHYSICS_FORCE, _, pos);
		CreateTimer(5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
		TF2_StunPlayer(i, 5.0, _, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, owner);
	}

	i = -1;
	while ((i = FindEntityByClassname(i, "obj_*")) != -1)
	{
		if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(owner))
			continue;
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", otherpos);
		if ((dist = GetVectorDistance(pos, otherpos)) > 400.0)
			continue;

		TR_TraceRayFilter(pos, otherpos, MASK_SHOT|CONTENTS_GRATE, RayType_EndPoint, RockTrace, i);
		if (TR_DidHit())
			continue;

		SetEntProp(i, Prop_Send, "m_bDisabled", 1);
		SetPawnTimer(ReEnableBuilding, 4.0*(1 - dist / 400.0), EntIndexToEntRef(i));
	}

	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%i.mp3", TankRockLand, GetRandomInt(1, 3));
	EmitSoundToAll(s, .origin = pos);

	TF2_RemoveWeaponSlot(owner, TFWeaponSlot_Secondary);
	RemoveEntity(ent);
	TE_SetupDust(pos, NULL_VECTOR, 80.0, 80.0);
	TE_SendToAll();
	DoExplosion(owner, 0, 400, pos);
}

public bool RockTrace(int ent, int mask, any data)
{
	return ent <= 0;
}

public void ReEnableBuilding(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (ent > MaxClients && IsValidEntity(ent))
		SetEntProp(ent, Prop_Send, "m_bDisabled", 0);
}
public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

public Action SoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (entity <= MaxClients)
		return;

	if (!strncmp(sample, ")weapons\\cleaver_hit", 20, false))
	{
		VSH2Player owner = VSH2Player(GetEntPropEnt(entity, Prop_Send, "m_hThrower"));
		if (IsClientValid(owner.index) && owner.iType == ThisPluginIndex)
		{
//			PrintToChatAll("AAA");
			ExplodeRock(entity, owner.index);
		}
	}
}

public Action TF2_CalcIsAttackCritical(int client, int wep, char[] wpnname, bool &result)
{
	VSH2Player player = VSH2Player(client);
	if (player.iType == ThisPluginIndex && wep == GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
	{
		EmitSoundToAll(TankThrow, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(TankThrow, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}