#include <sdktools>
#undef REQUIRE_PLUGIN
#include <smac>
#define REQUIRE_PLUGIN
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <tf2attributes>
#include <scag>
#include <dhooks>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Dio", 
	author = "Scag", 
	description = "VSH2 boss Dio", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

Handle g_hGetBodyInterface;
Handle g_hGetHullMins;
Handle g_hGetHullMaxs;
Handle g_hMyNextBotPointer;
//Handle g_hDispatchAnimEvents;

public void OnPluginStart()
{
	AddNormalSoundHook(SoundHook);
	HookEvent("teamplay_round_win", OnRoundEnd, EventHookMode_Pre);

	GameData hConf = LoadGameConfigFile("tf2.vsh2");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::MyNextBotPointer");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hMyNextBotPointer = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseEntity::MyNextBotPointer offset!"); 

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetBodyInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetBodyInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetBodyInterface!");

	g_hGetHullMins         = DHookCreateEx(hConf, "IBody::GetHullMins", HookType_Raw, ReturnType_VectorPtr, ThisPointer_Address, IBody_GetHullMins);
	g_hGetHullMaxs         = DHookCreateEx(hConf, "IBody::GetHullMaxs", HookType_Raw, ReturnType_VectorPtr, ThisPointer_Address, IBody_GetHullMaxs);
//	g_hDispatchAnimEvents = DHookCreateEx(hConf, "CBaseAnimating::DispatchAnimEvents", HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, CBaseAnimating_DispatchAnimEvents);
//	DHookAddParam(g_hDispatchAnimEvents, HookParamType_CBaseEntity);
//	Handle hook = DHookCreateDetourEx(hConf, "CBaseAnimatingOverlay::StudioFrameAdvance", CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
//	if (!hook)
//		LogError("Could not load detour for CBaseAnimatingOverlay::StudioFrameAdvance");
//	else DHookEnableDetour(hook, false, CBaseAnimatingOverlay_StudioFrameAdvance);
	delete hConf;
}

int iWorld;

public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!iWorld)
		return Plugin_Continue;

	VSH2Player player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		SDKUnhook(i, SDKHook_SetTransmit, OnDioTransmit);

		player = VSH2Player(i);
		if (player.iType == ThisPluginIndex && player.iSpecial)
		{
			TurnTimeOff(player);
			break;
		}
	}
	iWorld = 0;
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	VSH2Player player = VSH2Player(client);
	if (player.iType == ThisPluginIndex && player.iSpecial)
	{
		FixMediguns(player);
		TurnTimeOff(player);
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_dio");
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
		VSH2_Hook(OnBossKillBuilding, fwdOnBossKillBuilding);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
		VSH2_Hook(OnBossDealDamage, fwdOnBossDealDamage);
		VSH2_Hook(OnHealthBarUpdate, fwdOnHealthBarUpdate);
	}
}

#define DioModel                 	"models/freak_fortress_2/newdio/newdio2.mdl"

#define DioGeneric 					"opst/saxtonhale/dio/generic"	// 7
#define DioStart 					"opst/saxtonhale/dio/intro.mp3"
#define DioFail 					"opst/saxtonhale/dio/lose.mp3"
#define DioWin 						"opst/saxtonhale/dio/win"//3
#define DioTheme 					"opst/saxtonhale/dio/theme"
#define DioStab 					"opst/saxtonhale/dio/stab2.mp3"//2
#define DioJump 					"opst/saxtonhale/dio/jump.mp3"
#define DioRage 					"opst/saxtonhale/dio/zawarudo.mp3"
#define RoadRoller 					"opst/saxtonhale/dio/roller.mp3"
#define MudaMudaMuda 				"opst/saxtonhale/dio/mudamudamuda.mp3"
#define Nani 						"opst/saxtonhale/dio/nani.mp3"

#define RollerModel 				"models/props_hydro/dumptruck.mdl"

int iLaserBeam, iHalo;

