public Action ReSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss player = BaseBoss(event.GetInt("userid"), true);
	if (player.index)
	{
		SetVariantString(""); AcceptEntityInput(player.index, "SetCustomModel");
		player.SetOverlay("0");
		int gmflags = gamemode.iSpecialRound;
		player.bInJump = false;

		if (player.bIsBoss && gamemode.iRoundState < StateEnding && gamemode.iRoundState != StateDisabled)
		{
			if (GetClientTeam(player.index) != gamemode.iHaleTeam && !(gmflags & ROUND_HVH))
				player.ForceTeamChange(gamemode.iHaleTeam);
			player.ConvertToBoss();		// in base.sp
			if (player.iHealth == 0)
				player.iHealth = player.iMaxHealth;
		}

		if (!player.bIsBoss && StateStarting <= gamemode.iRoundState <= StateEnding && !player.bIsMinion)
		{
//			PrintToChatAll("AAAA");
			if (GetClientTeam(player.index) != gamemode.iOtherTeam)
			{
				if (!(gmflags & ROUND_HVH) && !(CheckCommandAccess(player.index, "sm_asdcdfc", ADMFLAG_ROOT, true) && gamemode.iRoundState == StateRunning))
					player.ForceTeamChange(gamemode.iOtherTeam);
			}
			if (gmflags & (ROUND_SURVIVAL|ROUND_HVH) && gamemode.iRoundState == StateRunning)
				TF2_AddCondition(player.index, TFCond_Ubercharged, 5.0);

			if (gamemode.iRush != TFClass_Unknown)
				TF2_SetPlayerClass(player.index, gamemode.iRush);
			SetPawnTimer(PrepPlayers, 0.2, player);
		}
	}
	return Plugin_Continue;
}
public Action Resupply(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss player = BaseBoss(event.GetInt("userid"), true);
	if (player.index)
	{
		SetVariantString(""); AcceptEntityInput(player.index, "SetCustomModel");
		player.SetOverlay("0"); //SetClientOverlay(client, "0");
		SetEntProp(player.index, Prop_Send, "m_bForcedSkin", 0);
		SetEntProp(player.index, Prop_Send, "m_nForcedSkin", 0);

		if (player.bIsBoss && gamemode.iRoundState < StateEnding && gamemode.iRoundState != StateDisabled)
		{
			if (!(gamemode.iSpecialRound & ROUND_HVH) && GetClientTeam(player.index) != gamemode.iHaleTeam)
				player.ForceTeamChange(gamemode.iHaleTeam);
			player.ConvertToBoss();		// in base.sp
		}
	}
	return Plugin_Continue;
}

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState == StateDisabled)	// Bug patch: first round kill immediately ends the round.
		return Plugin_Continue;

	BaseBoss victim = BaseBoss(event.GetInt("userid"), true);
	BaseBoss fighter = BaseBoss(event.GetInt("attacker"), true);
