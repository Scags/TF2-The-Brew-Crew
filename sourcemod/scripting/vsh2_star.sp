#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - STAR_", 
	author = "Scag", 
	description = "VSH2 boss STAR_", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_star");
		VSH2_AddToFwdC(Fwd_OnBossTakeDamage, ThisPluginIndex);
		VSH2_AddToFwdC(Fwd_OnBossDealDamage, ThisPluginIndex);
		VSH2_AddToFwdC(Fwd_OnSoundHook, ThisPluginIndex);
		VSH2_UnCycle(ThisPluginIndex);

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

#define StarModel		"models/player/star_/ster.mdl"

#define StarStart		"saxton_hale/star/start.mp3"
#define StarFail		"saxton_hale/star/fail"	//1-3
#define StarKill		"saxton_hale/star/kill" //1-5
#define StarBstab		"saxton_hale/star/stab" //1-2
//#define StarKShotgun	"saxton_hale/star_kill_shotgun.wav"
//#define StarKB			"saxton_hale/star_killbuilding.wav" //1-2
//#define StarKSniper		"saxton_hale/star_killsniper.wav"
//#define StarKSoldier	"saxton_hale/star_killsoldier.wav"
//#define StarKSpree		"saxton_hale/star/kspree" //1-2
#define StarRage		"saxton_hale/star/rage" //1-3
#define StarWin			"saxton_hale/star/win.mp3"
//#define StarTheme1		"saxton_hale/star_theme1_fix.mp3"
#define StarTheme2		"saxton_hale/star_theme2.mp3"

#define STARWEIGHDOWNTIME 7.0

static const char StarMats[][] = {
	"materials/models/maxxy/enhanced_soldier_v2/eyeball_invun.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/eyeball_l.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/eyeball_r.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/invulnfx_blue.vmt",
	// "invulnfx_red.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/normal_blue.vmt",
	// "normal_red.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/shirtless_blue.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/shirtless_blue.vtf",
	// "shirtless_red.vmt",
	// "shirtless_red.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/sh_soldier_normal.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/soldier_blue.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/soldier_head_blue.vmt",
	// "soldier_head_red.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/soldier_normal.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/soldier_normal_vest.vtf",
	// "soldier_red.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/soldier_sfm_hands.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/soldier_sfm_hands.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/suit.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/suit_blue.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/suit_blue.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/suit_n.vtf",
	// "suit_red.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/vest_blue.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/vest_blue.vtf",
	// "vest_red.vmt",
	// "vest_red.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/zipper.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/zipper_blue.vmt",
	"materials/models/maxxy/enhanced_soldier_v2/zipper_blue.vtf",
	"materials/models/maxxy/enhanced_soldier_v2/zipper_n.vtf",
	// "zipper_red.vtf"
};

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	
	int i;
	
	PrepareModel(StarModel);
	
	/*PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/eyeball_invun");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/eyeball_l");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/eyeball_r");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/invulnfx_blue");
	//PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/invulnfx_red");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/normal_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/sh_soldier_normal");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/shirtless_blue");
	//PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/shirtless_red");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_head");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_head_blue");
	//PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_head_red");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_normal");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_normal_vest");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_sfm_hands");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/suit");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/suit_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/suit_n");
	//PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/suit_red");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/vest_blue");
	//PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/vest_red");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/zipper");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/zipper_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/zipper_n");
	//PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/zipper_red");*/

	DownloadMaterialList(StarMats, sizeof(StarMats));

	PrepareSound(StarStart);
	PrepareSound(StarBstab);
	PrepareSound(StarWin);
	PrepareSound(StarTheme2);

	for (i = 1; i <= 5; i++)
	{
		if (i <= 2)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", StarBstab, i);
			PrepareSound(s);
			
		}
		if (i <= 3)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", StarFail, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", StarRage, i);
			PrepareSound(s);

//			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", StarKSpree, i);
//			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", StarKill, i);
		PrepareSound(s);
	}
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	char helpstr[] = "STAR_:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 7 seconds in midair, look down and hold crouch\nRage (Jerma, the Crits!): Call for medic (e) when Rage is full.\nBe mini-crit boosted for 8 seconds.\nNearby players are stunned.";
	Panel panel = new Panel();
	panel.SetTitle (helpstr);
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

	int wep = GetPlayerWeaponSlot(Player.index, 0);
	if (IsValidEntity(wep))
		SetWeaponClip(wep, 4);

	wep = GetPlayerWeaponSlot(Player.index, 1);
	if (IsValidEntity(wep))
		SetWeaponAmmo(wep, 255);

	Player.DoGenericThink(true, false, _, _, _, _, 7.0);
	SetEntPropFloat(Player.index, Prop_Send, "m_flMaxspeed", 240.0);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(StarModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "400 ; 1.0 ; 37 ; 5.0 ; 1 ; 0.0 ; 252 ; 0.0 ; 169 ; 0.75 ; 534 ; 0.5 ; 534 ; 0.5 ; 643 ; 0.0 ; 181 ; 1.0 ; 214 ; %d", GetRandomInt(999, 9999));
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_rocketlauncher", 237, 100, 5, attribs);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	SetWeaponAmmo(SaxtonWeapon, 255);

	Format(attribs, sizeof(attribs), "137 ; 2.0 ; 138 ; 0.5 ; 337 ; 1 ; 214 ; %d", GetRandomInt(999, 9999));
	SaxtonWeapon = Player.SpawnWeapon("tf_weapon_shotgun_soldier", 10, 100, 5, attribs);
	SetEntProp(SaxtonWeapon, Prop_Send, "m_iClip1", 6);
	SetWeaponAmmo(SaxtonWeapon, 255);

	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 2.0 ; 259 ; 1.0 ; 267 ; 1.0 ; 775 ; 0.75 ; 309 ; 1.0 ; 360 ; 1 ; 214 ; %d", GetRandomInt(999, 9999));
	SaxtonWeapon = Player.SpawnWeapon("tf_weapon_shovel", 416, 100, 5, attribs);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Soldier, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		EmitSoundToAll(StarStart);
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	TF2_AddCondition(player.index, view_as<TFCond>(42), 4.0);
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	player.DoGenericStun(300.0);
	TF2_AddCondition(player.index, TFCond_Buffed, 8.0);

	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", StarRage, GetRandomInt(1, 3));

	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	strcopy(song, sizeof(song), StarTheme2);
	time = 267.0;
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "STAR_");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", StarKill, GetRandomInt(1, 5));
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%d.mp3", StarFail, GetRandomInt(1, 3));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, _, SNDVOL_NORMAL, _, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, _, SNDVOL_NORMAL, _, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	Format(s, FULLPATH, "%s%i.mp3", StarBstab, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, FULLPATH, StarWin);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "STAR_");
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("STAR_", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "STAR_");
	}
}