public void fwdOnDownloadsCalled()
{
	PrepareModel(DioModel);
	PrepareMaterial("materials/freak_fortress_2/jojo/basewarp");
	PrepareMaterial("materials/freak_fortress_2/jojo/facewarp");
	PrepareMaterial("materials/freak_fortress_2/jojo/ntxr000");
	PrepareMaterial("materials/freak_fortress_2/jojo/ntxr0001");
	PrepareMaterial("materials/freak_fortress_2/jojo/ntxr001");
	PrepareMaterial("materials/freak_fortress_2/jojo/ntxr002");
	PrepareMaterial("materials/freak_fortress_2/jojo/ntxr030");
	PrepareMaterial("materials/freak_fortress_2/jojo/ntxr040");
	PrepareMaterial("materials/freak_fortress_2/jojo/ntxr050");
	PrepareMaterial("materials/freak_fortress_2/jojo/phong_exp");

	int i;
	char s[PLATFORM_MAX_PATH];

	for (i = 1; i <= 7; i++)
	{
		FormatEx(s, sizeof(s), "%s%d.mp3", DioGeneric, i);
		PrepareSound(s);

		if (i <= 3)
		{
			FormatEx(s, sizeof(s), "%s%d.mp3", DioWin, i);
			PrepareSound(s);
		}

		if (i <= 2)
		{
			FormatEx(s, sizeof(s), "%s%d.mp3", DioTheme, i);
			PrepareSound(s);
		}
	}

	PrepareSound(DioStab);
	PrepareSound(DioStart);
	PrepareSound(DioFail);
	PrepareSound(DioJump);
	PrepareSound(DioRage);

	PrepareSound(RoadRoller);
	PrepareSound(MudaMudaMuda);
	PrepareSound(Nani);

	PrecacheModel("models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl", true);
	PrecacheModel(RollerModel, true);
	iLaserBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	iHalo = PrecacheModel("materials/sprites/glow01.vmt", true);
}

