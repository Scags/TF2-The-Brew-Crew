/*
ALL NON-BOSS AND NON-MINION RELATED CODE AND AT THE BOTTOM. HAVE FUN CODING!
*/

enum/* Bosses *//* When you add custom Bosses, add to the anonymous enum as the Boss' ID */
{
	Hale = 0, 
	Vagineer = 1, 
	CBS = 2, 
	HHHjr = 3, 
	Bunny = 4
};

//#define MAXBOSS		4	// When adding new bosses, increase the MAXBOSS define for the newest boss id
#define MAXBOSS 	(Bunny + g_hPluginsRegistered.Length)

#include "modules/bosses.sp"

/*
PLEASE REMEMBER THAT PLAYERS THAT DON'T HAVE THEIR BOSS ID'S SET ARE NOT BOSSES.
THIS PLUGIN HAS BEEN SETUP SO THAT IF YOU BECOME A BOSS, YOU MUST HAVE A VALID BOSS ID

FOR MANAGEMENT FUNCTIONS, DO NOT HAVE THEM DISCRIMINATE WHO IS A BOSS OR NOT, SIMPLY CHECK THE ITYPE TO SEE IF IT REALLY WAS A BOSS PLAYER.
*/

public void ManageDownloads()
{
	PrecacheSound("ui/item_store_add_to_cart.wav", true);
	PrecacheSound("player/doubledonk.wav", true);

	PrecacheSound("saxton_hale/9000.wav", true);
	CheckDownload("sound/saxton_hale/9000.wav");
	PrecacheSound("vo/announcer_am_capincite01.mp3", true);
	PrecacheSound("vo/announcer_am_capincite03.mp3", true);
	PrecacheSound("vo/announcer_am_capenabled02.mp3", true);

	PrecacheSound("vo/announcer_ends_60sec.mp3", true);
	PrecacheSound("vo/announcer_ends_30sec.mp3", true);
	PrecacheSound("vo/announcer_ends_10sec.mp3", true);
	PrecacheSound("vo/announcer_ends_1sec.mp3", true);
	PrecacheSound("vo/announcer_ends_2sec.mp3", true);
	PrecacheSound("vo/announcer_ends_3sec.mp3", true);
	PrecacheSound("vo/announcer_ends_4sec.mp3", true);
	PrecacheSound("vo/announcer_ends_5sec.mp3", true);
	PrecacheSound("items/pumpkin_pickup.wav", true);
	PrecacheSound("misc/ks_tier_04_kill_01.wav", true);
	PrecacheSound("items/spawn_item.wav", true);

	AddHaleToDownloads();
	AddVagToDownloads();
	AddCBSToDownloads();
	AddHHHToDownloads();
	AddBunnyToDownloads();
	Call_OnCallDownloads(); // in forwards.sp
}

public void ManageMenu(Menu &menu)
{
	AddHaleToMenu(menu);
	AddVagToMenu(menu);
	AddCBSToMenu(menu);
	AddHHHToMenu(menu);
	AddBunnyToMenu(menu);
	Call_OnBossMenu(menu);
}

public void ManageDisconnect(const int client)
{
	BaseBoss leaver = BaseBoss(client);
	if (leaver.bIsBoss)
	{
		if(gamemode.iRoundState >= StateRunning)
		{	/// Arena mode flips out when no one is on the other team
			BaseBoss[] bosses = new BaseBoss[MaxClients];
			int numbosses = gamemode.GetBosses(bosses, false);
			if(numbosses-1 > 0)
			{	/// Exclude leaver, this is why CountBosses() can't be used
				for(int i=0; i<numbosses; i++)
				{
					if(bosses[i] == leaver)
						continue;
					if(IsPlayerAlive(bosses[i].index))
						break;

					BaseBoss next = gamemode.FindNextBoss();
					if(gamemode.hNextBoss)
					{
						next = gamemode.hNextBoss;
						gamemode.hNextBoss = view_as< BaseBoss >(0);
					}
					if(IsClientValid(next.index))
					{
						next.bIsMinion = true;	/// Dumb hack, prevents spawn hook from forcing them back to red
						next.ForceTeamChange(gamemode.iHaleTeam);
					}

					if(gamemode.iRoundState == StateRunning)
						ForceTeamWin(gamemode.iOtherTeam);
					break;
				}
			}
			else {	/// No bosses left
				BaseBoss next = gamemode.FindNextBoss();
				if(gamemode.hNextBoss)
				{
					next = gamemode.hNextBoss;
					gamemode.hNextBoss = view_as< BaseBoss >(0);
				}
				if(IsClientValid(next.index))
				{
					next.bIsMinion = true;
					next.ForceTeamChange(gamemode.iHaleTeam);
				}

				if(gamemode.iRoundState == StateRunning)
					ForceTeamWin(gamemode.iOtherTeam);
			}
		}
		else if(gamemode.iRoundState == StateStarting)
		{
			BaseBoss replace = gamemode.FindNextBoss();
			if(gamemode.hNextBoss)
			{
				replace = gamemode.hNextBoss;
				gamemode.hNextBoss = view_as< BaseBoss >(0);
			}
			if(IsClientValid(replace.index))
			{
				replace.MakeBossAndSwitch(replace.iPresetType == -1 ? leaver.iType : replace.iPresetType, true);
				CPrintToChat(replace.index, "{olive}[VSH 2]{green} Surprise! You're on NOW!");
			}
			leaver.iQueue /= 2;
		}
		CPrintToChatAll("{olive}[VSH 2]{red} A Boss Just Disconnected!");

		delete leaver.hSpecial;
	}
	else
	{
		//if (IsPlayerAlive(client))
		SetPawnTimer(CheckAlivePlayers, 0.1);
		if (IsClientInGame(client) && client == gamemode.FindNextBoss().index)
			SetPawnTimer(_SkipBossPanel, 1.0);
		
		if (leaver.userid == gamemode.hNextBoss.userid)
			gamemode.hNextBoss = view_as<BaseBoss>(0);
	}
}

public void ManageOnBossSelected(const BaseBoss base)
{
	ManageBossHelp(base);
	Call_OnBossSelected(base);

//	BaseBoss boss;
//	while (gamemode.iMulti-- > 1)
//	{
//		boss = gamemode.FindNextBoss();
//		if (boss && boss.index)
//			boss.MakeBossAndSwitch(boss.iPresetType == -1 ? GetRandomInt(Hale, MAXBOSS) : boss.iPresetType, false);
//		else
//		{
			//CPrintToChatAll("{orange}[VSH 2]{default} Couldn't find enough bosses to satisfy amount, clamping.");
//			break;
//		}
//	}
//	gamemode.iMulti = 1;

	// Uncomment this and I'll kill you
	/*
	if (gamemode.iPlaying < 10 || GetRandomInt(0, 3) > 0)
		return;

	int extraBosses = gamemode.iPlaying / 12;
	extraBosses = (extraBosses > 1) ? GetRandomInt(1, extraBosses) : extraBosses;
	while (extraBosses-- > 0)
		gamemode.FindNextBoss().MakeBossAndSwitch(GetRandomInt(Hale, MAXBOSS), false);*/
}

public void ManageOnTouchPlayer(const BaseBoss base, const BaseBoss victim)
{
	if (!IsValidEntity(base.index) || !IsValidEntity(victim.index))
		return;

	switch (base.iType)
	{
		case  - 1: {  }
	}
	Call_OnTouchPlayer(base, victim);
}

public void ManageOnTouchBuilding(const BaseBoss base, const int building)
{
	switch (base.iType)
	{
		case  - 1: {  }
	}
	Call_OnTouchBuilding(base, EntIndexToEntRef(building));
}

public void ManageBossHelp(const BaseBoss base)
{
	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).Help();
		case Vagineer:ToCVagineer(base).Help();
		case CBS:ToCChristian(base).Help();
		case HHHjr:ToCHHHJr(base).Help();
		case Bunny:ToCBunny(base).Help();
	}
}

public void ManageBossThink(const BaseBoss base)
{
	if (!IsPlayerAlive(base.index))
		return;

//	SetEntPropFloat(base.index, Prop_Send, "m_flHeadScale", 1.0);

	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).Think();
		case Vagineer:ToCVagineer(base).Think();
		case CBS:ToCChristian(base).Think();
		case HHHjr:ToCHHHJr(base).Think();
		case Bunny:ToCBunny(base).Think();
	}
	Call_OnBossThink(base);
	/* Adding this so bosses can take minicrits if airborne */
	if (!bMiniStuff)
		TF2_AddCondition(base.index, TFCond_GrapplingHookSafeFall, 0.2);

	if (gamemode.iSpecialRound & ROUND_HVH)
		TF2_AddCondition(base.index, TFCond_TeleportedGlow, 0.2);
}

public void ManageBossModels(const BaseBoss base)
{
	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).SetModel();
		case Vagineer:ToCVagineer(base).SetModel();
		case CBS:ToCChristian(base).SetModel();
		case HHHjr:ToCHHHJr(base).SetModel();
		case Bunny:ToCBunny(base).SetModel();
	}
	if (base.iType != -1)
	{
		SetEntityRenderColor(base.index, 255, 255, 255, 255);
		SetEntityRenderMode(base.index, RENDER_NORMAL);
	}
	Call_OnBossModelTimer(base);
}

public void ManageBossDeath(const BaseBoss base)
{
	if (gamemode.iRoundState == StateStarting)
		return;

	base.iType = base.iPureType;
	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).Death();
		case Vagineer:ToCVagineer(base).Death();
		case CBS:ToCChristian(base).Death();
		case HHHjr:ToCHHHJr(base).Death();
		case Bunny:ToCBunny(base).Death();
	}
	Call_OnBossDeath(base);
	if (!gamemode.CountBosses(true))
		gamemode.iHealthBarState = !gamemode.iHealthBarState;
}

public void ManageBossEquipment(const BaseBoss base)
{
	SetEntProp(base.index, Prop_Send, "m_bForcedSkin", 0);
	SetEntProp(base.index, Prop_Send, "m_nForcedSkin", 0);

	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).Equip();
		case Vagineer:ToCVagineer(base).Equip();
		case CBS:ToCChristian(base).Equip();
		case HHHjr:ToCHHHJr(base).Equip();
		case Bunny:ToCBunny(base).Equip();
	}
	Call_OnBossEquipped(base);

	char s[MAX_BOSS_NAME_LENGTH];
	switch (base.iPureType)
	{
		case Hale:strcopy(s, sizeof(s), (BeTheRobot_GetRobotStatus(base.index) == RobotStatus_Robot ? "S@xt0n H@1e" : "Saxton Hale"));
		case Vagineer:strcopy(s, sizeof(s), "The Vagineer");
		case HHHjr:strcopy(s, sizeof(s), "The Horseless Headless Horsemann Jr.");
		case CBS:strcopy(s, sizeof(s), "The Christian Brutal Sniper");
		case Bunny:strcopy(s, sizeof(s), "The Easter Bunny");
		default:Call_OnBossSetName(base, s);
	}
	if (s[0] != '\0')
		base.SetName(s);

	if (gamemode.iSpecialRound & ROUND_MANNPOWER)
		base.SpawnWeapon("tf_weapon_grapplinghook", 1152, 1, 10, "241 ; 0 ; 280 ; 26 ; 712 ; 1");
}

public void ManageBossTransition(const BaseBoss base, const bool override)/* whatever stuff needs initializing should be done here */
{
	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:TF2_SetPlayerClass(base.index, TFClass_Soldier, _, false);
		case Vagineer:TF2_SetPlayerClass(base.index, TFClass_Engineer, _, false);
		case CBS:TF2_SetPlayerClass(base.index, TFClass_Sniper, _, false);
		case HHHjr, Bunny:TF2_SetPlayerClass(base.index, TFClass_DemoMan, _, false);
	}

//	SetEntProp(base.index, Prop_Send, "m_nSkin", 2);

	ManageBossModels(base);
	switch (base.iType)
	{
		case  - 1: {  }
		case HHHjr:if (!override) ToCHHHJr(base).flCharge = -1000.0;
		default:if (!override) base.flCharge = -100.0;
	}
	Call_OnBossInitialized(base, override);
	ManageBossEquipment(base);
}

public void ManageMinionTransition(const BaseBoss base)
{
	if(!base.bIsMinion)
		return;

//	base.ForceTeamChange(gamemode.iHaleTeam);
	BaseBoss owner = BaseBoss(base.iOwnerBoss);

	switch (owner.iType)
	{
		case -1: {	}
	}
	Call_OnMinionInitialized(base, owner);
}

public void ManagePlayBossIntro(const BaseBoss base)
{
	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).PlaySpawnClip();
		case Vagineer:ToCVagineer(base).PlaySpawnClip();
		case CBS:ToCChristian(base).PlaySpawnClip();
		case HHHjr:ToCHHHJr(base).PlaySpawnClip();
		case Bunny:ToCBunny(base).PlaySpawnClip();
	}
	Call_OnBossPlayIntro(base);
}

