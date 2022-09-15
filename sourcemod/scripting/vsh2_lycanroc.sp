#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <tf2attributes>
#include <tf2items>
#include <scag>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Lycanroc", 
	author = "Scag", 
	description = "VSH2 boss Lycanroc", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_lycanroc");
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
	}
}

#define LycanrocModel			"models/freak_fortress_2/lycanroc/lycanroc.mdl"
#define LycanrocModelPrefix		"models/freak_fortress_2/lycanroc/lycanroc"

#define LycanrocKill			"saxton_hale/lycanroc/kill" //1-5
#define LycanrocStart			"saxton_hale/lycanroc/start1.mp3"
#define LycanrocFail			"saxton_hale/lycanroc/fail" //1-2
#define LycanrocJump			"saxton_hale/lycanroc/jump.mp3"
#define LycanrocRage			"saxton_hale/lycanroc/rage" //1-2
#define LycanrocWin				"saxton_hale/lycanroc/start1.mp3"
#define LycanrocStab			"saxton_hale/lycanroc/stab1.mp3"
#define LycanrocTheme			"saxton_hale/lycanroc/theme1.mp3"
#define LycanrocTheme2			"saxton_hale/lycanroc/theme2.mp3"

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;

	for (i = 0; i < sizeof(extensions); i++) {
		Format(s, PLATFORM_MAX_PATH, "%s%s", LycanrocModelPrefix, extensions[i]);
		CheckDownload(s);
	}

	PrepareMaterial("materials/freak_fortress_2/lycanroc/lycan");
	PrepareMaterial("materials/freak_fortress_2/lycanroc/body");

	for (i = 1; i <= 5; i++) 
	{
		if (i <= 2) 
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", LycanrocRage, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", LycanrocFail, i);
			PrepareSound(s);
		}			
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", LycanrocKill, i);
		PrepareSound(s);
	}

	PrepareSound(LycanrocStart);
	PrepareSound(LycanrocJump);
	PrepareSound(LycanrocWin);
	PrepareSound(LycanrocTheme);
	PrepareSound(LycanrocTheme2);
	PrepareSound(LycanrocStab);

	PrepareModel(LycanrocModel);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Lycanroc:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Midnight Form): Call for medic (e) when Rage is full.\nYou move and swing faster.");
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

	Player.DoGenericThink(true, true, LycanrocJump, .vol = 0.5);
	if (TF2_IsPlayerInCondition(Player.index, TFCond_MegaHeal))
			SetEntPropFloat(Player.index, Prop_Send, "m_flMaxspeed", 600.0);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(LycanrocModel);
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
		char s[PLATFORM_MAX_PATH];
		strcopy(s, PLATFORM_MAX_PATH, LycanrocStart);
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

	int wep = GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee);
	TF2Attrib_SetByDefIndex(wep, 396, 0.8);
	SetPawnTimer(ResetSwingSpeed, 8.0, EntIndexToEntRef(wep));
	
	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", LycanrocRage, GetRandomInt(1, 2));
	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(1, 2))
	{
		case 1:
		{
			strcopy(song, sizeof(song), LycanrocTheme);
			time = 431.0;
		}
		case 2:
		{
			strcopy(song, sizeof(song), LycanrocTheme2);
			time = 300.0;
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Lycanroc");
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
		event.SetString("weapon", "fists");

	if (Victim.index == Attacker.index)
	{
		event.SetString("weapon", "fists");
		return;
	}

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", LycanrocKill, GetRandomInt(1, 5));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", LycanrocFail, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, FULLPATH, LycanrocStab);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, sizeof(s), LycanrocWin);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Lycanroc");
}
public void fwdOnBossKillBuilding(const VSH2Player player, int building, Event event)
{
	if (player.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
}

public void ResetSwingSpeed(const int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		TF2Attrib_RemoveByDefIndex(ent, 396);
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Lycanroc", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Lycanroc");
	}
}