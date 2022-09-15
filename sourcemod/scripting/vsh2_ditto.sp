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
	name = "VSH2 - Ditto", 
	author = "Scag", 
	description = "VSH2 boss Ditto", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;
Handle g_VSH2;
Function g_ManageBossTransition, g_ManageBossTaunt;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_ditto");
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
		VSH2_Hook(OnBossGiveBackRage, fwdOnBossGiveBackRage);
		VSH2_Hook(OnLastPlayer, fwdOnLastPlayer);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
		g_VSH2 = VSH2_Self();
		g_ManageBossTransition = GetFunctionByName(g_VSH2, "ManageBossTransition");
		g_ManageBossTaunt = GetFunctionByName(g_VSH2, "ManageBossTaunt");
	}
}

#define DittoModel 			"models/freak_fortress_2/pokemon/ditto2.mdl"
#define Ditto1 				"opst/saxtonhale/ditto/ditto1.mp3"
#define Ditto2 				"opst/saxtonhale/ditto/ditto2.mp3"
#define DittoIntro 			"opst/saxtonhale/ditto/intro.mp3"
#define DittoTheme 			"opst/saxtonhale/ditto/dittobgm.mp3"
#define DittoDie 			"opst/saxtonhale/ditto/die.mp3"

public void fwdOnDownloadsCalled()
{
	PrepareModel(DittoModel);
	PrepareSound(Ditto1);
	PrepareSound(Ditto2);
	PrepareSound(DittoIntro);
	PrepareSound(DittoTheme);
	PrepareSound(DittoDie);
	PrepareMaterial("materials/freak_fortress_2/pokemon/ditto/ditto");
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Ditto:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Morph): Call for medic (e) when the Rage is full to morph into another boss.\nYou will rage as them and use their abilities!");
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

	Player.DoGenericThink(true, true, Ditto1);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(DittoModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 4.5 ; 259 ; 1.0 ; 775 ; 0.75 ; 252 ; 0.3 ; 214 ; %d", GetRandomInt(999, 9999));
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_slap", 1181, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	Player.bNoRagdoll = false;
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Pyro, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		strcopy(s, PLATFORM_MAX_PATH, DittoIntro);
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	player.iType = GetRandomIntExcept(0, VSH2GameMode_MaxBoss(), ThisPluginIndex);

	Call_StartFunction(g_VSH2, g_ManageBossTransition);
	Call_PushCell(player);
	Call_PushCell(true);
	Call_Finish();

	Call_StartFunction(g_VSH2, g_ManageBossTaunt);
	Call_PushCell(player);
	Call_Finish();
	SetPawnTimer(BecomeDittoAgain, 15.0, player.userid, VSH2GameMode_GetProperty("iRoundCount"));
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	strcopy(song, sizeof(song), DittoTheme);
	time = 146.0;
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Ditto");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
	{
		if (Victim.bIsMinion && Attacker.index != Victim.index)
		{
			VSH2Player owner = VSH2Player(Victim.iOwnerBoss, true);
			if (IsClientValid(owner.index) && owner.iPureType == ThisPluginIndex)
				Victim.bIsMinion = false;
		}
		return;
	}

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	if (!GetRandomInt(0, 3))
	{
		char snd[PLATFORM_MAX_PATH];
		strcopy(snd, PLATFORM_MAX_PATH, (GetRandomInt(0, 1) ? Ditto1 : Ditto2));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	EmitSoundToAll(DittoDie, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(DittoDie, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, FULLPATH, DittoDie);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, sizeof(s), Ditto2);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Ditto");
}
public Action fwdOnBossGiveBackRage(const VSH2Player player)
{
	if (player.iPureType == ThisPluginIndex)
	{
		player.iType = ThisPluginIndex;
		fwdOnBossModelTimer(player);
		fwdOnBossEquipped(player);
	}
	return Plugin_Continue;
}
public void fwdOnLastPlayer(const VSH2Player player)
{
	if (player.iType == ThisPluginIndex)
	{
		EmitSoundToAll(Ditto2, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(Ditto2, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}

public void BecomeDittoAgain(const int userid, int rndcount)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client))
		return;

	if (rndcount != VSH2GameMode_GetProperty("iRoundCount"))
		return;

	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	if (!IsPlayerAlive(client))
		return;

	VSH2Player player = VSH2Player(client);
	if (!player.bIsBoss)
		return;

	if (player.iType == ThisPluginIndex)
		return;

	player.iType = ThisPluginIndex;

	Handle vsh2 = VSH2_Self();
	Call_StartFunction(vsh2, GetFunctionByName(vsh2, "ManageBossTransition"));
	Call_PushCell(player);
	Call_PushCell(true);
	Call_Finish();

	SetEntProp(player.index, Prop_Send, "m_bForcedSkin", 0);
	SetEntProp(player.index, Prop_Send, "m_nForcedSkin", 0);
	player.SetOverlay("0");

	StopSound(player.index, SNDCHAN_AUTO, "acvshtank/tankdrive.mp3");
	StopSound(player.index, SNDCHAN_AUTO, "acvshtank/tankidle.mp3");
	SetEntProp(player.index, Prop_Data, "m_takedamage", 2);
	if (player.flCharge <= -100.0)
		player.flCharge = -100.0;
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Ditto", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Ditto");
	}
}