public Action ManageOnBossTakeDamage(const BaseBoss victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action action, action2;
	switch (victim.iType)
	{
		case  - 1: {  }
		default:
		{
			if (hFwdCompat[Fwd_OnBossTakeDamage].FindValue(victim.iType) == -1)
				return Call_OnBossTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			int client = victim.index;
			char trigger[32];
			if (attacker != -1 && GetEntityClassname(attacker, trigger, sizeof(trigger)))
			{
				if (!strcmp(trigger, "trigger_hurt", false))
				{
					if (damage >= 100.0 && !gamemode.bNoTele)
						TeleportToSpawn(client, GetClientTeam(client));

					victim.iHealth -= (damage > 1000.0 ? 1000 : RoundFloat(damage));
					action = Plugin_Changed;
				}
			}
			if (attacker <= 0 || attacker > MaxClients)
				return action;

			if (gamemode.iRoundState == StateStarting)
			{
				damage *= 0.0;
				return Plugin_Changed;
			}

			if (!TF2_IsKillable(victim.index))
				return Plugin_Continue;

			char classname[64], strEntname[32];
			if (inflictor != -1)
				GetEntityClassname(inflictor, strEntname, sizeof(strEntname));
			if (weapon != -1)
				GetEdictClassname(weapon, classname, sizeof(classname));

			float curtime = GetGameTime();

			int wepindex = weapon > MaxClients ? GetItemIndex(weapon) : -1;
			if (damagecustom == TF_CUSTOM_BACKSTAB)
			{
				char snd[PLATFORM_MAX_PATH];
				switch (victim.iType)
				{
					case Hale:Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
					case Vagineer:strcopy(snd, PLATFORM_MAX_PATH, "vo/engineer_positivevocalization01.mp3");
					case HHHjr:Format(snd, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_pain0%d.mp3", GetRandomInt(1, 3));
					case Bunny:strcopy(snd, PLATFORM_MAX_PATH, BunnyPain[GetRandomInt(0, sizeof(BunnyPain) - 1)]);
				}
				if (snd[0] != '\0')
				{
					EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
					EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				}

				float changedamage = ((Pow(float(victim.iMaxHealth) * 0.0014, 2.0) + 899.0) - (float(victim.iMaxHealth) * (float(victim.iStabbed) / 100)));
				if (victim.iStabbed < 4)
					victim.iStabbed++;
				damage = changedamage / 3.0; // You can level "damage dealt" with backstabs
				damagetype |= DMG_CRIT;
				
				EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				EmitSoundToAll("player/crit_received3.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", curtime + 2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", curtime + 2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", curtime + 2.0);

				PrintCenterText(attacker, "You Tickled The Boss!");
				PrintCenterText(client, "You Were Just Backstabbed!");

				int vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				if (vm > MaxClients && IsValidEntity(vm) && TF2_GetPlayerClass(attacker) == TFClass_Spy)
				{
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					int anim = 15;
					switch (melee) 
					{
						case 727:anim = 41;
						case 4, 194, 665, 794, 803, 883, 892, 901, 910:anim = 10;
						case 638:anim = 31;
					}
					SetEntProp(vm, Prop_Send, "m_nSequence", anim);
				}
				int pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);
				if (pistol == 525)
				{  //Diamondback gives 2 crits on backstab
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits + 2);
				}
				switch (wepindex)
				{
					case 356:		// Kunai
					{
						int health = GetClientHealth(attacker) + 180;
						if (health > 270)
							health = 270;
						SetEntProp(attacker, Prop_Data, "m_iHealth", health);
						SetEntProp(attacker, Prop_Send, "m_iHealth", health);
					}
					case 461:		// Big Earner
					{
						SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);
						TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 2.0);						
					}
					case 649:		// Spy-Cicle
					{
						damage *= 0.67;
						victim.flRAGE -= (damage*3.0)/SquareRoot(30000.0)*4.0;
						victim.flRAGE -= 15.0;
						EmitSoundToAll("weapons/sapper_plant.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
						if (bAch)
							VSH2Ach_AddTo(attacker, A_DeRage, 15);
					}
					case 225, 574:	// YER
					{
						int ent;
						int team = GetClientTeam(attacker);
						float pos[3]; GetClientAbsOrigin(attacker, pos);
						float ang[3]; GetClientEyeAngles(attacker, ang);
						ang[0] = 0.0;
						char mdl[256];
						GetClientModel(attacker, mdl, sizeof(mdl));
						ent = CreateEntityByName("prop_dynamic_override");
						if (ent != -1)
						{
							SetEntityModel(ent, mdl);
							DispatchKeyValue(ent, "DefaultAnim", strGestures[GetRandomInt(0, sizeof(strGestures)-1)]);

							DispatchSpawn(ent);

							TeleportEntity(ent, pos, ang, NULL_VECTOR);

							SetEntProp(ent, Prop_Send, "m_nSkin", team-2);
							SetEntProp(ent, Prop_Send, "m_iTeamNum", team);
							SetEntProp(ent, Prop_Send, "m_CollisionGroup", 2);

							int numwearables = TF2_GetNumWearables(client);
							int wearable;
							for (int i = 0; i < numwearables; ++i)
							{
								wearable = TF2_GetWearable(attacker, i);
								if (wearable == -1)
									continue;

								if (!GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable"))
								{
									GetEntPropString(wearable, Prop_Data, "m_ModelName", mdl, PLATFORM_MAX_PATH);
									EquipItem(ent, "head", mdl, _, team);
								}
							}
						}

						CreateTimer(4.0, RemoveEnt, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
						TF2_AddCondition(attacker, TFCond_Stealthed, 2.0);
					}
				}

				Call_OnBossBackstabbed(victim, BaseBoss(attacker));
				action = Plugin_Changed;

				++BaseBoss(attacker).iStabs;
				if (bAch)
					VSH2Ach_AddTo(attacker, A_Backstabber, 1);
			}
			// Detects if boss is damaged by Rock Paper Scissors
			/*if (!damagecustom
				 && TF2_IsPlayerInCondition(client, TFCond_Taunting)
				 && TF2_IsPlayerInCondition(attacker, TFCond_Taunting))
			{
				damage = victim.iHealth+0.2;
				BaseBoss(attacker).iDamage += RoundFloat(damage);	// If necessary, just cheat by using the arrays.
				action = Plugin_Changed;
			}*/
			if (damagecustom == TF_CUSTOM_TELEFRAG && !TF2_IsPlayerInCondition(victim.index, TFCond_PasstimeInterception))
			{
				damage = 9001.0;
				int teleowner = FindTeleOwner(attacker);
				if(teleowner != -1 && teleowner != attacker)
				{
					BaseBoss builder = BaseBoss(teleowner);
					builder.iDamage += 5401;
					PrintCenterText(teleowner, "TELEFRAG ASSIST! Good job setting it up.");
				}
				PrintCenterText(attacker, "TELEFRAG! You are pro.");
				PrintCenterText(victim.index, "TELEFRAG! Be careful around quantum tunneling devices!");
				action = Plugin_Changed;
			}
			if (damagecustom == TF_CUSTOM_TAUNT_BARBARIAN_SWING) // Gives 4 heads if successful sword killtaunt!
			{
				for (int i = 0; i < 4; ++i)
					IncrementHeadCount(attacker);
			}
			if (damagecustom == TF_CUSTOM_BOOTS_STOMP && FindPlayerBack(attacker, { 405, 444, 608, 1179 }, 4) != -1)
			{
				damage = 1024.0;
				action = Plugin_Changed;
			}

			if (cvarVSH2[Anchoring].BoolValue)// && victim.iDifficulty <= 3)
			{
				int iFlags = GetEntityFlags(client);
					// If Hale is ducking on the ground, it's harder to knock him back
				if (iFlags & (FL_ONGROUND | FL_DUCKING) == (FL_ONGROUND|FL_DUCKING))
					TF2Attrib_SetByDefIndex(client, 252, 0.0);
				else if (GetEntProp(client, Prop_Data, "m_nWaterLevel") == 3)
					TF2Attrib_SetByDefIndex(client, 252, 0.5);
				else TF2Attrib_RemoveByDefIndex(client, 252);
			}
			switch (wepindex)
			{
				case 593: //Third Degree
				{
					int healers = GetEntProp(attacker, Prop_Send, "m_nNumHealers");
					int healer;
					int medics;
					int i;
					for (i = 0; i < healers; ++i)
						if (GetHealerByIndex(attacker, i) <= MaxClients)
							++medics;

					for (i = 0; i < healers; ++i) 
					{
						healer = GetHealerByIndex(attacker, i);
						if (healer <= MaxClients)
						{
							int medigun = GetPlayerWeaponSlot(healer, TFWeaponSlot_Secondary);
							if (IsValidEntity(medigun)) 
							{
								float uber = GetMediCharge(medigun) + (0.2 / medics);
								float max = 1.0;
								if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease") && GetEntProp(medigun, Prop_Send, "m_iItemDefinitionIndex") != 998)
									max = 1.5;
								if (uber > max)
									uber = max;
								SetMediCharge(medigun, uber);
							}
						}
					}
				}
				case 132, 266, 482, 1082:IncrementHeadCount(attacker);
				case 172:TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 2.0);
				case 355:{ victim.flRAGE -= cvarVSH2[FanoWarRage].FloatValue; if (bAch) VSH2Ach_AddTo(attacker, A_DeRage, cvarVSH2[FanoWarRage].IntValue); }
				case 317:SpawnSmallHealthPackAt(attacker, GetClientTeam(attacker));
				case 214, 310:
				{
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health + 25;
					if (health < max + 50) 
					{
						if (newhealth > max + 50)
							newhealth = max + 50;
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						TF2_RemoveCondition(attacker, TFCond_OnFire);
				}
				case 357:
				{
					SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
					if (GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
						SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health + 35;
					if (health < max + 25) 
					{
						if (newhealth > max + 25)
						{ newhealth = max + 25; }
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						TF2_RemoveCondition(attacker, TFCond_OnFire);
					int weap = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
					int index = GetItemIndex(weap);
					int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if (index == 357 && active == weap) 
					{
						damage = 195.0 / 3.0;
						action = Plugin_Changed;
					}
				}
				case 416, 609: // Chdata's Market Gardener backstab
				{
					if (BaseBoss(attacker).bInJump) 
					{
						//Can't get stuck in HHH in midair and mg him multiple times.
						//if ((GetEntProp(client, Prop_Send, "m_iStunFlags") & TF_STUNFLAGS_GHOSTSCARE | TF_STUNFLAG_NOSOUNDOREFFECT) && Special == HHH) action = Plugin_Continue;

						if (victim.iMarketted < 5)
							victim.iMarketted++;

						const float div = 4.0;

						damage = (Pow(float(victim.iMaxHealth), (0.74074)) - (victim.iMarketted/128*float(victim.iMaxHealth)))/div;

						//divide by 3 because victim is basedamage and lolcrits (0.714286)) + 1024.0)
						damagetype |= DMG_CRIT;
						PrintCenterText(attacker, "You %s the Boss!", wepindex == 416 ? "Market Gardened" : "Chug Jugged");

						PrintCenterText(client, "You Were Just %s!", wepindex == 416 ? "Market Gardened" : "Chug Jugged");

						EmitSoundToAll("player/doubledonk.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
						SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", curtime + 2.0);
						SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", curtime + 2.0);
						
						if (TF2_IsPlayerInCondition(attacker, TFCond_Parachute))
						{
							damage *= 0.67;
							TF2_RemoveCondition(attacker, TFCond_Parachute);
						}
						action = Plugin_Changed;

						if (bAch)
							VSH2Ach_AddTo(attacker, A_Gardener, 1);
					}
				}
				case 61, 1006: //Ambassador does 2.5x damage on headshot
				{
					if (damagecustom == TF_CUSTOM_HEADSHOT)
					{
						damage *= 2.5; 
						action = Plugin_Changed;
					}
				}
				/*case 751: //SMG does 2.5x damage on headshot
				{
					damagetype |= DMG_USE_HITLOCATIONS;
					action = Plugin_Changed;
				}*/
				case 525, 595:	// Diamondback/Manmelter
				{
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					if (iCrits) 
					{  //If a revenge crit was used, give a damage bonus
						damage = 85.0;
						action = Plugin_Changed;
					}
				}
				case 656:	// Holiday Punch
				{
					SetPawnTimer(_StopTickle, cvarVSH2[StopTickleTime].FloatValue, victim.userid);
					if (TF2_IsPlayerInCondition(attacker, TFCond_Dazed))
						TF2_RemoveCondition(attacker, TFCond_Dazed);
				}
				case 43:	// KGB
					TF2_AddCondition(attacker, TFCond_CritOnWin, 4.0);
				case 224:	// Letranger
				{
					float bossGlow = victim.flGlowtime;
					float time = (bossGlow > 10 ? 2.0 : 4.0);
					time += (bossGlow > 10 ? (bossGlow > 20 ? 1 : 2) : 4);
					bossGlow += RoundToCeil(time);
					if (bossGlow > 30.0)
						bossGlow = 30.0;
					victim.flGlowtime = bossGlow;
				}
				case 404:	// Persian Persuader
					SpawnSmallAmmoPackAt(attacker, GetClientTeam(attacker));
				case 41:	// Natascha
				{
					damagetype |= DMG_PREVENT_PHYSICS_FORCE;
					action = Plugin_Changed;
				}
//				case 442:	// Bison
//				{
//					ScaleVector(damageForce, 6.0);
//					action = Plugin_Changed;
//				}
				case 307:	// Caber
					if (!TF2_IsKillable(attacker))
						ForcePlayerSuicide(attacker);

				case 1180:	// Gas Passer
				{
					damage *= 0.5;
					action = Plugin_Changed;
				}
				case 406:	// Splendid Screen
				{
					if (damagecustom != TF_CUSTOM_BOOTS_STOMP)
					{
						damage *= 5.0;
						action = Plugin_Changed;
					}
				}
			}

			if (weapon != -1 && TF2Attrib_GetByDefIndex(weapon, 208) != Address_Null)
				TF2_IgnitePlayer(victim.index, attacker);
			if (StrContains(classname, "tf_weapon_sniperrifle", false) > -1 && gamemode.iRoundState != StateEnding)
			{
				float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
				if (chargelevel < 150.0 && !(damagetype & DMG_CRIT))
					damagetype |= DMG_PREVENT_PHYSICS_FORCE;

				damagetype |= DMG_SLOWBURN|DMG_POISON;

				if ((damagetype & DMG_CRIT) && damagecustom == TF_CUSTOM_HEADSHOT)
					damage *= 1.2;

				if (wepindex != 230 && wepindex != 526 && wepindex != 752 && wepindex != 30665)
				{
					float bossGlow = victim.flGlowtime;
					// float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
					float time = (bossGlow > 10 ? 1.0 : 2.0);
					time += (bossGlow > 10 ? (bossGlow > 20 ? 1 : 2) : 4) * (chargelevel / 100);
					bossGlow += RoundToCeil(time);
					if (bossGlow > 30.0)
						bossGlow = 30.0;
					victim.flGlowtime = bossGlow;
				}
				if (wepindex == 402)
					if (damagecustom == TF_CUSTOM_HEADSHOT)
						IncrementHeadCount(attacker, false);
				if (wepindex == 752)
				{
					// float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
					float add = 10 + (chargelevel / 10);
					if (TF2_IsPlayerInCondition(attacker, view_as<TFCond>(46)))
						add /= 3.0;
					float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
					SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
				}
				if (!(damagetype & DMG_CRIT))
				{
					bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));
					damage *= (ministatus) ? 2.222222 : 3.0;
				}
				//if (damage > 450.0 && custom != TF_CUSTOM_HEADSHOT)
				//	damage = 450.0;

				if (!TF2_IsPlayerInCondition(attacker, TFCond_Slowed))
				{
					damage /= 1.5;
				}

				action = Plugin_Changed;
			}
/*			else if (!StrContains(classname, "tf_weapon_minigun", false) && !(damagetype & DMG_CRIT))
			{
				static ConVar tf_damage_range;
				if (!tf_damage_range)
					tf_damage_range = FindConVar("tf_damage_range");

				float flRandomDamage = tf_damage_range.FloatValue;
				float flCenter = 0.5;
				float mypos[3], theirpos[3];
				GetClientAbsOrigin(victim.index, mypos);
				GetClientAbsOrigin(attacker, theirpos);
				SubtractVectors(mypos, theirpos, mypos);
				float flDistance = fmax(1.0, GetVectorLength(mypos));

				flCenter = RemapValClamped(flDistance / 512.0, 0.0, 2.0, 1.0, 0.0);

				if (flCenter > 0.5)
				{
					float flOut = SimpleSplineRemapValClamped(flCenter, 0.0, 1.0, -flRandomDamage, flRandomDamage);
					PrintToChatAll("%.0f | %.0f", damage, flOut);
					damage += flOut;
					damagetype &= ~DMG_USEDISTANCEMOD;
					action = Plugin_Changed;
				}
			}*/
		}
	}
	action2 = Call_OnBossTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	return action > action2 ? action : action2;
}

public Action ManageOnBossDealDamage(const BaseBoss victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BaseBoss fighter = BaseBoss(attacker);
	Action action, action2;
	switch (fighter.iType)
	{
		case  - 1: {  }
		default:
		{
			if (hFwdCompat[Fwd_OnBossDealDamage].FindValue(fighter.iType) == -1)
				return Call_OnBossDealDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

			if (damagetype & DMG_CRIT)
				damagetype &= ~DMG_CRIT;

			int client = victim.index;

			if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
			{
				float flFallVelocity = GetEntPropFloat(inflictor, Prop_Send, "m_flFallVelocity");
				damage = 10.0 * (GetRandomFloat(0.8, 1.2) * (5.0 * (flFallVelocity / 300.0))); //TF2 Fall Damage formula, modified for VSH2
				action = Plugin_Changed;
			}

			if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
			{
				ScaleVector(damageForce, 9.0);
				damage *= 0.3;
				action = Plugin_Changed;
			}
			if (TF2_IsPlayerInCondition(client, TFCond_CritMmmph) || TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph))
			{
				damage *= 0.35;
				action = Plugin_Changed;
			}

			int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if (medigun != -1
				 && HasEntProp(medigun, Prop_Send, "m_bChargeRelease")
				 && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				 && weapon == GetPlayerWeaponSlot(attacker, 2))
			{
				/*
					If medic has (nearly) full uber, use it as a single-hit shield to prevent medics from dying early.
					Entire team is pretty much screwed if all the medics just die.
				*/
				if (GetMediCharge(medigun) >= 1.0)
				{
					switch (GetItemIndex(medigun))
					{
						case 411, 998:{}
						default:
						{
							SetMediCharge(medigun, (GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 173 ? 0.35 : 0.2));
							damage *= 10;
							TF2_AddCondition(client, TFCond_UberchargedOnTakeDamage, 0.1);
							EmitSoundToAll("misc/ks_tier_04_kill_01.wav", client);
							action = Plugin_Changed;
						}
					}
				}
			}

			if (TF2_IsKillable(client) && weapon == GetPlayerWeaponSlot(attacker, 2))
			{
				int numwearables = TF2_GetNumWearables(client);
				if (numwearables > 0)
				{
					int ent;
					int i;
					char buffer[32];
					for (i = 0; i < numwearables; ++i)
					{
						ent = TF2_GetWearable(client, i);
						if (ent == -1)
							continue;

						if (!GetEntProp(ent, Prop_Send, "m_bDisguiseWearable")
						&& GetEntityClassname(ent, buffer, sizeof(buffer))
						&& (!strcmp(buffer, "tf_wearable_demoshield") || !strcmp(buffer, "tf_wearable_razorback")))
						{
							TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
							TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
							TF2_RemoveWearable(client, ent);
							EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
							--numwearables;
							break;
						}
					}
				}
				if (!TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed) && GetIndexOfWeaponSlot(client, TFWeaponSlot_Secondary) == 226)
					if (GetEntPropFloat(client, Prop_Send, "m_flRageMeter") < 100.0)
						SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 100.0);
			}
		}
	}
	action2 = Call_OnBossDealDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	return action > action2 ? action : action2;
}
#if defined _goomba_included_
public Action ManageOnGoombaStomp(int attacker, int client, float & damageMultiplier, float & damageAdd, float & JumpPower)
{
	if (gamemode.iRoundState != StateDisabled && GetClientTeam(attacker) == gamemode.iHaleTeam)
		return Plugin_Handled;
	BaseBoss boss = BaseBoss(client);
	if (boss.bIsBoss) //Players Stomping the Boss
	{
		switch (boss.iType)
		{
			case  - 1: {  } // Ignore if not boss at all.
			default: //Default behaviour for Goomba Stomping the Boss
			{
				if (FindPlayerBack(attacker, { 444, 405, 608 }, 3) != -1 && !cvarVSH2[CanMantreadsGoomba].BoolValue)
				{
					return Plugin_Handled; // Prevent goomba stomp for mantreads/demo boots if being able to is disabled.
				}

				int wep = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Secondary);
				if (wep != -1)
				{
					int idx = GetItemIndex(wep);
					if (idx == 810 || idx == 831)
						return Plugin_Handled;
				}

				if (!TF2_IsKillable(client))
					return Plugin_Handled;

				//TF2_RemoveCondition(client, TFCond_LostFooting);
				damageAdd = float(cvarVSH2[GoombaDamageAdd].IntValue);
				damageMultiplier = cvarVSH2[GoombaLifeMultiplier].FloatValue;
				JumpPower = cvarVSH2[GoombaReboundPower].FloatValue;
				
				//PrintToChatAll("%N Just Goomba stomped %N(The Boss)!", attacker, client);
				//CPrintToChatAllEx(attacker, "{olive}>> {teamcolor}%N {default}just goomba stomped {unique}%N{default}!", attacker, client);
				return Plugin_Changed;
			}
		}
		return Plugin_Continue;
	}
	boss = BaseBoss(attacker);
	if (boss.bIsBoss) //The Boss(es) Stomping a player
	{
		switch (boss.iType)
		{
			case  - 1: {  } // Ignore if !boss at all.
			default: //Default behaviour for the Boss Goomba Stomping other players.
			{
				if (!cvarVSH2[CanBossGoomba].BoolValue)
				{
					return Plugin_Handled; //Block the Boss from Goomba Stomping if disabled.
				}
				if (RemoveDemoShield(client)) // If the demo had a shield to break
				{
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					//TF2_AddCondition(client, TFCond_Bonked, 0.1);
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					damageAdd = 0.0;
					damageMultiplier = 0.0;
					//JumpPower = 0.0;
					return Plugin_Changed;
				}
				//PrintToChatAll("%N(The Boss) just got stomped by %N!", client, attacker);
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}
#endif
public void ManageBossKillPlayer(const BaseBoss attacker, const BaseBoss victim, Event event) // To lazy to code this better lol
{
	// int dmgbits = event.GetInt("damagebits");
	int deathflags = event.GetInt("death_flags");
	if (victim.bIsBoss && gamemode.iRoundState == StateRunning && !event.GetBool("sourcemod")) // If victim is a boss, kill him off
	{
		if (0 < attacker.index <= MaxClients && IsClientInGame(attacker.index) && attacker.index != victim.index)
		{
//			if (bTBC)
//			{
//				TBC_GiveCredits(attacker.index, 15);
//				CPrintToChat(attacker.index, TBC_TAG ... "You have earned {unique}15{default} Gimgims for killing a boss!");
//			}
			if (bAch)
			{
				if (GetLivingPlayers(GetClientTeam(attacker.index)) == 1)
					VSH2Ach_AddTo(attacker.index, A_Soloer, 1);

				VSH2Ach_AddTo(attacker.index, A_HaleKiller, 1);
				VSH2Ach_AddTo(attacker.index, A_HaleGenocide, 1);
				VSH2Ach_AddTo(attacker.index, A_HaleExtinction, 1);

				if (!IsPlayerAlive(attacker.index))
					VSH2Ach_AddTo(attacker.index, A_BeyondTheGrave, 1);

				if (victim.iType == Hale && BeTheRobot_GetRobotStatus(victim.index) == RobotStatus_Robot)
					VSH2Ach_AddTo(attacker.index, A_BeepBoop, 1);

				switch (event.GetInt("customkill"))
				{
					case TF_CUSTOM_TAUNT_HADOUKEN,
						TF_CUSTOM_TAUNT_HIGH_NOON,
						TF_CUSTOM_TAUNT_GRAND_SLAM,
						TF_CUSTOM_TAUNT_FENCING,
						TF_CUSTOM_TAUNT_ARROW_STAB,
						TF_CUSTOM_TAUNT_GRENADE,
						TF_CUSTOM_TAUNT_BARBARIAN_SWING,
						TF_CUSTOM_TAUNT_UBERSLICE,
						TF_CUSTOM_TAUNT_ENGINEER_SMASH,
						TF_CUSTOM_TAUNT_ENGINEER_ARM,
						TF_CUSTOM_TAUNT_ARMAGEDDON,
						TF_CUSTOM_TAUNTATK_GASBLAST:VSH2Ach_AddTo(attacker.index, A_Embarrassed, 1);
				}

				char wpn[32]; event.GetString("weapon_logclassname", wpn, 32);
				if (!strcmp(wpn, "warfan"))
					VSH2Ach_AddTo(attacker.index, A_Pulverised, 1);
			}
			Call_OnActualBossDeath(victim, attacker, event);
		}
		SetPawnTimer(_BossDeath, 0.1, victim.userid);
		if (victim.bNoRagdoll)
			RequestFrame(RemoveRagdoll, victim.userid);
	}

	if (attacker.bIsBoss)
	{
		if (attacker.index != victim.index && gamemode.iRoundState == StateRunning) 
		{
			if (bAch)
			{
				VSH2Ach_AddTo(attacker.index, A_MercKiller, 1);
				VSH2Ach_AddTo(attacker.index, A_MercGenocide, 1);
				VSH2Ach_AddTo(attacker.index, A_MercExtinction, 1);

				switch (event.GetInt("customkill"))
				{
					case TF_CUSTOM_TAUNT_HADOUKEN,
						TF_CUSTOM_TAUNT_HIGH_NOON,
						TF_CUSTOM_TAUNT_GRAND_SLAM,
						TF_CUSTOM_TAUNT_FENCING,
						TF_CUSTOM_TAUNT_ARROW_STAB,
						TF_CUSTOM_TAUNT_GRENADE,
						TF_CUSTOM_TAUNT_BARBARIAN_SWING,
						TF_CUSTOM_TAUNT_UBERSLICE,
						TF_CUSTOM_TAUNT_ENGINEER_SMASH,
						TF_CUSTOM_TAUNT_ENGINEER_ARM,
						TF_CUSTOM_TAUNT_ARMAGEDDON,
						TF_CUSTOM_TAUNTATK_GASBLAST:VSH2Ach_AddTo(attacker.index, A_Overkill, 1);
				}
			}
			if (gamemode.iSpecialRound & ROUND_SURVIVAL)
				attacker.iSurvKills++;
			switch (attacker.iType)
			{
				case  - 1: {  }
				case Hale:
				{
					if (deathflags & TF_DEATHFLAG_DEADRINGER)
						event.SetString("weapon", "fists");
					else ToCHale(attacker).KilledPlayer(victim, event);
				}
				case Vagineer:ToCVagineer(attacker).KilledPlayer(victim, event);
				case CBS:ToCChristian(attacker).KilledPlayer(victim, event);
				case HHHjr:ToCHHHJr(attacker).KilledPlayer(victim, event);
				case Bunny:ToCBunny(attacker).KilledPlayer(victim, event);
			}
		}
	}
	else if (attacker.bIsMinion && !(deathflags & TF_DEATHFLAG_DEADRINGER))
		if (GetClientTeam(victim.index) == gamemode.iOtherTeam && ++attacker.iKillCount >= 5 && bAch)
			VSH2Ach_AddTo(attacker.index, A_Minion1, 1);
	if (victim.bIsMinion && IsClientValid(attacker.index) && attacker.index != victim.index && GetClientTeam(attacker.index) == gamemode.iOtherTeam)
	{
		if (!(deathflags & TF_DEATHFLAG_DEADRINGER))
			if (++attacker.iKillCount >= 10 && bAch)
				VSH2Ach_AddTo(attacker.index, A_Alternate, 1);
	}
	Call_OnPlayerKilled(attacker, victim, event);
}
public void ManageMinionKillPlayer(const BaseBoss attacker, const BaseBoss victim, Event event)
{
	BaseBoss boss = BaseBoss(attacker.iOwnerBoss);
	switch (boss.iType)
	{
		case -1: {}
	}
}
public void ManageHurtPlayer(const BaseBoss attacker, const BaseBoss victim, Event event)
{
	int damage = event.GetInt("damageamount");
	int custom = event.GetInt("custom");
	int weapon = event.GetInt("weaponid");
	int client = attacker.index;

	switch (victim.iType)
	{
		case  - 1: {  }
		default:
		{
			victim.iHealth -= damage;
			victim.GiveRage(damage);
		}
	}

	if (attacker.bIsMinion || attacker.bIsBoss)
		return;

	if (victim.bIsMinion)
	{
		BaseBoss owner = BaseBoss(victim.iOwnerBoss);
		switch (owner.iType)
		{
			case -1:{}
		}
	}

	if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary) == 1104) // Compatibility patch for Randomizer
	{
		if (weapon == TF_WEAPON_ROCKETLAUNCHER)
			attacker.iAirDamage += damage;
		int div = cvarVSH2[AirStrikeDamage].IntValue;
		SetEntProp(client, Prop_Send, "m_iDecapitations", attacker.iAirDamage / div);
	}

	bool iskillable = TF2_IsKillable(victim.index);

	if (attacker.bIsBoss && iskillable)
		++victim.iHits;

	if (custom == TF_CUSTOM_TELEFRAG && victim.bIsBoss && TF2_IsKillable(victim.index))
	{
		damage = 9001;
//		if (bTBC)
//		{
//			TBC_GiveCredits(client, 20);
//			CPrintToChat(client, TBC_TAG ... "You have earned {unique}20{default} Gimgims for telefragging a Boss!");
//		}
		if (bAch)
		{
			VSH2Ach_AddTo(client, A_Telefragger, 1);
			VSH2Ach_AddTo(client, A_TelefragMachine, 1);
			VSH2Ach_AddTo(client, A_FrogMan, 1);
			VSH2Ach_AddTo(client, A_MasterFrogMan, 1);
		}
	}
	
	if (victim.bIsBoss && gamemode.iRoundState == StateRunning)
	{
		attacker.iDamage += damage;
		if (bAch)
		{
			VSH2Ach_AddTo(attacker.index, A_Damager, damage);
			VSH2Ach_AddTo(attacker.index, A_DamageKing, damage);
		}
	}

	if(!GetEntProp(client, Prop_Send, "m_bShieldEquipped")
	 && GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary) <= 0
	 && TF2_GetPlayerClass(client) == TFClass_DemoMan)
 	{
 		int iReqDmg = cvarVSH2[ShieldRegenDmgReq].IntValue;
 		if(iReqDmg>0)
 		{
 			attacker.iShieldDmg += damage;
 			if(attacker.iShieldDmg >= iReqDmg)
 			{
 				// save data so we can get our shield back.
 				// save health, heads, && weapon data.
 				int health, heads, primclip, primammo;
 				health = GetClientHealth(client);
 				if(HasEntProp(client, Prop_Send, "m_iDecapitations"))
 					heads = GetEntProp(client, Prop_Send, "m_iDecapitations");
 				primammo = GetAmmo(client, TFWeaponSlot_Primary);
 				primclip = GetClip(client, TFWeaponSlot_Primary);
 				// "respawn" player.
 				TF2_RegeneratePlayer(client);
 				// reset old data
 				SetEntityHealth(client, health);
 				if(HasEntProp(client, Prop_Send, "m_iDecapitations") && heads>0)
 					SetEntProp(client, Prop_Send, "m_iDecapitations", heads);
 				SetAmmo(client, TFWeaponSlot_Primary, primammo);
 				SetClip(client, TFWeaponSlot_Primary, primclip);
 				attacker.iShieldDmg = 0;
 			}
 		}
 	}
}

