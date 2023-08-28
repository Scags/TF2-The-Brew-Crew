#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>
#include <morecolors>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Tank", 
	author = "Scag", 
	description = "VSH2 boss Tank", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;
bool IsTank[34];

public void OnPluginStart()
{
	RegAdminCmd("sm_betank", CmdBeTank, ADMFLAG_VOTE);
	AddCommandListener(OnRobot, "sm_robot");
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_tank");
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
		VSH2_Hook(OnTouchPlayer, fwdOnTouchPlayer);
		VSH2_Hook(OnTouchBuilding, fwdOnTouchBuilding);
		VSH2_Hook(OnVariablesReset, fwdOnVariablesReset);
		VSH2_Hook(OnBossTakeDamage, fwdOnBossTakeDamage);
		VSH2_Hook(OnBossDealDamage, fwdOnBossDealDamage);
		VSH2_Hook(OnPlayerAirblasted, fwdOnPlayerAirblasted);
		VSH2_Hook(OnRedPlayerThink, fwdOnRedPlayerThink);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define TankModel			"models/custom/tanks/panzer2.mdl" //thx to Friagram for saving teh day!
#define TankModelPrefix			"models/custom/tanks/panzer"

#define TankShoot			"acvshtank/fire"
#define TankDeath			"acvshtank/dead"
#define TankSpawn			"acvshtank/spawn"
#define TankReload			"acvshtank/reload.mp3"
#define TankCrush			"acvshtank/vehicle_hit_person.mp3"
#define TankMove			"acvshtank/tankdrive.mp3"
#define TankIdle			"acvshtank/tankidle.mp3"

#define ROCKET_DMG				75.0
#define TANK_ACCELERATION		7.0
#define TANK_SPEEDMAX			260.0
#define TANK_SPEEDMAXREVERSE		240.0
#define TANK_INITSPEED			180.0
#define SMG_DAMAGE_MULT			1.0

#define TankTheme1 		"saxton_hale/tanktheme1.mp3"
#define TankTheme2 		"saxton_hale/tanktheme2.mp3"

char VehicleHorns[][] = {
	"acvshtank/awooga.mp3",
	"acvshtank/dukesofhazzard.mp3",
	"acvshtank/lacucaracha.mp3",
	"acvshtank/twohonks.mp3"
};

public Action CmdBeTank(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	VSH2Player player = VSH2Player(client);
	if (!args)
	{
		if (!IsTank[player.index])
		{
			IsTank[player.index] = true;
			player.iHealth = 1000;
			if (!IsPlayerAlive(client))
				TF2_RespawnPlayer(client);

			fwdOnBossModelTimer(player);
			fwdOnBossEquipped(player);
		}
		else
		{
			IsTank[player.index] = false;

			if (IsPlayerAlive(client))
			{
				player.PreEquip();
				TF2_RegeneratePlayer(client);
				Handle vsh2 = VSH2_Self();
				Call_StartFunction(vsh2, GetFunctionByName(vsh2, "PrepPlayers"));
				Call_PushCell(player);
				Call_Finish();
			}
			player.SetOverlay("0");
			StopSound(client, SNDCHAN_AUTO, TankIdle);
			StopSound(client, SNDCHAN_AUTO, TankMove);
		}

		CPrintToChat(client, "{orange}[VSH 2]{default} Tank mode %sabled.", IsTank[player.index] ? "en" : "dis");
		return Plugin_Handled;
	}

	if (args <= 1)
	{
		CPrintToChat(client, "{orange}[VSH 2]{default} Usage: /betank <user> <1/0> OR /betank");
		return Plugin_Handled;
	}

	char arg1[32]; GetCmdArg(1, arg1, sizeof(arg1));
	char arg2[4]; GetCmdArg(2, arg2, sizeof(arg2));
	bool tanked = !!StringToInt(arg2);

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
		arg1,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; ++i)
	{
		if (!IsClientInGame(target_list[i]))
			continue;

		player = VSH2Player(target_list[i]);
		if (tanked)
		{
			if (player.bIsBoss)
			{
				player.MakeBossAndSwitch(ThisPluginIndex, false);
				continue;
			}

			if (!IsPlayerAlive(target_list[i]))
				TF2_RespawnPlayer(target_list[i]);

			player.iHealth = 1000;
			fwdOnBossModelTimer(player);
			fwdOnBossEquipped(player);
			CPrintToChat(target_list[i], "{orange}[VSH 2]{default} An admin turned you into a tank!");
			IsTank[player.index] = true;
		}
		else if (!player.bIsBoss)
		{
			if (IsPlayerAlive(target_list[i]))
			{
				player.PreEquip();
				TF2_RegeneratePlayer(target_list[i]);

				Handle vsh2 = VSH2_Self();
				Call_StartFunction(vsh2, GetFunctionByName(vsh2, "PrepPlayers"));
				Call_PushCell(player);
				Call_Finish();
			}

			IsTank[player.index] = false;
			player.SetOverlay("0");
			StopSound(target_list[i], SNDCHAN_AUTO, TankIdle);
			StopSound(target_list[i], SNDCHAN_AUTO, TankMove);
			CPrintToChat(target_list[i], "{orange}[VSH 2]{default} An admin has removed your tank status!");
		}
	}
	return Plugin_Handled;
}

