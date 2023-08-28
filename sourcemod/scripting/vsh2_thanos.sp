#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>
#include <tf2attributes>
#include <arrayqueue>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Thanos", 
	author = "Scag", 
	description = "VSH2 boss Thanos", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;
bool bReverseThings;
ArrayQueue hTime[34];
Handle g_VSH2;
Function g_Func;

enum struct TimeShit
{
	float pos[3];
	float ang[3];
	float vel[3];
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", false))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_thanos");
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
		VSH2_Hook(OnBossKillBuilding, fwdOnBossKillBuilding);
		VSH2_Hook(OnMinionHurt, fwdOnMinionHurt);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
		VSH2_Hook(OnRedPlayerThink, fwdOnRedPlayerThink);
		g_VSH2 = VSH2_Self();
		g_Func = GetFunctionByName(g_VSH2, "ManageBossModels");
	}
}

public void OnPluginStart()
{
	HookEvent("teamplay_round_win", OnRoundEnd, EventHookMode_Pre);
	HookEvent("player_spawn", OnSpawn);
	for (int i = 0; i < 34; ++i)
		hTime[i] = new ArrayQueue(sizeof(TimeShit));
}

public Action OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (bReverseThings)
		bReverseThings = false;
	return Plugin_Continue;
}

public void OnSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	hTime[client].Clear();
}


#define ThanosModel                 "models/freak_fortress_2/thanos_v4/thanos_v4.mdl"

#define ThanosKill 					"opst/saxtonhale/thanos/kill"	// 7
#define ThanosStart 				"opst/saxtonhale/thanos/start"	// 5
#define ThanosFail 					"opst/saxtonhale/thanos/fail1.mp3"
#define ThanosWin 					"opst/saxtonhale/thanos/win1.mp3"
#define ThanosSecret 				"opst/saxtonhale/thanos/secret.mp3"
//#define ThanosRage 					"opst/saxtonhale/thanos/snap.mp3"
#define ThanosTheme1 				"opst/saxtonhale/thanos/theme1.mp3"
#define ThanosTheme2 				"opst/saxtonhale/thanos/theme2.mp3"
#define ThanosJump 					"opst/saxtonhale/thanos/jump"	// 2

static const char ThanosRages[][] = {
	"misc/ks_tier_04_kill_01.wav",
	"misc/ks_tier_04.wav",
	"misc/ks_tier_04_death.wav"
};

static const char strStones[][] = {
	"Reality",
	"Power",
	"Space",
	"Mind",
	"Time",
	"Soul"
};