public void ManagePlayerAirblast(const BaseBoss airblaster, const BaseBoss airblasted, Event event)
{
//	if (!(-1 < airblasted.iDifficulty <= 2))
//		return;
	switch (airblasted.iType)
	{
		case  - 1: {  }
		case Vagineer:
		{
			if (TF2_IsPlayerInCondition(airblasted.index, TFCond_Ubercharged))
				TF2_AddCondition(airblasted.index, TFCond_Ubercharged, 2.0);
			else airblasted.flRAGE += cvarVSH2[AirblastRage].FloatValue;
		}
		default:if (!TF2_IsPlayerInCondition(airblasted.index, TFCond_MegaHeal))
			airblasted.ReceiveGenericRage();
	}
	Call_OnPlayerAirblasted(airblaster, airblasted, event);
}

public Action ManageTraceHit(const BaseBoss victim, const BaseBoss attacker, int & inflictor, float & damage, int & damagetype, int & ammotype, int hitbox, int hitgroup)
{
	switch (victim.iType)
	{
		case  - 1: {  }
	}
	if (victim.bIsBoss)
	{
		int idx = GetItemIndex(GetActiveWep(attacker.index));
		if (idx == 751 && hitgroup == 1)
		{
			damagetype |= DMG_AIRBOAT|DMG_CRIT;
			damage *= 2.0;
			return Plugin_Changed;
		}
		else if (idx == 752 && hitgroup == 1 && !TF2_IsPlayerInCondition(attacker.index, TFCond_Slowed))
		{
			damagetype |= DMG_AIRBOAT|DMG_CRIT;
			return Plugin_Changed;
		}
	}
	Call_OnTraceAttack(victim, attacker, inflictor, damage, damagetype, ammotype, hitbox, hitgroup);
	return Plugin_Continue;
}
public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	if (!bEnabled.BoolValue || !IsPlayerAlive(client))
		return Plugin_Continue;

	BaseBoss base = BaseBoss(client);

	switch (base.iType)
	{
		case -1:
		{
		}
		case Bunny:
		{
			if (GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == GetActiveWep(client))
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
		case HHHjr: {
			if (base.flCharge >= 47.0 && (buttons & IN_ATTACK))
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	BaseBoss player = BaseBoss(client);
	//int provider = GetConditionProvider(client, condition);
	if (!player.bIsBoss)
	{
		if (condition == TFCond_SpeedBuffAlly && TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
			TF2_RemoveCondition(client, TFCond_SpeedBuffAlly);
	}

	else
	{
		switch (condition)
		{
			case TFCond_Disguised, TFCond_Jarated:TF2_RemoveCondition(client, condition);
//			case TFCond_Dazed:
//			{
//				float dur = GetConditionDuration(client, condition);
//				if (dur >= 0.5)
//					player.flCharge -= dur * 50.0;
//			}
		}
	}
}

public void ManageBossMedicCall(const BaseBoss base)
{
	switch (base.iType)
	{
		case  - 1: {  }
		default:DoTaunt(base.index, "", 0);
	}
	Call_OnBossMedicCall(base);
}
public Action ManageBossTaunt(const BaseBoss base)
{
	if (gamemode.iRoundState != StateRunning)
		return Plugin_Continue;

	if (base.flRAGE < 100.0)
		return Plugin_Continue;

	switch (base.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(base).RageAbility();
		case Vagineer:ToCVagineer(base).RageAbility();
		case CBS:ToCChristian(base).RageAbility();
		case HHHjr:ToCHHHJr(base).RageAbility();
		case Bunny:ToCBunny(base).RageAbility();
		default:Call_OnBossTaunt(base);
	}

	if (bAch && base.iType != -1)
	{
		VSH2Ach_AddTo(base.index, A_Rager, 1);
		VSH2Ach_AddTo(base.index, A_EMasher, 1);
		VSH2Ach_AddTo(base.index, A_RageNewb, 1);
	}

	base.flRAGE = 0.0;
	return Plugin_Handled;
}
public void ManageBuildingDestroyed(const BaseBoss base, const int building, const int objecttype, Event event)
{
	switch (base.iType)
	{
		case  - 1: {  }
		case Hale: {
			event.SetString("weapon", "fists");
			if (!GetRandomInt(0, 3))
			{
				char snd[PLATFORM_MAX_PATH];
				strcopy(snd, PLATFORM_MAX_PATH, HaleSappinMahSentry132);
				EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, base.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, base.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			}
		}
	}
	Call_OnBossKillBuilding(base, building, event);
}
public void ManagePlayerJarated(const BaseBoss attacker, const BaseBoss victim)
{
	switch (victim.iType)
	{
		case  - 1: {  }
		case CBS:
		{
			victim.flRAGE -= cvarVSH2[JarateRage].FloatValue;
			if (bAch)
				VSH2Ach_AddTo(attacker.index, A_DeRage, cvarVSH2[JarateRage].IntValue);
			int ammo = GetAmmo(victim.index, 0);
			if (ammo > 0)
				SetWeaponAmmo(GetPlayerWeaponSlot(victim.index, 0), ammo-1);
		}
		default:victim.RemoveGenericRage(attacker.index);
	}
	Call_OnBossJarated(victim, attacker);
}
public Action SoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!bEnabled.BoolValue || !IsClientValid(entity))
		return Plugin_Continue;

	BaseBoss base = BaseBoss(entity);

	switch (base.iType)
	{
		case  - 1: {
			if (StrEqual(sample, "player/pl_impact_stun.wav", false) && gamemode.iRoundState != StateDisabled)
				return Plugin_Handled;

			else if (StrContains(sample, "cbar_hit1", false) != -1 || StrContains(sample, "cbar_hit2", false) != -1)
			{
				float vecAng[3];
				float vecEye[3];
				GetClientEyeAngles(entity, vecAng);
				GetClientEyePosition(entity, vecEye);

				TR_TraceRayFilter(vecEye, vecAng, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceRayDontHitSelf, entity);
				int ent = TR_GetEntityIndex();

				if (IsValidEntity(ent))
				{
					char cls[64]; GetEntityClassname(ent, cls, sizeof(cls));
					if (!StrContains(cls, "obj_", false) && GetEntProp(ent, Prop_Send, "m_iTeamNum") == GetClientTeam(entity))
					{
						float vecOther[3];
						float vecMe[3]; GetClientAbsOrigin(entity, vecMe);
						GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vecOther);

						if (GetVectorDistance(vecOther, vecMe, false) < 100.0) //Make sure they're close enough to the building, it's pretty easy to trigger the sound without being in range
						{
							BuildingHit(entity, ent);
							return Plugin_Continue;
						}
					}
				}
			}
		}
		case Hale:
		{
			if (!strncmp(sample, "vo", 2, false))
				return Plugin_Handled;
		}
		case Vagineer: {
			if (StrContains(sample, "vo/engineer_laughlong01", false)!= - 1)
			{
				strcopy(sample, PLATFORM_MAX_PATH, VagineerKSpree);
				return Plugin_Changed;
			}
			
			if (!strncmp(sample, "vo", 2, false))
			{
				if (StrContains(sample, "positivevocalization01", false)!= - 1) // For backstab sound
					return Plugin_Continue;
				if (StrContains(sample, "engineer_moveup", false)!= - 1)
					Format(sample, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
				
				else if (StrContains(sample, "engineer_no", false)!= - 1 || GetRandomInt(0, 9) > 6)
					strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_no01.mp3");
				
				else strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_jeers02.mp3");
				return Plugin_Changed;
			}
			else return Plugin_Continue;
		}
		case HHHjr: {
			if (!strncmp(sample, "vo", 2, false))
			{
				if (GetRandomInt(0, 30) <= 10)
				{
					Format(sample, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
					return Plugin_Changed;
				}
				if (StrContains(sample, "halloween_boss") == - 1)
					return Plugin_Handled;
			}
		}
		case Bunny: {
			if (StrContains(sample, "gibberish", false) == -1
				 && StrContains(sample, "burp", false) == -1
				 && !GetRandomInt(0, 2)) // Do sound things
			{
				strcopy(sample, PLATFORM_MAX_PATH, BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice) - 1)]);
				return Plugin_Changed;
			}
		}
		default: {
			if (hFwdCompat[Fwd_OnSoundHook].FindValue(base.iType) != -1)
				if (!strncmp(sample, "vo", 2, false))
					return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool & result)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	
	BaseBoss base = BaseBoss(client);
	switch (base.iType)
	{
		case  - 1: {  }
		case HHHjr: {
			if (base.iClimbs < 10)
			{
				if (base.ClimbWall(weapon, 600.0, 0.0, false))
				{
					base.flWeighDown = 0.0;
					base.iClimbs++;					
				}
			}
		}
	}
	if (base.bIsBoss)
	{  // Fuck random crits
		if (TF2_IsPlayerCritBuffed(base.index))
			return Plugin_Continue;
		result = false;
		return Plugin_Changed;
	}
	
	else if (!base.bIsBoss)
	{
		if (TF2_GetPlayerClass(base.index) == TFClass_Sniper && IsWeaponSlotActive(base.index, TFWeaponSlot_Melee))
			base.ClimbWall(weapon, 600.0, 15.0, true);
	}
	return Plugin_Continue;
}