//	if (IsClientValid(fighter.index) && fighter.index != victim.index)
//		fighter.iKillCount++;
	victim.iKillCount = 0;

	//if (fighter.bIsBoss and !player.bIsBoss) // If Boss is killer and victim is not a Boss
	ManageBossKillPlayer(fighter, victim, event);

	//if (fighter.bIsBoss and victim.bIsBoss) //clash of the titans - when both killer and victim are Bosses

	if (!victim.bIsBoss && !victim.bIsMinion)	// Patch: Don't want multibosses playing last-player sound clips when a BOSS dies...
		SetPawnTimer(CheckAlivePlayers, 0.1);

	if (fighter.bIsMinion && !victim.bIsMinion)
		if (!(event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER))
			ManageMinionKillPlayer(fighter, victim, event);
	
	if ((TF2_GetPlayerClass(victim.index) == TFClass_Engineer) && !(event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER))
	{
		if (cvarVSH2[EngieBuildings].IntValue) {
			switch (cvarVSH2[EngieBuildings].IntValue) {
				case 1:
				{
					int sentry = FindSentry(victim.index);
					if (sentry != -1)
					{
						SetVariantInt(GetEntProp(sentry, Prop_Send, "m_iMaxHealth")+8);
						AcceptEntityInput(sentry, "RemoveHealth");
					}
				}
				case 2:
				{
					for (int ent=MaxClients+1 ; ent<2048 ; ++ent)
					{
						if (!IsValidEdict(ent)) 
							continue;
						else if (!HasEntProp(ent, Prop_Send, "m_hBuilder"))
							continue;
						else if (GetBuilder(ent) != victim.index)
							continue;

						SetVariantInt(GetEntProp(ent, Prop_Send, "m_iMaxHealth")+8);
						AcceptEntityInput(ent, "RemoveHealth");
					}
				}
			}
		}
	}
	if ((gamemode.iSpecialRound & (ROUND_SURVIVAL|ROUND_HVH)) && !victim.bIsMinion && !victim.bIsBoss && gamemode.iRoundState == StateRunning)
	{
		victim.iRespawnTime = gamemode.iSpecialRound & ROUND_SURVIVAL ? 6 : 16;
		SetPawnTimer(DoRespawn, 1.0, victim);
	}
	if ((gamemode.iSpecialRound & ROUND_HVH) && !victim.bIsBoss && IsClientValid(fighter.index) && fighter.index != victim.index && gamemode.iRoundState == StateRunning && !(event.GetInt("deathflags") & TF_DEATHFLAG_DEADRINGER))
	{
		BaseBoss[] bosses = new BaseBoss[MaxClients];
		int numbosses = gamemode.GetBosses(bosses, false);
		for (int i = 0; i < numbosses; ++i)
			if (IsPlayerAlive(bosses[i].index))
			{
				bosses[i].iHealth -= 100 / (numbosses/2);
				fighter.iDamage += 100 / (numbosses/2);
			}
	}

	return Plugin_Continue;
}
public Action PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss victim = BaseBoss(event.GetInt("userid"), true);
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	//int damage = event.GetInt("damageamount");

	// make sure the attacker is valid so we can set him/her as BaseBoss instance
	if (victim.index == attacker || attacker <= 0)
		return Plugin_Continue;

	BaseBoss boss = BaseBoss(event.GetInt("attacker"), true);
	ManageHurtPlayer(boss, victim, event);
	Call_OnPlayerHurt(boss, victim, event);
	//if (player.bIsBoss)
	//	player.iHealth -= damage;
	return Plugin_Continue;
}
public void PlayerHurtPost(Event event, const char[] name, bool dontBroadcast)
{
	if (gamemode.iRoundState != StateRunning)
		return;

	int atkr = GetClientOfUserId(event.GetInt("attacker"));
	if (!(0 < atkr <= MaxClients))
		return;

	BaseBoss attacker = BaseBoss(atkr);
	if (attacker.bIsBoss || attacker.bIsMinion)
		return;
	BaseBoss victim = BaseBoss(event.GetInt("userid"), true);
	if (GetClientTeam(victim.index) == gamemode.iOtherTeam)
		return;
	int damage = event.GetInt("damageamount");
	int client = attacker.index;

	if (!attacker.bIsBoss && victim.bIsBoss)
		DoKSShit(attacker, victim);

	if (victim.bIsMinion)
		Call_OnMinionHurt(victim, attacker, damage, event);
	else if (!victim.bIsBoss)
		damage = 0;

	if (damage)
	{
		int healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
		BaseBoss medic;
		for (int i = 0; i < healers; ++i)
		{
			medic = BaseBoss(GetHealerByIndex(client, i));
			if (0 < medic.index <= MaxClients)
			{
				if (damage < 10 || medic.iUberTarget == attacker.userid)
					medic.iDamage += damage;
				else medic.iDamage += damage / (healers + 1);

				DoKSShit(medic, victim);
			}
		}
	}
}
public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	sv_tags.Flags &= ~FCVAR_NOTIFY;
	SetConVarIntHidden(mp_friendlyfire, 0);

	if (!bEnabled.BoolValue) {
#if defined _steamtools_included
		Steam_SetGameDescription("Team Fortress");
#endif
		return Plugin_Continue;
	}
	/*if (gamemode.hMusic != null) {
		KillTimer(gamemode.hMusic);
		gamemode.hMusic = null;
	}*/
	StopBackGroundMusic();
	gamemode.bMedieval = (FindEntityByClassname(-1, "tf_logic_medieval") != -1 || tf_medieval.BoolValue);
	//gamemode.CheckArena(cvarVSH2[PointType].BoolValue);
	gamemode.bPointReady = false;
	gamemode.iTimeLeft = 0;
	gamemode.iCaptures = 0;

	EnableCap();
	int playing;
	for (int iplay=MaxClients ; iplay ; --iplay)
	{
		if (!IsClientInGame(iplay))	
			continue;

		ManageResetVariables(BaseBoss(iplay));	// in handler.sp
		if (GetClientTeam(iplay) > view_as< int >(TFTeam_Spectator))
			++playing;
	}
	gamemode.GetBossType();		// in gamemode.sp
	if (GetClientCount() <= 1 || playing < 2) {
		CPrintToChatAll("{olive}[VSH 2]{default} Need more Players to Commence");
		gamemode.iRoundState = StateDisabled;
		SetArenaCapEnableTime(9999.0);
		//SetPawnTimer(EnableCap, 71.0); //CreateTimer(71.0, Timer_EnableCap, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}
	else if (gamemode.iRoundCount <= 0 && !cvarVSH2[FirstRound].BoolValue)
	{
		CPrintToChatAll("{olive}[VSH 2]{default} Normal Round while Everybody is Loading");
		gamemode.iRoundState = StateDisabled;
		SetArenaCapEnableTime(9999.0);
		mp_teams_unbalance_limit.SetInt(1);
		//SetPawnTimer(EnableCap, 71.0); //CreateTimer(71.0, Timer_EnableCap, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}

	mp_teams_unbalance_limit.SetInt(0);

	BaseBoss boss = gamemode.FindNextBoss();
	if (boss.index <= 0)
	{
		CPrintToChatAll("{olive}[VSH 2]{default} Boss client index was Invalid. Need more Players to Commence");
		gamemode.iRoundState = StateDisabled;
		SetControlPoint(true);
		return Plugin_Continue;
	}
	else if (gamemode.hNextBoss)
	{
		boss = gamemode.hNextBoss;
		gamemode.hNextBoss = view_as< BaseBoss >(0);
	}

	// Got our boss, let's prep him/her.
	boss.bSetOnSpawn = true;
	boss.iPureType = boss.iType = gamemode.iSpecial;
	ManageOnBossSelected(boss);	// Setting this here so we can intercept Boss type and other info
	boss.ConvertToBoss();
	gamemode.iSpecial = -1;
	gamemode.iSpecial2 = 0;
	gamemode.iSpecialRound = gamemode.iSpecialRoundPreset;
	gamemode.iSpecialRoundPreset = 0;
	int gmflags = gamemode.iSpecialRound;

	if (GetClientTeam(boss.index) != gamemode.iHaleTeam)
		boss.ForceTeamChange(gamemode.iHaleTeam);

	BaseBoss player;
	int i;
	if (gmflags & ROUND_HVH)
	{
		SDKHook(AttachParticle(boss.index, GetClientTeam(boss.index) == BLU ? "teleporter_blue_exit" : "teleporter_red_exit", .remove = false), SDKHook_SetTransmit, BVBGlowTransmit);
		mp_teams_unbalance_limit.SetInt(1);
		int numbosses = gamemode.iMulti * 2 - 1;
		bool flip;
		for (i = 0; i < numbosses; ++i)
		{
			player = gamemode.FindNextBoss();
			if (IsClientValid(player.index))
			{
				player.MakeBossAndSwitch(player.iPresetType == -1 ? GetRandomInt(Hale, MAXBOSS) : player.iPresetType, false);
				player.ForceTeamChange(flip ? gamemode.iHaleTeam : gamemode.iOtherTeam);
				SDKHook(AttachParticle(player.index, !flip ? "teleporter_red_exit" : "teleporter_blue_exit", .remove = false), SDKHook_SetTransmit, BVBGlowTransmit);
				flip = !flip;
			}
			else break;
		}
	}
	else if (gamemode.iMulti > 1)
	{
		for (i = 0; i < gamemode.iMulti; ++i)
		{
			player = gamemode.FindNextBoss();
			if (IsClientValid(player.index))
				player.MakeBossAndSwitch(player.iPresetType == -1 ? GetRandomInt(Hale, MAXBOSS) : player.iPresetType, false);
			else break;
		}
	}

	if (gmflags & ROUND_HVH)
	{
		int countred, countblu;
		int tries, val;
		do
		{
			val = RoundFloat(FloatAbs(float((countred = GetLivingPlayers(RED)) - (countblu = GetLivingPlayers(BLU)))) / 2);

			if (val <= 1)
				break;

			if (tries > 50)
				break;

			player = BaseBoss(GetRandomClient(countred > countblu ? RED : BLU, true));

			if (player.index == -1)
				break;

			if (player.bIsBoss)
				continue;

			player.ForceTeamChange(countred > countblu ? BLU : RED);
		} while ++tries <= 50;
	}
	else
	{
		for (i=MaxClients ; i ; --i) {
			if (!IsClientInGame(i) || GetClientTeam(i) <= SPEC)
				continue;

			player = BaseBoss(i);
			if (player.bIsBoss)
				continue;

			if (GetClientTeam(i) == gamemode.iHaleTeam && gamemode.iRoundState != StateRunning)
				player.ForceTeamChange(gamemode.iOtherTeam);	// Forceteamchange already does respawn by itself
		}
	}
	gamemode.iRoundState = StateStarting;		// We got players and a valid boss, set the gamestate to Starting
	SetPawnTimer(RoundStartPost, 10.1, gamemode.iRoundCount);		// in handler.sp
	SetPawnTimer(ManagePlayBossIntro, 3.5, boss);	// in handler.sp

	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_regenerate")) != -1)
		AcceptEntityInput(ent, "Disable");
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_respawnroomvisualizer")) != -1)
		AcceptEntityInput(ent, "Disable");

	if (!(gmflags & ROUND_HVH))
	{
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "obj_dispenser")) != -1)
		{
			SetVariantInt(gamemode.iOtherTeam);
			AcceptEntityInput(ent, "SetTeam");
			AcceptEntityInput(ent, "skin");
			SetEntProp(ent, Prop_Send, "m_nSkin", 0);
		}

		ent = -1;
		while ((ent = FindEntityByClassname(ent, "mapobj_cart_dispenser")) != -1)
		{
			SetVariantInt(gamemode.iOtherTeam);
			AcceptEntityInput(ent, "SetTeam");
			AcceptEntityInput(ent, "skin");
		}
	}

	gamemode.SearchForItemPacks();
	gamemode.iHealthChecks = 0;
	gamemode.iMulti = 1;
	return Plugin_Continue;
}
public Action ObjectDeflected(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss airblaster = BaseBoss(event.GetInt("userid"), true);
	BaseBoss airblasted = BaseBoss(event.GetInt("ownerid"), true);
	int weaponid = event.GetInt("weaponid");
	if (weaponid)		// number lower or higher than 0 is considered "true", learned that in C programming lol
		return Plugin_Continue;

	ManagePlayerAirblast(airblaster, airblasted, event);

	return Plugin_Continue;
}

