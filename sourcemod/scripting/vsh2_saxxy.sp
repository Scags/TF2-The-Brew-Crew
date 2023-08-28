#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <scag>
#include <rtd>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Saxxy", 
	author = "Scag", 
	description = "VSH2 boss Saxxy", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_saxxy");
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
		VSH2_Hook(OnLastPlayer, fwdOnLastPlayer);
		VSH2_Hook(OnBossSetName, fwdOnBossSetName);
		VSH2_Hook(OnBossDeath, fwdOnBossDeath);
		VSH2_Hook(OnBossWin, fwdOnBossWin);
		VSH2_Hook(OnBossKillBuilding, fwdOnBossKillBuilding);
		VSH2_Hook(OnSetBossArgs, fwdOnSetBossArgs);
	}
}

#define SaxxyTheme1			"opst/saxtonhale/saxxy/saxxytheme1.mp3"
#define SaxxyTheme2			"opst/saxtonhale/saxxy/saxxytheme2.mp3"

#define HaleModel                   "models/player/saxton_hale_jungle_inferno/saxton_hale.mdl"

//Saxton Hale voicelines
#define HaleComicArmsFallSound	"saxton_hale/saxton_hale_responce_2.wav"
#define HaleLastB		"vo/announcer_am_lastmanalive"
#define HaleKSpree		"saxton_hale/saxton_hale_responce_3.wav"
#define HaleKSpree2		"saxton_hale/saxton_hale_responce_4.wav"	//this line is broken and unused
#define HaleRoundStart		"saxton_hale/saxton_hale_responce_start" //1-5
#define HaleJump		"saxton_hale/saxton_hale_responce_jump"			//1-2
#define HaleRageSound		"saxton_hale/saxton_hale_responce_rage"		   //1-4
#define HaleKillMedic		"saxton_hale/saxton_hale_responce_kill_medic.wav"
#define HaleKillSniper1		"saxton_hale/saxton_hale_responce_kill_sniper1.wav"
#define HaleKillSniper2		"saxton_hale/saxton_hale_responce_kill_sniper2.wav"
#define HaleKillSpy1		"saxton_hale/saxton_hale_responce_kill_spy1.wav"
#define HaleKillSpy2		"saxton_hale/saxton_hale_responce_kill_spy2.wav"
#define HaleKillEngie1		"saxton_hale/saxton_hale_responce_kill_eggineer1.wav"
#define HaleKillEngie2		"saxton_hale/saxton_hale_responce_kill_eggineer2.wav"
#define HaleKSpreeNew		"saxton_hale/saxton_hale_responce_spree"  //1-5
#define HaleWin			"saxton_hale/saxton_hale_responce_win"		  //1-2
#define HaleLastMan		"saxton_hale/saxton_hale_responce_lastman"  //1-5
#define HaleFail		"saxton_hale/saxton_hale_responce_fail"			//1-3
#define HaleJump132		"saxton_hale/saxton_hale_132_jump_" //1-2
#define HaleStart132		"saxton_hale/saxton_hale_132_start_"   //1-5
#define HaleKillDemo132		"saxton_hale/saxton_hale_132_kill_demo.wav"
#define HaleKillEngie132	"saxton_hale/saxton_hale_132_kill_engie_" //1-2
#define HaleKillHeavy132	"saxton_hale/saxton_hale_132_kill_heavy.wav"
#define HaleKillScout132	"saxton_hale/saxton_hale_132_kill_scout.wav"
#define HaleKillSpy132		"saxton_hale/saxton_hale_132_kill_spie.wav"
#define HaleKillPyro132		"saxton_hale/saxton_hale_132_kill_w_and_m1.wav"
#define HaleSappinMahSentry132	"saxton_hale/saxton_hale_132_kill_toy.wav"
#define HaleKillKSpree132	"saxton_hale/saxton_hale_132_kspree_"	//1-2
#define HaleKillLast132		"saxton_hale/saxton_hale_132_last.wav"
#define HaleStubbed132		"saxton_hale/saxton_hale_132_stub_"  //1-4
#define HaleTheme			"saxton_hale/saxtonhale.mp3"
#define HaleTheme3			"saxton_hale/haletheme4_fix.mp3"