/*
IT SHOULD BE WORTH NOTING THAT ManageMessageIntro IS CALLED AFTER BOSS HEALTH CALCULATION, IT MAY OR MAY NO BE A GOOD IDEA TO RESET BOSS HEALTH HERE IF NECESSARY. ESPECIALLY IF YOU HAVE A MULTIBOSS THAT REQUIRES UNEQUAL HEALTH DISTRIBUTION.
*/
public void ManageMessageIntro(ArrayList bosses) //(const BaseBoss base[34])		// I can't believe this works lmaooo
{
	gameMessage[0] = '\0';
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_door"))!= - 1)
	{
		AcceptEntityInput(ent, "Open");
		AcceptEntityInput(ent, "Unlock");
	}
	//Call_OnMessageIntro(bosses);
	int i;
	BaseBoss base;
	int len = bosses.Length;
	char name[MAX_BOSS_NAME_LENGTH];
	int gmflags = gamemode.iSpecialRound;
	for (i = 0; i < len; ++i)
	{
		base = bosses.Get(i);
		if (base == view_as<BaseBoss>(0))
			continue;

		base.GetName(name);
		Format(gameMessage, MAXMESSAGE, "%s\n%s%N has become %s with %i Health", gameMessage, (gmflags & ROUND_HVH ? (GetClientTeam(base.index) == RED ? "RED's " : "BLU's ") : ""),
						base.index, name, base.iHealth);
		Call_OnMessageIntro(base, gameMessage);
//		switch (base.iDifficulty)
//		{
//			case -1:Format(gameMessage, MAXMESSAGE, "%s\nNo-Rage Mode", gameMessage);
//			case 2:Format(gameMessage, MAXMESSAGE, "%s\nHARD MODE", gameMessage);
//			case 3:Format(gameMessage, MAXMESSAGE, "%s\nINSANE MODE", gameMessage);
//			case 4:Format(gameMessage, MAXMESSAGE, "%s\nIMPOSSIBLE MODE", gameMessage);
//		}
	}
	if (gameMessage[0] != '\0')
	{
		if (gmflags & ROUND_SURVIVAL)
			StrCat(gameMessage, sizeof(gameMessage), "\nSURVIVAL MODE");
		if (gmflags & ROUND_MANNPOWER)
			StrCat(gameMessage, sizeof(gameMessage), "\nMANNPOWER MODE");
		if (gmflags & ROUND_HVH)
			StrCat(gameMessage, sizeof(gameMessage), "\nBOSS VS BOSS");

		SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
		for (i = MaxClients; i; --i)
		{
			if (IsClientValid(i))
				ShowHudText(i, -1, "%s", gameMessage);
			//PrintCenterTextAll(gameMessage);
		}
	}
	//SetPawnTimer(_MusicPlay, 2.0);		// in vsh2.sp
	gamemode.iRoundState = StateRunning;
	delete bosses;
}