public Action ObjectDestroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss boss = BaseBoss(event.GetInt("attacker"), true);
	int building = event.GetInt("index");
	int objecttype = event.GetInt("objecttype");

	ManageBuildingDestroyed(boss, building, objecttype, event);

	return Plugin_Continue;
}

public Action PlayerJarated(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss jarateer = BaseBoss(event.GetInt("thrower_entindex"), true);
	BaseBoss jarateed = BaseBoss(event.GetInt("victim_entindex"), true);
	PrintToChatAll("jarateer %d jarateed %d", jarateer.index, jarateed.index);
	ManagePlayerJarated(jarateer, jarateed);

	return Plugin_Continue;
}
/*public Action OnPlayerJarated(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss attacker = BaseBoss(BfReadByte(bf));
	BaseBoss victim = BaseBoss(BfReadByte(bf));

	if (!victim.bIsBoss)
		return Plugin_Continue;

	int jar = GetPlayerWeaponSlot(attacker.index, 1);
	int jindex = GetEntProp(jar, Prop_Send, "m_iItemDefinitionIndex");

	if (jar != -1 && (jindex == 58 || jindex == 1083 || jindex == 1105) && GetEntProp(jar, Prop_Send, "m_iEntityLevel") != -122)    //-122 is the Jar of Ants and should not be used in this
	{
		ManagePlayerJarated(attacker, victim);
	}
	return Plugin_Continue;
}*/
public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	gamemode.iRoundCount++;
	sv_tags.Flags &= ~FCVAR_NOTIFY;
	SetConVarIntHidden(mp_friendlyfire, 1);
	mp_teams_unbalance_limit.SetInt(0);