public void OnGameFrame()
{
	if (iWorld)
	{
		VSH2Player player;
		for (int i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			player = VSH2Player(i);
			if (player.iType == ThisPluginIndex && player.iSpecial == 2)
			{
				float pos[3]; GetEntPropVector(EntRefToEntIndex(player.iClimbs), Prop_Send, "m_vecOrigin", pos);
				pos[2] += 160.0;
				TeleportEntity(i, pos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Dio Brando:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch.\nRage (The World): Call for medic (e) when the Rage is full.\nRoooadaa Rollaaaaaadaaa!!!");
	panel.DrawItem( "Exit" );
	panel.Send(Player.index, PANEL, 10);
	delete (panel);
}
public int PANEL(Menu menu, MenuAction action, int client, int select)
{
	return 0;
}
public void fwdOnBossThink(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	player.DoGenericThink(true, !iWorld, DioJump, .showhud = false);

	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	float jmp = player.flCharge;
	if (jmp > 0.0)
		jmp *= 4.0;
	if (player.flRAGE >= 100.0)
		ShowSyncHudText(player.index, VSH2_BossHud(), "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", RoundFloat(jmp));
	else if (player.iSpecial == 1)
		ShowSyncHudText(player.index, VSH2_BossHud(), "Jump: %i | Rage: USED - Look at a position and CLICK to activate\n%.1f", RoundFloat(jmp), player.flSpecial - GetGameTime());
	else ShowSyncHudText(player.index, VSH2_BossHud(), "Jump: %i | Rage: %0.1f", RoundFloat(jmp), player.flRAGE);

	if (player.iSpecial >= 2)
	{
		int ent = EntRefToEntIndex(player.iClimbs);
		if (IsValidEntity(ent))
		{
			int hpbar = VSH2GameMode_GetProperty("iHealthBar");
			if (IsValidEntity(hpbar))
			{
				int val = RoundToCeil(GetEntProp(ent, Prop_Data, "m_iHealth") / float(GetEntProp(ent, Prop_Data, "m_iMaxHealth")) * 255.0);
//				PrintToChatAll("%d", val);
				SetEntProp(hpbar, Prop_Send, "m_iBossHealthPercentageByte", val);
			}
		}
	}
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(DioModel);
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
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Spy, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		EmitSoundToAll(DioStart);
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null); // should reset Hale's animation
	}
	EmitSoundToAll(DioRage);
	EmitSoundToAll(DioRage);
	SetPawnTimer(DoDioTime, 2.0, player);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	int i = GetRandomInt(1, 2);
	switch (i)
	{
		case 1:time = 265.0;
		case 2:time = 114.0;
	}
	Format(song, sizeof(song), "%s%d.mp3", DioTheme, i);
}
public void fwdOnBossMenu(Menu &menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Dio Brando");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (iWorld && TF2_GetPlayerClass(Victim.index) == TFClass_Medic)
	{
		int wep = GetPlayerWeaponSlot(Victim.index, TFWeaponSlot_Secondary);
		if (wep > MaxClients && IsValidEntity(wep) && HasEntProp(wep, Prop_Send, "m_bChargeRelease"))
		{
			TF2Attrib_RemoveByDefIndex(wep, 314);
			TF2Attrib_RemoveByDefIndex(wep, 7);
		}
	}
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	if (iWorld)
	{
		event.SetString("weapon", "tf_pumpkin_bomb");
		event.SetInt("customkill", TF_CUSTOM_PUMPKIN_BOMB);
	}

	char wep[32];
	event.GetString("weapon", wep, sizeof(wep));
	if (!strcmp(wep, "shovel", false))
	{
		event.SetString("weapon", "fists");

		if (!GetRandomInt(0, 1))
		{
			char s[PLATFORM_MAX_PATH];
			Format(s, sizeof(s), "%s%d.mp3", DioGeneric, GetRandomInt(1, 7));
			EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	EmitSoundToAll(DioFail, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(DioFail, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	if (iWorld && Player.iSpecial)
		TurnTimeOff(Player);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, PLATFORM_MAX_PATH, DioStab);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	Format(s, FULLPATH, "%s%i.mp3", DioWin, GetRandomInt(1, 2));
}
public void fwdOnBossKillBuilding(const VSH2Player Attacker, const int building, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
	if (iWorld && Attacker.iSpecial)
		event.BroadcastDisabled = true;
}
public Action SoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!(0 < entity <= MaxClients))
		return Plugin_Continue;

	if (iWorld && VSH2Player(entity).iType == -1)
		if (!strncmp(sample, "vo", 2, false))
			return Plugin_Handled;
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	if (iWorld)
	{
		VSH2Player player = VSH2Player(client);
		if (player.iType != ThisPluginIndex && iWorld == 1)
			return Plugin_Handled;
		else if (player.iType == ThisPluginIndex)
		{
			if (player.iSpecial == 1)
			{
				bool hit;
				float pos[3]; Dio_GetAimPos(client, pos, hit);
				pos[2] += 10.0;
				TE_SetupBeamRingPoint(pos, 400.0, 400.1, iLaserBeam, iHalo, 0, 10, 0.1, 2.0, 0.0, {255, 255, 255, 255}, 10, 0);
				TE_SendToClient(client);
				bool go = false;
				go = hit && (buttons & IN_ATTACK) && player.flSpecial > GetGameTime();
				if (player.flSpecial <= GetGameTime())
				{
					go = true;
					if (!hit)
						GetClientAbsOrigin(client, pos);
				}
				if (go)
				{
					player.iSpecial = 2;

					pos[2] += 2190.0;
					int ent = CreateEntityByName("prop_physics_override");
					int hpbar = VSH2GameMode_GetProperty("iHealthBar");
					if (IsValidEntity(hpbar))
						SetEntProp(hpbar, Prop_Send, "m_iBossState", !GetEntProp(hpbar, Prop_Send, "m_iBossState"));

					SetEntityModel(ent, RollerModel);
					char tmodel[16]; FormatEx(tmodel, sizeof(tmodel), "roller%d", client);
					DispatchKeyValue(ent, "targetname", tmodel);
					SetVariantInt(1);
					AcceptEntityInput(ent, "SetHealth");

					DispatchSpawn(ent);
					SetEntProp(ent, Prop_Data, "m_iMaxHealth", 1);
					SetEntProp(ent, Prop_Data, "m_iHealth", 1);
					SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
					SetEntProp(ent, Prop_Send, "m_usSolidFlags", GetEntProp(ent, Prop_Send, "m_usSolidFlags") | 4);
					SetEntProp(ent, Prop_Send, "m_CollisionGroup", 0);
					SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(client));

//					float mins[3], maxs[3];
//					GetEntPropVector(ent, Prop_Send, "m_vecMins", mins);
//					GetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxs);
//					PrintToChatAll("%.2f, %.2f, %.2f\n%.2f, %.2f, %.2f", mins[0], mins[1], mins[2], maxs[0], maxs[1], maxs[2]);

					player.iClimbs = EntIndexToEntRef(ent);
					float ang[3]; GetClientEyeAngles(client, ang);
					ang[0] = 90.0;
					TeleportEntity(ent, pos, ang, NULL_VECTOR);

					float cangles[3], clientEyes[3], resultant[3];

					for (int i = MaxClients; i; --i)
					{
						if (!IsClientInGame(i) || !IsPlayerAlive(i))
							continue;

						GetClientEyePosition(i, clientEyes);
						MakeVectorFromPoints(pos, clientEyes, resultant);
						GetVectorAngles(resultant, cangles);
						if (cangles[0] >= 270.0)
						{
							cangles[0] -= 270.0;
							cangles[0] = (90.0 - cangles[0]);
						}
						else if (cangles[0] <= 90.0)
							cangles[0] = -cangles[0];

						cangles[1] -= 180;
						TeleportEntity(i, NULL_VECTOR, cangles, NULL_VECTOR);
					}

					pos[2] += 200.0;
					SetEntityGravity(client, 0.75);
					ang[0] = -90.0;
					TeleportEntity(client, pos, ang, view_as< float >({0.0, 0.0, 0.0}));
					ang[0] = -120.0;
					SetEntProp(client, Prop_Send, "m_CollisionGroup", 0);

					char s[PLATFORM_MAX_PATH];
					strcopy(s, PLATFORM_MAX_PATH, RoadRoller);
					EmitSoundToAll(s);
					EmitSoundToAll(s);

					SetPawnTimer(RollerCollide, 2.5, player);
				}
				buttons &= ~IN_ATTACK;
			}
			else if (player.iSpecial == 2)
			{
				buttons = 0;
				float eyeang[3]; GetClientEyeAngles(client, eyeang);
				eyeang[0] = 90.0;
				vel[1] = 1.0;
				TeleportEntity(client, NULL_VECTOR, eyeang, NULL_VECTOR);
			}
			else if (player.iSpecial == 3)
			{
				buttons |= IN_ATTACK;
			}

			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public void RollerCollide(const VSH2Player player)
{
	if (!IsClientValid(player.index) || !IsPlayerAlive(player.index))
		return;

	int ent = EntRefToEntIndex(player.iClimbs);
	if (!IsValidEntity(ent))
		return;

	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	float ang[3]; GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
	RemoveEntity(ent);

	ent = CreateEntityByName("base_boss");
	SetEntityModel(ent, RollerModel);
	char tmodel[16]; FormatEx(tmodel, sizeof(tmodel), "roller%d", player.index);
	DispatchKeyValue(ent, "targetname", tmodel);

	DispatchSpawn(ent);
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", player.index);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 5);
	SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(player.index));

	SetEntityMoveType(ent, MOVETYPE_NONE);
	int hp = RoundFloat(500.0 + 600.0 * Pow(float(GetLivingPlayers(player.iOtherTeam)), 0.6969));
	SetVariantInt(hp);
	AcceptEntityInput(ent, "SetHealth");
	SetEntProp(ent, Prop_Data, "m_iMaxHealth", hp);
	SetEntProp(ent, Prop_Data, "m_iHealth", hp);
	SetEntProp(ent, Prop_Data, "m_takedamage", 2);
	SetEntProp(ent, Prop_Data, "m_bloodColor", -1); //Don't bleed
	SetEntData(ent, FindSendPropInfo("CTFBaseBoss", "m_lastHealthPercentage") + 28, false, 4, true);	//ResolvePlayerCollisions

	HookSingleEntityOutput(ent, "OnKilled", OnRollerBreak);
	SDKHook(ent, SDKHook_OnTakeDamage, OnRollerTakeDamage);
//	SDKHook(ent, SDKHook_Think, RollerSetBox);
//	SDKHook(ent, SDKHook_OnTakeDamagePost, OnRollerTakeDamage);

	player.iClimbs = EntIndexToEntRef(ent);
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	pos[2] += 100.0;
	TeleportEntity(player.index, pos, NULL_VECTOR, NULL_VECTOR);

	Address pBody = GetBodyInterface(ent);
	if (pBody != Address_Null)
	{
		DHookRaw(g_hGetHullMins,         true, pBody);  //Fixes the NPC getting stuck so much
		DHookRaw(g_hGetHullMaxs,         true, pBody);  //Fixes the NPC getting stuck so much  
	}

	SetPawnTimer(EmitMuda, 0.7, player);

	SetEntityMoveType(player.index, MOVETYPE_NONE);
	SetEntityMoveType(ent, MOVETYPE_NONE);

	TurnTimeHalfOff(player);
}

public Action OnRollerTakeDamage(int victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (0 < attacker <= MaxClients)
	{
		if (TF2_GetPlayerClass(attacker) == TFClass_Heavy && weapon == GetPlayerWeaponSlot(attacker, 0))
		{
			damage /= 3.0;
			return Plugin_Changed;
		}
		else if (inflictor != -1)
		{
			char cls[32]; GetEntityClassname(inflictor, cls, sizeof(cls));
			if (!strncmp(cls, "obj_", 4, false))
			{
				damage /= 3.0;
				return Plugin_Changed;
			}
		}
//		damagetype &= ~DMG_CRIT;
	}
	return Plugin_Continue;
}
public void OnRollerBreak(const char[] output, int ent, int breaker, float delay)
{
	VSH2Player owner = VSH2Player(GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity"));
	if (IsClientValid(owner.index))
	{
		RollerExplode(owner, false);
		EmitSoundToAll(Nani, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, owner.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(Nani, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, owner.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}

public void EmitMuda(const VSH2Player player)
{
	if (!IsClientValid(player.index) || !IsPlayerAlive(player.index))
		return;

	int ent = EntRefToEntIndex(player.iClimbs);
	if (!IsValidEntity(ent))
		return;

	EmitSoundToAll(MudaMudaMuda, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(MudaMudaMuda, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);

	SetPawnTimer(RollerExplode, 7.3, player, true);

	player.iSpecial = 3;

	TF2Attrib_SetByDefIndex(GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee), 6, 0.25);
}

public void RollerExplode(const VSH2Player player, bool kill)
{
	if (!IsClientValid(player.index) || !IsPlayerAlive(player.index))
		return;

	int ent = EntRefToEntIndex(player.iClimbs);
	if (!IsValidEntity(ent))
		return;

	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(ent, Prop_Send, "m_usSolidFlags", GetEntProp(ent, Prop_Send, "m_usSolidFlags") | 4);
	UnhookSingleEntityOutput(ent, "OnBreak", OnRollerBreak);
	RemoveEntity(ent);

	SetEntityMoveType(player.index, MOVETYPE_WALK);
	player.iSpecial = 0;

	int shaker = CreateEntityByName("env_shake");
	if (!IsValidEntity(shaker))
		return;

	DispatchKeyValue(shaker, "amplitude", "16");
	DispatchKeyValue(shaker, "radius", "8000");
	DispatchKeyValue(shaker, "duration", "4");
	DispatchKeyValue(shaker, "frequency", "20");
	DispatchKeyValue(shaker, "spawnflags", "4");

	TeleportEntity(shaker, pos, NULL_VECTOR, NULL_VECTOR);
	ShowParticle(pos, "fireSmoke_collumn_mvmAcres", 7.0);
	DispatchSpawn(shaker);
	AcceptEntityInput(shaker, "StartShake");
	CreateTimer(5.0, DeleteShake, EntIndexToEntRef(shaker));

	DataPack pack = new DataPack();
	pack.WriteCell(player);
	pack.WriteCell(kill);
	pack.WriteFloat(pos[0]);
	pack.WriteFloat(pos[1]);
	pack.WriteFloat(pos[2]);
	RequestFrame(PerformExplode, pack);

	EmitSoundToAll("misc/doomsday_missile_explosion.wav");
	TurnTimeOff(player);

	TF2Attrib_RemoveByDefIndex(GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee), 6);
}

public void PerformExplode(DataPack pack)
{
	pack.Reset();
	VSH2Player player = pack.ReadCell();
	if (IsClientValid(player.index))
	{
		if (pack.ReadCell())
		{
			DataPack pack2 = new DataPack();
			pack2.WriteFloat(pack.ReadFloat());
			pack2.WriteFloat(pack.ReadFloat());
			pack2.WriteFloat(pack.ReadFloat());
			pack2.WriteCell(player);
			RequestFrame(DoExplode, pack2);
		}
		else
		{
			float v[3];
			v[2] = GetRandomFloat(1000.0, 2000.0);
			v[1] = GetRandomFloat(-1000.0, 1000.0);
			v[0] = GetRandomFloat(-1000.0, 1000.0);
			TeleportEntity(player.index, NULL_VECTOR, NULL_VECTOR, v);
			TF2_AddCondition(player.index, TFCond_AirCurrent, 1.0);
		}
		RequestFrame(CheckForStuck, player);
	}
	delete pack;
}

public void DoExplode(DataPack pack)
{
	pack.Reset();
	float pos[3];
	pos[0] = pack.ReadFloat();
	pos[1] = pack.ReadFloat();
	pos[2] = pack.ReadFloat();
	VSH2Player player = pack.ReadCell();

	if (IsClientValid(player.index) && IsPlayerAlive(player.index))
		DoExplosion(player.index, 1000, 500, pos);

	delete pack;
}

public void CheckForStuck(const VSH2Player player)
{
	if (IsClientValid(player.index) && IsPlayerAlive(player.index))
	{
		float pos[3];
		GetClientAbsOrigin(player.index, pos);
		if (IsClientStuck(player.index, pos) || TR_PointOutsideWorld(pos))
			player.TeleToSpawn(GetClientTeam(player.index));
	}
}

public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Dio Brando");
}

MoveType iOldMoveType[(1 << 11)];

public void DoDioTime(const VSH2Player base)
{
	if (!IsClientValid(base.index) || !IsPlayerAlive(base.index) || iWorld || VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	iWorld = 1;

	int client = base.index;
	int wep, i;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (i == client)
			continue;

		SetEntityMoveType(i, MOVETYPE_NONE);
		if (TF2_GetPlayerClass(i) == TFClass_Heavy && TF2_IsPlayerInCondition(i, TFCond_Slowed))
		{
			char weaponname[32];
			GetClientWeapon(i, weaponname, sizeof(weaponname));
			if (!strcmp(weaponname, "tf_weapon_minigun", false)) 
			{
				SetEntProp(GetPlayerWeaponSlot(i, 0), Prop_Send, "m_iWeaponState", 0);
				TF2_RemoveCondition(i, TFCond_Slowed);
			}
		}

		wep = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
		if (wep > MaxClients && IsValidEntity(wep) && HasEntProp(wep, Prop_Send, "m_bChargeRelease"))
		{
			TF2Attrib_SetByDefIndex(wep, 314, 99999.0);
			TF2Attrib_SetByDefIndex(wep, 7, 0.0);
		}
	}

	i = -1;
	while ((i = FindEntityByClassname(i, "obj_*")) != -1)
		SetEntProp(i, Prop_Send, "m_bDisabled", 1);

	i = -1;
	while ((i = FindEntityByClassname(i, "tf_projectile_*")) != -1)
	{
		iOldMoveType[i] = GetEntityMoveType(i);
		SetEntityMoveType(i, MOVETYPE_NONE);
	}

	base.flSpecial2 = base.flGlowtime;
	base.flGlowtime = 0.0;

	SDKHook(client, SDKHook_SetTransmit, OnDioTransmit);
	TF2_RemoveCondition(client, TFCond_OnFire);
	TF2_RemoveCondition(client, TFCond_Bleeding);
	TF2_RemoveCondition(client, TFCond_Milked);
	SetEntProp(client, Prop_Data, "m_takedamage", 0);
	SetEntityFlags(base.index, GetEntityFlags(base.index)|FL_NOTARGET);

	base.iSpecial = 1;
	base.flSpecial = GetGameTime() + 8.0;
}

public void FixMediguns(const VSH2Player base)
{
	int wep, i;
	for (i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (i == base.index)
			continue;

		wep = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
		if (wep > MaxClients && HasEntProp(wep, Prop_Send, "m_bChargeRelease"))
		{
			TF2Attrib_RemoveByDefIndex(wep, 314);
			TF2Attrib_RemoveByDefIndex(wep, 7);
		}
	}
}

public void TurnTimeHalfOff(const VSH2Player base)
{
	iWorld = 2;
	int i;
	FixMediguns(base);

	i = -1;
	while ((i = FindEntityByClassname(i, "obj_*")) != -1)
		SetEntProp(i, Prop_Send, "m_bDisabled", 0);

	i = -1;
	while ((i = FindEntityByClassname(i, "tf_projectile_*")) != -1)
		if (iOldMoveType[i] != view_as< MoveType >(-1))
		{
			SetEntityMoveType(i, iOldMoveType[i]);
			iOldMoveType[i] = view_as< MoveType >(-1);
		}

	SDKUnhook(base.index, SDKHook_SetTransmit, OnDioTransmit);
	base.flGlowtime = base.flSpecial2;
	base.flSpecial2 = 0.0;
}

public void TurnTimeOff(const VSH2Player base)
{
	if (!iWorld)
		return;

	iWorld = 0;
	int hpbar = VSH2GameMode_GetProperty("iHealthBar");
	if (IsValidEntity(hpbar))
		SetEntProp(hpbar, Prop_Send, "m_iBossState", !GetEntProp(hpbar, Prop_Send, "m_iBossState"));

	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i))
			SetEntityMoveType(i, MOVETYPE_WALK);
	}

	if (!IsClientValid(base.index))
		return;

	SetPawnTimer(DoSetHP, 0.2, base);
	base.flGlowtime = base.flSpecial2;
	base.flSpecial2 = 0.0;
	base.iSpecial = 0;
	SetEntityGravity(base.index, 1.0);

	SetEntProp(base.index, Prop_Send, "m_CollisionGroup", 6);
}

public void DoSetHP(const VSH2Player base)
{
	if (IsClientValid(base.index) && IsPlayerAlive(base.index))
	{
		SetEntityFlags(base.index, GetEntityFlags(base.index) & ~FL_NOTARGET);
		SetEntProp(base.index, Prop_Data, "m_takedamage", 2);
	}
}

public Action OnDioTransmit(int ent, int other)
{
	if (ent == other)
		return Plugin_Continue;
	return Plugin_Handled;
}

public Action SMAC_OnCheatDetected(int client, const char[] module, DetectionType type, Handle info)
{
	if (iWorld)
		return Plugin_Handled;
	return Plugin_Continue;
}

public Action DeleteShake(Handle timer, any ref)
{
	int iEntity = EntRefToEntIndex(ref); 
	if (iEntity > MaxClients) 
	{
		AcceptEntityInput(iEntity, "Kill"); 
		AcceptEntityInput(iEntity, "StopShake");
	}
	return Plugin_Handled;
}

public void ShowParticle(float pos[3], char[] particlename, float time)
{
    int particle = CreateEntityByName("info_particle_system");
    if (IsValidEdict(particle))
    {
        TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(particle, "effect_name", particlename);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "start");
        CreateTimer(time, DeleteParticles, EntIndexToEntRef(particle));
    }
}
public Action DeleteParticles(Handle timer, any particle)
{
	int ent = EntRefToEntIndex(particle);

	if (ent != INVALID_ENT_REFERENCE)
	{
		char classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
			AcceptEntityInput(ent, "kill");
	}
	return Plugin_Handled;
}

stock bool TE_DrawBox(int client, float m_vecOrigin[3], float m_vecMins[3], float m_vecMaxs[3], float flDur = 0.1, int color[4], bool hullonly = false)
{
	//Trace top down
	float tStart[3]; tStart = m_vecOrigin;
	float tEnd[3];   tEnd = m_vecOrigin;
	
	tStart[2] = (tStart[2] + m_vecMaxs[2]);
	
//	TE_ShowPole(tStart, view_as<int>( { 255, 0, 255, 255 } ));
//	TE_ShowPole(tEnd, view_as<int>( { 0, 255, 255, 255 } ));
	
	Handle trace = TR_TraceHullFilterEx(tStart, tEnd, m_vecMins, m_vecMaxs, MASK_SHOT|CONTENTS_GRATE, WorldOnly, client);
	bool bDidHit = TR_DidHit(trace);
	delete trace;

	if (hullonly)
		return bDidHit;
	
	if( m_vecMins[0] == m_vecMaxs[0] && m_vecMins[1] == m_vecMaxs[1] && m_vecMins[2] == m_vecMaxs[2] )
	{
		m_vecMins = view_as<float>({-15.0, -15.0, -15.0});
		m_vecMaxs = view_as<float>({15.0, 15.0, 15.0});
	}
	else
	{
		AddVectors(m_vecOrigin, m_vecMaxs, m_vecMaxs);
		AddVectors(m_vecOrigin, m_vecMins, m_vecMins);
	}
	
	float vPos1[3], vPos2[3], vPos3[3], vPos4[3], vPos5[3], vPos6[3];
	vPos1 = m_vecMaxs;
	vPos1[0] = m_vecMins[0];
	vPos2 = m_vecMaxs;
	vPos2[1] = m_vecMins[1];
	vPos3 = m_vecMaxs;
	vPos3[2] = m_vecMins[2];
	vPos4 = m_vecMins;
	vPos4[0] = m_vecMaxs[0];
	vPos5 = m_vecMins;
	vPos5[1] = m_vecMaxs[1];
	vPos6 = m_vecMins;
	vPos6[2] = m_vecMaxs[2];

	TE_SendBeam(client, m_vecMaxs, vPos1, flDur, color);
	TE_SendBeam(client, m_vecMaxs, vPos2, flDur, color);
	TE_SendBeam(client, m_vecMaxs, vPos3, flDur, color);
	TE_SendBeam(client, vPos6, vPos1, flDur, color);
	TE_SendBeam(client, vPos6, vPos2, flDur, color);
	TE_SendBeam(client, vPos6, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos4, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos5, m_vecMins, flDur, color);
	TE_SendBeam(client, vPos5, vPos1, flDur, color);
	TE_SendBeam(client, vPos5, vPos3, flDur, color);
	TE_SendBeam(client, vPos4, vPos3, flDur, color);
	TE_SendBeam(client, vPos4, vPos2, flDur, color);
		
	return bDidHit;
}

public bool WorldOnly(int ent, int mask, any data)
{
	return ent <= 0;
}

stock void TE_SendBeam(int client, float m_vecMins[3], float m_vecMaxs[3], float flDur = 0.1, int color[4])
{
	TE_SetupBeamPoints(m_vecMins, m_vecMaxs, iLaserBeam, iHalo, 0, 0, flDur, 1.0, 1.0, 1, 0.0, color, 0);
	TE_SendToClient(client);
}

public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Dio Brando", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Dio Brando");
	}
}