public void ManageBossPickUpItem(const BaseBoss base, const char item[64])
{
	//if (GetIndexOfWeaponSlot(base.index, TFWeaponSlot_Melee) == 404)	// block Persian Persuader
	//	return;
	switch (base.iType)
	{
		case  - 1: {  }
	}
	Call_OnBossPickUpItem(base, item);
}

public void ManageResetVariables(const BaseBoss base)
{
	base.bIsBoss = base.bSetOnSpawn = false;
	base.iType = -1;
	base.iPureType = -1;
	base.iStabbed = 0;
	base.iMarketted = 0;
	base.flRAGE = 0.0;
//	base.iDifficulty = 0;
	base.iDamage = 0;
	base.iAirDamage = 0;
	base.iUberTarget = 0;
	base.flCharge = 0.0;
	base.bGlow = 0;
	base.flGlowtime = 0.0;
	base.bUsedUltimate = false;
	base.bIsMinion = false;
	base.bNoRagdoll = false;
	base.iOwnerBoss = 0;
	base.iSongPick = -1;
	SetEntityRenderColor(base.index, 255, 255, 255, 255);
	base.flLastShot = 0.0;
	base.flLastHit = 0.0;
	base.iState = -1;
	base.iHits = 0;
	base.iKillCount = 0;
	base.iLives = 0;
	base.iHealth = 0;
	base.iMaxHealth = 0;
	base.iShieldDmg = 0;
	base.iStreaks = 0;
	base.iStreakCount = 0;
	base.iStabs = 0;
	base.iSpecial = 0;
	base.iSpecial2 = 0;
	base.iSurvKills = 0;
	base.flSpecial = 0.0;
	base.flSpecial2 = 0.0;
	base.flMusicTime = 0.0;
	delete base.hSpecial;
	base.SetOverlay("0");
	Call_OnVariablesReset(base);
}
public void ManageEntityCreated(const int entity, const char[] classname)
{
//	if (StrContains(classname, "rune")!= - 1) // Special request
//		SDKHook(entity, SDKHook_Spawn, KillOnSpawn);
	
	if (!cvarVSH2[DroppedWeapons].BoolValue && StrEqual(classname, "tf_dropped_weapon")) //Remove dropped weapons to avoid bad things
	{
		AcceptEntityInput(entity, "kill");
		return;
	}

	if (gamemode.iRoundState == StateRunning && !strcmp(classname, "tf_projectile_pipe", false))
		SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);

	else if (!strcmp(classname, "tf_ragdoll", false))
		SDKHook(entity, SDKHook_Spawn, OnRagSpawn);
}