//	FindConVar("sv_tags").Flags |= FCVAR_NOTIFY;
	
	if (!bEnabled.BoolValue || gamemode.iRoundState == StateDisabled)
		return Plugin_Continue;

	gamemode.iRoundState = StateEnding;
	BaseBoss boss;
	int i;
	int bosscount = gamemode.iBossCount;
	int gmflags = gamemode.iSpecialRound;
	for (i=MaxClients ; i ; --i)
	{
		if (!IsClientInGame(i))
			continue;
		//SetEntProp(i, Prop_Send, "m_bForcedSkin", 0);
		//SetEntProp(i, Prop_Send, "m_nForcedSkin", 0);
#if defined _tf2attributes_included
		if (gamemode.bTF2Attribs)
			TF2Attrib_RemoveByDefIndex(i, 26);
#endif

		if (bAch && !(gmflags & ROUND_HVH))
			if (IsPlayerAlive(i))
				if (bosscount >= 6 && GetClientTeam(i) == gamemode.iOtherTeam)
					VSH2Ach_AddTo(i, A_NotOP, 1);
		//PrintToConsole(i, "resetting boss hp.");
	}
	StopBackGroundMusic();	// in handler.sp
	/*if (gamemode.hMusic != null) {
		KillTimer(gamemode.hMusic);
		gamemode.hMusic = null;
	}*/
	
	ShowPlayerScores();	// In vsh2.sp
	SetPawnTimer(CalcScores, 3.0);	// In vsh2.sp

	//BaseBoss bosses[34];
	ArrayList bosses = new ArrayList();
	//int index = 0;
	for (i=MaxClients ; i ; --i) {		// Loop again for bosses only
		if (!IsClientInGame(i))
			continue;

		boss = BaseBoss(i);
		if (!boss.bIsBoss)
			continue;

		boss.iType = boss.iPureType;

		if (!IsPlayerAlive(i) && !(gmflags & ROUND_HVH))
			if (GetClientTeam(i) != gamemode.iHaleTeam)
				ChangeClientTeam(i, gamemode.iHaleTeam);
				//boss.ForceTeamChange(gamemode.iHaleTeam);
		bosses.Push(boss); //bosses[index++] = boss;
	}
	ManageRoundEndBossInfo(bosses, event.GetInt("team"));
	/*
	int teamroundtimer = FindEntityByClassname(-1, "team_round_timer");
	if (teamroundtimer and IsValidEntity(teamroundtimer))
		AcceptEntityInput(teamroundtimer, "Kill");
	*/

	if ((gmflags & ROUND_MANNPOWER))
	{
		GameRules_SetProp("m_bPowerupMode", 0);
		FindConVar("tf_grapplinghook_enable").SetInt(0);
	}
	gamemode.iSpecialRound = 0;
	gamemode.iRush = TFClass_Unknown;
	return Plugin_Continue;
}
public void OnHookedEvent(Event event, const char[] name, bool dontBroadcast)
{
	BaseBoss(event.GetInt("userid"), true).bInJump = StrEqual(name, "rocket_jump", false) || StrEqual(name, "sticky_jump", false);
}
public Action ItemPickedUp(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState != StateRunning)
		return Plugin_Continue;

	BaseBoss player = BaseBoss(event.GetInt("userid"), true);
	char item[64]; event.GetString("item", item, sizeof(item));
	ManageBossPickUpItem(player, item);	// In handler.sp

	return Plugin_Continue;
}