public void fwdOnDownloadsCalled()
{
	PrepareSound(SaxxyTheme1);
	PrepareSound(SaxxyTheme2);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Saxxy:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage 1 (Lunge): Reload (r) when the Rage is > 20% to lunge at players.\nRage 2 (Ultrastomp): Press Mouse3 (middle click) when high in the air and rage > 50% to slam the ground beneath you.\nRage 3 (stun): Call for medic (e) when the Rage is full to stun nearby enemies.");
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

	int client = Player.index;
	int buttons = GetClientButtons(client);
	//float currtime = GetGameTime();
	int flags = GetEntityFlags(client);

	//int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	int health = Player.iHealth;
	float speed = 340.0 + 0.7 * (100-health*100/Player.iMaxHealth);
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", speed);

	if (Player.flGlowtime > 0.0) {
		Player.bGlow = 1;
		Player.flGlowtime -= 0.1;
	}
	else if (Player.flGlowtime <= 0.0)
		Player.bGlow = 0;

	if (OnlyScoutsAndSpiesLeft(Player.iOtherTeam))
		Player.flRAGE += 0.25;

	if ( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (Player.flCharge >= 0.0) )
	{
		if (Player.flCharge+2.5 < 25.0)
			Player.flCharge += 1.25;
		else Player.flCharge = 25.0;
	}
	else if (Player.flCharge < 0.0)
	{
		if (Player.iDifficulty <= 3)
			Player.flCharge += 2.0;
		else Player.flCharge += 1.25;
	}
	else {
		float EyeAngles[3]; GetClientEyeAngles(client, EyeAngles);
		if ( Player.flCharge > 1.0 && EyeAngles[0] < -5.0 ) {
			float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
			bool big = RTD_GetRollType(client) == PERK_JUMP;
			int v = big ? 1000 : 750;
			vel[2] = v + Player.flCharge * 13.0;

			SetEntProp(client, Prop_Send, "m_bJumping", 1);
			vel[0] *= (1+Sine(Player.flCharge * FLOAT_PI / 50));
			vel[1] *= (1+Sine(Player.flCharge * FLOAT_PI / 50));
			if (big)
			{
				vel[0] *= 1.2;
				vel[1] *= 1.2;
			}
			TeleportEntity(client, nullvec, nullvec, vel);
			Player.flCharge = -100.0;

			char snd[PLATFORM_MAX_PATH];
			Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", GetRandomInt(0, 1) ? HaleJump : HaleJump132, GetRandomInt(1, 2));
			EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
		else Player.flCharge = 0.0;
	}

	if ( flags & FL_ONGROUND )
	{
		Player.flWeighDown = 0.0;
		if (Player.bUsedUltimate)
		{
			int i = CreateEntityByName("env_shake");
			if (IsValidEntity(i))
			{
				float flPos[3]; GetEntPropVector(Player.index, Prop_Send, "m_vecOrigin", flPos);

				DispatchKeyValue(i, "amplitude", "16");
				DispatchKeyValue(i, "radius", "1200");
				DispatchKeyValue(i, "duration", "2");
				DispatchKeyValue(i, "frequency", "20");
				DispatchKeyValue(i, "spawnflags", "4");

				TeleportEntity(i, flPos, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(i);
				AcceptEntityInput(i, "StartShake");
				CreateTimer(3.0, DeleteShake, EntIndexToEntRef(i));

				float pos2[3], distance;
				for (i = MaxClients; i; --i)
				{
					if (!IsClientInGame(i) || !IsPlayerAlive(i))
						continue;
					if (GetClientTeam(i) == GetClientTeam(Player.index))
						continue;
					if (!(GetEntityFlags(i) & FL_ONGROUND))
						continue;

					GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
					distance = GetVectorDistance(flPos, pos2);
					if (distance <= 500.0)
					{
						SDKHooks_TakeDamage(i, 0, Player.index, 150.0*((500.0-distance)/distance), DMG_DIRECT|DMG_CRUSH, _, _, _);
						TF2_AddCondition(i, TFCond_LostFooting, 3.0);
					}
				}
			}
			Player.bUsedUltimate = false;
		}
	}

	if (flags & FL_INWATER)
		Player.bUsedUltimate = false;
	else Player.flWeighDown += 0.1;

	if ( (buttons & IN_DUCK) && Player.flWeighDown >= 3.0 && Player.iDifficulty <= 3)
	{
		float ang[3]; GetClientEyeAngles(client, ang);
		if ( ang[0] > 60.0 )
		{
			//float fVelocity[3];
			//GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			//fVelocity[2] = -500.0;
			//TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
			SetEntityGravity(client, 6.0);
			SetPawnTimer(SetGravityNormal, 1.0, Player.userid);
			Player.flWeighDown = 0.0;
		}
	}
	else if ((buttons & IN_ATTACK3) && Player.flWeighDown >= 1.0 && Player.flRAGE >= 50.0)
	{
		char snd[PLATFORM_MAX_PATH];
		Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, GetRandomInt(1, 4));
		float pos[3]; GetClientAbsOrigin(client, pos);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, client, pos, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, client, pos, NULL_VECTOR, false, 0.0);
		float vec[3] = {0.0, 0.0, 1000.0};
		TeleportEntity(Player.index, nullvec, nullvec, vec);
		SetPawnTimer(DoGrav, 0.7, Player);
		Player.flWeighDown = 0.0;
		Player.bUsedUltimate = true;
		Player.flRAGE -= 50.0;
	}
	else if ((buttons & IN_RELOAD) && Player.flRAGE >= 20.0 && !Player.bUsedUltimate && /*(flags & FL_ONGROUND) &&*/ Player.flCharge >= 0.0)
	{
		float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
		vel[2] = 400.0;

		SetEntProp(client, Prop_Send, "m_bJumping", 1);
		vel[0] *= (1.95);
		vel[1] *= (1.95);
		TeleportEntity(client, nullvec, nullvec, vel);
		Player.flRAGE -= 20.0;
		char snd[PLATFORM_MAX_PATH];
		Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", GetRandomInt(0, 1) ? HaleJump : HaleJump132, GetRandomInt(1, 2));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		Player.flCharge = -50.0;
		Player.flWeighDown = 0.0;
	}

	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	float jmp = Player.flCharge;
	if (jmp > 0.0)
		jmp *= 4.0;
	if (Player.flRAGE >= 100.0)
		ShowSyncHudText(client, VSH2_BossHud(), "Jump: %i | Rage: FULL - Call Medic (default: E) to activate\nReload (r) to Lunge | Middle Click (m3) to Ultrastomp", RoundFloat(jmp));
	else if (Player.flRAGE >= 50.0)
		ShowSyncHudText(client, VSH2_BossHud(), "Jump: %i | Rage: %0.1f\nReload (r) to Lunge | Middle Click (m3) to Ultrastomp", RoundFloat(jmp), Player.flRAGE);
	else if (Player.flRAGE >= 20.0)
		ShowSyncHudText(client, VSH2_BossHud(), "Jump: %i | Rage: %0.1f\nReload (r) to Lunge", RoundFloat(jmp), Player.flRAGE);
	else ShowSyncHudText(client, VSH2_BossHud(), "Jump: %i | Rage: %0.1f", RoundFloat(jmp), Player.flRAGE);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(HaleModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 252 ; 0.6 ; 2025 ; 3 ; 2013 ; %d ; 2014 ; 2 ; 150 ; 1 ; 214 ; %d", GetRandomInt(2002, 2008), GetRandomInt(999, 9999));
	int SaxtonWeapon = Player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	SetEntProp(Player.index, Prop_Send, "m_bForcedSkin", 1);
	SetEntProp(Player.index, Prop_Send, "m_nForcedSkin", 3);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
		TF2_SetPlayerClass(Player.index, TFClass_Soldier, _, false);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	if (Player.iType == ThisPluginIndex)
	{
		char snd[PLATFORM_MAX_PATH];
		if( !GetRandomInt(0, 1) )
			Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, GetRandomInt(1, 5));
		else Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, GetRandomInt(1, 5));

		EmitSoundToAll(snd, _, _, _, SND_CHANGEPITCH, _, SNDPITCH_LOW-20);
	}
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
		fwdOnBossModelTimer(player); //MakeModelTimer(null); // should reset Hale's animation
	}

	player.DoGenericStun(500.0);

	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, GetRandomInt(1, 4));
	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, client, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, client, pos, NULL_VECTOR, false, 0.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(0, 1))
	{
		case 0:
		{
			time = 246.0;
			strcopy(song, sizeof(song), SaxxyTheme1);
		}
		case 1:
		{
			time = 328.0;
			strcopy(song, sizeof(song), SaxxyTheme2);
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Saxxy");
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
	if (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		event.SetString("weapon", (dmgbits & DMG_CRUSH) ? "mantreads" : "fists");
	}
	else if (dmgbits & DMG_CRUSH)
	{
		event.SetString("weapon_logclassname", "vehicle_crush");
		event.SetString("weapon", "mantreads");
	}
	else if (event.GetInt("customkill") != TF_CUSTOM_BOOTS_STOMP)
		event.SetString("weapon", "fists");

	char snd[PLATFORM_MAX_PATH];
	if (!GetRandomInt(0, 2))
	{
		TFClassType playerclass = TF2_GetPlayerClass(Victim.index);
		switch (playerclass)
		{
			case TFClass_Scout:	strcopy(snd, PLATFORM_MAX_PATH, HaleKillScout132);
			case TFClass_Pyro:	strcopy(snd, PLATFORM_MAX_PATH, HaleKillPyro132);
			case TFClass_DemoMan:	strcopy(snd, PLATFORM_MAX_PATH, HaleKillDemo132);
			case TFClass_Heavy:	strcopy(snd, PLATFORM_MAX_PATH, HaleKillHeavy132);
			case TFClass_Medic:	strcopy(snd, PLATFORM_MAX_PATH, HaleKillMedic);
			case TFClass_Sniper:
			{
				if (GetRandomInt(0, 1))
					strcopy(snd, PLATFORM_MAX_PATH, HaleKillSniper1);
				else strcopy(snd, PLATFORM_MAX_PATH, HaleKillSniper2);
			}
			case TFClass_Spy:
			{
				switch (GetRandomInt(0, 2)) {
					case 0: strcopy(snd, PLATFORM_MAX_PATH, HaleKillSpy1);
					case 1: strcopy(snd, PLATFORM_MAX_PATH, HaleKillSpy2);
					case 2: strcopy(snd, PLATFORM_MAX_PATH, HaleKillSpy132);
				}
			}
			case TFClass_Engineer:
			{
				switch (GetRandomInt(0, 3)) {
					case 0: strcopy(snd, PLATFORM_MAX_PATH, HaleKillEngie1);
					case 1: strcopy(snd, PLATFORM_MAX_PATH, HaleKillEngie2);
					case 2: Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, GetRandomInt(1, 2));
					case 3: Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, GetRandomInt(1, 2));
				}
			}
		}
		if (snd[0] != '\0')
		{
			EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}

	Attacker.iKills++;

	if (!(Attacker.iKills % 3)) {
		int randsound = GetRandomInt(0, 7);
		if( !randsound || randsound == 1 )
			strcopy(snd, PLATFORM_MAX_PATH, HaleKSpree);
		else if( randsound < 5 && randsound > 1 )
			Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, GetRandomInt(1, 5));
		else Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, GetRandomInt(1, 2));
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		Attacker.iKills = 0;
	}
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetEntityRenderColor(Player.index);
	SetEntityRenderMode(Player.index, RENDER_NORMAL);

	char snd[PLATFORM_MAX_PATH];
	Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, GetRandomInt(1, 3));
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	SetEntProp(Player.index, Prop_Send, "m_bForcedSkin", 0);
	SetEntProp(Player.index, Prop_Send, "m_nForcedSkin", 0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	Format(s, FULLPATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
	sndflags = SND_CHANGEPITCH;
	pitch = SNDPITCH_LOW-20;
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Saxxy");
}
public void fwdOnLastPlayer(const VSH2Player player)
{
	if (player.iType == ThisPluginIndex)
	{
		char snd[PLATFORM_MAX_PATH];
		switch( GetRandomInt(0, 5) ) {
			case 0: strcopy(snd, PLATFORM_MAX_PATH, HaleComicArmsFallSound);
			case 1: Format(snd, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, GetRandomInt(1, 4));
			case 2: strcopy(snd, PLATFORM_MAX_PATH, HaleKillLast132);
			default: Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, GetRandomInt(1, 5));
		}
		float pos[3]; GetClientAbsOrigin(player.index, pos);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, player.index, pos, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, player.index, pos, NULL_VECTOR, false, 0.0);
	}
}

public void fwdOnBossKillBuilding(const VSH2Player Attacker, const int building, Event event)
{
	if (Attacker.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
	if (!GetRandomInt(0, 3))
	{
		char snd[PLATFORM_MAX_PATH];
		strcopy(snd, FULLPATH, HaleSappinMahSentry132);
		EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_CHANGEPITCH, SNDVOL_NORMAL, SNDPITCH_LOW-20, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
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

public void DoGrav(const VSH2Player boss)
{
	if (boss && boss.index)
	{
		SetEntityGravity(boss.index, 6.0);
		SetPawnTimer(SetGravityNormal, 1.0, boss.userid);
	}
}
public void SetGravityNormal(const int userid)
{
	int i = GetClientOfUserId(userid);
	if (IsClientValid(i))
		SetEntityGravity(i, 1.0);
}
public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Saxxy", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Saxxy");
	}
}