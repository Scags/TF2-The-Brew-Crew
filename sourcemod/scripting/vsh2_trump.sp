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
	name = "VSH2 - Trump", 
	author = "Scag", 
	description = "VSH2 boss Trump", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_trump");
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
		VSH2_Hook(OnLastPlayer, fwdOnLastPlayer);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
	}
}

#define TrumpModel				"models/freak_fortress_2/trump/newtrump2.mdl"

#define TrumpKill				"opst/saxtonhale/dtrump/kill" //1-8
#define TrumpWin				"opst/saxtonhale/dtrump/win"//4
#define TrumpKillPyro 			"opst/saxtonhale/dtrump/killpyro"//3
#define TrumpSpree 				"opst/saxtonhale/dtrump/spree"//3
#define TrumpJump				"opst/saxtonhale/dtrump/jump"	//3
#define TrumpStab				"opst/saxtonhale/dtrump/stab"//3
#define TrumpFail				"opst/saxtonhale/dtrump/lose" //1-2
#define TrumpRage				"opst/saxtonhale/dtrump/rage" //1-2
#define TrumpLast 				"opst/saxtonhale/dtrump/last"//2
#define TrumpStart				"opst/saxtonhale/dtrump/intro1.mp3"
#define TrumpTheme				"opst/saxtonhale/dtrump/theme1.mp3"
#define TrumpTheme2				"opst/saxtonhale/dtrump/theme2.mp3"
#define WALL 					"opst/saxtonhale/dtrump/wall.mp3"
#define WallModel 				"models/props_medieval/fort_wall.mdl"

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;

	PrepareMaterialDir(false, "materials/freak_fortress_2/donaldt");

	for (i = 1; i <= 8; i++) 
	{
		if (i <= 4)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpWin, i);
			PrepareSound(s);
		}
		if (i <= 3)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpKillPyro, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpSpree, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpJump, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpStab, i);
			PrepareSound(s);
		}
		if (i <= 2)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpFail, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpRage, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpLast, i);
			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%d.mp3", TrumpKill, i);
		PrepareSound(s);
	}

	PrepareSound(TrumpStart);
	PrepareSound(TrumpTheme);
	PrepareSound(TrumpTheme2);
	PrepareSound(WALL);

	PrepareModel(TrumpModel);
	PrecacheModel(WallModel, true);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Donald Trump:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Wall): Call for medic (e) when Rage is full.\nTrap players inside of your wall!");
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

	Player.DoGenericThink(true, true, TrumpJump, 3);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(TrumpModel);
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
		TF2_SetPlayerClass(Player.index, TFClass_Spy, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		strcopy(s, PLATFORM_MAX_PATH, TrumpStart);
		EmitSoundToAll(s);
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

	char snd[PLATFORM_MAX_PATH];
	strcopy(snd, sizeof(snd), WALL);
	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);
	TF2_AddCondition(player.index, TFCond_DefenseBuffNoCritBlock, 4.0);
//	TF2_AddCondition(player.index, TFCond_Kritzkrieged, 6.0);

	float ang[3];
//	int hp = 300;
	float angle, x, y;
	pos[2] += 350.0;
	float currpos = pos[2];
	float pos1[3]; pos1 = pos;

	while (angle <= 2 * FLOAT_PI)
	{
		ang[2] = 0.0;
		pos1[2] = currpos;
		x = 400.0 * Cosine(angle);
		y = 400.0 * Sine(angle);

		pos1[0] = pos[0] + x;
		pos1[1] = pos[1] + y;
		ang[1] = RadToDeg(angle);

		MakeWall(player.index, pos1, ang);

		ang[2] = -180.0;
		pos1[2] -= 450.0;
		MakeWall(player.index, pos1, ang);

		angle += (FLOAT_PI / 7);
	}
}

public void MakeWall(int client, float pos[3], float ang[3])
{
	int ent;
	ent = CreateEntityByName("prop_dynamic_override");
	SetEntityModel(ent, WallModel);

	char name[16];
	FormatEx(name, sizeof(name), "wall%d:%.1f%.1f", client, ang[0], pos[2]);
	DispatchKeyValue(ent, "targetname", name);
	DispatchKeyValue(ent, "solid", "6");
//	DispatchKeyValue(ent, "model", WallModel);

	DispatchSpawn(ent);

	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 5);
	SetEntProp(ent, Prop_Send, "m_usSolidFlags", GetEntProp(ent, Prop_Send, "m_usSolidFlags") & ~4);
	SetEntProp(ent, Prop_Data, "m_takedamage", 2, 1);
	SetEntProp(ent, Prop_Data, "m_iHealth", 200);
//	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);

//	AcceptEntityInput(ent, "EnableCollision");

	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	SDKHook(ent, SDKHook_OnTakeDamage, OnWallTakeDamage);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(1, 2))
	{
		case 1:
		{
			strcopy(song, sizeof(song), TrumpTheme);
			time = 150.0;
		}
		case 2:
		{
			strcopy(song, sizeof(song), TrumpTheme2);
			time = 150.0;
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Donald Trump");
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
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpKill, GetRandomInt(1, 8));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	Attacker.iKills++;

	if (Attacker.iKills & 3 == 0)
	{
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpSpree, GetRandomInt(1, 3));
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
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TrumpFail, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%d.mp3", TrumpStab, GetRandomInt(1, 3));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	Format(s, sizeof(s), "%s%d.mp3", TrumpWin, GetRandomInt(1, 4));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Donald Trump");
}
public void fwdOnBossKillBuilding(const VSH2Player player, int building, Event event)
{
	if (player.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
}
public void fwdOnLastPlayer(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%d.mp3", TrumpLast, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}

public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Donald Trump", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Donald Trump");
	}
}

public Action OnWallTakeDamage(int victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (0 < attacker <= MaxClients)
	{
		if (GetEntPropEnt(victim, Prop_Send, "m_hOwnerEntity") == attacker)
		{
			damage = 1000.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}