public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss medic = BaseBoss(event.GetInt("userid"), true);
	BaseBoss patient = BaseBoss(event.GetInt("targetid"), true);
	ManageUberDeploy(medic, patient);	// In handler.sp
	return Plugin_Continue;
}

public Action ArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	int	i;	// Count amount of bosses for health calculation!
	if (gamemode.iRoundState == StateDisabled)
	{
		gamemode.iTimeLeft = 120;
		CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		for (i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			SetPawnTimer(PrepPlayers, 0.2, GetClientUserId(i));
		}
		return Plugin_Continue;
	}
//	gamemode.iSpecialRound = gamemode.iSpecialRoundPreset;
//	gamemode.iSpecialRoundPreset = 0;
	gamemode.iRush = gamemode.iRushPre;
	gamemode.iRushPre = TFClass_Unknown;
	int playing = gamemode.iPlaying;
	int gmflags = gamemode.iSpecialRound;
	if (bAch)
	{
		if (playing < 6)
		{
			VSH2Ach_Toggle(false);
			CPrintToChatAll("{olive}[VSH 2]{default} Achievements disabled due to low player count.");
		}
		else VSH2Ach_Toggle(true);
	}

	BaseBoss boss;
	for (i=MaxClients ; i ; --i)
	{
		if (!IsClientInGame(i))
			continue;
		else if (!IsPlayerAlive(i))
			continue;

		if (bAch)
		{
			VSH2Ach_AddTo(i, A_Veteran, 1);
			VSH2Ach_AddTo(i, A_Battlescarred, 1);
			VSH2Ach_AddTo(i, A_Master, 1);
			VSH2Ach_AddTo(i, A_BrewMaster, 1);			
		}

		boss = BaseBoss(i);
		boss.iDamage = 0;
//		boss.flMusicTime = 0.0;
		if (!boss.bIsBoss)
		{
			SetEntityMoveType(i, MOVETYPE_WALK);
			if (GetClientTeam(i) != gamemode.iOtherTeam && GetClientTeam(i) > SPEC && !(gmflags & ROUND_HVH))	// For good measure!
				boss.ForceTeamChange(gamemode.iOtherTeam);

			if (gamemode.iRush == TFClass_Unknown)
				SetPawnTimer(PrepPlayers, 0.2, boss.userid);	// in handler.sp
		}
	}
	i = -1;
	while ((i = FindEntityByClassname(i, "team_control_point")) != -1)
	{
		if (IsValidEntity(i))
		{
			AcceptEntityInput(i, "HideModel");
			SetVariantInt(1);
			AcceptEntityInput(i, "SetLocked");
			AcceptEntityInput(i, "Disable");
		}
	}

	gamemode.iTotalMaxHealth = 0;
	int bosscount = gamemode.CountBosses(true);
	if (!bosscount)
	{
		BaseBoss next = gamemode.FindNextBoss();
		if (next)
		{
			next.MakeBossAndSwitch((next.iPresetType == -1 ? GetRandomInt(0, MAXBOSS) : next.iPresetType), true);
			CPrintToChat(next.index, "{olive}[VSH 2]{green} Surprise! You're on NOW!");
			bosscount = 1;			
		}
		else
		{
			CPrintToChatAll("{olive}[VSH 2]{default} Invalid next boss. VSH is disabled for this round.");
			gamemode.iRoundState = StateDisabled;
			gamemode.iTimeLeft = 120;
			CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}
	}

	//BaseBoss bosses[34];	// There's no way almost everybody can be an overpowered boss...
	ArrayList bosses = new ArrayList();
	//int index = 0;
	int currtime = GetTime();
	if (gmflags & ROUND_MANNPOWER)
	{
		playing = RoundFloat(playing * 1.25);
		FindConVar("tf_grapplinghook_enable").SetInt(1);
		GameRules_SetProp("m_bPowerupMode", 1);
	}

	for (i=MaxClients ; i ; --i)
	{	// Loop again for bosses only
		if (!IsClientInGame(i))
			continue;

		boss = BaseBoss(i);
		if (!boss.bIsBoss)
			continue;

		if (GetClientTeam(i) <= SPEC)
		{
			boss.bIsBoss = false;
			continue;
		}

		bosses.Push(boss);
		boss.iTime = currtime;
		if (!IsPlayerAlive(i))
			TF2_RespawnPlayer(i);

//		boss.iDifficulty = boss.iStartingDifficulty;
//		if (gmflags & ROUND_HVH)
//			boss.iDifficulty = 1;

		boss.iMaxHealth = (CalcBossHealth(760.8, playing, 1.0, 1.0341, 2046.0));///(boss.iDifficulty <= 1 ? 1 : boss.iDifficulty));// / bosscount;	// In stocks.sp

		if (gmflags & ROUND_HVH)
			boss.iMaxHealth /= (bosscount / 2);
		else boss.iMaxHealth /= bosscount;

//		switch (boss.iDifficulty)
//		{
//			case -2:
//			{
//				if (playing > 10 && bosscount == 1 && !gmflags)
//					gamemode.iSpecialRound |= ROUND_SURVIVAL;
//				else CPrintToChat(boss.index, "{olive}[VSH 2]{default} Failed to meet requirements for Survival Mode.");
//				boss.iDifficulty = 0;
//			}
//		}
		if (gmflags & ROUND_MANNPOWER)
			boss.SpawnWeapon("tf_weapon_grapplinghook", 1152, 1, 10, "241 ; 0 ; 280 ; 26 ; 712 ; 1");

		if (boss.iMaxHealth < 3000 && bosscount == 1)
			boss.iMaxHealth = 3000;
		else if (boss.iMaxHealth > 3000 && bosscount > 1 && !(gmflags & ROUND_HVH))
			boss.iMaxHealth -= cvarVSH2[MultiBossHandicap].IntValue;	// Putting in multiboss Handicap from complaints multibosses being too overpowered.

		int maxhp = GetEntProp(boss.index, Prop_Data, "m_iMaxHealth");
		TF2Attrib_RemoveAll(boss.index);
		TF2Attrib_SetByDefIndex(boss.index, 26, float(boss.iMaxHealth-maxhp));

		if (!(gmflags & ROUND_HVH))
			if (GetClientTeam(boss.index) != gamemode.iHaleTeam)
				boss.ForceTeamChange(gamemode.iHaleTeam);
		gamemode.iTotalMaxHealth += boss.iMaxHealth;
		boss.iHealth = boss.iMaxHealth;
		boss.iQueue = 0;
	}
	if (gamemode.iRush != TFClass_Unknown)
		SetPawnTimer(DoRush, 0.2);

	SetPawnTimer(CheckAlivePlayers, 0.1);
	SetPawnTimer(SkipHalePanel, 10.0);
	ManageMessageIntro(bosses);
	gamemode.flHealthTime = 0.0;
	gamemode.iHealthBarState = 1;
	gamemode.iBossCount = bosscount;

	if (gmflags & ROUND_HVH)
	{
		gamemode.iTimeLeft = 480;
		CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	if (FindEntityByClassname(-1, "team_control_point_master") != -1)
		GameRules_SetPropFloat("m_flCapturePointEnableTime", 31536000.0+GetGameTime());
	GameRules_SetProp("m_bInSetup", false);
	return Plugin_Continue;
}