public Action OnRobot(int client, const char[] command, int args)
{
	VSH2Player player = VSH2Player(client);
	if (player.iType == ThisPluginIndex)
		return Plugin_Handled;
	return Plugin_Continue;
}


public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;

	PrepareModel(TankModel);

	PrepareMaterial("materials/models/custom/tanks/panzer");
	PrepareMaterial("materials/models/custom/tanks/panzer_blue");
	PrepareMaterial("materials/models/custom/tanks/panzer_track");
	PrepareMaterial("materials/models/custom/tanks/pziv_ausfg");
	PrepareMaterial("materials/models/custom/tanks/pziv_ausfg_nm");
	PrepareMaterial("materials/models/custom/tanks/pziv_ausfg_red");
	PrepareMaterial("materials/models/custom/tanks/hummel_track");
	PrepareMaterial("materials/models/custom/tanks/hummel_track_nm");
	
	for (i = 1; i <= 5; ++i) {
		if (i < 3) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankDeath, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}

		if (i <= 3)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankShoot, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);

//			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankSpawn, i);
//			PrecacheSound(s, true);
//			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
//			AddFileToDownloadsTable(s);			
		}
		Format(s, PLATFORM_MAX_PATH, "weapons/fx/rics/ric%i.wav", i);
		PrecacheSound(s);
	}
	PrepareSound(TankReload);
	PrepareSound(TankCrush);
	PrepareSound(TankMove);
	PrepareSound(TankIdle);

	PrecacheGeneric("fireSmoke_collumn_mvmAcres");
	PrecacheSound("misc/doomsday_missile_explosion.wav", true);
	PrecacheSound("mvm/ambient_mp3/mvm_siren.mp3", true);
	PrecacheSound("mvm/mvm_tank_horn.wav", true);

	PrepareSound(TankTheme1);
	PrepareSound(TankTheme2);

	DownloadSoundList(VehicleHorns, sizeof(VehicleHorns));
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("The Military Tank:\nSMG/Missile: Left-Click to shoot bullets, right-click to shoot rockets.\nWall Walking: Walk to and look at walls to climb them.\nRage (Nuke): Call for medic (e) when Rage is full.\nYour next rocket is a nuke!\nMouse 3: Awooga!");
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
	if (Player.iType != ThisPluginIndex && !IsTank[Player.index])
		return;

	int player = Player.index;

	int wep = GetPlayerWeaponSlot(player, TFWeaponSlot_Secondary);
	if (wep != -1)
		SetWeaponAmmo(wep, 255);

	int buttons = GetClientButtons(player);
	float vell[3];	GetEntPropVector(player, Prop_Data, "m_vecAbsVelocity", vell);
	float currtime = GetGameTime();

	if (Player.flGlowtime > 0.0) {
		Player.bGlow = 1;
		Player.flGlowtime -= 0.1;
	}
	else if (Player.flGlowtime <= 0.0)
		Player.bGlow = 0;

	if ( (buttons & IN_FORWARD) && vell[0] != 0.0 && vell[1] != 0.0 )
	{
		StopSound(player, SNDCHAN_AUTO, TankIdle);

		Player.flSpeed += TANK_ACCELERATION; /*simulates vehicular physics; not as good as Valve does with vehicle entities though*/
		if (Player.flSpeed > TANK_SPEEDMAX)
			Player.flSpeed = TANK_SPEEDMAX;

		if (Player.flSpecial != 0.0)
			Player.flSpecial = 0.0;
		if ( Player.flLastShot < currtime ) {
			//strcopy(snd, PLATFORM_MAX_PATH, TankMove);
			EmitSoundToAll(TankMove, player, SNDCHAN_AUTO);
			Player.flLastShot = currtime+31.0;
		}
	}
	else if ( (buttons & IN_BACK) && vell[0] != 0.0 && vell[1] != 0.0 )
	{
		StopSound(player, SNDCHAN_AUTO, TankIdle);

		Player.flSpeed += TANK_ACCELERATION;
		if (Player.flSpeed > TANK_SPEEDMAXREVERSE)
			Player.flSpeed = TANK_SPEEDMAXREVERSE;
		
		if (Player.flSpecial != 0.0)
			Player.flSpecial = 0.0;
		if ( Player.flLastShot < currtime ) {
			//strcopy(snd, PLATFORM_MAX_PATH, TankMove);
			EmitSoundToAll(TankMove, player, SNDCHAN_AUTO);
			Player.flLastShot = currtime+31.0;
		}
	}
	else {
		StopSound(player, SNDCHAN_AUTO, TankMove);

		if (Player.flLastShot != 0.0)
			Player.flLastShot = 0.0;
		if ( Player.flSpecial < currtime ) {
			//strcopy(snd, PLATFORM_MAX_PATH, TankIdle);
			EmitSoundToAll(TankIdle, player, SNDCHAN_AUTO);
			Player.flSpecial = currtime+5.0;
		}
		Player.flSpeed -= TANK_ACCELERATION;
		if (Player.flSpeed < TANK_INITSPEED)
			Player.flSpeed = TANK_INITSPEED;
	}

	SetEntPropFloat(player, Prop_Send, "m_flMaxspeed", Player.flSpeed);

	if ( GetEntityFlags(player) & FL_ONGROUND )
		Player.flWeighDown = 0.0;
	else Player.flWeighDown += 0.1;

	if (OnlyScoutsAndSpiesLeft(Player.iOtherTeam) && Player.iDifficulty <= 2)
		Player.flRAGE += 0.25;

	if ( (buttons & IN_DUCK) && Player.flWeighDown >= 10.0 && Player.iDifficulty <= 3)
	{
		float ang[3]; GetClientEyeAngles(player, ang);
		if ( ang[0] > 60.0 ) {
			//float fVelocity[3];
			//GetEntPropVector(player, Prop_Data, "m_vecVelocity", fVelocity);
			//fVelocity[2] = -500.0;
			//TeleportEntity(player, NULL_VECTOR, NULL_VECTOR, fVelocity);
			SetEntityGravity(player, 6.0);
			SetPawnTimer(SetGravityNormal, 1.0, Player.userid);
			Player.flWeighDown = 0.0;
		}
	}

	if (!IsTank[player])
	{
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);

		if (Player.bUsedUltimate)
			ShowSyncHudText(player, VSH2_BossHud(), "Rage: USED - shoot a rocket (MOUSE2) to activate\nWalk on walls | M2 to fire rockets");
		else if (Player.flRAGE < 100.0)
			ShowSyncHudText(player, VSH2_BossHud(), "Rage: %0.1f\nWalk on walls | M2 to fire rockets", Player.flRAGE);
		else ShowSyncHudText(player, VSH2_BossHud(), "Rage: FULL - Call Medic (default: E) to activate\nWalk on walls | M2 to fire rockets");
	}

	if (buttons & IN_FORWARD)
	{
		float ang[3]; GetClientEyeAngles(player, ang);
		float origin[3]; GetClientAbsOrigin(player, origin);
		ang[0] = 0.0;
		origin[2] += 16.0;

		TR_TraceRayFilter(origin, ang, MASK_ALL, RayType_Infinite, WorldOnly);
		if (TR_DidHit())
		{
//			char classname[32];
//			int TRIndex = TR_GetEntityIndex();
//			GetEdictClassname(TRIndex, classname, sizeof(classname));
//			if (StrEqual(classname, "worldspawn") || !strncmp(classname, "prop_", 5))
//			{
			TR_GetEndPosition(ang);
			if (GetVectorDistance(ang, origin) < 50.0)
			{
				TR_GetPlaneNormal(null, ang);
				GetVectorAngles(ang, ang);

				if (-45.0 < ang[0] < 45.0)
				{
					GetEntPropVector(player, Prop_Data, "m_vecVelocity", ang);
					ang[2] = 300.0;
					TeleportEntity(player, NULL_VECTOR, NULL_VECTOR, ang);
				}
			}
		}
	}
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex && !IsTank[Player.index])
		return;

	SetVariantString(TankModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex && !IsTank[Player.index])
		return;

	Player.PreEquip();
    
	SetEntProp(Player.index, Prop_Send, "m_bForcedSkin", 1);
	SetEntProp(Player.index, Prop_Send, "m_nForcedSkin", 1);
	char attribs[256];
	Format(attribs, sizeof(attribs), "6 ; 0.6 ; 326 ; 0.0 ; 252 ; 0.0 ; 66 ; 0.67 ; 25 ; 0.0 ; 53 ; 1 ; 59 ; 0.0 ; 60 ; 0.8 ; 65 ; 1.4 ; 62 ; 0.34 ; 4 ; 4.0 ; 214 ; %d", GetRandomInt(999, 9999));

	int Turret = Player.SpawnWeapon("tf_weapon_smg", 16, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", Turret);
	SetWeaponAmmo(Turret, 256);
	Player.SetOverlay( "effects/combine_binocoverlay" );
	Player.flLastShot = 0.0;
	Player.flSpecial = 0.0;
	Player.iSpecial = false;
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Pyro, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		EmitSoundToAll("mvm/mvm_tank_horn.wav");
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	int client = player.index;
	TF2_AddCondition(client, view_as<TFCond>(42), 4.0);
	if ( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}
	player.bUsedUltimate = true;
	EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3");
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(0, 1))
	{
		case 0:
		{
			strcopy(song, sizeof(song), TankTheme1);
			time = 125.0;
		}
		case 1:
		{
			strcopy(song, sizeof(song), TankTheme2);
			time = 141.0;
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "The Military Tank");
}
public void fwdOnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	if (!IsPlayerAlive(Attacker.index))
		return;

	if (Victim.index == Attacker.index)
		return;

	int dmgbits = event.GetInt("damagebits");
	if (dmgbits & (DMG_ALWAYSGIB))
	{
		event.SetString("weapon", "purgatory");
		event.SetInt("customkill", TF_WEAPON_ROCKETLAUNCHER);
	}
	else if (dmgbits & DMG_VEHICLE) {
		event.SetString("weapon_logclassname", "vehicle_crush");
		event.SetString("weapon", "mantreads");
		//event.SetInt("customkill", TF_CUSTOM_TRIGGER_HURT);
		//event.SetInt("playerpenetratecount", 0);

		char s[PLATFORM_MAX_PATH];
		strcopy(s, PLATFORM_MAX_PATH, TankCrush);
		EmitSoundToAll(s);
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex && !IsTank[Player.index])
		return;

	StopSound(Player.index, SNDCHAN_AUTO, TankIdle);
	StopSound(Player.index, SNDCHAN_AUTO, TankMove);
	Player.SetOverlay("0");
	Player.flLastShot = 0.0;
	Player.flSpecial = 0.0;
	Player.flSpecial2 = 0.0;
	Player.iSpecial = false;

	AttachParticle(Player.index, "buildingdamage_dispenser_fire1", 1.0);
	if (IsTank[Player.index])
	{
		IsTank[Player.index] = false;
		return;
	}

	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", TankDeath, GetRandomInt(1, 2)); // Sounds from Call of Duty 1
	EmitSoundToAll(snd);
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	strcopy(s, sizeof(s), VehicleHorns[GetRandomInt(0, sizeof(VehicleHorns)-1)]);
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "The Military Tank");
}
public Action fwdOnBossTakeDamage(const VSH2Player victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (victim.iType == ThisPluginIndex)
	{
		if (victim.index == attacker) {	// vehicles shouldn't be able to hurt themselves
			damage *= 0.0;
		}

		else if( damagetype & (DMG_BULLET|DMG_CLUB|DMG_SLASH) )
		{
			TE_SetupArmorRicochet(damagePosition, NULL_VECTOR);
			TE_SendToAll();
			char sound[PLATFORM_MAX_PATH]; Format( sound, PLATFORM_MAX_PATH, "weapons/fx/rics/ric%i.wav", GetRandomInt(1, 5) );
			EmitSoundToAll(sound, victim.index); EmitSoundToAll(sound, victim.index);
		}

		damagetype |= DMG_PREVENT_PHYSICS_FORCE;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void fwdOnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if (airblasted.iType != ThisPluginIndex)
		return;

	float Vel[3];
	TeleportEntity(airblasted.index, NULL_VECTOR, NULL_VECTOR, Vel); // Stops knockback
	TF2_RemoveCondition(airblasted.index, TFCond_Dazed); // Stops slowdown
	SetEntPropVector(airblasted.index, Prop_Send, "m_vecPunchAngle", Vel);
	SetEntPropVector(airblasted.index, Prop_Send, "m_vecPunchAngleVel", Vel); // Stops screen shake
}

public Action fwdOnBossDealDamage(const VSH2Player victim, int & attacker, int & inflictor, float & damage, int & damagetype, int & weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player fighter = VSH2Player(attacker);
	if (fighter.iType == ThisPluginIndex && (damagetype & DMG_BLAST))
	{
		if (inflictor > MaxClients && GetEntPropFloat(inflictor, Prop_Send, "m_flModelScale") >= 1.2)
		{
			TF2_MakeBleed(victim.index, attacker, 20.0 * (damage / ROCKET_DMG));
			TF2_AddCondition(victim.index, TFCond_MarkedForDeath, 20.0 * (damage / ROCKET_DMG), attacker);
		}
		TF2_AddCondition(victim.index, TFCond_LostFooting, 1.5, attacker);
	}
	return Plugin_Continue;
}
public Action RunCmd(VSH2Player base, int &buttons, float angles[3], float vel[3])
{
	Action action = Plugin_Continue;
	int player = base.index;

	int vehflags = GetEntityFlags(player);
	if( (buttons & IN_MOVELEFT) && (vehflags & FL_ONGROUND) ) {
		buttons &= ~IN_MOVELEFT;
		vel[1] = 1.0;
		action = Plugin_Changed;
	}
	if( (buttons & IN_MOVERIGHT) && (vehflags & FL_ONGROUND) ) {
		buttons &= ~IN_MOVERIGHT;
		vel[1] = 1.0;
		action = Plugin_Changed;
	}
	
	// novelty horn honking! It's the small details that really add to a mod :)
	if( (buttons & IN_ATTACK3) ) {
		if (!base.iSpecial) {
			base.iSpecial = true;
			EmitSoundToAll(VehicleHorns[GetRandomInt(0, sizeof(VehicleHorns)-1)], player);
			SetPawnTimer(_ResetHorn, 4.0, base);
		}
	}

	// Vehicles shouldn't be able to duck
	if( (buttons & IN_DUCK) && (vehflags & FL_ONGROUND) ) {
		buttons &= ~IN_DUCK;
		action = Plugin_Changed;
	}

	if( (buttons & IN_ATTACK2) )
	{
		float currtime = GetGameTime();
		if (base.flSpecial2 < currtime)
		{
			base.flSpecial2 = currtime+4.0;
			float vPosition[3], vAngles[3], vVec[3];
			GetClientEyePosition(player, vPosition);
			GetClientEyeAngles(player, vAngles);

			vVec[0] = Cosine( DegToRad(vAngles[1]) ) * Cosine( DegToRad(vAngles[0]) );
			vVec[1] = Sine( DegToRad(vAngles[1]) ) * Cosine( DegToRad(vAngles[0]) );
			vVec[2] = -Sine( DegToRad(vAngles[0]) );

			vPosition[0] += vVec[0] * 50.0;
			vPosition[1] += vVec[1] * 50.0;
			vPosition[2] += vVec[2] * 50.0;
			bool crit = ( TF2_IsPlayerInCondition(player, TFCond_Kritzkrieged) || TF2_IsPlayerInCondition(player, TFCond_CritOnWin) );
			TE_SetupMuzzleFlash(vPosition, vAngles, 9.0, 1);
			TE_SendToAll();
			if (base.bUsedUltimate)
			{
				int nuke = ShootRocket(player, false, vPosition, vAngles, 3000.0, ROCKET_DMG, "");
				RequestFrame(HookRocket, EntIndexToEntRef(nuke));
				base.flRAGE = 0.0;
				base.bUsedUltimate = false;
			}
			else ShootRocket(player, crit, vPosition, vAngles, 4000.0, ROCKET_DMG, "");
			char snd[PLATFORM_MAX_PATH];
			Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", TankShoot, GetRandomInt(1, 3)); //sounds from Call of duty 1
			EmitSoundToAll(snd, player, SNDCHAN_AUTO);
			CreateTimer(1.0, Timer_ReloadTank, base.userid, TIMER_FLAG_NO_MAPCHANGE); //useless, only plays a 'reload' sound
			
			float PunchVec[3] = {100.0, 0.0, 90.0};
			SetEntPropVector(player, Prop_Send, "m_vecPunchAngleVel", PunchVec);
		}
	}
	return action;
}
public void fwdOnTouchPlayer(VSH2Player victim, VSH2Player base)
{
	if (base.iType != ThisPluginIndex && !IsTank[base.index])
		return;

	if( GetEntPropEnt(victim.index, Prop_Send, "m_hGroundEntity") == base.index ) // If human/vehicle on vehicle, ignore.
		return;

	if( GetEntPropEnt(base.index, Prop_Send, "m_hGroundEntity") == victim.index ) // Vehicle is standing on player, kill them!
		SDKHooks_TakeDamage(victim.index, base.index, base.index, 50.0, DMG_VEHICLE);

	//int buttons = GetClientButtons(base.index);

	float vecShoveDir[3];	GetEntPropVector(base.index, Prop_Data, "m_vecAbsVelocity", vecShoveDir);
	if( vecShoveDir[0] != 0.0 && vecShoveDir[1] != 0.0 ) {
		float entitypos[3];	GetEntPropVector(base.index, Prop_Data, "m_vecAbsOrigin", entitypos);
		float targetpos[3];	GetEntPropVector(victim.index, Prop_Data, "m_vecAbsOrigin", targetpos);

		float vecTargetDir[3];
		vecTargetDir = Vec_SubtractVectors(entitypos, targetpos);

		vecShoveDir = Vec_NormalizeVector(vecShoveDir);
		vecTargetDir = Vec_NormalizeVector(vecTargetDir);
		
		if( GetVectorDotProduct(vecShoveDir, vecTargetDir) <= 0 )
			SDKHooks_TakeDamage(victim.index, base.index, base.index, 10.0, DMG_VEHICLE);
	}
}
public void fwdOnTouchBuilding(const VSH2Player base, int building)
{
	if (base.iType == ThisPluginIndex && !IsTank[base.index])
		SDKHooks_TakeDamage( building, base.index, base.index, 5.0, DMG_VEHICLE);
}
public void fwdOnVariablesReset(const VSH2Player base)
{
	IsTank[base.index] = false;
	StopSound(base.index, SNDCHAN_AUTO, TankIdle);
	StopSound(base.index, SNDCHAN_AUTO, TankMove);
}
public void fwdOnRedPlayerThink(const VSH2Player player)
{
	if (IsTank[player.index])
		fwdOnBossThink(player);
}

public void TF2_OnConditionAdded(int client, TFCond cond)
{
	if (VSH2Player(client).iType == ThisPluginIndex)
	{
		switch( cond )
		{
			case TFCond_Bleeding, TFCond_OnFire, TFCond_Jarated:
			{	/* vehicles shouldn't bleed or be flammable */
				TF2_RemoveCondition(client, cond);
				VSH2Player(client).SetOverlay("effects/combine_binocoverlay");
			}
			case TFCond_Milked:
			{
				SetConditionDuration(client, cond, GetConditionDuration(client, cond)/2.0);
			}
		}
	}
}

public Action OnPlayerRunCmd(int client, int & buttons, int & impulse, float vel[3], float angles[3], int & weapon, int & subtype, int & cmdnum, int & tickcount, int & seed, int mouse[2])
{
	VSH2Player player = VSH2Player(client);
	if (IsTank[client] || player.iType == ThisPluginIndex)
		return RunCmd(player, buttons, angles, vel);
	return Plugin_Continue;
}

public void HookRocket(const int rocket)
{
	int nuke = EntRefToEntIndex(rocket);
	if (IsValidEntity(nuke))
	{
		SetEntPropFloat(nuke, Prop_Send, "m_flModelScale", 1.2);
		SDKHook(nuke, SDKHook_StartTouch, OnRocketTouch);
		char buffer[64];
		Format(buffer, sizeof(buffer), "critical_rocket_%s", GetEntProp(rocket, Prop_Send, "m_iTeamNum") == BLU ? "blue" : "red");
		AttachParticle(nuke, buffer, 0.0, true);
		StrCat(buffer, sizeof(buffer), "sparks");
		AttachParticle(nuke, buffer, 0.0, true);
	}
}

public Action OnRocketTouch(int rocket, int other)
{
	if (!IsValidEntity(rocket))
		return Plugin_Continue;

	int owner = GetOwner(rocket);
	if (!IsClientValid(owner))
		return Plugin_Continue;

	int shaker = CreateEntityByName("env_shake");
	if (!IsValidEntity(shaker))
		return Plugin_Continue;

	float vecSrc[3]; GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", vecSrc);

	DispatchKeyValue(shaker, "amplitude", "16");
	DispatchKeyValue(shaker, "radius", "8000");
	DispatchKeyValue(shaker, "duration", "4");
	DispatchKeyValue(shaker, "frequency", "20");
	DispatchKeyValue(shaker, "spawnflags", "4");
		
	TeleportEntity(shaker, vecSrc, NULL_VECTOR, NULL_VECTOR);
	ShowParticle(vecSrc, "fireSmoke_collumn_mvmAcres", 7.0);
	DispatchSpawn(shaker);
	AcceptEntityInput(shaker, "StartShake");
	CreateTimer(5.0, DeleteShake, EntIndexToEntRef(shaker));

	DoExplosion(owner, RoundFloat(ROCKET_DMG), 1000, vecSrc, rocket);
	EmitSoundToAll("misc/doomsday_missile_explosion.wav");
	AcceptEntityInput(rocket, "KillHierarchy");
	AcceptEntityInput(rocket, "Kill");

	return Plugin_Continue;
}

public void _ResetHorn(const VSH2Player client)
{
	if( IsClientValid(client.index) )
		client.iSpecial = false;
}
public Action Timer_ReloadTank (Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	VSH2Player tanker = VSH2Player(client);
	if (!tanker.bIsBoss || tanker.iType != ThisPluginIndex)
		return Plugin_Continue;

	if (client && IsClientInGame(client)) {
		//char s[PLATFORM_MAX_PATH];
		//strcopy(s, PLATFORM_MAX_PATH, TankReload);
		EmitSoundToAll(TankReload, client, SNDCHAN_AUTO);
	}
	return Plugin_Continue;
}

public bool WorldOnly(int entity, int contentsMask, any iExclude)
{
	if (entity <= 0)
		return true;

	if (entity <= MaxClients)
		return false;

	char cls[32]; GetEntityClassname(entity, cls, sizeof(cls));
	return !strncmp(cls, "prop_", 5, false);
}

public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
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
public void SetGravityNormal(const int userid)
{
	int i = GetClientOfUserId(userid);
	if (IsClientValid(i))
		SetEntityGravity(i, 1.0);
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
	return Plugin_Continue;
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("The Military Tank", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "The Military Tank");
	}
}