public Action fwdOnBossDealDamage(VSH2Player victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!(0 < attacker <= MaxClients))
		return Plugin_Continue;

	if (VSH2Player(attacker).iType == ThisPluginIndex && iWorld)
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action fwdOnHealthBarUpdate()
{
	return iWorld ? Plugin_Handled : Plugin_Continue;
}

public MRESReturn IBody_GetHullMins(Address pThis, Handle hReturn, Handle hParams)
{
	DHookSetReturnVector(hReturn, view_as<float>( {-188.05, -64.29, -1.92} ));
	return MRES_Supercede;
}

public MRESReturn IBody_GetHullMaxs(Address pThis, Handle hReturn, Handle hParams)
{
	DHookSetReturnVector(hReturn, view_as<float>( {77.55, 64.29, 139.34} ));
	return MRES_Supercede;
}

public MRESReturn CBaseAnimatingOverlay_StudioFrameAdvance(int pThis)
{
	if (iWorld == 1)
	{
//		PrintToChatAll("Stopping for %d", pThis);
//		if (0 < pThis <= MaxClients)
//		{
//			if (VSH2Player(pThis).iType == ThisPluginIndex && VSH2Player(pThis).iSpecial)
//				return MRES_Ignored;
//		}
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public MRESReturn CBaseAnimating_DispatchAnimEvents(int pThis, Handle hParams)
{
	if (iWorld == 1)
	{
		PrintToChatAll("Stopping for %d", pThis);
//		if (0 < pThis <= MaxClients)
//		{
//			if (VSH2Player(pThis).iType == ThisPluginIndex && VSH2Player(pThis).iSpecial)
//				return MRES_Ignored;
//		}
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public Address GetBodyInterface(int index)
{
	Address pNB = SDKCall(g_hMyNextBotPointer, index);
	return SDKCall(g_hGetBodyInterface, pNB);
}

Handle DHookCreateEx(Handle gc, const char[] key, HookType hooktype, ReturnType returntype, ThisPointerType thistype, DHookCallback callback)
{
	int iOffset = GameConfGetOffset(gc, key);
	if(iOffset == -1)
	{
		SetFailState("Failed to get offset of %s", key);
		return null;
	}
	
	return DHookCreate(iOffset, hooktype, returntype, thistype, callback);
}

stock Handle DHookCreateDetourEx(GameData conf, const char[] name, CallingConvention callConv, ReturnType returntype, ThisPointerType thisType)
{
	Handle h = DHookCreateDetour(Address_Null, callConv, returntype, thisType);
	if (h)
		if (!DHookSetFromConf(h, conf, SDKConf_Signature, name))
			LogError("Could not set %s from config!", name);
	return h;
}

stock bool Dio_GetAimPos(const int client, float vecPos[3], bool &hit)
{
	float StartOrigin[3], Angles[3];
	GetClientEyeAngles(client, Angles);
	GetClientEyePosition(client, StartOrigin);

	Handle trace = TR_TraceRayFilterEx(StartOrigin, Angles, MASK_ALL & (~CONTENTS_HITBOX), RayType_Infinite, DioTrace, client);
	if (TR_DidHit(trace) && !(TR_GetSurfaceFlags(trace) & SURF_SKY))
	{
		hit = true;
		TR_GetEndPosition(vecPos, trace);
	}
	else hit = false;
	delete trace;
	return hit;
}

public bool DioTrace(int ent, int mask, any data)
{
	return !(0 < ent <= MaxClients);
}