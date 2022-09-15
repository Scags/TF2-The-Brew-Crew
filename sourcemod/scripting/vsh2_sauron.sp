#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Sauron", 
	author = "Scag", 
	description = "VSH2 boss Sauron", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PreThink, OnThink);
}

public void OnThink(int client)
{
	if (VSH2Player(client).iType == ThisPluginIndex && IsPlayerAlive(client))
	{
		int vm = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
		if (vm > MaxClients && IsValidEntity(vm))
		{
			int seq = GetEntProp(vm, Prop_Send, "m_nSequence");
			int toset;
			if (seq == 4 || seq == 5)
				toset = 19;
			else if (seq == 3)
				toset = 18;

			if (toset)
				SetEntProp(vm, Prop_Send, "m_nSequence", toset);
		}
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_sauron");
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
		VSH2_Hook(OnLastPlayer, fwdOnLastPlayer);
		VSH2_Hook(OnBossDealDamage, fwdOnBossDealDamage);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define SauronModel                 	"models/freak_fortress_2/lotr_sauron/sauron2.mdl"

#define SauronGeneric 					"opst/saxtonhale/sauron/generic"	// 6
#define SauronStart 					"opst/saxtonhale/sauron/start"	// 3
#define SauronFail 						"opst/saxtonhale/sauron/fail1.mp3"
#define SauronWin 						"opst/saxtonhale/sauron/win"//3
#define SauronTheme 					"opst/saxtonhale/sauron/theme"
#define SauronStab 						"opst/saxtonhale/sauron/stab1.mp3"
#define SauronLast 						"opst/saxtonhale/sauron/last"	// 3
#define SauronRage 						"opst/saxtonhale/sauron/rage1.mp3"
#define SauronJump 						"opst/saxtonhale/sauron/jump.mp3"
#define SauronStrike 					"opst/saxtonhale/sauron/strike1.mp3"
#define SauronStrikeFinish				"opst/saxtonhale/sauron/strike2.mp3"

public void fwdOnDownloadsCalled()
{
	PrepareModel(SauronModel);
	PrepareMaterial("materials/freak_fortress_2/sauron/slow_armor");
	PrepareMaterial("materials/freak_fortress_2/sauron/slow_armor_2");
	PrepareMaterial("materials/freak_fortress_2/sauron/slow_cape");
	PrepareMaterial("materials/freak_fortress_2/sauron/slow_helmet");
	PrepareMaterial("materials/freak_fortress_2/sauron/slow_weapon");
	int i;
	char s[PLATFORM_MAX_PATH];
	for (i = 1; i <= 6; i++)
	{
		Format(s, sizeof(s), "%s%d.mp3", SauronGeneric, i);
		PrepareSound(s);

		if (i <= 3)
		{
			Format(s, sizeof(s), "%s%d.mp3", SauronWin, i);
			PrepareSound(s);

			Format(s, sizeof(s), "%s%d.mp3", SauronStart, i);
			PrepareSound(s);

			Format(s, sizeof(s), "%s%d.mp3", SauronLast, i);
			PrepareSound(s);
		}

		if (i <= 2)
		{
			Format(s, sizeof(s), "%s%d.mp3", SauronTheme, i);
			PrepareSound(s);
		}
	}

	PrepareSound(SauronStab);
	PrepareSound(SauronFail);
	PrepareSound(SauronRage);
	PrepareSound(SauronJump);
	PrepareSound(SauronStrike);
	PrepareSound(SauronStrikeFinish);

	PrecacheSound("weapons/medigun_no_target.wav", true);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Sauron:\nWeigh-down: After 1 second in midair, look down and hold crouch\nRage 1 (Eye of Sauron): Call for medic (e) when Rage is full.\nGrants knockback immunity and wallhacks.\nRage 2 (Tele-Strike): Reload or Middle Click >= 50% to teleport your aim position.");
	panel.DrawItem( "Exit" );
	panel.Send(Player.index, PANEL, 10);
	delete panel;
}
public int PANEL(Menu menu, MenuAction action, int client, int select)
{
	return;
}
public void fwdOnBossThink(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.DoGenericThink(true, true, .strSound = SauronJump, .showhud = false, .vol = 0.75);

	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);

	float jmp = Player.flCharge;
	if (jmp > 0.0)
		jmp *= 4.0;
	if (Player.flRAGE >= 100.0)
		ShowSyncHudText(Player.index, VSH2_BossHud(), "Jump: %i | Rage: FULL - Call Medic (default: E) to activate\nReload (default: R) to Teleport", RoundFloat(jmp));
	else if (Player.flRAGE >= 50.0)
		ShowSyncHudText(Player.index, VSH2_BossHud(), "Jump: %i | Rage: %0.1f\nReload (default: R) to Teleport", RoundFloat(jmp), Player.flRAGE);
	else ShowSyncHudText(Player.index, VSH2_BossHud(), "Jump: %i | Rage: %0.1f", RoundFloat(jmp), Player.flRAGE);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(SauronModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 5.77 ; 259 ; 1.0 ; 252 ; 0.6 ; 5 ; 1.7 ; 214 ; %d", GetRandomInt(999, 9999));
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_bat", 325, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	Player.bNoRagdoll = true;
}
public void RemoveSauronGlow()
{
	TF2_KillAllGlow("PlayersOutline");
	TF2_KillAllGlow("BuildingsOutline");
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Medic, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		Format(s, sizeof(s), "%s%d.mp3", SauronStart, GetRandomInt(1, 3));
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	int client = player.index;
	TF2_AddCondition(client, TFCond_MegaHeal, 8.0);

	if ( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null); // should reset Hale's animation
	}
	int i;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == GetClientTeam(client))
			continue;

		Sauron_CreateGlow(i, "PlayersOutline");
	}

	i = -1;
	while ((i = FindEntityByClassname(i, "obj_*")) != -1)
		Sauron_CreateGlow(i, "BuildingsOutline");

	SetPawnTimer(RemoveSauronGlow, 16.0);

	EmitSoundToAll(SauronRage, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(SauronRage, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	int i = GetRandomInt(1, 2);
	switch (i)
	{
		case 1:time = 276.0;
		case 2:time = 165.0;
	}
	Format(song, sizeof(song), "%s%d.mp3", SauronTheme, i);
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Sauron");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	if (!GetRandomInt(0, 1))
	{
		char snd[PLATFORM_MAX_PATH];
		Format(snd, sizeof(snd), "%s%d.mp3", SauronGeneric, GetRandomInt(1, 6));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	EmitSoundToAll(SauronFail, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(SauronFail, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, PLATFORM_MAX_PATH, SauronStab);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	Format(s, PLATFORM_MAX_PATH, "%s%d.mp3", SauronWin, GetRandomInt(1, 3));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Sauron");
}
public void fwdOnLastPlayer(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%d.mp3", SauronLast, GetRandomInt(1, 3));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossDealDamage(VSH2Player Victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player fighter = VSH2Player(attacker);
	if (fighter.iType == ThisPluginIndex)
	{
		TE_SetupMetalSparks(damagePosition, NULL_VECTOR);
		TE_SendToAll();
	}
	return Plugin_Continue;
}
public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	VSH2Player player = VSH2Player(client);
	if (player.iType == ThisPluginIndex && IsPlayerAlive(player.index) && (buttons & (IN_RELOAD|IN_ATTACK3)) && player.flRAGE >= 50.0 && !(GetEntProp(client, Prop_Data, "m_nOldButtons") & (IN_RELOAD|IN_ATTACK3)))
		ShadowStrike(player);
}

public void ShadowStrike(const VSH2Player player)
{
	int client = player.index;

	float vecPos[3]; GetClientEyePosition(client, vecPos);
	float vecAng[3]; GetClientEyeAngles(client, vecAng);
	TR_TraceRayFilter(vecPos, vecAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

	if (!TR_DidHit())
	{
		EmitSoundToClient(client, "weapons/medigun_no_target.wav");
		return;
	}

	char classname[32];
	int TRIndex = TR_GetEntityIndex();
	GetEdictClassname(TRIndex, classname, sizeof(classname));
	if (!StrEqual(classname, "worldspawn"))
	{
		EmitSoundToClient(client, "weapons/medigun_no_target.wav");
		return;
	}

	float pos[3];
	TR_GetEndPosition(pos);
	bool free;

	float cpy[3]; cpy = pos;
	float flMins[3]; GetEntPropVector(client, Prop_Send, "m_vecMins", flMins);
	float flMaxs[3]; GetEntPropVector(client, Prop_Send, "m_vecMaxs", flMaxs);
	flMins[2] += 2.0;

	for (float i = 1.0; i < 10.0; ++i)
	{
		cpy = pos;
		cpy[0] += i;
		TR_TraceHullFilter(cpy, cpy, flMins, flMaxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client);
		if (!TR_DidHit())
		{
			free = true;
			break;
		}
		cpy = pos;
		cpy[1] += i;
		TR_TraceHullFilter(cpy, cpy, flMins, flMaxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client);
		if (!TR_DidHit())
		{
			free = true;
			break;
		}
		cpy = pos;
		cpy[2] -= i;
		TR_TraceHullFilter(cpy, cpy, flMins, flMaxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client);
		if (!TR_DidHit())
		{
			free = true;
			break;
		}
		cpy = pos;
		cpy[0] -= i;
		TR_TraceHullFilter(cpy, cpy, flMins, flMaxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client);
		if (!TR_DidHit())
		{
			free = true;
			break;
		}
		cpy = pos;
		cpy[1] -= i;
		TR_TraceHullFilter(cpy, cpy, flMins, flMaxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client);
		if (!TR_DidHit())
		{
			free = true;
			break;
		}
		cpy = pos;
		cpy[2] -= i;
		TR_TraceHullFilter(cpy, cpy, flMins, flMaxs, MASK_PLAYERSOLID, TraceEntityFilterPlayer, client);
		if (!TR_DidHit())
		{
			free = true;
			break;
		}
	}

	if (!free)
	{
		EmitSoundToClient(client, "weapons/medigun_no_target.wav");
		return;
	}

	CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation", _, false)));
	TeleportEntity(client, cpy, nullvec, nullvec);
	CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation", _, false)));

//	pThrower->SetFOV( pThrower, 0, 0.3f, 120 );
//
//	// Screen flash
//	color32 fadeColor = {255,255,255,100};
//	UTIL_ScreenFade( pThrower, fadeColor, 0.25, 0.4, FFADE_IN );

	EmitSoundToAll(SauronStrike/*, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, false, 0.0*/);
	EmitSoundToAll(SauronStrike/*, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, false, 0.0*/);
	SetPawnTimer(SSFinish, 0.8);
	player.flRAGE -= 50.0;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
	return entity > MaxClients || !entity;
}

public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

public void SSFinish()
{
	EmitSoundToAll(SauronStrikeFinish);
	EmitSoundToAll(SauronStrikeFinish);
}

stock int Sauron_CreateGlow(int iEnt, char[] strTargetname)
{
	char strGlowColor[18];
	switch(GetEntProp(iEnt, Prop_Send, "m_iTeamNum"))
	{
		case (2):Format(strGlowColor, sizeof(strGlowColor), "%i %i %i %i", 255, 51, 51, 255);
		case (3):Format(strGlowColor, sizeof(strGlowColor), "%i %i %i %i", 153, 194, 216, 255);
		default: return -1;
	}
	
	char oldEntName[64];
	GetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));
	
	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);

	int ent = CreateEntityByName("tf_glow");
	if (IsValidEntity(ent))
	{
		SDKHook(ent, SDKHook_SetTransmit, Sauron_GlowTransmit);
		DispatchKeyValue(ent, "targetname", strTargetname);
		DispatchKeyValue(ent, "target", strName);
		DispatchKeyValue(ent, "Mode", "0");
		DispatchKeyValue(ent, "GlowColor", strGlowColor);	
		DispatchSpawn(ent);

		AcceptEntityInput(ent, "Enable");
		
		//Change name back to old name because we don't need it anymore.
		SetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName);
		return ent;
	}
	return -1;
}

public Action Sauron_GlowTransmit(int entity, int client) 
{
	SetEdictFlags(entity, GetEdictFlags(entity) & ~FL_EDICT_ALWAYS);
	if (!(VSH2Player(client).bIsBoss))
		return Plugin_Handled;
	
	char strName[64];
	GetEntPropString(entity, Prop_Data, "m_iName", strName, sizeof(strName));
	if(StrEqual(strName, "PlayersOutline"))
		return Plugin_Continue;
	else if(StrEqual(strName, "BuildingsOutline"))
		return Plugin_Continue;
	
	return Plugin_Handled;
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Sauron", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Sauron");
	}
}