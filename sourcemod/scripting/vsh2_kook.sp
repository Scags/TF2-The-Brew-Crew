#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#undef REQUIRE_PLUGIN
#include <vsh2_achievements>
#define REQUIRE_PLUGIN
#include <scag>
#include <tf2attributes>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Space Kook", 
	author = "Scag", 
	description = "VSH2 boss Space Kook", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;
bool bAch;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("VSH2Ach_Toggle");
	MarkNativeAsOptional("VSH2Ach_AddTo");
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_kook");
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
		VSH2_Hook(OnPlayerHurt, fwdOnPlayerHurt);
		VSH2_Hook(OnBossKillBuilding, fwdOnBossKillBuilding);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
	else if (!strcmp(name, "VSH2Ach", false))
		bAch = true;
}

public void OnLibraryRemoved(const char[] name)
{
	if (!strcmp(name, "VSH2Ach", false))
		bAch = false;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_GetMaxHealth, OnGetMaxHealth);
}

public Action OnGetMaxHealth(int client, int &result)
{
	VSH2Player player = VSH2Player(client);
	if (player.bIsMinion && VSH2Player(player.iOwnerBoss).iType == ThisPluginIndex)
	{
		result = 100;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

#define KookModel 			"models/freak_fortress_2/spooky_space_kook_v3/space_kook_v3.mdl"
#define KookStart 			"opst/saxtonhale/kook/default.mp3"
#define KookKill 			"opst/saxtonhale/kook/kill"//3
#define KookStab 			"opst/saxtonhale/kook/ouch.mp3"
#define KookDed 			"opst/saxtonhale/kook/dead.mp3"
#define KookTheme 			"opst/saxtonhale/kook/theme"//3

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;
	
	PrepareMaterial("materials/freak_fortress_2/spooky_space_kook/kook_texture");
	PrepareModel(KookModel);

	PrepareSound(KookStab);
	PrepareSound(KookDed);
	PrepareSound(KookStart);
	for (i = 1; i <= 3; ++i)
	{
		Format(s, PLATFORM_MAX_PATH, "%s%d.mp3", KookKill, i);
		PrepareSound(s);

		Format(s, PLATFORM_MAX_PATH, "%s%d.mp3", KookTheme, i);
		PrepareSound(s);
	}
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Spooky Space Kook:\nClimb: Hit walls to climb them.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Buff): Gain an attack and defense buff for yourself and your minions.\nDamage dealt to your minions is reflected unto you!");
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

	Player.DoGenericThink(false, _, _, _, _, false);
	if (GetEntityFlags(Player.index) & FL_ONGROUND)
		Player.iClimbs = 0;

	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	float jmp = Player.flCharge;
	if (jmp > 0.0)
		jmp *= 4.0;
	if (Player.flRAGE >= 100.0)
		ShowSyncHudText(Player.index, VSH2_BossHud(), "Climbs: %i | Rage: FULL - Call Medic (default: E) to activate\nHit walls to climb", Player.iClimbs);
	else ShowSyncHudText(Player.index, VSH2_BossHud(), "Climbs: %i | Rage: %0.1f\nHit walls to climb", Player.iClimbs, Player.flRAGE);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(KookModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %d", GetRandomInt(999, 9999));
	int assbeater = Player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", assbeater);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Sniper, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		EmitSoundToAll(KookStart);
		EmitSoundToAll(KookStart);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	TF2_AddCondition(player.index, TFCond_Buffed, 8.0);
	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);
	TF2_AddCondition(player.index, view_as<TFCond>(42), 8.0);

	VSH2Player base;
	int team = GetClientTeam(player.index);
	int i;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) != team)
			continue;

		base = VSH2Player(i);
		if (base.bIsMinion && base.iOwnerBoss == player.index)
		{
			TF2_AddCondition(i, TFCond_Buffed, 8.0);
			TF2_AddCondition(i, TFCond_HalloweenQuickHeal, 4.0);
			TF2_AddCondition(i, view_as<TFCond>(42), 8.0);
		}
	}
	
	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(KookStart, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(KookStart, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	int i = GetRandomInt(1, 3);
	switch (i)
	{
		case 1:time = 84.0;
		case 2:time = 70.0;
		case 3:time = 55.0;
	}
	Format(song, sizeof(song), "%s%d.mp3", KookTheme, i);
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "The Spooky Space Kook");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER)
		return;

	if (Attacker.iType != ThisPluginIndex)
	{
		if (Victim.bIsMinion)
		{
			VSH2Player owner = VSH2Player(Victim.iOwnerBoss);
			if (!IsClientValid(owner.index) || !IsPlayerAlive(owner.index))
				return;

			if (owner.iType != ThisPluginIndex)
				return;

			if ((VSH2GameMode_GetProperty("iSpecialRound") & (ROUND_HVH|ROUND_SURVIVAL)) && !Attacker.bIsBoss)
				Victim.bIsMinion = false;
			else
			{
				int time = 14 + RoundToCeil(Pow(30.0 - GetLivingPlayers(owner.iOtherTeam), 0.777));
				Victim.iRespawnTime = time;
				SetPawnTimer(DoRespawn, 1.0, Victim);
			}
		}
		else if (Attacker.bIsMinion)
		{
			VSH2Player owner = VSH2Player(Attacker.iOwnerBoss);
			if (IsClientValid(owner.index) && owner.iType == ThisPluginIndex && IsPlayerAlive(owner.index))
			{
				Victim.iOwnerBoss = owner.userid;
				Victim.bIsMinion = true;
				int time = 14 + RoundToCeil(Pow(30.0 - GetLivingPlayers(owner.iOtherTeam), 0.777));
				Victim.iRespawnTime = time;
				SetPawnTimer(DoRespawn, 1.0, Victim);
				//SetPawnTimer(DoKookRespawnThings, 0.2, Victim);
			}
		}
		return;
	}

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	if (event.GetInt("customkill") != TF_CUSTOM_BOOTS_STOMP)
		event.SetString("weapon", "fists");

	if (!GetRandomInt(0, 2))
	{
		char snd[PLATFORM_MAX_PATH];
		Format(snd, 256, "%s%d.mp3", KookKill, GetRandomInt(1, 3));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}

	Victim.iOwnerBoss = Attacker.userid;
	Victim.bIsMinion = true;
	int time = 14 + RoundToCeil(Pow(30.0 - GetLivingPlayers(Attacker.iOtherTeam), 0.777));
	Victim.iRespawnTime = time;
	SetPawnTimer(DoRespawn, 1.0, Victim);
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	EmitSoundToAll(KookDed, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(KookDed, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, PLATFORM_MAX_PATH, KookStab);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	Format(s, PLATFORM_MAX_PATH, "%s%d.mp3", KookKill, GetRandomInt(1, 3));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "The Spooky Space Kook");
}
public void fwdOnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	if (!victim.bIsMinion)
		return;

	if (GetClientTeam(attacker.index) == GetClientTeam(victim.index))
		return;

	VSH2Player owner = VSH2Player(victim.iOwnerBoss);
	if (IsClientValid(owner.index) && owner.iType != ThisPluginIndex)
		return;

	int damage = event.GetInt("damageamount");
	owner.iHealth -= damage;
	owner.GiveRage(damage);
	attacker.iDamage += damage;
	if (bAch)
	{
		VSH2Ach_AddTo(attacker.index, A_Damager, damage);
		VSH2Ach_AddTo(attacker.index, A_DamageKing, damage);
	}
}
public void fwdOnBossKillBuilding(const VSH2Player player, int building, Event event)
{
	if (player.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
}

public void DoKookRespawnThings(VSH2Player base)
{
	if (!IsClientValid(base.index))
		return;

	if (IsPlayerAlive(base.index))
		return;

	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	VSH2Player owner = VSH2Player(base.iOwnerBoss);
	if (!IsClientValid(owner.index) || !IsPlayerAlive(owner.index))
		return;

	base.ForceTeamChange(GetClientTeam(owner.index));
	int rand = GetRandomInt(0, 2);
	switch (rand)
	{
		case 0:TF2_SetPlayerClass(base.index, TFClass_Scout, _, false);
		case 1:TF2_SetPlayerClass(base.index, TFClass_Soldier, _, false);
		case 2:TF2_SetPlayerClass(base.index, TFClass_DemoMan, _, false);
	}
	TF2_RegeneratePlayer(base.index);
	base.PreEquip();

	switch (rand)
	{
		case 1:SetWeaponAmmo(base.SpawnWeapon("tf_weapon_rocketlauncher", 237, 100, 5, "400 ; 1.0 ; 37 ; 5.0 ; 1 ; 0.0 ; 643 ; 0.0"), 200);
		case 2:SetWeaponAmmo(base.SpawnWeapon("tf_weapon_pipebomblauncher", 265, 100, 5, "400 ; 1.0 ; 78 ; 5.0 ; 1 ; 0.0 ; 643 ; 0.0"), 200);
	}

	char attribs[256];
	FormatEx(attribs, sizeof(attribs), "58 ; 10.0 ; 99 ; 2.0%s", TF2_GetPlayerClass(base.index) == TFClass_Scout ? " ; 489 ; 1.5" : "");
	SetEntPropEnt(base.index, Prop_Send, "m_hActiveWeapon", base.SpawnWeapon("tf_weapon_stickbomb", 307, 100, 5, attribs));
	TF2Attrib_SetByDefIndex(base.index, 57, 10.0);
	TF2_AddCondition(base.index, TFCond_Ubercharged, 5.0);
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	if (!IsClientValid(client))
		return Plugin_Continue;

	VSH2Player player = VSH2Player(client);
	if (player.iType != ThisPluginIndex)
		return Plugin_Continue;

	if (player.iClimbs < 10)
	{
		if (player.ClimbWall(weapon, 600.0, 0.0, false))
		{
			player.flWeighDown = 0.0;
			player.iClimbs++;					
		}
	}
	return Plugin_Continue;
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("The Spooky Space Kook", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Spooky Space Kook");
	}
}

public void DoRespawn(const VSH2Player player)
{
	if (!player || !player.index)
		return;

	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	if (IsPlayerAlive(player.index))
		return;

	if (!player.bIsMinion)
		return;

	player.iRespawnTime--;
	if (!player.iRespawnTime)
	{
		DoKookRespawnThings(player);
		return;
	}

	SetHudTextParams(-1.0, 0.4, 1.2, 255, 255, 255, 255);
	ShowSyncHudText(player.index, VSH2_JumpHud(), "You will respawn in %d second%s.", player.iRespawnTime, player.iRespawnTime == 1 ? "" : "s");
	SetPawnTimer(DoRespawn, 1.0, player);
}