public void OnEggBombSpawned(int entity)
{
	int owner = GetOwner(entity);
	BaseBoss boss = BaseBoss(owner);
	if (IsClientValid(owner) && boss.bIsBoss && boss.iType == Bunny)
		CreateTimer(0.0, Timer_SetEggBomb, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}

public void ManageUberDeploy(const BaseBoss medic, const BaseBoss patient)
{
	if (medic.bIsMinion)
		return;

	int medigun = GetPlayerWeaponSlot(medic.index, TFWeaponSlot_Secondary);
	if (IsValidEntity(medigun) && HasEntProp(medigun, Prop_Send, "m_bChargeRelease"))
	{
		int idx = GetItemIndex(medigun);
		if (idx != 998)
			SetMediCharge(medigun, 1.51);

		if (idx != 411 && idx != 998 && !(gamemode.iSpecialRound & ROUND_HVH))
			TF2_AddCondition(medic.index, TFCond_CritOnWin, 0.5, medic.index);

		if (idx == 411)
			TF2_AddCondition(medic.index, TFCond_DefenseBuffNoCritBlock, 0.2, medic.index);

		if (IsClientValid(patient.index) && IsPlayerAlive(patient.index))
		{
			medic.iUberTarget = patient.userid;
			if (idx != 411 && idx != 998 && !(gamemode.iSpecialRound & ROUND_HVH))
				TF2_AddCondition(patient.index, TFCond_CritOnWin, 0.2);
		}
		else medic.iUberTarget = 0;

		Call_OnUberDeployed(medic, patient);
		CreateTimer(0.1, TimerLazor, EntIndexToEntRef(medigun), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void ManageMusic(char song[PLATFORM_MAX_PATH], float & time)
{
	// UNFORTUNATELY, we have to get a random boss so we can set our music, tragic I know...
	// Remember that you can get a random boss filtered by type as well!
	if (MapHasMusic())
	{ song[0] = '\0'; time = -1.0; return; }

	BaseBoss currBoss = gamemode.GetRandomBoss(false);
	if (currBoss)
	{
		switch (currBoss.iPureType)
		{
			case  - 1: { song[0] = '\0'; time = -1.0; }
			case Hale: {
				switch (GetRandomInt(1, 2))
				{
					case 1:
					{
						strcopy(song, sizeof(song), HaleTheme);
						time = 170.0;
					}
					case 2:
					{
						strcopy(song, sizeof(song), HaleTheme3);
						time = 220.0;
					}
				}
			}
			case Vagineer: {
				switch (GetRandomInt(1, 3))
				{
					case 1:
					{
						strcopy(song, sizeof(song), VagTheme);
						time = 226.0;
					}
					case 2:
					{
						strcopy(song, sizeof(song), VagTheme2);
						time = 212.0;
					}
					case 3:
					{
						strcopy(song, sizeof(song), VagTheme3);
						time = 186.0;
					}
				}
			}
			case CBS: {
				switch (GetRandomInt(1, 3))
				{
					case 1:
					{
						strcopy(song, sizeof(song), CBSTheme);
						time = 140.0;
					}
					case 2:
					{
						strcopy(song, sizeof(song), CBSTheme2);
						time = 146.0;
					}
					case 3:
					{
						strcopy(song, sizeof(song), CBSTheme3);
						time = 217.0;
					}
				}
			}
			case HHHjr: {
				switch (GetRandomInt(1, 3))
				{
					case 1:
					{
						strcopy(song, sizeof(song), HHHTheme);
						time = 90.0;
					}
					case 2:
					{
						strcopy(song, sizeof(song), HHHTheme2);
						time = 150.0;
					}
					case 3:
					{
						strcopy(song, sizeof(song), HHHTheme2);
						time = 234.0;
					}
				}
			}
			case Bunny: {
				switch (GetRandomInt(1, 3)) 
				{
					case 1:
					{
						strcopy(song, sizeof(song), BunnyTheme);
						time = 272.0;
					}
					case 2:
					{
						strcopy(song, sizeof(song), BunnyTheme2);
						time = 153.0;
					}
					case 3:
					{
						strcopy(song, sizeof(song), BunnyTheme3);
						time = 185.0;
					}
				}
			}
			default:Call_OnMusic(song, time, currBoss);
		}
	}
}
public void StopBackGroundMusic()
{
	for (int i = MaxClients; i; --i) 
		if (IsClientInGame(i))
			if (BackgroundSong[i][0] != '\0')
				StopSound(i, SNDCHAN_AUTO, BackgroundSong[i]);
}
public void ManageRoundEndBossInfo(ArrayList bosses, int team) //(const BaseBoss base[34])	// I STILL can't believe this works lmaoooo.
{
	char victory[PLATFORM_MAX_PATH];
	gameMessage[0] = '\0';
	char name[64];
	char time[32];
	int i = 0;
	BaseBoss base;
	//Call_OnRoundEndInfo(bosses, bossWon);
	bool surv = !!(gamemode.iSpecialRound & ROUND_SURVIVAL);

	for (i = 0; i < bosses.Length; ++i)
	{
		base = bosses.Get(i);
		if (base == view_as<BaseBoss>(0))
			continue;

		if (!IsPlayerAlive(base.index) && !surv)
			continue;

		base.GetName(name);
		base.SetName("");

		if (surv)
		{
			FormatTime(time, sizeof(time), "%M:%S", GetTime() - base.iTime);
			Format(gameMessage, MAXMESSAGE, "%s\n%s (%N) got %d kill%s and survived %s.", gameMessage, name, base.index, base.iSurvKills, base.iSurvKills == 1 ? "" : "s", time);
		}
		else Format(gameMessage, MAXMESSAGE, "%s\n%s (%N) had %i (of %i) health left.", gameMessage, name, base.index, base.iHealth, base.iMaxHealth);

//		switch (base.iDifficulty)
//		{
//			case -1:Format(gameMessage, MAXMESSAGE, "%s (No-Rage Mode)", gameMessage);
//			case 2:Format(gameMessage, MAXMESSAGE, "%s (HARD MODE)", gameMessage);
//			case 3:Format(gameMessage, MAXMESSAGE, "%s (INSANE MODE)", gameMessage);
//			case 4:Format(gameMessage, MAXMESSAGE, "%s (IMPOSSIBLE MODE)", gameMessage);
//		}
		Call_OnRoundEndInfo(base, team == gamemode.iHaleTeam, gameMessage);
		if (team == GetClientTeam(base.index))
		{
			if (surv)
				CPrintToChat(base.index, "{olive}[VSH 2]{default} You did it!");

			if (bAch)
			{
				if (base.iHealth < 100)
					VSH2Ach_AddTo(base.index, A_CloseCall, 1);
				else if (base.iHealth == base.iMaxHealth)
					VSH2Ach_AddTo(base.index, A_Invincible, 1);
			}
		}
		else if (gamemode.iSpecialRound & ROUND_HVH)
		{
			bosses.Erase(i);
			--i;
		}
	}

	if (team == gamemode.iHaleTeam && bosses.Length)
	{
		victory[0] = '\0';
		base = bosses.Get(GetRandomInt(0, bosses.Length-1));
		int sndflags = SND_NOFLAGS;
		int pitch = 100;
		switch (base.iType)
		{
			case  -1: {  }
			case Vagineer:Format(victory, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
			case Bunny:strcopy(victory, PLATFORM_MAX_PATH, BunnyWin[GetRandomInt(0, sizeof(BunnyWin) - 1)]);
			case Hale:Format(victory, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
			default:Call_OnBossWin(base, victory, sndflags, pitch);
		}
		if (victory[0] != '\0')
		{
			EmitSoundToAll(victory, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, sndflags, SNDVOL_NORMAL, pitch, base.index, _, NULL_VECTOR, false, 0.0);
			EmitSoundToAll(victory, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, sndflags, SNDVOL_NORMAL, pitch, base.index, _, NULL_VECTOR, false, 0.0);
		}
	}
	if (gameMessage[0] !='\0')
	{
		CPrintToChatAll("{olive}[VSH 2] End of Round{default} %s", gameMessage);
		SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
		for (i = MaxClients; i; --i)
		{
			if (IsClientInGame(i) && !(GetClientButtons(i) & IN_SCORE))
				ShowHudText(i, -1, "%s", gameMessage);
		}
	}
	delete bosses;
}
public void ManageLastPlayer()
{
	BaseBoss currBoss = gamemode.GetRandomBoss(true);
	switch (currBoss.iType)
	{
		case  - 1: {  }
		case Hale:ToCHale(currBoss).LastPlayerSoundClip();
		case Vagineer:ToCVagineer(currBoss).LastPlayerSoundClip();
		case CBS:ToCChristian(currBoss).LastPlayerSoundClip();
		case Bunny:ToCBunny(currBoss).LastPlayerSoundClip();
		default:Call_OnLastPlayer(currBoss);
	}
}
public void ManageBossCheckHealth(const BaseBoss base)
{
	static int LastBossTotalHealth;
	float currtime = GetGameTime();
	char name[MAX_BOSS_NAME_LENGTH];
	if (base.bIsBoss)
	{  // If a boss reveals their own health, only show that one boss' health.
		base.GetName(name);
		PrintCenterTextAll("%s showed his current HP: %i of %i", name, base.iHealth, base.iMaxHealth);
		Call_OnBossHealthCheck(base, true, gameMessage);
		LastBossTotalHealth = base.iHealth;
		return;
	}
	if (currtime >= gamemode.flHealthTime)
	{  // If a non-boss is checking health, reveal all Boss' hp
		gamemode.iHealthChecks++;
		BaseBoss boss;
		int totalHealth;
		gameMessage[0] = '\0';
		int gmflags = gamemode.iSpecialRound;
		for (int i = MaxClients; i; --i)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i)) // exclude dead bosses for health check
				continue;
			boss = BaseBoss(i);
			if (!boss.bIsBoss)
				continue;

			boss.GetName(name);
			Format(gameMessage, MAXMESSAGE, "%s\n%s%s%s current health is: %i of %i", gameMessage, (gmflags & ROUND_HVH ? (GetClientTeam(i) == RED ? "RED's " : "BLU's ") : ""),
			 				name, (name[strlen(name)-1] == 's' ? "'" : "'s"), boss.iHealth, boss.iMaxHealth);
			Call_OnBossHealthCheck(boss, false, gameMessage);

			if (gameMessage[0] != '\0' && boss.iPureType != -1)
			{
//				switch (base.iDifficulty)
//				{
//					case -1:Format(gameMessage, MAXMESSAGE, "%s. (No-Rage Mode)", gameMessage);
//					case 2:Format(gameMessage, MAXMESSAGE, "%s. (HARD MODE)", gameMessage);
//					case 3:Format(gameMessage, MAXMESSAGE, "%s. (INSANE MODE)", gameMessage);
//					case 4:Format(gameMessage, MAXMESSAGE, "%s. (IMPOSSIBLE MODE)", gameMessage);
//				}
			}
			//Call_OnBossHealthCheck(boss);
			totalHealth += boss.iHealth;
		}
		if (gameMessage[0] != '\0')
		{
			if (gmflags & ROUND_SURVIVAL)
				StrCat(gameMessage, sizeof(gameMessage), "\nSURVIVAL MODE");
			if (gmflags & ROUND_MANNPOWER)
				StrCat(gameMessage, sizeof(gameMessage), "\nMANNPOWER MODE");
			if (gmflags & ROUND_HVH)
				StrCat(gameMessage, sizeof(gameMessage), "\nBOSS VS BOSS");
			PrintCenterTextAll(gameMessage);

			CPrintToChatAll("{olive}[VSH 2] Boss Health Check{default} %s", gameMessage);
		}
		LastBossTotalHealth = totalHealth;
		gamemode.flHealthTime = currtime + (gamemode.iHealthChecks < 3 ? 10.0 : 60.0);
	}
	else CPrintToChat(base.index, "{olive}[VSH 2]{default} You can not see the Boss HP now (wait %i seconds). Last known total health was %i.", RoundFloat(gamemode.flHealthTime - currtime), LastBossTotalHealth);
}
public void CheckAlivePlayers()
{
	if (gamemode.iRoundState != StateRunning)
		return;

	int living = GetLivingPlayers(gamemode.iHaleTeam);
	if (!living)
		ForceTeamWin(gamemode.iOtherTeam);

	living = GetLivingPlayers(gamemode.iOtherTeam);
	if (!living)
		ForceTeamWin(gamemode.iHaleTeam);

	if (!(gamemode.iSpecialRound & ROUND_HVH))
	{
		if (living == 1 && gamemode.GetRandomBoss(true))
		{
			ManageLastPlayer(); // in handler.sp
			if (gamemode.iTimeLeft <= 0)
			{
				gamemode.iTimeLeft = cvarVSH2[LastPlayerTime].IntValue;
				CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
			else if (gamemode.iTimeLeft > cvarVSH2[LastPlayerTime].IntValue)
				gamemode.iTimeLeft = cvarVSH2[LastPlayerTime].IntValue;
		}
		else if (living <= 3 && gamemode.GetRandomBoss(true))
		{
			if (gamemode.iTimeLeft <= 0)
			{
				gamemode.iTimeLeft = 300;
				CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}
public int ManageSetBossArgs(const char[] bossname, char[] buffer)
{
	int typei = -1;
	if (StrContains("Saxton Hale", bossname, false) != -1)
	{
		typei = Hale;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Saxton Hale");
	}
	else if (StrContains("The Vagineer", bossname, false) != -1)
	{
		typei = Vagineer;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Vagineer");
	}
	else if (StrContains(bossname, "hhh", false) != -1 || StrContains("The Horseless Headless Horsemann Jr.", bossname, false) != -1)
	{
		typei = HHHjr;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Horseless Headless Horsemann Jr.");
	}
	else if (StrContains("The Christian Brutal Sniper", bossname, false) != -1)
	{
		typei = CBS;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Christian Brutal Sniper");
	}
	else if (StrContains("The Easter Bunny", bossname, false) != -1)
	{
		typei = Bunny;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Easter Bunny");
	}
	else Call_OnSetBossArgs(bossname, typei, buffer);
	return typei;
}

public void ManageOnBossCap(char sCappers[MAXPLAYERS + 1], const int CappingTeam)
{
	switch (CappingTeam)
	{
		case RED: {  } // Code pertaining to red team here
		case BLU: {  } // Code pertaining to blu team and/or bosses here
	}
	Call_OnControlPointCapped(sCappers, CappingTeam);
}

public void _SkipBossPanel()
{
	BaseBoss upnext[3];
	for (int j = 0; j < 3; ++j)
	{
		upnext[j] = gamemode.FindNextBoss();
		if (!upnext[j].userid)
			continue;
		upnext[j].bSetOnSpawn = true;
		if (!j) // If up next to become a boss.
			SkipBossPanelNotify(upnext[j].index);
		else if (!IsFakeClient(upnext[j].index))
			CPrintToChat(upnext[j].index, "{olive}[VSH 2]{default} You are going to be a Boss soon! Type {olive}/halenext{default} to check/reset your queue points.");
	}
	for (int n = MaxClients; n; --n)
	{  // Ughhh, reset shit...
		if (!IsClientValid(n))
			continue;
		upnext[0] = BaseBoss(n);
		if (!upnext[0].bIsBoss)
			upnext[0].bSetOnSpawn = false;
	}
}

public void PrepPlayers(const BaseBoss player)
{
	int client = player.index;
	if (!(0 < client <= MaxClients))
		return;

	int roundstate = gamemode.iRoundState;
	if (!IsPlayerAlive(client)
		|| roundstate == StateEnding
		|| player.bIsBoss
		|| player.bIsMinion
		|| GetClientTeam(client) <= SPEC)
	return;
	
	TF2Attrib_RemoveAll(client);

	int specialround = gamemode.iSpecialRound;
	int team = GetClientTeam(client);

	if (!(specialround & ROUND_HVH) && team != gamemode.iOtherTeam && team > SPEC && roundstate != StateDisabled)
	{
		if (!(CheckCommandAccess(player.index, "sm_asdcdfc", ADMFLAG_ROOT, true) && roundstate == StateRunning))
		{
			player.ForceTeamChange(gamemode.iOtherTeam);
//			TF2_RegeneratePlayer(client); // Added fix by Chdata to correct team colors
		}
	}
	TF2_RegeneratePlayer(client);
	SetEntityHealth(client, GetEntProp(client, Prop_Data, "m_iMaxHealth"));

	TF2Attrib_RemoveByDefIndex(client, 58);
	if (FindPlayerBack(client, { 444 }, 1) != -1) //  Fixes mantreads to have jump height again
	{
		TF2Attrib_SetByDefIndex(client, 58, 1.3); //  "self dmg push force increased"
		RemovePlayerBack(client, { 133 }, 1);
	}

	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int index = -1;
	TFClassType class = TF2_GetPlayerClass(client);
	if (weapon != -1)
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			case 237:	// Rocket Jumper
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				RemovePlayerBack(client, { 444, 133 }, 2);
				TF2Attrib_RemoveByDefIndex(client, 58);
			}
			case 1153:	// Panic Attack -> Golden Wrench
			{
				if (class == TFClass_Engineer)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);		// You see Mr. Powers...
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);		// I love goooooooold...
					player.SpawnWeapon("tf_weapon_wrench", 169, 9001, 6, "150 ; 1 ; 6 ; 0.75 ; 94 ; 1.5 ; 169 ; 0.7 ; 141 ; 1.0 ; 113 ; 10");
					SetEntityHealth(client, 125);
				}
			}
		}
	}

	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (weapon != -1)
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			case 265: // Stickyjumper
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				RemovePlayerBack(client, {405, 608}, 2);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
			}
//			case 735, 736, 810, 831, 933, 1080, 1102: // Replace sapper with more useful nail-firing Pistol
//			{
//				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
//				weapon = player.SpawnWeapon("tf_weapon_handgun_scout_secondary", 23, 5, 10, "280 ; 5 ; 6 ; 0.7 ; 2 ; 0.66 ; 4 ; 4.167 ; 78 ; 8.333 ; 137 ; 6.0");
//				SetWeaponAmmo(weapon, 200);
//			}
			case 46, 1145: //bonk atomic punch
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_lunchbox_drink", 163, 1, 0, "144 ; 2");
			}
		}
	}

	if (FindPlayerBack(client, { 642 }, 1) != -1)
		player.SpawnWeapon("tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 1 ; 0.85");

	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (weapon != -1)
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			/*case 331: {
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				weapon = player.SpawnWeapon("tf_weapon_fists", 195, 1, 6, "");
			}*/
			case 357:SetPawnTimer(_NoHonorBound, 1.0, player.userid);
		}
	}

	static bool mirage;
	if (!mirage)
		mirage = LibraryExists("tf2mirage");
	if (!mirage)
	{
		weapon = GetPlayerWeaponSlot(client, 4);
		if (weapon > MaxClients && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 60)
		{
			TF2_RemoveWeaponSlot(client, 4);
			weapon = player.SpawnWeapon("tf_weapon_invis", 30, 1, 0, "");
		}
	}
	switch (class)
	{
		case TFClass_Medic:
		{
			weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			float toset = GetIndexOfWeaponSlot(player.index, TFWeaponSlot_Melee) == 173 ? 0.35 : 0.2;
			SetMediCharge(weapon, toset);
		}
	}

	if (roundstate != StateRunning)
		LoadoutPanel(client);

	if (specialround & ROUND_MANNPOWER)
	{
		TF2_RemoveWeaponSlot(client, 6);
		player.SpawnWeapon("tf_weapon_grapplinghook", 1152, 1, 10, "241 ; 0 ; 280 ; 26 ; 547 ; 0 ; 199 ; 0 ; 712 ; 1");
	}
	Call_OnPrepRedTeam(player);
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle & hItem)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	Handle hItemOverride = null;

	switch (iItemDefinitionIndex)
	{
		case 59: // dead ringer
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "35 ; 2.0 ; 729 ; 0.0");
		}
		case 1103: //Backscatter
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1.0");
		}
		case 220: //shortstop
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "526 ; 1.2 ; 533 ; 1.4 ; 534 ; 1.4 ; 328 ; 1 ; 241 ; 1.5 ; 78 ; 1.389 ; 97 ; 0.75");	// Override
		}
		case 349: //sun on a stick
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "134 ; 13 ; 208 ; 1 ; 73 ; 2.0");
		}
		/*case 444: //Mantreads
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "275 ; 1.0");
		}*/
		case 648: //wrap assassin
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "279 ; 5.0");
		}
		/*case 224: //Letranger
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "166 ; 15 ; 1 ; 0.8", true);
		}*/
		case 225, 574: //YER
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "155 ; 1 ; 160 ; 1");
		}
		//case 232, 401: // Bushwacka + Shahanshah
		//{
		//	hItemOverride = PrepareItemHandle(hItem, _, _, "236 ; 1");
		//}
		case 226: // The Battalion's Backup
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "252 ; 0.25");
		}
		case 305, 1079: // Medic Xbow
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.1 ; 2 ; 1.45"); // ; 266 ; 1.0");
		}
		case 56, 1005, 1092: // Huntsman
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "76 ; 2.0");
		}
		case 239, 1084, 1100: //gru
		{
			hItemOverride = PrepareItemHandle(hItem, _, iItemDefinitionIndex, "107 ; 1.75 ; 1 ; 0.5 ; 128 ; 1 ; 191 ; -30 ; 772 ; 2.0 ; 547 ; 0.25 ; 236 ; 1.0");	// Override
		}
		case 415: //reserve shooter
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "868 ; 1.0 ; 179 ; 1 ; 114 ; 1.0 ; 178 ; 0.6 ; 3 ; 0.66");	// Override
		}
		case 405, 608: // Demo boots have falling stomp damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "259 ; 1 ; 252 ; 0.25");
		}
		case 36: // Blutsauger
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.01");
		}
		case 412:	// Overdose
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.01 ; 107 ; 1.05 ; 128 ; 1.0");
		}
		case 772: // Baby Face Blaster
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "106 ; 0.4 ; 2 ; 1.3 ; 3 ; 0.13 ; 96 ; 1.3");	// Override
		}
		/*case 133: // Gunboats ; make gunboats more attractive compared to the mantreads by having it reduce more rj dmg
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "135 ; 0.25", true);
		}*/
		case 813, 834: //neon annihilator gives more primary ammo, decreased damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "76 ; 1.5 ; 1 ; 0.5");
		}
		case 154: //pain train ammo boost
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "76 ; 1.5 ; 78 ; 1.5 ; 412 ; 1.2");
		}
		case 45, 1078: //force a nature less accurate
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "36 ; 1.5 ; 518 ; 1.0");
		}
		case 38, 457, 1000: //axtinguisher/pummeler no fall damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "795 ; 1.2");
		}
		case 325, 452: // Boston Basher heal on hit
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "110 ; 1");
		}
		case 595: //manmelter firing speed
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "6 ; 0.67");
		}
		case 304: // medic melee weapon switch speed
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "178 ; 0.5");
		}
		case 5075: //rings give sunbeams effects
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "134 ; 17");
		}
		case 128:	// Equalizer
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "235 ; 1.0 ; 414 ; 1.0 ; 236 ; 1.0");
		}
		case 775:	// Escape plan
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "115 ; 1.0");
		}
		case 609: //demo gardener
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "267 ; 1");
		}
		case 331: //fists of steel tank
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "128 ; 1.0 ; 206 ; 0.5 ; 205 ; 0.5 ; 772 ; 3.0 ; 236 ; 1.0 ; 109 ; 0.5");	// Override
		}
		case 228, 1085: //black box
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "741 ; 35");
		}
		case 355: //fan o war firing speed
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "6 ; 0.6 ; 218 ; 0");
		}
		case 1098: //classic extra headshot damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "392 ; 0.8 ; 390 ; 1.2 ; 128 ; 1.0");
		}
		case 460: // Enforcer better cloak regen
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "5 ; 1.2 ; 1 ; 0.9 ; 84 ; 1.2");
		}
		case 307: //caber is suicidal
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "207 ; 10.0 ; 2 ; 3.0");
		}
		case 354: //concheror increased movement speed
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "107 ; 1.15");
		}
		case 413: //solemn vow increased swing speed + uber on hit
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "396 ; 0.5 ; 17 ; 0.1");	// Override
		}
		case 450: //atomizer, like old winger (goomba stomps)
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "524 ; 1.25");
		}
		case 237: // Rocket jumper, less heals, less ammo
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "37 ; 0.3 ; 740 ; 0.5 ; 109 ; 0.5");
		}
		case 265: // Sticky jumper, less heals, less ammo
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "25 ; 0.3 ; 740 ; 0.5 ; 109 ; 0.5 ; 3 ; 0.25");
		}
		case 528: // Short Circuit bonus metal
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "80 ; 1.5");
		}
		case 1181: // Hot Hand dmg to burning
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "795 ; 2.0");
		}
		case 773: // PBPP firing speed + less damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "6 ; 0.6 ; 1 ; 0.75");
		}
		case 812, 833: // Cleaver perks on hit; extra primary ammo
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "737 ; 1.0 ; 741 ; 3 ; 37 ; 1.2");
		}
		case 1179:	// Thermal Thruster instaswitch + relaunch
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "199 ; 0.01 ; 547 ; 0.01 ; 872 ; 1.0");
		}
		case 224:	// Letranger
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "280 ; 5 ; 266 ; 1 ; 6 ; 0.6");	// Override
		}
		case 153, 466:	// Homewrecker/Maul help engis
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "94 ; 9001.0 ; 148 ; 9001.0 ; 421 ; 1.0 ; 80 ; 2.0");
		}
		case 61, 1006:	// Ambassador has old stats
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "868 ; 0.0");
		}
		case 589:	// Eurwonka effect
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "352 ; 0.0 ; 124 ; 1.0");
		}
		case 449:	// Winger + damage and air control
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "2 ; 1.3 ; 610 ; 1.25");
		}
		case 1180:	// Gas passer explode
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "875 ; 1.0");
		}
		case 348:	// SVF more afterburn damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "71 ; 2.0");
		}
		case 172:	// Scotsman's Skullcutter speed boost on hit
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "877 ; 1.0");
		}
		case 231:	// Danger Shield +50 hp
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "26 ; 50.0");
		}
		case 327:	// Claid increased charge time
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "202 ; 2.0 ; 128 ; 0.0");
		}
		case 60:	// Cloak and Dagger mirage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "84 ; 4.0 ; 729 ; 0.0");	// Override
		}
		case 39, 1081:	// Flare Gun
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "551 ; 1 ; 25 ; 0.5 ; 207 ; 1.66 ; 144 ; 1 ; 58 ; 3.0");
		}
		case 351:	// Detonator
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "551 ; 1 ; 25 ; 0.5 ; 207 ; 1.66 ; 144 ; 1 ; 58 ; 3.0 ; 1 ; 1.0");
		}
		case 740:	// Scorch Shot
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "551 ; 1 ; 25 ; 0.5 ; 207 ; 1.33 ; 416 ; 3 ; 58 ; 2.08 ; 59 ; 1.0");
		}
		case 221, 999:	// Holy Mackerel swing speed
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "6 ; 0.4 ; 1 ; 0.4");
		}
		case 356:	// Kunai
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "125 ; -65");
		}
		case 155:	// Southern Hospitality multiway tele
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "276 ; 1.0 ; 5 ; 1.25");
		}
		case 310:	// Warrior's Spirit regen hp over time, less max hp
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "490 ; 10 ; 16 ; 50 ; 128 ; 0.0");
		}
		case 426:	// Eviction Notice faster attack speed, no hp drain
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "6 ; 0.5 ; 855 ; 0.0");
		}
		case 317:	// Candy cane fast swing speed, no damage
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "6 ; 0.4 ; 1 ; 0.01");
		}
		case 447:	// Disciplinary action speed boost on hit
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "737 ; 1.0");
		}
		case 17, 204:	// Syringegun
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.03 ; 144 ; 1");
		}
		case 129, 1001: 	// Buff Banner
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "478 ; 1.25");
		}
		case 159, 433: // Dalokohs
		{
			hItemOverride = PrepareItemHandle(hItem, _, _, "801 ; 35.0");
		}