public void fwdOnDownloadsCalled()
{
	PrepareModel(ThanosModel);
	PrepareMaterial("materials/freak_fortress_2/thanos_v3/thanos_texture");
	PrepareMaterial("materials/freak_fortress_2/thanos_v3/stone_texture");
	int i;
	char s[PLATFORM_MAX_PATH];
	for (i = 1; i <= 6; i++)
	{
		Format(s, sizeof(s), "%s%d.mp3", ThanosKill, i);
		PrepareSound(s);

		if (i <= 5)
		{
			Format(s, sizeof(s), "%s%d.mp3", ThanosStart, i);
			PrepareSound(s);
		}
		
		if (i <= 2)
		{
			Format(s, sizeof(s), "%s%d.mp3", ThanosJump, i);
			PrepareSound(s);
		}
	}
	PrepareSound(ThanosFail);
	PrepareSound(ThanosWin);
	//PrepareSound(ThanosSecret);
	PrepareSound(ThanosTheme1);
	PrepareSound(ThanosTheme2);
	for (i = 0; i < sizeof(ThanosRages); ++i)
		PrecacheSound(ThanosRages[i], true);
	PrecacheSound("weapons/vaccinator_toggle.wav", true);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Thanos:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch.\nRage (Infinity Gauntlet): Call for medic (e) when the Rage is full to activate one of your Infinity Stones.\nReload (r) to cycle through your active Stone.");
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

	Player.DoGenericThink(true, true, ThanosJump, 2, _, false);
	if (Player.flSpecial2 <= GetGameTime())
	{
		if (Player.iSpecial == 3)
			bReverseThings = false;
		else if (Player.iSpecial == 5)
		{
//			int wep = GetPlayerWeaponSlot(Player.index, TFWeaponSlot_Melee);
//			if (wep > MaxClients)
//				TF2Attrib_RemoveByDefIndex(Player.index, 71);
		}
		Player.iSpecial = 0;
	}
	else if (Player.iSpecial == 5)
	{
		int i;

		float pos[3], pos2[3], distance;
		GetEntPropVector(Player.index, Prop_Send, "m_vecOrigin", pos);
		for(i=MaxClients ; i ; --i)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i) || i == Player.index)
				continue;
			else if(GetClientTeam(i) == GetClientTeam(Player.index))
				continue;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (distance < 400.0 && TF2_IsKillable(i))
			{
				TF2_IgnitePlayer(i, Player.index);
				SDKHooks_TakeDamage(i, 0, Player.index, 1.0, DMG_BURN);
			}
		}

		if (!GetRandomInt(0, 15))
		{
			static char particles[][] = {"cinefx_goldrush", "hightower_explosion", "mvm_hatch_destroy"};
			float angle[3];
			angle[0] = GetRandomFloat(-180.0, 180.0);
			SetPawnTimer(RemoveEnt, 2.0, EntIndexToEntRef(CreateRocketTrail(Player.index, particles[GetRandomInt(0, sizeof(particles)-1)], angle)));
		}
	}

	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	float jmp = Player.flCharge;
	if (jmp > 0.0)
		jmp *= 4.0;
	if (Player.flRAGE >= 100.0)
		ShowSyncHudText(Player.index, VSH2_BossHud(), "Jump: %i | Rage: FULL - Call Medic (default: E) to activate\nStone: %s | Reload (default: R) to cycle", RoundFloat(jmp), strStones[Player.iSpecial2]);
	else ShowSyncHudText(Player.index, VSH2_BossHud(), "Jump: %i | Rage: %0.1f\nStone: %s | Reload (default: R) to cycle", RoundFloat(jmp), Player.flRAGE, strStones[Player.iSpecial2]);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(ThanosModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 252 ; 0.6 ; 350 ; 1.0 ; 214 ; %d", GetRandomInt(999, 9999));
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_bonesaw", 5, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	Player.iSpecial2 = GetRandomInt(0, 5);
	Player.bNoRagdoll = true;
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Medic, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char s[PLATFORM_MAX_PATH];
		Format(s, PLATFORM_MAX_PATH, "%s%d.mp3", ThanosStart, GetRandomInt(1, 5));
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	int client = player.index;

	if ( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null); // should reset Hale's animation
	}
	switch (player.iSpecial2)
	{
		case 0:		// Reality stone
		{
			int i, count, team = GetClientTeam(client);
			int[] clients = new int[MaxClients];

			for (i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				if (GetClientTeam(i) == team)
					continue;

				SetVariantString(ThanosModel);
				AcceptEntityInput(i, "SetCustomModel");
				SetEntProp(i, Prop_Send, "m_bUseClassAnimations", 1);
				if (!GetEntProp(i, Prop_Send, "m_bCarryingObject") && !TF2_IsPlayerInCondition(i, TFCond_Slowed))
					SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(i, TFWeaponSlot_Melee));
				clients[count++] = i;
			}

			int target;
			if (count)
			{
				float vecMyPos[3]; GetClientAbsOrigin(client, vecMyPos);
				float vecMyEyes[3]; GetClientEyeAngles(client, vecMyEyes);
				float vecTheirPos[3], vecTheirEyes[3];
				for (int tries = 0;; ++tries)
				{
					if (tries > MaxClients)
					{
						PrintCenterText(client, "Couldn't find a target!");
						break;
					}

					target = clients[GetRandomInt(0, count-1)];
					if (IsClientValid(target))
					{
						GetClientAbsOrigin(target, vecTheirPos);
						if (IsClientStuck(client, vecTheirPos))
							continue;

						if (GetEntProp(target, Prop_Send, "m_bDucked"))
							FixDucking(client);

						GetClientEyeAngles(target, vecTheirEyes);
						TeleportEntity(target, vecMyPos, vecMyEyes, NULL_VECTOR);
						TeleportEntity(client, vecTheirPos, vecTheirEyes, NULL_VECTOR);	
						player.flGlowtime = 0.0;
						TF2_RemoveCondition(player.index, TFCond_OnFire);
						break;
					}
				}
			}
			else PrintCenterText(client, "Couldn't find a target!");

			SetEntityFlags(client, GetEntityFlags(client)|FL_NOTARGET);
			SetPawnTimer(RedoFlags, 5.0, player);
			SetPawnTimer(ResetAllModels, 15.0, VSH2GameMode_GetProperty("iRoundCount"), GetClientTeam(player.index));
		}
		case 1:		// Power Stone
		{
			TF2_AddCondition(client, TFCond_Kritzkrieged, 8.0);
			TF2_AddCondition(client, TFCond_MegaHeal, 8.0);
			TF2_AddCondition(client, TFCond_DefenseBuffNoCritBlock, 8.0);
		}
		case 2:		// Space Stone
		{
			int i, count;
			int[] clients = new int[MaxClients];

			for (i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				if (GetClientTeam(i) == player.iOtherTeam)
					clients[count++] = i;
			}
			int count2 = RoundFloat(GetLivingPlayers(player.iOtherTeam) * 0.66);
			if (count2 <= 1)
			{
				PrintCenterText(client, "Can't use Space Stone with player few players!");
				VSH2GameMode_GiveBackRage(player.userid);
				return;
			}

			TF2_AddCondition(client, view_as<TFCond>(42), 8.0);
			TF2_AddCondition(client, TFCond_MegaHeal, 8.0);
			float vecEyes[2][3];
			float vecPos[2][3];
			int client1, client2;
			bool ducked[2];
			for (i = 0; i < count2; ++i)
			{
				client1 = clients[GetRandomInt(0, count-1)];
				client2 = clients[GetRandomIntExcept(0, count-1, client1)];
				GetClientAbsOrigin(client1, vecPos[0]);
				GetClientEyeAngles(client1, vecEyes[0]);
				GetClientAbsOrigin(client2, vecPos[1]);
				GetClientEyeAngles(client2, vecEyes[1]);
				ducked[0] = !!GetEntProp(client1, Prop_Send, "m_bDucked");
				ducked[1] = !!GetEntProp(client2, Prop_Send, "m_bDucked");
				if (ducked[0])
					FixDucking(client2);
				if (ducked[1])
					FixDucking(client1);
				TeleportEntity(client1, vecPos[1], vecEyes[1], NULL_VECTOR);
				TeleportEntity(client2, vecPos[0], vecEyes[0], NULL_VECTOR);
			}
		}
		case 3:		// Mind Stone
		{
			bReverseThings = true;
			player.iSpecial = 3;
			player.flSpecial2 = GetGameTime() + 8.0;
//			SetPawnTimer(ResetReverse, 8.0, player);
		}
		case 4:		// Time Stone
		{
			TF2_AddCondition(client, view_as< TFCond >(42), 8.0);
			TimeShit t;
			int i;
			for (i = MaxClients; i; --i)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;

				if (GetClientTeam(i) == GetClientTeam(client))
					continue;

				if (hTime[i].DequeueArrayEx(t))
					TeleportEntity(i, t.pos, t.ang, t.vel);
			}
		}
		case 5:		// Soul Stone
		{
			//	float pos[3];
			//	GetClientAbsOrigin(client, pos);
			//	int i;
			//	int living;
			//	int dead;
			//	int total;

			//	for (i = MaxClients; i; --i)
			//	{
			//		if (!IsClientInGame(i))
			//			continue;

			//		if (IsPlayerAlive(i) && GetClientTeam(i) == player.iOtherTeam)
			//			++living;
			//		else if (!IsPlayerAlive(i))
			//			++dead;
			//	}
			//	total = min(living, dead);
			//	if (total > 5)
			//		total = 5;

			//	VSH2Player base;
			//	for (i = 0; i < total; ++i)
			//	{
			//		base = VSH2Player(GetDeadPlayer());
			//		if (!IsClientValid(base.index))
			//			break;

			//		base.iOwnerBoss = player.userid;
			//		base.bIsMinion = true;
			//		TF2_SetPlayerClass(base.index, view_as< TFClassType >(GetRandomInt(1, 9)));
			//		base.ForceTeamChange(GetClientTeam(player.index));
			//		base.PreEquip();
			//		TF2_RegeneratePlayer(base.index);

			//		float vecVel[3];
			//		TF2_AddCondition(base.index, TFCond_Ubercharged, 4.0);
			//		vecVel[0] = GetRandomFloat(-300.0, 300.0);
			//		vecVel[1] = GetRandomFloat(-300.0, 300.0);
			//		vecVel[2] = GetRandomFloat(150.0,  300.0);
			//		TeleportEntity(base.index, pos, nullvec, vecVel);
			//		TF2Attrib_SetByDefIndex(base.index, 57, 2.0);
			//	}

			player.iSpecial = 5;
			player.flSpecial2 = GetGameTime() + 6.0;

			TF2_AddCondition(player.index, TFCond_MarkedForDeath, 10.0);
			float pos[3]; GetClientAbsOrigin(player.index, pos);
			float angle[3];
			angle[0] = GetRandomFloat(-180.0, 180.0);
			SetPawnTimer(RemoveEnt, 4.0, EntIndexToEntRef(CreateRocketTrail(player.index, "mvm_hatch_destroy", angle)));
//			int wep = GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee);
//			if (wep > MaxClients)
//				TF2Attrib_SetByDefIndex(wep, 71, 4.0);
		}
	}
	PrintCenterTextAll("Thanos has used the %s Stone!", strStones[player.iSpecial2]);
	EmitSoundToAll(ThanosRages[GetRandomInt(0, 2)]);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(0, 1))
	{
		case 0:
		{
			strcopy(song, sizeof(song), ThanosTheme1);
			time = 198.0;
		}
		case 1:
		{
			strcopy(song, sizeof(song), ThanosTheme2);
			time = 232.0;
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Thanos");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
	{
		if (Victim.bIsMinion && !(event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER))
		{
			VSH2Player owner = VSH2Player(Victim.iOwnerBoss);
			if (IsClientValid(owner.index) && owner.iType == ThisPluginIndex)
			{
				Victim.bIsMinion = false;
				SetPawnTimer(SetTeam, 0.2, Victim, Victim.iOtherTeam);
//				ChangeClientTeam(Victim.index, Victim.iOtherTeam);
			}
		}

		return;
	}

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	if (event.GetInt("customkill") != TF_CUSTOM_BOOTS_STOMP)
	{
		char str[32]; event.GetString("weapon_logclassname", str, sizeof(str));
		if (strcmp(str, "flamethrower"))
			event.SetString("weapon", "fists");
	}

	if (!GetRandomInt(0, 1))
	{
		char snd[PLATFORM_MAX_PATH];
		Format(snd, sizeof(snd), "%s%d.mp3", ThanosKill, GetRandomInt(1, 6));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	EmitSoundToAll(ThanosFail, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(ThanosFail, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, sizeof(s), ThanosWin);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Thanos");
}
public void fwdOnBossKillBuilding(const VSH2Player player, const int building, Event event)
{
	if (player.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
}
public void fwdOnMinionHurt(const VSH2Player victim, const VSH2Player attacker, int &damage, Event event)
{
	if (VSH2Player(victim.iOwnerBoss).iType == ThisPluginIndex)
		damage = 0;
}

public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	VSH2Player player = VSH2Player(client);
	if (bReverseThings)
	{
		VSH2Player base;
		int team;
		for (int i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			base = VSH2Player(i);
			if (base.iType == ThisPluginIndex && base.iSpecial == 3)
			{
				team = GetClientTeam(i);
				break;
			}
		}
		if (team && GetClientTeam(client) != team)
		{
			vel[0] = -vel[0];
			vel[1] = -vel[1];
			vel[2] = -vel[2];
		}
		return Plugin_Changed;
	}
	if (player.iType == ThisPluginIndex)
	{
		if (buttons & (IN_RELOAD|IN_ATTACK3) && !(GetEntProp(client, Prop_Data, "m_nOldButtons") & (IN_RELOAD|IN_ATTACK3)))
		{
			EmitSoundToClient(player.index, "weapons/vaccinator_toggle.wav");
			if (++player.iSpecial2 > 5)
				player.iSpecial2 = 0;
		}
	}
	return Plugin_Continue;
}

//public void ResetReverse(const VSH2Player player)
//{
//	bReverseThings = false;
//	if (IsClientValid(player.index))
//		player.iSpecial = 0;
//}

public Action OnStartTouch(int entity, int other)
{
	if (other > 0 && other <= MaxClients)
		return Plugin_Continue;
	
	SDKHook(entity, SDKHook_Touch, OnTouch);
	return Plugin_Handled;
}

public Action OnTouch(int entity, int other)
{
	float vOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
	
	float vAngles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngles);
	
	float vVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vVelocity);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TEF_ExcludeEntity, entity);
	
	if(!TR_DidHit(trace))
	{
		delete trace;
		return Plugin_Continue;
	}
	
	float vNormal[3];
	TR_GetPlaneNormal(trace, vNormal);
	
	//PrintToServer("Surface Normal: [%.2f, %.2f, %.2f]", vNormal[0], vNormal[1], vNormal[2]);
	
	delete trace;
	
	float dotProduct = GetVectorDotProduct(vNormal, vVelocity);
	
	ScaleVector(vNormal, dotProduct);
	ScaleVector(vNormal, 2.0);
	
	float vBounceVec[3];
	SubtractVectors(vVelocity, vNormal, vBounceVec);
	
	float vNewAngles[3];
	GetVectorAngles(vBounceVec, vNewAngles);
	
	//PrintToServer("Angles: [%.2f, %.2f, %.2f] -> [%.2f, %.2f, %.2f]", vAngles[0], vAngles[1], vAngles[2], vNewAngles[0], vNewAngles[1], vNewAngles[2]);
	//PrintToServer("Velocity: [%.2f, %.2f, %.2f] |%.2f| -> [%.2f, %.2f, %.2f] |%.2f|", vVelocity[0], vVelocity[1], vVelocity[2], GetVectorLength(vVelocity), vBounceVec[0], vBounceVec[1], vBounceVec[2], GetVectorLength(vBounceVec));
	
	TeleportEntity(entity, NULL_VECTOR, vNewAngles, vBounceVec);
	
	SDKUnhook(entity, SDKHook_Touch, OnTouch);
	return Plugin_Handled;
}

