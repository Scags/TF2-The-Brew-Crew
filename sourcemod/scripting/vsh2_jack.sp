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
	name = "VSH2 - Jack", 
	author = "Scag", 
	description = "VSH2 boss Jack", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_jack");
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
		VSH2_Hook(OnBossTakeDamage, fwdOnBossTakeDamage);
		VSH2_Hook(OnBossDealDamage, fwdOnBossDealDamage);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define JackModel 			"models/freak_fortress_2/samuraisoldier/newsamuraisoldier2.mdl"
#define JackStart 			"saxton_hale/samuraijack/start.mp3"
#define JackTheme1 			"saxton_hale/samuraijack/theme1.mp3"
#define JackTheme2 			"saxton_hale/samuraijack/theme2.mp3"

public void fwdOnDownloadsCalled()
{
	PrepareModel(JackModel);

	PrepareMaterial("materials/models/maxxy/samurai_soldier/samurai_robe_normal");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/samurai_robe");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/samurai_sandal_exp");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/samurai_sandal");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/samurai_hair_exp");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/samurai_hair");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/soldier_sfm_hands");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/samurai_robe_misc");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/soldier_head_red");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/eyeball_r");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/eyeball_l");
	PrepareMaterial("materials/models/maxxy/samurai_soldier/tongue");

	PrepareSound(JackStart);
	PrepareSound(JackTheme1);
	PrepareSound(JackTheme2);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Samurai Jack:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Wrath of Aku): Call for medic (e) when the Rage is full.\nNearby players are stunned and you become invincible for a time.\nYour swing speed and damage are proportional to your health.");
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

	Player.DoGenericThink(true);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(JackModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 2.0 ; 259 ; 1.0 ; 252 ; 0.6 ; 235 ; 1.0 ; 115 ; 1.0 ; 651 ; 0.5 ; 214 ; %d", GetRandomInt(999, 9999));
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_katana", 357, 100, 5, attribs);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Soldier, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		EmitSoundToAll(JackStart);
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	int client = player.index;

	TF2_AddCondition(client, TFCond_PasstimeInterception, 8.0);
	TF2_AddCondition(client, TFCond_MegaHeal, 8.0);
	if ( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null); // should reset Hale's animation
	}

	player.DoGenericStun(533.333);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(0, 1))
	{
		case 0:
		{
			time = 266.0;
			strcopy(song, sizeof(song), JackTheme1);
		}
		case 1:
		{
			time = 207.0;
			strcopy(song, sizeof(song), JackTheme2);
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Samurai Jack");
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Samurai Jack");
}
public Action fwdOnBossTakeDamage(VSH2Player Victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (Victim.iType == ThisPluginIndex)
	{
		if (TF2_IsPlayerInCondition(Victim.index, TFCond_PasstimeInterception))
			TF2Attrib_SetByDefIndex(Victim.index, 252, 0.0);
		else TF2Attrib_RemoveByDefIndex(Victim.index, 252);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public Action fwdOnBossDealDamage(VSH2Player Victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player fighter = VSH2Player(attacker);
	if (fighter.iType == ThisPluginIndex)
	{
		damage *= 2.0 - (float(fighter.iHealth)/float(fighter.iMaxHealth));
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool & result)
{
	if (!IsClientValid(client))
		return Plugin_Continue;

	if (VSH2Player(client).iType == ThisPluginIndex && VSH2GameMode_GetProperty("iRoundState") == StateRunning)
		RequestFrame(DoFrameRof, GetClientUserId(client));

	return Plugin_Continue;
}


public void DoFrameRof(const int userid)
{
	VSH2Player player = VSH2Player(userid, true);
	if (IsClientValid(player.index))
	{
		int wep = GetActiveWep(player.index);
		if (IsValidEntity(wep))
		{
			float rof = (GetGameTime() + 1.0) - (0.5 - (0.5 * (float(player.iHealth)/float(player.iMaxHealth))));
			SetEntPropFloat(wep, Prop_Send, "m_flNextPrimaryAttack", rof);
			SetEntPropFloat(wep, Prop_Send, "m_flNextSecondaryAttack", rof);
		}
	}
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Samurai Jack", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Samurai Jack");
	}
}