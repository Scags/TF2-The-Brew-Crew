#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Hitler", 
	author = "Scag", 
	description = "VSH2 boss Hitler", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;
bool Marked[34];
int iGasCount[34];

public void OnClientPutInServer(int client)
{
	Marked[client] = false;
	iGasCount[client] = 0;
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_hitler");
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
		VSH2_Hook(OnVariablesReset, fwdOnVariablesReset);
		VSH2_Hook(OnBossKillBuilding, fwdOnBossKillBuilding);
		VSH2_Hook(OnLastPlayer, fwdOnLastPlayer);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define HitlerModel 	"models/player/vatican/hitler/hitler2.mdl"

#define HitlerKill 		"saxton_hale/hitler/kill"	// 4
#define HitlerStab		"saxton_hale/hitler/stab"	// 2
#define HitlerLast		"saxton_hale/hitler/last.mp3"
#define HitlerRage		"saxton_hale/hitler/rage"	// 3
#define HitlerFail		"saxton_hale/hitler/fail"	// 4
#define HitlerStart		"saxton_hale/hitler/start.mp3"
#define HitlerWin		"saxton_hale/hitler/win"	// 2
#define HitlerTheme1	"saxton_hale/hitler/theme1.mp3"
#define HitlerTheme2	"saxton_hale/hitler/theme2.mp3"
#define HitlerJump 		"saxton_hale/hitler/jump.mp3"

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;
	PrepareModel(HitlerModel);

	for (i = 1; i <= 4; i++)
	{
		if (i <= 2)
		{
			Format(s, sizeof(s), "%s%d.mp3", HitlerStab, i);
			PrepareSound(s);

			Format(s, sizeof(s), "%s%d.mp3", HitlerWin, i);
			PrepareSound(s);
		}

		if (i <= 3)
		{
			Format(s, sizeof(s), "%s%d.mp3", HitlerRage, i);
			PrepareSound(s);

			Format(s, sizeof(s), "player/drown%d.wav", i);
			PrecacheSound(s, true);
		}

		Format(s, sizeof(s), "%s%d.mp3", HitlerFail, i);
		PrepareSound(s);

		Format(s, sizeof(s), "%s%d.mp3", HitlerKill, i);
		PrepareSound(s);
	}

	PrepareSound(HitlerLast);
	PrepareSound(HitlerStart);
	PrepareSound(HitlerJump);
	PrepareSound(HitlerTheme1);
	PrepareSound(HitlerTheme2);

	PrepareMaterial("materials/hitler/hitler");
	PrepareMaterial("materials/models/player/vatican/adolf/body");
	PrepareMaterial("materials/models/player/vatican/adolf/head");
	PrepareMaterial("materials/models/player/vatican/adolf/hitlerbody_colspec");
	PrepareMaterial("materials/models/player/vatican/adolf/hitlerbody_norms");
	PrepareMaterial("materials/models/player/vatican/adolf/hitlerhead_norms");
	PrepareMaterial("materials/models/player/vatican/adolf/hitlerhead_colspec");
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Adolf Hitler:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (The Final Solution): Call for medic (e) when the Rage is full to liquidate nearby players.");
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

	Player.DoGenericThink(true, true, HitlerJump);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(HitlerModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 37 ; 0.0 ; 252 ; 0.6 ; 214 ; %d", GetRandomInt(999, 9999));
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_bonesaw", 5, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Medic, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		EmitSoundToAll(HitlerStart);
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	TF2_AddCondition(player.index, view_as<TFCond>(42), 4.0);
	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
	  && !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player);
	}
	GasEm(player.index);

	char snd[PLATFORM_MAX_PATH];
	if (GetRandomInt(0, 4))
		Format(snd, FULLPATH, "%s%d.mp3", HitlerRage, GetRandomInt(1, 3));
	else strcopy(snd, FULLPATH, HitlerJump);

	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(0, 1))
	{
		case 0:
		{
			strcopy(song, sizeof(song), HitlerTheme1);
			time = 118.0;
		}
		case 1:
		{
			strcopy(song, sizeof(song), HitlerTheme2);
			time = 97.0;
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Adolf Hitler");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	bool deathed = Marked[Victim.index];
	int dmgbits = event.GetInt("damagebits");
	int custom = event.GetInt("customkill");

	if (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		if ((dmgbits & (DMG_VEHICLE|DMG_BURN)) && deathed)
		{
			event.SetString("weapon", "purgatory");
			event.SetInt("customkill", TF_WEAPON_GRENADE_JAR_GAS);
		}
		else if (custom != TF_CUSTOM_BOOTS_STOMP)
			event.SetString("weapon", "fists");
		return;
	}

	if ((dmgbits & (DMG_VEHICLE|DMG_BURN)) && deathed)
	{
		event.SetString("weapon", "purgatory");
		event.SetInt("customkill", TF_WEAPON_GRENADE_JAR_GAS);
	}
	else if (custom != TF_CUSTOM_BOOTS_STOMP)
		event.SetString("weapon", "fists");

	Marked[Victim.index] = false;
	iGasCount[Victim.index] = 0;

	char snd[PLATFORM_MAX_PATH];
	Format(snd, FULLPATH, "%s%d.mp3", HitlerKill, GetRandomInt(1, 4));
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, FULLPATH, "%s%d.mp3", HitlerFail, GetRandomInt(1, 4));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	Format(s, FULLPATH, "%s%d.mp3", HitlerStab, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", HitlerWin, GetRandomInt(1, 2));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Adolf Hitler");
}
public void fwdOnVariablesReset(const VSH2Player player)
{
	Marked[player.index] = false;
	iGasCount[player.index] = 0;
}
public void fwdOnBossKillBuilding(const VSH2Player player, int building, Event event)
{
	if (player.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
}
public void fwdOnLastPlayer(const VSH2Player player)
{
	if (player.iType == ThisPluginIndex)
	{
		char snd[PLATFORM_MAX_PATH];
		float pos[3]; GetClientAbsOrigin(player.index, pos);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	}
}

public void TF2_OnConditionAdded(int client, TFCond cond)
{
	int provider = GetConditionProvider(client, cond);
	if (provider && cond == TFCond_Gas && !Marked[client] && VSH2Player(provider).iType == ThisPluginIndex)
	{
		Marked[client] = true;
		iGasCount[client] = 0;
		SetPawnTimer(TheGas, 5.0, GetClientUserId(client), GetClientUserId(provider));
	}

	if (cond == TFCond_Charging && Marked[client])
		Marked[client] = false;
}
public void GasEm(const int client)
{
	float vecPos[3]; GetClientAbsOrigin(client, vecPos);
	float vecRand[3];

	vecPos[2] += 100.0;
	int gas;
	int living = GetLivingPlayers(VSH2Player(client).iOtherTeam);
	if (living < 12) living = 12;

	for (int i = 0; i < living; ++i)
	{
		gas = CreateEntityByName("tf_projectile_jar_gas");

		vecRand[0] = GetRandomFloat(-1500.0, 1500.0);
		vecRand[1] = GetRandomFloat(-1500.0, 1500.0);
		vecRand[2] = GetRandomFloat(100.0, 250.0);

		if (gas != -1)
		{
			DispatchKeyValue(gas, "solid", "6");
			DispatchKeyValue(gas, "renderfx", "0");
			DispatchKeyValue(gas, "rendercolor", "255 255 255");
			DispatchKeyValue(gas, "renderamt", "255");

			// vecRand[0] = GetRandomFloat(1000.0, 3000.0);
			// vecRand[1] = GetRandomFloat(1000.0, 3000.0);
			// vecRand[2] = GetRandomFloat(300.0, 1500.0);
			SetEntPropEnt(gas, Prop_Send, "m_hOwnerEntity", client);
			DispatchSpawn(gas);
			TeleportEntity(gas, vecPos, nullvec, vecRand);

			// RequestFrame(HookEnt, EntIndexToEntRef(gas));
		}
	}
}

public void TheGas(int id, int bossid)
{
	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	int i = GetClientOfUserId(id);
	if (!i || !IsClientInGame(i) || !IsPlayerAlive(i))
		return;

	int boss = GetClientOfUserId(bossid);
	if (!boss || !IsClientInGame(boss) || !IsPlayerAlive(boss) || !Marked[i])
		return;

	SDKHooks_TakeDamage(i, boss, boss, 5.0, DMG_VEHICLE, _, _, _);
	TF2_AddCondition(i, TFCond_LostFooting, 0.5, boss);
	float vec[3];
	float lvl = 180.0/++iGasCount[i];

	vec[0] = !GetRandomInt(0, 1) ? -lvl : lvl;
	vec[1] = !GetRandomInt(0, 1) ? -lvl : lvl;
	vec[2] = !GetRandomInt(0, 1) ? -lvl : lvl;

	SetEntPropVector(i, Prop_Send, "m_vecPunchAngle", vec);
	SetEntPropVector(i, Prop_Send, "m_vecPunchAngleVel", vec);

	char snd[PLATFORM_MAX_PATH];
	Format(snd, FULLPATH, "player/drown%d.wav", GetRandomInt(1, 3));
	EmitSoundToAll(snd, i);

	if (iGasCount[i] >= 10)
	{
		Marked[i] = false;
		iGasCount[i] = 0;
		return;
	}
	SetPawnTimer(TheGas, 1.0, id, bossid);
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Adolf Hitler", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Adolf Hitler");
	}
}