//		case 442: 	// Bison
//		{
//			hItemOverride = PrepareItemHandle(hItem, _, _, "103 ; 6.0");
//		}
	}

	if (hItemOverride != null)
	{
		delete hItem;
		hItem = view_as<Handle>(hItemOverride);
		return Plugin_Changed;
	}

	TFClassType iClass = TF2_GetPlayerClass(client);

	if (!strncmp(classname, "tf_weapon_rocketlauncher", 24, false) || !strncmp(classname, "tf_weapon_particle_cannon", 25, false))
	{
		switch (iItemDefinitionIndex)
		{
			case 127:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 179 ; 1.0");
			case 414:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 99 ; 1.25");
			case 1104:hItemOverride = PrepareItemHandle(hItem, _, _, "76 ; 1.25 ; 114 ; 1.0");
			case 730:	// Beggar's
				hItemOverride = PrepareItemHandle(hItem, _, _, "394 ; 0.1 ; 241 ; 1.3 ; 3 ; 0.75 ; 411 ; 5 ; 6 ; 0.2 ; 642 ; 1 ; 413 ; 1 ; 1 ; 0.7", true);	// Override
			default:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0");
		}
	}
	/*if (!strncmp(classname, "tf_weapon_sword", 15, false))
	{
		hItemOverride = PrepareItemHandle(hItem, _, _, "178 ; 0.8");
	}*/
	else if (!strncmp(classname, "tf_weapon_shotgun", 17, false) || !strncmp(classname, "tf_weapon_sentry_revenge", 24, false))
	{
		switch (iClass)
		{
			case TFClass_Soldier:
			hItemOverride = PrepareItemHandle(hItem, _, _, "135 ; 0.6 ; 114 ; 1.0");
			default:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0");
		}
		//hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0");
	}
	switch (iClass)
	{
		case TFClass_Engineer:
		{
			if (!strncmp(classname, "tf_weapon_wrench", 16, false) 
			|| !strncmp(classname, "tf_weapon_robot_arm", 19, false)
			|| !strcmp(classname, "saxxy", false))
			{
				if (iItemDefinitionIndex == 142)
					hItemOverride = PrepareItemHandle(hItem, _, _, "26 ; 55");
				else if (iItemDefinitionIndex == 169 && GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == -1)
				{}
				else hItemOverride = PrepareItemHandle(hItem, _, _, "26 ; 25");
			}
		}

		case TFClass_DemoMan:
		{
			if (!strncmp(classname, "tf_weapon_pipe", 14, false))
			{
				switch (iItemDefinitionIndex)
				{
					case 1150:	// Quickiebomb instant arm
						hItemOverride = PrepareItemHandle(hItem, _, _, "126 ; -1.0 ; 1 ; 0.5");
					case 130:	// Scottish Resistance firing speed
						hItemOverride = PrepareItemHandle(hItem, _, _, "6 ; 0.34");
					default:	// Stock Sticky Launcher
						hItemOverride = PrepareItemHandle(hItem, _, _, "178 ; 0.75");
				}
			}
			else if (!strncmp(classname, "tf_weapon_grenadelauncher", 25, false) || !strncmp(classname, "tf_weapon_cannon", 16, false))
			{
				switch (iItemDefinitionIndex)
				{
					// loch n load
					case 308:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 208 ; 1.0");
					default:hItemOverride = PrepareItemHandle(hItem, _, _, "114 ; 1.0 ; 128 ; 1");
				}
			}
			else if (!strncmp(classname, "tf_wearable_demoshield", 22, false))
			{
				switch (iItemDefinitionIndex)
				{
					case 1099:{}
					case 406:	// Splendid screen whack damage
						hItemOverride = PrepareItemHandle(hItem, _, _, "2 ; 4.0");
					default:	// Targe lots of buffs
						hItemOverride = PrepareItemHandle(hItem, _, _, "62 ; 0.34 ; 64 ; 0.34 ; 66 ; 0.34 ; 135 ; 0.8");
				}
			}
		}
		case TFClass_Heavy:
		{
			if (!strncmp(classname, "tf_weapon_minigun", 17, false))
			{
				switch (iItemDefinitionIndex)
				{
					case 41: // Natascha
						hItemOverride = PrepareItemHandle(hItem, _, _, "87 ; 0.5 ; 280 ; 2 ; 2 ; 1.5 ; 642 ; 1 ; 411 ; 4 ; 181 ; 2.0 ; 58 ; 2.0");	// Override
					case 811, 832: //huo long heater bonus damage vs burning players
						hItemOverride = PrepareItemHandle(hItem, _, _, "795 ; 1.50 ; 75 ; 2.09");
					default:
						hItemOverride = PrepareItemHandle(hItem, _, _, "75 ; 2.09");
				}
			}
		}
		case TFClass_Scout:
		{
			if (!strncmp(classname, "tf_weapon_pistol", 16, false))
				hItemOverride = PrepareItemHandle(hItem, _, _, "106 ; 0.5");
		}
		case TFClass_Medic:
		{
			if (!strncmp(classname, "tf_weapon_medigun", 17, false))
			{
				switch (iItemDefinitionIndex)
				{
					case 998:hItemOverride = PrepareItemHandle(hItem, _, _, "499 ; 2.0 ; 178 ; 0.75 ; 75");
					case 411:{}//hItemOverride = PrepareItemHandle(hItem, _, _, "178 ; 0.75 ; 10 ; 2.0");
					default:hItemOverride = PrepareItemHandle(hItem, _, _, "10 ; 1.25 ; 178 ; 0.75 ; 18 ; 0");
				}
			}
		}
	}

	if (hItemOverride != null)
	{
		delete hItem;
		hItem = view_as<Handle>(hItemOverride);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void ManageFighterThink(const BaseBoss fighter)
{
	int i = fighter.index;
	char wepclassname[64];
	int buttons = GetClientButtons(i);
	SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
	if (!IsPlayerAlive(i))
	{
		BaseBoss player;
		int obstarget = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
		player = BaseBoss(obstarget);
		if (obstarget != i && IsClientValid(obstarget) && player.iType == -1)
		{
			if (!(buttons & IN_SCORE))
				ShowSyncHudText(i, rageHUD, "Damage: %d - %N's Damage: %d", fighter.iDamage, obstarget, player.iDamage);
		}
		else if (!(buttons & IN_SCORE))
			ShowSyncHudText(i, rageHUD, "Damage: %d", fighter.iDamage);

		Call_OnFighterDeadThink(fighter);
		return;
	}

	if (fighter.bIsMinion)
		return;

	if (!(buttons & IN_SCORE))
		ShowSyncHudText(i, rageHUD, "Damage: %d", fighter.iDamage);

	Call_OnRedPlayerThink(fighter);
	TFClassType TFClass = TF2_GetPlayerClass(i);
	int weapon = GetActiveWep(i);
	if (weapon <= MaxClients || !IsValidEntity(weapon) || !GetEntityClassname(weapon, wepclassname, sizeof(wepclassname)))
		wepclassname[0] = '\0';

	bool validwep = (!strncmp(wepclassname, "tf_wea", 6, false));
	int index = GetItemIndex(weapon);

	switch (TFClass)
	{
		// Chdata's Deadringer Notifier
		case TFClass_Spy:
		{
			if (GetClientCloakIndex(i) == 59)
			{
				int drstatus = TF2_IsPlayerInCondition(i, TFCond_Cloaked) ? 2 : GetEntProp(i, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
				char s[32];
				switch (drstatus)
				{
					case 1:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Feign-Death Ready");
					}
					case 2:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Dead-Ringered");
					}
					default:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Inactive");
					}
				}
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "%s", s);
			}
		}
		case TFClass_Medic:
		{
			int medigun = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);

			if (validwep && weapon == medigun && HasEntProp(medigun, Prop_Send, "m_bChargeRelease"))
			{
				SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
				int charge = RoundToFloor(GetMediCharge(medigun) * 100.0);
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "Ubercharge: %i", charge);

				switch (GetItemIndex(medigun))
				{
					case 411:	// Quickfix
					{
						if (GetEntProp(medigun, Prop_Send, "m_bHealing"))
						{
							int target = GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
							if (0 < target <= MaxClients)
								TF2_AddCondition(target, TFCond_DefenseBuffNoCritBlock, 0.2, i);
							if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
								TF2_AddCondition(i, TFCond_DefenseBuffNoCritBlock, 0.2, i);
						}
					}
					case 35:
					{
						if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease") && GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") > 0.0 && 
							!(gamemode.iSpecialRound & ROUND_HVH))
							TF2_AddCondition(i, TFCond_Ubercharged, 1.0);
					}
					default:
					{
						if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease") && GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") > 0.0)
							TF2_AddCondition(i, TFCond_Ubercharged, 1.0); //Fixes Ubercharges ending prematurely on Medics.
					}
				}
			}
		}
		case TFClass_Soldier:
		{
			if (GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary) == 1104)
			{
				SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "Air Strike Damage: %i", fighter.iAirDamage);
			}
			int wep = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			if (wep > MaxClients && GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex") == 442)
				SetEntPropFloat(wep, Prop_Send, "m_flEnergy", 20.0);
		}
		case TFClass_Pyro:
		{
			int idx = GetIndexOfWeaponSlot(i, TFWeaponSlot_Melee);
			if (idx == 153 || idx == 466)
			{
				SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "Metal: %i", GetEntProp(i, Prop_Send, "m_iAmmo", _, 3));
			}
		}
		case TFClass_DemoMan:
		{
			int wep = GetPlayerWeaponSlot(i, TFWeaponSlot_Melee);
			if (wep > MaxClients)
			{
				char cls[32]; GetEntityClassname(wep, cls, sizeof(cls));
				if (!strncmp(cls, "tf_weapon_sword", 15, false))
				{
					switch (GetItemIndex(wep))
					{
						case 172, 327, 404:{}
						default:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
							if (!(buttons & IN_SCORE))
							{
								int heads = GetEntProp(i, Prop_Send, "m_iDecapitations");
								if (heads > 16)
									heads = 16;
								ShowSyncHudText(i, jumpHUD, "Speed Boost: %.0f%%", RoundToCeil(SquareRoot(float(heads)) * 8.0) / 0.32);
							}
						}
					}
				}
			}
		}
	}

	if (TF2_IsPlayerInCondition(i, TFCond_InHealRadius))
		TF2_AddCondition(i, TFCond_DefenseBuffNoCritBlock, 0.2);

	if (gamemode.iSpecialRound & ROUND_HVH)
		return;

	int living = GetLivingPlayers(gamemode.iOtherTeam);
	if (living == 1 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked))
	{
		TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
		int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
		if (TFClass == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
			SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
		TF2_AddCondition(i, TFCond_Buffed, 0.2);
		return;
	}
	else if (living == 2 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked))
		TF2_AddCondition(i, TFCond_Buffed, 0.2);

	/* THIS section really needs cleaning! */
	TFCond cond = TFCond_CritOnWin;
	if (TF2_IsPlayerInCondition(i, TFCond_CritCola) && (TFClass == TFClass_Scout || TFClass == TFClass_Heavy))
	{
		TF2_AddCondition(i, cond, 0.2);
		return;
	}

	bool addthecrit = false;
	bool addmini = false;
	int healers = GetEntProp(i, Prop_Send, "m_nNumHealers");
	int healer;
	for (int u = 0; u < healers; ++u)
	{
		healer = GetHealerByIndex(i, u);
		if (0 < healer <= MaxClients)
		{
			addmini = true;
//			int medigun = GetPlayerWeaponSlot(healer, TFWeaponSlot_Secondary);
//			if (medigun > MaxClients && HasEntProp(medigun, Prop_Send, "m_bChargeRelease") && GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
//			{
//				// Add blast resist
//			}
			break;
		}
	}
	if (validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
	{
		//slightly longer check but makes sure that any weapon that can backstab will !crit (e.g. Saxxy)
		if (strcmp(wepclassname, "tf_weapon_knife", false))
			addthecrit = true;
	}
	if (validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary)) // Primary weapon crit list
	{
		if (StrStarts(wepclassname, "tf_weapon_compound_bow") ||  // Sniper bows
			StrStarts(wepclassname, "tf_weapon_crossbow") ||  // Medic crossbows
			StrEqual(wepclassname, "tf_weapon_shotgun_building_rescue") ||  // Engineer Rescue Ranger
			StrEqual(wepclassname, "tf_weapon_drg_pomson")) // Engineer Pomson
		{
			addthecrit = true;
		}
	}
	if (validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)) // Secondary weapon crit list
	{
		if (StrStarts(wepclassname, "tf_weapon_pistol") ||  // Engineer/Scout pistols
			StrStarts(wepclassname, "tf_weapon_handgun_scout_secondary") ||  // Scout pistols
			StrStarts(wepclassname, "tf_weapon_raygun") ||  //Bison
			StrStarts(wepclassname, "tf_weapon_flaregun") ||  // Flare guns
			StrEqual(wepclassname, "tf_weapon_smg")) // Sniper SMGs minus Cleaner's Carbine
		{
			if (TFClass == TFClass_Scout && cond == TFCond_CritOnWin)
				cond = TFCond_Buffed;
			int PrimaryIndex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
			if ((TFClass == TFClass_Pyro && PrimaryIndex == 594) || FindPlayerBack(i, { 642, 231 }, 2) != -1) // No crits if using Phlogistinator or Cozy Camper
				addthecrit = false;
			else addthecrit = true;
		}
		if (StrStarts(wepclassname, "tf_weapon_jar") ||  // Jarate/Milk
			StrEqual(wepclassname, "tf_weapon_cleaver")) // Flying Guillotine
		addthecrit = true;
	}
	switch (index) //Specific weapon crit list
	{
		/*case :
		{
			addthecrit = true;
		}*/
		case 997: //Rescue Ranger
		{
			addthecrit = true;
		}
		case 656: //Holiday Punch
		{
			addthecrit = true;
			cond = TFCond_Buffed;
		}
		case 416: //Market Gardener
		{
			addthecrit = false;
		}
		case 307: //caber
		{
			addthecrit = true;
		}
		case 609: //scottish handshake
		{
			addthecrit = false;
		}
		case 413: //solemn vow
		{
			addthecrit = false;
		}
		case 23:
		{
			if (TFClass == TFClass_Spy)
				addthecrit = false;
			else cond = TFCond_Buffed;
		}
		case 450: //atomizer
		{
			addthecrit = false;
		}
		case 740:
		{
			addthecrit = true;
			cond = TFCond_Buffed;
		}
	}
	
	// if (TFClass == TFClass_DemoMan && !IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)))
	if(TFClass == TFClass_DemoMan && cvarVSH2[DemoShieldCrits].IntValue && validwep && weapon != GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
	{
		float flShieldMeter = GetEntPropFloat(i, Prop_Send, "m_flChargeMeter");

		if(cvarVSH2[DemoShieldCrits].IntValue >= 1)
		{
			addthecrit = true;
			if(cvarVSH2[DemoShieldCrits].IntValue == 1 || (cvarVSH2[DemoShieldCrits].IntValue == 3 && flShieldMeter < 100.0))
				cond = TFCond_Buffed;
			if(cvarVSH2[DemoShieldCrits].IntValue == 3 && (flShieldMeter < 35.0 || !GetEntProp(i, Prop_Send, "m_bShieldEquipped")))
				addthecrit = false;
		}
	}
	
	if (addthecrit)
	{
		TF2_AddCondition(i, cond, 0.2);
		if (addmini && cond != TFCond_Buffed)
			TF2_AddCondition(i, TFCond_Buffed, 0.2);
	}
	if (TFClass == TFClass_Spy && validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary))
	{
		if (!TF2_IsPlayerCritBuffed(i)
			&& !TF2_IsPlayerInCondition(i, TFCond_Buffed)
			&& !TF2_IsPlayerInCondition(i, TFCond_Cloaked)
			&& !TF2_IsPlayerInCondition(i, TFCond_Disguised)
			&& !GetEntProp(i, Prop_Send, "m_bFeignDeathReady"))
		{
			TF2_AddCondition(i, TFCond_CritCola, 0.2);
		}
	}
	if (TFClass == TFClass_Engineer
		&& weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary)
		&& StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
	{
		int sentry = FindSentry(i);
		if (IsValidEntity(sentry))
		{
			int enemy = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
			if (0 < enemy <= MaxClients && GetClientTeam(enemy) == 3)
			{  // Trying to target minions as well
				SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
				TF2_AddCondition(i, TFCond_Kritzkrieged, 0.2);
			}
			else
			{
				if (GetEntProp(i, Prop_Send, "m_iRevengeCrits"))
					SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
				else if (TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(i, TFCond_Healing))
					TF2_RemoveCondition(i, TFCond_Kritzkrieged);
			}
		}
	}
}

public void _RespawnPlayer(const int userid) // too many temp funcs just to call as a timer. No wonder sourcepawn needs lambda funcs...
{
	TF2_RespawnPlayer(GetClientOfUserId(userid));
}
