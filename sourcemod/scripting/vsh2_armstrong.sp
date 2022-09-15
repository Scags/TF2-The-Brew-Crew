#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <tf2attributes>
#include <tf2items>
#include <scag>

#pragma semicolon			1
#pragma newdecls			required

public Plugin myinfo = 
{
	name = "VSH2 - Senator Armstrong", 
	author = "Scag", 
	description = "VSH2 boss Senator Armstrong", 
	version = "1.0.0", 
	url = ""
};

int ThisPluginIndex;

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		ThisPluginIndex = VSH2_RegisterPlugin("vsh2_armstrong");
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
	}
}

#define ArmstrongModel			"models/freak_fortress_2/newarmstrong/newstevenarmstrong.mdl"

#define ArmstrongKill			"tbc/saxtonhale/armstrong/kill" //10
#define ArmstrongStart			"tbc/saxtonhale/armstrong/intro" //2
#define ArmstrongFail			"tbc/saxtonhale/armstrong/dead1.mp3"
#define ArmstrongJump			"tbc/saxtonhale/armstrong/jump" //3
#define ArmstrongRage			"tbc/saxtonhale/armstrong/rage.mp3"
#define ArmstrongWin				"tbc/saxtonhale/armstrong/win" //2
#define ArmstrongStab			"tbc/saxtonhale/armstrong/backstab" //2
#define ArmstrongLast 			"tbc/saxtonhale/armstrong/last" //3
#define ArmstrongTheme			"tbc/saxtonhale/armstrong/theme1.mp3"
#define ArmstrongTheme2			"tbc/saxtonhale/armstrong/theme2.mp3"

public void fwdOnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	int i;

	PrepareModel(ArmstrongModel);
	PrepareMaterialDir(false, "materials/freak_fortress_2/armstrong_fix");

	for (i = 1; i <= 10; i++) 
	{
		if (i <= 2)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ArmstrongStab, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ArmstrongWin, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ArmstrongStart, i);
			PrepareSound(s);
		}

		if (i <= 3)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ArmstrongLast, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ArmstrongJump, i);
			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ArmstrongKill, i);
		PrepareSound(s);
	}

	PrepareSound(ArmstrongFail);
	PrepareSound(ArmstrongRage);
	PrepareSound(ArmstrongTheme);
	PrepareSound(ArmstrongTheme2);
}

