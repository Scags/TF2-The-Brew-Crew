#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <dhooks>
#include <scag>
#include <tf2attributes>
#include <tf2condhooks>

#pragma semicolon			1
#pragma newdecls			required

#define ANIM_MOVE 78
#define ANIM_IDLE 48
#define ANIM_EXPL 103
#define ANIM_FLOA 86
#define MODEL_BUSTER "models/bots/demo/bot_sentry_buster.mdl"

public Plugin myinfo = 
{
	name = "VSH2 - Mecha-Engineer", 
	author = "Scag", 
	description = "VSH2 boss Mecha-Engineer", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_mechaengi");
		VSH2_AddToFwdC(Fwd_OnBossTakeDamage, ThisPluginIndex);
		VSH2_AddToFwdC(Fwd_OnBossDealDamage, ThisPluginIndex);
//		VSH2_AddToFwdC(Fwd_OnSoundHook, ThisPluginIndex);
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
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
		VSH2_Hook(OnLastPlayer, fwdOnLastPlayer);
		VSH2_Hook(OnBossTakeDamage, fwdOnBossTakeDamage);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
	}
}

#define EngiModel			"models/bots/engineer/bot_engineer.mdl"

static const char g_strKillSounds[][] = {
	"vo/mvm/norm/engineer_mvm_dominationengineer_mvm01.mp3",
	"vo/mvm/norm/engineer_mvm_dominationengineer_mvm06.mp3",
	"vo/mvm/norm/engineer_mvm_dominationengineer_mvm09.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy02.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy04.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy10.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy11.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy14.mp3",
	"vo/mvm/norm/engineer_mvm_dominationsoldier03.mp3",
	"vo/mvm/norm/engineer_mvm_dominationspy02.mp3",
	"vo/mvm/norm/engineer_mvm_dominationspy07.mp3",
	"vo/mvm/norm/engineer_mvm_dominationspy10.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization03.mp3",
	"vo/mvm/norm/engineer_mvm_specialcompleted07.mp3",
	"vo/mvm/norm/engineer_mvm_specialcompleted10.mp3",
	"vo/mvm/norm/engineer_mvm_specialcompleted11.mp3"
};

static const char g_strLast[][] = {
	"vo/mvm/norm/engineer_mvm_dominationdemoman01.mp3",
	"vo/mvm/norm/engineer_mvm_specialcompleted04.mp3"
};

static const char g_strStart[][] = {
	"vo/mvm/norm/engineer_mvm_battlecry06.mp3",
	"vo/mvm/norm/engineer_mvm_battlecry07.mp3",
	"vo/mvm/norm/engineer_mvm_gunslingertriplepunchfinal01.mp3"
};

static const char g_strStabbed[][] = {
	"vo/mvm/norm/engineer_mvm_dominationengineer_mvm05.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization03.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization06.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization07.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization08.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization09.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization10.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization11.mp3",
	"vo/mvm/norm/engineer_mvm_negativevocalization12.mp3"
};

static const char g_strWin[][] = {
	"vo/mvm/norm/engineer_mvm_dominationheavy01.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy08.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy09.mp3",
	"vo/mvm/norm/engineer_mvm_dominationheavy12.mp3",
	"vo/mvm/norm/engineer_mvm_dominationscout01.mp3",
	"vo/mvm/norm/engineer_mvm_dominationsoldier08.mp3",
	"vo/mvm/norm/engineer_mvm_autocappedintelligence01.mp3"
};

static const char g_strDeath[][] = {
	"vo/mvm/norm/engineer_mvm_paincriticaldeath01.mp3",
	"vo/mvm/norm/engineer_mvm_paincriticaldeath02.mp3",
	"vo/mvm/norm/engineer_mvm_paincriticaldeath03.mp3",
	"vo/mvm/norm/engineer_mvm_paincriticaldeath04.mp3",
	"vo/mvm/norm/engineer_mvm_paincriticaldeath05.mp3",
	"vo/mvm/norm/engineer_mvm_paincriticaldeath06.mp3"
};