public Action PointCapture(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue || gamemode.iRoundState != StateRunning)
		return Plugin_Continue;
	
	// int iCap = GetEventInt(event, "cp"); //Doesn't seem to give the correct origin vectors
	int iCapTeam = event.GetInt("team");
	gamemode.iCaptures++;
	
	//SetPawnTimer(_SetCapOwner, 0.1, 0);	// in stocks.inc
	_SetCapOwner(NEUTRAL);	// in stocks.inc
	
	char sCappers[MAXPLAYERS+1];
	event.GetString("cappers", sCappers, MAXPLAYERS);
	ManageOnBossCap(sCappers, iCapTeam);
	
	//int i = -1;
	/*switch (iCapTeam) {
		case BLU: {
			char sCappers[MAXPLAYERS+1];
			event.GetString("cappers", sCappers, MAXPLAYERS);
			BaseBoss boss = BaseBoss(sCappers[0]);
			if (boss) {
				//ManageOnBossCap(sCappers, iCapTeam);
			}
		}
		case RED: {
			char sCappers[MAXPLAYERS+1];
			event.GetString("cappers", sCappers, MAXPLAYERS);
			//ManageOnBossCap(sCappers, iCapTeam);
		}
	}*/
	return Plugin_Continue;
}

public void BroadcastAudio(Event event, const char[] name, bool dontBroadcast)
{
	if (!bEnabled.BoolValue)
		return;
	if (gamemode.iRoundCount <= 0)
		return;

	char sound[64];
	event.GetString("sound", sound, sizeof(sound));

	if (strcmp(sound, "Game.TeamWin3") == 0
	|| strcmp(sound, "Game.YourTeamLost") == 0
	|| strcmp(sound, "Game.YourTeamWon") == 0
	|| strcmp(sound, "Announcer.AM_RoundStartRandom") == 0
	|| strcmp(sound, "Game.Stalemate") == 0)
		event.BroadcastDisabled = true;
}

public void RoundStartPost(int roundcount)
{
	if (roundcount != gamemode.iRoundCount || gamemode.iRoundState > StateStarting)
		return;

	ArenaRoundStart(null, "", false);
}

public Action PlayerHealed(Event event, const char[] name, bool dontBroadcast)
{
	BaseBoss patient = BaseBoss(event.GetInt("patient"), true);
	BaseBoss healer = BaseBoss(event.GetInt("healer"), true);
//	int amount = event.GetInt("amount");

//	PrintToChatAll("Patient %N Healer %N", patient.index, healer.index);
	if (patient.bIsBoss && patient.index == healer.index)
	{
		event.SetInt("amount", 0);
		return Plugin_Handled;
	}

//	if (g_bBlockHeal)
//	{
//		g_bBlockHeal = false;
//		return Plugin_Handled;
//	}
	return Plugin_Continue;
}