public void fwdBossSelected(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	if (IsVoteInProgress())
		return;

	Panel panel = new Panel();
	panel.SetTitle("Senator Steven Armstrong:\nSuper Jump: Right-click, look up, and release.\nWeigh-down: After 3 seconds in midair, look down and hold crouch\nRage (You Little Fuck): Call for medic (e) when Rage is full.\nYou are launched forward and stun players!");
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

	Player.DoGenericThink(true, true, ArmstrongJump, 3);

	int flags = GetEntityFlags(Player.index);
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

					GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
					distance = GetVectorDistance(flPos, pos2);
					if (distance < 500.0)
					{
						SDKHooks_TakeDamage(i, 0, Player.index, 50.0, DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE, _, _, _);
						if(!TF2_IsPlayerInCondition(i, TFCond_Ubercharged))
						{
							CreateTimer(5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
							TF2_StunPlayer(i, 5.0, _, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, Player.index);
						}
					}
				}

				i = -1;
				while((i = FindEntityByClassname(i, "obj_sentrygun")) != -1)
				{
					if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(Player.index))
						continue;
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
					distance = GetVectorDistance(flPos, pos2);
					if(distance < 500.0)
					{
						SetEntProp(i, Prop_Send, "m_bDisabled", 1);
						AttachParticle(i, "yikes_fx", 75.0);
						SDKHooks_TakeDamage(i, 0, Player.index, 100.0, DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE, _, _, _);
						SetPawnTimer(EnableSG, 8.0, EntIndexToEntRef(i)); //CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
					}
				}
				i = -1;
				while((i = FindEntityByClassname(i, "obj_dispenser")) != -1)
				{
					if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(Player.index))
						continue;
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
					distance = GetVectorDistance(flPos, pos2);
					if(distance < 500.0)
					{
						SDKHooks_TakeDamage(i, 0, Player.index, 100.0, DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE, _, _, _);
					}
				}
				i = -1;
				while((i = FindEntityByClassname(i, "obj_teleporter")) != -1)
				{
					if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(Player.index))
						continue;
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
					distance = GetVectorDistance(flPos, pos2);
					if(distance < 500.0)
					{
						SDKHooks_TakeDamage(i, 0, Player.index, 100.0, DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE, _, _, _);
					}
				}
			}
			Player.bUsedUltimate = false;
		}
	}
}
public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	SetVariantString(ArmstrongModel);
	AcceptEntityInput(Player.index, "SetCustomModel");
	SetEntProp(Player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void fwdOnBossEquipped(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	Player.PreEquip();
	char attribs[128];
    
	Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %i ; 206 ; 0.9", GetRandomInt(9999, 99999));
	int assbeater = Player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs, false);
	SetEntPropEnt(Player.index, Prop_Send, "m_hActiveWeapon", assbeater);
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
		char s[PLATFORM_MAX_PATH];
		FormatEx(s, sizeof(s), "%s%d.mp3", ArmstrongStart, GetRandomInt(1, 2));
		EmitSoundToAll(s);
	}
}
public void fwdOnBossTaunt(const VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;
	
	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);
	if ( !GetEntProp(player.index, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(player.index, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(player.index, TFCond_Taunting);
		fwdOnBossModelTimer(player); //MakeModelTimer(null);
	}

	char snd[PLATFORM_MAX_PATH];
	strcopy(snd, PLATFORM_MAX_PATH, ArmstrongRage);
	float pos[3]; GetClientAbsOrigin(player.index, pos);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(snd);

	TF2_AddCondition(player.index, TFCond_MegaHeal, 8.0);

	player.flCharge = -100.0;

	SetPawnTimer(ArmstrongFling, 2.3, player);
}

public void ArmstrongFling(const VSH2Player player)
{
	int client = player.index;
	if (!client || player.iType != ThisPluginIndex || !IsPlayerAlive(client))
		return;

	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
	vel[2] = 600.0;

	SetEntProp(client, Prop_Send, "m_bJumping", 1);
	vel[0] *= 1.95;
	vel[1] *= 1.95;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
	player.flWeighDown = 0.0;

	SetEntityFlags(client, GetEntityFlags(client) & ~FL_ONGROUND);

	player.bUsedUltimate = true;

	SetPawnTimer(ArmstrongStomp, 0.5, player);
}

public void ArmstrongStomp(const VSH2Player player)
{
	int client = player.index;
	if (!client || player.iType != ThisPluginIndex || !IsPlayerAlive(client))
		return;

	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	SetEntityGravity(player.index, 6.0);
	SetPawnTimer(SetGravityNormal, 1.0, player.userid);
}
public void SetGravityNormal(const int userid)
{
	int i = GetClientOfUserId(userid);
	if (IsClientValid(i))
		SetEntityGravity(i, 1.0);
}
public void fwdOnMusic(char song[FULLPATH], float & time, const VSH2Player Player)
{
	if (Player.iPureType != ThisPluginIndex)
		return;

	switch (GetRandomInt(1, 2))
	{
		case 1:
		{
			strcopy(song, sizeof(song), ArmstrongTheme);
			time = 305.0;
		}
		case 2:
		{
			strcopy(song, sizeof(song), ArmstrongTheme2);
			time = 144.0;
		}
	}
}
public void fwdOnBossMenu(Menu & menu)
{
	char id[4]; IntToString(ThisPluginIndex, id, 4);
	menu.AddItem(id, "Senator Steven Armstrong");
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
	{
		if (event.GetInt("damagebits") == DMG_DIRECT|DMG_CRUSH|DMG_VEHICLE)
		{
			event.SetString("weapon", "tf_pumpkin_bomb");
			event.SetInt("customkill", TF_CUSTOM_PUMPKIN_BOMB);
		}
		else event.SetString("weapon", "fists");
	}

	char s[PLATFORM_MAX_PATH];
	Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", ArmstrongKill, GetRandomInt(1, 10));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Attacker.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void fwdOnBossDeath(const VSH2Player Player)
{
	if (Player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	strcopy(s, PLATFORM_MAX_PATH, ArmstrongFail);
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action fwdOnBossBackstabbed(const VSH2Player victim, const VSH2Player attacker)
{
	if (victim.iType != ThisPluginIndex)
		return Plugin_Continue;

	char s[PLATFORM_MAX_PATH];
	FormatEx(s, PLATFORM_MAX_PATH, "%s%d.mp3", ArmstrongStab, GetRandomInt(1, 2));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
public void fwdOnBossWin(const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	if (player.iPureType != ThisPluginIndex)
		return;

	FormatEx(s, sizeof(s), "%s%d.mp3", ArmstrongWin, GetRandomInt(1, 2));
}
public void fwdOnBossSetName(const VSH2Player player, char s[MAX_BOSS_NAME_LENGTH])
{
	if (player.iPureType == ThisPluginIndex)
		strcopy(s, sizeof(s), "Senator Steven Armstrong");
}
public void fwdOnBossKillBuilding(const VSH2Player player, int building, Event event)
{
	if (player.iType != ThisPluginIndex)
		return;

	event.SetString("weapon", "fists");
}

public void fwdOnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	if (type != -1)
		return;

	if (StrContains("Armstrong", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Senator Steven Armstrong");
	}
	else if (StrContains("Steven", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Senator Steven Armstrong");
	}
	else if (StrContains("Senator", bossname, false) != -1)
	{
		type = ThisPluginIndex;
		strcopy(buffer, MAX_BOSS_NAME_LENGTH, "Senator Steven Armstrong");
	}
}

public void fwdOnLastPlayer(VSH2Player player)
{
	if (player.iType != ThisPluginIndex)
		return;

	char s[PLATFORM_MAX_PATH];
	FormatEx(s, PLATFORM_MAX_PATH, "%s%d.mp3", ArmstrongLast, GetRandomInt(1, 3));
	EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, player.index, NULL_VECTOR, NULL_VECTOR, false, 0.0);
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

public void EnableSG(const int iid)
{
	int i = EntRefToEntIndex(iid);
	if (IsValidEntity(i) && i > MaxClients)
	{
		char s[32]; GetEdictClassname(i, s, sizeof(s));
		if ( StrEqual(s, "obj_sentrygun") ) {
			SetEntProp(i, Prop_Send, "m_bDisabled", 0);
			int ent = MaxClients+1;
			while ((ent = FindEntityByClassname(ent, "info_particle_system")) != -1)
			{
				if (GetOwner(ent) == i)
					RemoveEntity(ent);
			}
		}
	}
}