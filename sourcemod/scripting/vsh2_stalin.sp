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
	name = "VSH2 - Stalin", 
	author = "Scag", 
	description = "VSH2 boss Stalin", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_stalin");
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
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnPlayerKilled, fwdOnPlayerKilled);
		VSH2_Hook(OnBossKillBuilding, fwdOnBuildingDestroyed);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define StalinModel                 	"models/freak_fortress_2/stalin/stalin_boss2.mdl"

#define StalinStart 					"opst/saxtonhale/stalin/start.mp3"
#define StalinFail 						"opst/saxtonhale/stalin/dead.mp3"
#define StalinWin 						"opst/saxtonhale/stalin/win.mp3"
#define StalinTheme 					"opst/saxtonhale/stalin/theme1.mp3"
#define StalinJump 						"opst/saxtonhale/stalin/jump.mp3"
#define StalinRage 						"opst/saxtonhale/stalin/rage.mp3"

public void OnClientDisconnect(int client)
{
	VSH2Player player = VSH2Player(client);
	if (player.iType == ThisPluginIndex && player.iSpecial)
		UnFreeze(player, player.iSpecial2, GetClientTeam(player.index));
}

public void fwdOnDownloadsCalled()
{
	PrepareModel(StalinModel);
	PrepareMaterial("materials/models/suka/eyeball_l");
	PrepareMaterial("materials/models/suka/eyeball_r");
	PrepareMaterial("materials/models/suka/glint");
	PrepareMaterial("materials/models/suka/grigori_head");
	PrepareMaterial("materials/models/suka/monk_head_normal");
	PrepareMaterial("materials/models/suka/monk_sheet");
	PrepareMaterial("materials/models/suka/pupil_l");
	PrepareMaterial("materials/models/suka/pupil_r");

	PrepareSound(StalinStart);
	PrepareSound(StalinFail);
	PrepareSound(StalinWin);
	PrepareSound(StalinTheme);
	PrepareSound(StalinJump);
	PrepareSound(StalinRage);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Joseph Stalin:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch.\nRage (Soviet Winter): Call for medic (e) when the Rage is full.\nBlind players and disable sentry guns!");
	panel.DrawItem( "Exit" );
	panel.Send(Player.index, PANEL, 10);
	delete panel;
}
public int PANEL(Menu menu, MenuAction action, int client, int select)
{
	return 0;
}
public void fwdOnBossThink(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.DoGenericThink(true, !Player.iSpecial, StalinJump);
	if (Player.iSpecial && Player.flSpecial2 < GetGameTime())
		UnFreeze(Player, Player.iSpecial2, GetClientTeam(Player.index));
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(StalinModel);
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
		TF2_SetPlayerClass(Player.index, TFClass_Medic, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		EmitSoundToAll(StalinStart);
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;
	
	int client = player.index;

	if ( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null); // should reset Hale's animation
	}
	TF2_AddCondition(player.index, TFCond_MegaHeal, 6.0);
//	TF2_AddCondition(player.index, TFCond_FireImmune, 8.0);

	EmitSoundToAll(StalinRage);
	EmitSoundToAll(StalinRage);
	int i;
	VSH2Player base;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		base = VSH2Player(client);
		if (base.iType == ThisPluginIndex && player.iSpecial)
			UnFreeze(base, base.iSpecial2, GetClientTeam(base.index));
	}

	player.iSpecial = true;
	SetEntityFlags(player.index, GetEntityFlags(player.index) | FL_NOTARGET);
	player.flGlowtime = 0.0;
	TF2_RemoveCondition(player.index, TFCond_OnFire);

	int fog = CreateEntityByName("env_fog_controller");
	if (fog != -1)
	{
		DispatchKeyValue(fog, "targetname", "StalinFog");
		DispatchKeyValue(fog, "fogenable", "1");
		DispatchKeyValue(fog, "spawnflags", "1");
		DispatchKeyValue(fog, "fogblend", "255 255 255 255");
		DispatchKeyValue(fog, "fogcolor", "255 255 255 255");
		DispatchKeyValue(fog, "fogcolor2", "255 255 255 255");
		DispatchKeyValueFloat(fog, "fogstart", 64.0);
		DispatchKeyValueFloat(fog, "fogend", 384.0);
		DispatchKeyValueFloat(fog, "fogmaxdensity", 1.0);
		DispatchSpawn(fog);

		AcceptEntityInput(fog, "TurnOn");
	}

	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (GetClientTeam(i) == GetClientTeam(player.index))
			continue;

		if (IsPlayerAlive(i))
		{
			SetEntityRenderMode(i, RENDER_TRANSCOLOR);
			SetEntityRenderColor(i, 0, 128, 255, 255);
		}

		if (fog != -1)
		{
			SetVariantString("StalinFog");
			AcceptEntityInput(i, "SetFogController");
		}
	}

//	SetPawnTimer3(UnFreeze, 10.0, player, EntIndexToEntRef(fog), GetClientTeam(player.index));
	if (fog != -1)
	{
		player.iSpecial2 = EntIndexToEntRef(fog);
		player.flSpecial2 = GetGameTime() + 10.0;
	}
}
public void fwdOnMusic(char song[FULLPATH], float &time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	strcopy(song, sizeof(song), StalinTheme);
	time = 270.0;
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Joseph Stalin");
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	EmitSoundToAll(StalinFail, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(StalinFail, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	if (Player.iSpecial)
		UnFreeze(Player, Player.iSpecial2, GetClientTeam(Player.index));
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, sizeof(s), StalinWin);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Joseph Stalin");
}

public void UnFreeze(const VSH2Player base, const int ref, const int team)
{
	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i))
		{
			if (!IsPlayerAlive(i))
				continue;

			if (IsClientValid(base.index) && i == base.index)
				continue;

			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i);
		}
	}

	int fog = EntRefToEntIndex(ref);

	if (IsValidEntity(fog))
		RemoveEntity(fog);

	if (IsClientValid(base.index))
	{
		SetEntityFlags(base.index, GetEntityFlags(base.index) & ~FL_NOTARGET);
		base.iSpecial = false;
	}
}

public void fwdOnPlayerKilled(const VSH2Player player, const VSH2Player victim, Event event)
{
	if (player.iType == ThisPluginIndex)
		event.SetString("weapon", "fists");
}
public void fwdOnBuildingDestroyed(const VSH2Player player, int building, Event event)
{
	if (player.iType == ThisPluginIndex)
		event.SetString("weapon", "fists");
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Joseph Stalin", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Joseph Stalin");
	}
}

stock void SetPawnTimer3(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999, any param3 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	thinkpack.WriteCell(param3);

	CreateTimer(thinktime, DoThink3, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink3(Handle hTimer, DataPack hndl)
{
	hndl.Reset();

	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );

	any param1 = hndl.ReadCell();
	if ( param1 != -999 )
		Call_PushCell(param1);

	any param2 = hndl.ReadCell();
	if ( param2 != -999 )
		Call_PushCell(param2);

	any param3 = hndl.ReadCell();
	if ( param3 != -999 )
		Call_PushCell(param3);

	Call_Finish();
	return Plugin_Continue;
}

public void TF2_OnConditionAdded(int client, TFCond cond)
{
	VSH2Player player = VSH2Player(client);
	if (player.iSpecial 
	&& cond == TFCond_OnFire
	&& player.iType == ThisPluginIndex)
		TF2_RemoveCondition(client, cond);
}