static const char g_strJump[][] = {
	"vo/mvm/norm/engineer_mvm_no01.mp3"
};

#define EngiTheme 		"tbc/saxtonhale/mechaengi/theme1.mp3"

public void OnPluginStart()
{
	AddNormalSoundHook(SoundHook);

	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath);

	AddCommandListener(OnTaunt, "taunt");
	AddCommandListener(OnTaunt, "+taunt");
	AddCommandListener(OnRobot, "sm_robot");
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnBusterDamaged);
	SDKUnhook(client, SDKHook_Think, OnBusterThink);

//	StopSound(client, SNDCHAN_STATIC, "mvm/sentrybuster/mvm_sentrybuster_loop.wav");
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnBusterDamaged);
	SDKUnhook(client, SDKHook_Think, OnBusterThink);
//	StopSound(client, SNDCHAN_STATIC, "mvm/sentrybuster/mvm_sentrybuster_loop.wav");

	VSH2Player(client).iSpecial = 0;
}

//public void OnEntityDestroyed(int entity)
//{
//	if(MaxClients < EntRefToEntIndex(entity) <= 2048)
//		StopSound(entity, SNDCHAN_STATIC, "mvm/sentrybuster/mvm_sentrybuster_loop.wav");
//}

public void fwdOnDownloadsCalled()
{
	PrecacheModel(MODEL_BUSTER);

	//Absolutely fucking retarded.
	PrecacheSound(")mvm/sentrybuster/mvm_sentrybuster_explode.wav", true);
	PrecacheSound(")mvm/sentrybuster/mvm_sentrybuster_spin.wav", true);
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_loop.wav", true);
	PrecacheSound(")mvm/sentrybuster/mvm_sentrybuster_intro.wav", true);
	
	PrecacheSound("^mvm/sentrybuster/mvm_sentrybuster_step_01.wav", true);
	PrecacheSound("^mvm/sentrybuster/mvm_sentrybuster_step_02.wav", true);
	PrecacheSound("^mvm/sentrybuster/mvm_sentrybuster_step_03.wav", true);
	PrecacheSound("^mvm/sentrybuster/mvm_sentrybuster_step_04.wav", true);

	PrecacheSound("vo/mvm_sentry_buster_alerts01.mp3", true);

	PrecacheScriptSound("MVM.SentryBusterExplode");
	PrecacheScriptSound("MVM.SentryBusterSpin");
//	PrecacheScriptSound("MVM.SentryBusterLoop");
	PrecacheScriptSound("MVM.SentryBusterIntro");
	PrecacheScriptSound("MVM.SentryBusterStep");

	PrecacheSoundList(g_strKillSounds, sizeof(g_strKillSounds));
	PrecacheSoundList(g_strLast, sizeof(g_strLast));
	PrecacheSoundList(g_strStart, sizeof(g_strStart));
	PrecacheSoundList(g_strStabbed, sizeof(g_strStabbed));
	PrecacheSoundList(g_strWin, sizeof(g_strWin));
	PrecacheSoundList(g_strDeath, sizeof(g_strDeath));
	PrecacheSoundList(g_strJump, sizeof(g_strJump));

	PrepareSound(EngiTheme);
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_loop.wav", true);

	char s[PLATFORM_MAX_PATH];
	for (int i = 1; i <= 18; i++)
	{
		Format(s, sizeof(s), "mvm/player/footsteps/robostep_%s%i.wav", (i < 10) ? "0" : "", i);
		PrecacheSound(s, true);
	}
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("The Mecha-Engineer:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (Robot Minions): Call for medic (e) when Rage is full.\nSpawn robots of your choosing!");
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

	Player.DoGenericThink(true, true, g_strJump[0]);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(EngiModel);
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
	int assbeater = Player.SpawnWeapon("tf_weapon_wrench", 795, 100, 5, attribs);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", assbeater);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Engineer, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		strcopy(s, PLATFORM_MAX_PATH, g_strStart[GetRandomInt(0, sizeof(g_strStart)-1)]);
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	float spawnpos[3]; GetClientAbsOrigin(player.index, spawnpos);
	float spawnpos2[3];
	GetSpawnPoint(player.index, spawnpos2);

	int living = GetLivingPlayers(player.iOtherTeam);
	if (living > 5)
		living = 5;

	int client;
	VSH2Player base;
	int count;
	for (int i = 0; i < living; ++i)
	{
		client = GetDeadPlayer();
		if (client == -1)
		{
			if (count == 0)
			{
				VSH2GameMode_GiveBackRage(base.index);
				PrintCenterText(player.index, "You can't spawn any minions!");
				return;
			}
			break;
		}
		base = VSH2Player(client);
		base.bIsMinion = true;
		base.iOwnerBoss = player.userid;

		TF2_SetPlayerClass(client, TFClass_DemoMan, _, false);
		ChangeClientTeam(client, GetClientTeam(player.index));
		TF2_RespawnPlayer(client);
		base.PreEquip();
		TF2_SetPlayerClass(client, TFClass_DemoMan, _, false);

		SetVariantString(MODEL_BUSTER);
		AcceptEntityInput(client, "SetCustomModel");

		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
//		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.75);
		SetEntProp(client, Prop_Data, "m_bloodColor", -1); //Don't bleed
		SetEntityHealth(client, 500);

		int wep = base.SpawnWeapon("tf_weapon_stickbomb", 307, 10, 6, "26 ; 425 ; 107 ; 2.0 ; 252 ; 0.5 ; 329 ; 0.5 ; 330 ; 7 ; 402 ; 1 ; 138 ; 0 ; 275 ; 1 ; 109 ; 0", false);
		SetActive(client, wep);

		if (!TF2_UnstuckPlayer(client, .position = spawnpos))
			TeleportEntity(client, spawnpos2, NULL_VECTOR, NULL_VECTOR);

		SDKHook(client, SDKHook_OnTakeDamageAlive, OnBusterDamaged);

//		SDKHook(client, SDKHook_Think, OnBusterThink);

		EmitGameSoundToAll("MVM.SentryBusterIntro", client);
//		EmitGameSoundToAll("MVM.SentryBusterLoop",  client);

		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
		++count;
	}

	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	EmitSoundToAll("vo/mvm_sentry_buster_alerts01.mp3");
}
public bool BusterTrace(int ent, int mask, any data)
{
	return !(0 < ent <= MaxClients);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	strcopy(song, sizeof(song), EngiTheme);
	time = 120.0;
}
public void fwdOnBossMenu(Menu &menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "The Mecha-Engineer");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Victim.iType != ThisPluginIndex && VSH2Player(Victim.iOwnerBoss).iType == ThisPluginIndex)
	{
		SDKUnhook(Victim.index, SDKHook_OnTakeDamageAlive, OnBusterDamaged);
		SDKUnhook(Victim.index, SDKHook_Think, OnBusterThink);

		Victim.bIsMinion = false;
		Victim.iOwnerBoss = 0;
		return;
	}

	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	static int wrenches[] = {
		795,
		804,
		884,
		893,
		902,
		911,
		960,
		969
	};

	int weapon = GetEntPropEnt(Attacker.index, Prop_Send, "m_hActiveWeapon");
	if (weapon == GetPlayerWeaponSlot(Attacker.index, TFWeaponSlot_Melee))
	{
		TF2_RemoveWeaponSlot(Attacker.index, TFWeaponSlot_Melee);
		char attribs[128];
		FormatEx(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %i", GetRandomInt(9999, 99999));

		weapon = Attacker.SpawnWeapon("tf_weapon_wrench", wrenches[GetRandomInt(0, sizeof(wrenches)-1)], 100, 5, attribs);
		SetEntPropEnt(Attacker.index, Prop_Send, "m_hActiveWeapon", weapon);
	}

	if (!GetRandomInt(0, 1))
	{
		char s[PLATFORM_MAX_PATH];
		strcopy(s, sizeof(s), g_strKillSounds[GetRandomInt(0, sizeof(g_strKillSounds)-1)]);
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);		
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, sizeof(s), g_strDeath[GetRandomInt(0, sizeof(g_strDeath)-1)]);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	VSH2Player base;
	for (int ent = MaxClients; ent; --ent)
	{
		if (!IsClientInGame(ent) || !IsPlayerAlive(ent))
			continue;

		base = VSH2Player(ent);
		if (base.bIsMinion && base.iOwnerBoss == Player.index)
			if (!TF2_IsPlayerInCondition(ent, TFCond_Bonked))
				Buster_StartDetonation(ent);
	}
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, FULLPATH, g_strStabbed[GetRandomInt(0, sizeof(g_strStabbed)-1)]);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage(const VSH2Player victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char cls[32];
	if (inflictor != -1 && GetEntityClassname(inflictor, cls, sizeof(cls)) && !strcmp(cls, "env_explosion", false) && GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") == victim.index)
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, sizeof(s), g_strWin[GetRandomInt(0, sizeof(g_strWin)-1)]);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "The Mecha-Engineer");
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("The Mecha-Engineer", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Mecha-Engineer");
	}
}
public void fwdOnLastPlayer(VSH2Player player)
{
	if (player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		strcopy(s, FULLPATH, g_strLast[GetRandomInt(0, sizeof(g_strLast)-1)]);
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}

public Action SoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!(0 < entity <= MaxClients))
		return Plugin_Continue;

	if (sample[0] == '\0')
		return Plugin_Continue;


	VSH2Player player = VSH2Player(entity);
	if (player.bIsMinion && VSH2Player(player.iOwnerBoss).iType == ThisPluginIndex)
	{
		if (!strncmp(sample, "vo", 2, false))
			return Plugin_Handled;
	}

	if (player.iType != ThisPluginIndex)
		return Plugin_Continue;

	if (!StrContains(sample, "player/footsteps/", false))
	{
		int rand = GetRandomInt(1,18);
		Format(sample, sizeof(sample), "mvm/player/footsteps/robostep_%s%i.wav", (rand < 10 ? "0" : ""), rand);
		pitch = GetRandomInt(95, 100);
		EmitSoundToAll(sample, entity, _, _, _, 0.15, pitch);
		return Plugin_Handled;
	}
	if (strncmp(sample, "vo", 2, false) || StrContains(sample, "announcer", false) != -1)
		return Plugin_Continue;

	if (!strncmp(sample, "vo/mvm", 6, false))
		return Plugin_Continue;

	ReplaceStringEx(sample, sizeof(sample), "vo/", "vo/mvm/norm/");
	ReplaceStringEx(sample, sizeof(sample), ".wav", ".mp3");
	ReplaceStringEx(sample, sizeof(sample), "engineer", "engineer_mvm");
	PrecacheSound(sample);
	return Plugin_Changed;
}