public bool TEF_ExcludeEntity(int entity, int contentsMask, any data)
{
	return (entity != data);
}

public void ResetAllModels(const int roundcount, const int team)
{
	if (roundcount != VSH2GameMode_GetProperty("iRoundCount"))
		return;

	VSH2Player player;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if (GetClientTeam(i) == team)
			continue;

		player = VSH2Player(i);

		if (player.bIsBoss)
		{
			Call_StartFunction(g_VSH2, g_Func);
			Call_PushCell(player);
			Call_Finish();
		}
		else
		{
			SetVariantString("");
			AcceptEntityInput(i, "SetCustomModel");
		}
	}
}

public void RedoFlags(const VSH2Player player)
{
	if (IsClientValid(player.index))
		SetEntityFlags(player.index, GetEntityFlags(player.index) & ~FL_NOTARGET);
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Thanos", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Thanos");
	}
}

public void fwdOnRedPlayerThink(const VSH2Player player)
{
	TimeShit t;
	GetClientAbsOrigin(player.index, t.pos);
	GetClientEyeAngles(player.index, t.ang);
	GetEntPropVector(player.index, Prop_Data, "m_vecVelocity", t.vel);
	hTime[player.index].EnqueueArray(t);
	if (hTime[player.index].Length > 50)
		hTime[player.index].Dequeue();
}

public void SetTeam(const VSH2Player player, const int team)
{
	if (IsClientValid(player.index))
		ChangeClientTeam(player.index, team);
}

stock int min(int a, int b)
{
	return a < b ? a : b;
}

stock void FixDucking(int client)
{
	float collisionvec[3] = {24.0, 24.0, 62.0};
	SetEntPropVector(client, Prop_Send, "m_vecMaxs", collisionvec);
	SetEntProp(client, Prop_Send, "m_bDucked", 1);
	SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
}

stock int CreateRocketTrail(int client, const char[] particlename, float angle[3])
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "effect_name", particlename);

//		DispatchKeyValue(particle, "angles", "-90.0, 0.0, 0.0"); 
		DispatchSpawn(particle);

		float pos[3]; GetClientAbsOrigin(client, pos);
		TeleportEntity(particle, pos, angle);

		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", client);
		ActivateEntity(particle);
		SetVariantString("flag");
		AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset");

		AcceptEntityInput(particle, "start");
	}
	return particle;
}

stock int CreateParticleBlast(int entity, const char[] particlename, float vloc[3])
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		char tName[32];
		Format(tName, sizeof(tName), "target%i", entity);
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, vloc, NULL_VECTOR, NULL_VECTOR);
	}
	return particle;
}
public void RemoveEnt(any data)
{
	if (IsValidEntity(data))
		RemoveEntity(data);
}