public Action TF2_OnAddCond(int client, TFCond &cond, float &time, int &provider)
{
	if (cond == TFCond_Gas)
	{
		VSH2Player player = VSH2Player(client);
		if (player.bIsMinion && VSH2Player(player.iOwnerBoss).iType == ThisPluginIndex)
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

stock bool GetSpawnPoint(int client, float vSpawn[3])
{
	int spawn = -1;
	while((spawn = FindEntityByClassname(spawn, "info_player_teamspawn")) != -1)
	{
		bool bDisabled = !!GetEntProp(spawn, Prop_Data, "m_bDisabled");
		int iSpawnTeam = GetEntProp(spawn, Prop_Data, "m_iTeamNum");
		
		if(!bDisabled && iSpawnTeam == GetClientTeam(client))
			break;
	}
	
	if(spawn == INVALID_ENT_REFERENCE)
		return false;
	
	GetEntPropVector(spawn, Prop_Data, "m_vecAbsOrigin", vSpawn);
	
	return true;
}

public Action OnBusterDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	int iHealth = GetEntProp(victim, Prop_Data, "m_iHealth");
	
	CreateParticle("bot_impact_heavy", victim);
	
	if(damage > iHealth)
	{
		damage = 0.0;
		Buster_StartDetonation(victim);
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	VSH2Player player = VSH2Player(client);
	if (player.bIsMinion && VSH2Player(player.iOwnerBoss).iType == ThisPluginIndex && IsPlayerAlive(client))
	{
		if (TF2_IsPlayerInCondition(client, TFCond_Bonked))
			return Plugin_Handled;
		else if (buttons & (IN_ATTACK|IN_ATTACK2))
		{
			Buster_StartDetonation(client);
			buttons &= ~(IN_ATTACK|IN_ATTACK2);
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public void OnBusterThink(int iEntity)
{
	float flCycle = GetEntPropFloat(iEntity, Prop_Data, "m_flCycle");
	if(flCycle >= 1.0) //PreDetonate animation complete.
	{
		Buster_Detonate(iEntity);
	}
}

//public bool Buster_Traversible(int bot_entidx, int other_entidx, TraverseWhenType when) { return true; }

void Buster_StartDetonation(int bot)
{
	if (GetEntProp(bot, Prop_Send, "m_nSequence") == ANIM_EXPL || VSH2Player(bot).iSpecial)
		return;

	FakeClientCommandEx(bot, "taunt");
	FakeClientCommandEx(bot, "+taunt");

	VSH2Player(bot).iSpecial = 1;
	TF2_AddCondition(bot, TFCond_Bonked, 4.0);

	EmitGameSoundToAll("MVM.SentryBusterSpin",  bot);
	
	SDKUnhook(bot, SDKHook_OnTakeDamageAlive, OnBusterDamaged);

	SetPawnTimer(Bewm, 2.0, GetClientUserId(bot));
}

public void Bewm(int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsPlayerAlive(client))
		return;

	Buster_Detonate(client);
	ForcePlayerSuicide(client);
	CreateTimer(0.0, Timer_RemoveRagdoll, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RemoveRagdoll(Handle timer, any uid)
{
	int client = GetClientOfUserId(uid);
	if (!client)
		return Plugin_Continue;

	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll) || ragdoll <= MaxClients)
		return Plugin_Continue;

	AcceptEntityInput(ragdoll, "Kill");
	return Plugin_Continue;
}

public Action OnTaunt(int client, const char[] command, int args)
{
	if (GetEntProp(client, Prop_Send, "m_hGroundEntity") == -1)
		return Plugin_Continue;

	VSH2Player player = VSH2Player(client);
	if (player.bIsMinion && VSH2Player(player.iOwnerBoss).iType == ThisPluginIndex)
		Buster_StartDetonation(player.index);

	return Plugin_Continue;
}

public Action OnRobot(int client, const char[] command, int args)
{
	VSH2Player player = VSH2Player(client);
	if (player.bIsMinion && VSH2Player(player.iOwnerBoss).iType == ThisPluginIndex)
		return Plugin_Handled;
	return Plugin_Continue;
}


void Buster_Detonate(int bot)
{
	//Finish Detonation
	float vPos[3];
	GetEntPropVector(bot, Prop_Data, "m_vecAbsOrigin", vPos);
	vPos[2] += 64.0;
	
	CreateParticle("fluidSmokeExpl_ring_mvm", bot);
	CreateParticle("explosionTrail_seeds_mvm", bot);

	int owner = bot;

	DataPack pack = new DataPack();
//	CreateDataTimer(0.1, DoDoExplosion, pack, TIMER_FLAG_NO_MAPCHANGE);

	pack.WriteCell(owner == -1 ? 0 : owner);
	pack.WriteFloat(vPos[0]);
	pack.WriteFloat(vPos[1]);
	pack.WriteFloat(vPos[2]);

	RequestFrame(DoDoExplosion, pack);

//	Explosion(owner == -1 ? 0 : owner, 5000, 300, vPos, bot);
	EmitGameSoundToAll("MVM.SentryBusterExplode", bot, .origin = vPos);
	
//	StopSound(bot, SNDCHAN_STATIC, "mvm/sentrybuster/mvm_sentrybuster_loop.wav");
	
	SDKUnhook(bot, SDKHook_Think, OnBusterThink);
}
public void DoDoExplosion(DataPack pack)
{
	pack.Reset();

	int owner = pack.ReadCell();
	float pos[3];
	pos[0] = pack.ReadFloat();
	pos[1] = pack.ReadFloat();
	pos[2] = pack.ReadFloat();
	Explosion(owner == -1 ? 0 : owner, 1000, 300, pos);

	delete pack;
}
stock Address GetStudioHdr(int ent)
{
	return view_as< Address >(GetEntData(ent, FindDataMapInfo(ent, "m_flFadeScale") + 28));
}

stock void CreateParticle(char[] particle, int iEntity)
{
	int tblidx = FindStringTable("ParticleEffectNames");
	char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	
	for(int i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, particle, false))
		{
			stridx = i;
			break;
		}
	}
	
	float vPos[3], vAng[3];
	GetEntPropVector(iEntity, Prop_Data, "m_vecAbsOrigin", vPos);
	GetEntPropVector(iEntity, Prop_Data, "m_angRotation", vAng);
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", vPos[0]);
	TE_WriteFloat("m_vecOrigin[1]", vPos[1]);
	TE_WriteFloat("m_vecOrigin[2]", vPos[2]);
	TE_WriteVector("m_vecAngles", vAng);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", iEntity);
	TE_WriteNum("m_iAttachType", 0);
	TE_SendToAll();
}

stock void Explosion(const int owner, const int damage, const int radius, float pos[3], int inflictor = 0)
{
	int explode = CreateEntityByName("env_explosion");
	if (!IsValidEntity(explode))
		return;

	DispatchKeyValue(explode, "targetname", "exploder");
	DispatchKeyValue(explode, "spawnflags", "4");
	DispatchKeyValue(explode, "rendermode", "5");

	SetEntPropEnt(explode, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(explode, Prop_Data, "m_iMagnitude", damage);
	SetEntProp(explode, Prop_Data, "m_iRadiusOverride", radius);
	if (inflictor) SetEntPropEnt(explode, Prop_Data, "m_hInflictor", inflictor);

	int team = GetClientTeam(owner);
	SetVariantInt(team); AcceptEntityInput(explode, "TeamNum");
	SetVariantInt(team); AcceptEntityInput(explode, "SetTeam");

	TeleportEntity(explode, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(explode);
	ActivateEntity(explode);
	AcceptEntityInput(explode, "Explode");
	AcceptEntityInput(explode, "Kill");
}

stock void Explode(float flPos[3], float flDamage, float flRadius, const char[] strParticle, const char[] strSound)
{
    int iBomb = CreateEntityByName("tf_generic_bomb");
    DispatchKeyValueVector(iBomb, "origin", flPos);
    DispatchKeyValueFloat(iBomb, "damage", flDamage);
    DispatchKeyValueFloat(iBomb, "radius", flRadius);
    DispatchKeyValue(iBomb, "health", "1");
    DispatchKeyValue(iBomb, "explode_particle", strParticle);
    DispatchKeyValue(iBomb, "sound", strSound);
    DispatchSpawn(iBomb);

    AcceptEntityInput(iBomb, "Detonate");
}
