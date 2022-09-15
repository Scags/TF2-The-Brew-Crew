#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2attributes>
#include <dhooks>

#define PLUGIN_VERSION "1.2.2"

ConVar tf_flamethrower_burst_zvelocity;

float flZVelocity = 0.0;

public Plugin myinfo = {
	name = "[TF2] Pyro Airblast Jump",
	author = "Leonardo",
	description = "",
	version = PLUGIN_VERSION,
	url = "http://xpenia.org/"
}


public APLRes AskPluginLoad2(Handle hMySelf, bool bLate, char[] strError, int iMaxErrors)
{
    RegPluginLibrary( "tf2pyroairjump" );
    return APLRes_Success;
}

public void OnPluginStart()
{
	tf_flamethrower_burst_zvelocity = FindConVar( "tf_flamethrower_burst_zvelocity" );
	
	GameData conf = LoadGameConfigFile("tf2.pyroairjump");
	Handle hook = DHookCreateDetourEx(conf, "CTFFlameThrower::FireAirblast", CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	DHookAddParam(hook, HookParamType_Int);
	DHookEnableDetour(hook, true, CTFFlameThrower_FireAirblast);
	delete conf;
}

public void OnConVarChanged_PluginVersion( ConVar hConVar, const char[] strOldValue, const char[] strNewValue )
{
	if( strcmp( strNewValue, PLUGIN_VERSION, false ) != 0 )
		SetConVarString( hConVar, PLUGIN_VERSION, true, true );
}
public void OnConVarChanged( ConVar hConVar, const char[] strOldValue, const char[] strNewValue )
{
	OnConfigsExecuted();
}

public void OnConfigsExecuted()
{
	flZVelocity = GetConVarFloat( tf_flamethrower_burst_zvelocity );
}

public void OnPlayerRunCmdPost(int iClient, int buttons)
{
	if( !IsPlayerAlive(iClient) )
		return;
	
	if( TF2_GetPlayerClass(iClient) != TFClass_Pyro )
		return;

	int iWeapon = GetEntPropEnt( iClient, Prop_Send, "m_hActiveWeapon" );
	if( !IsValidEntity(iWeapon))
		return;

	char cls[32]; GetEntityClassname(iWeapon, cls, sizeof(cls));
	if (!strncmp(cls, "tf_weapon_flamethrower", 22, false) || !strcmp(cls, "tf_weapon_rocketlauncher_fireball", false))
	{
		float airblasttime = GetGameTime() - GetEntPropFloat( iWeapon, Prop_Send, "m_flNextSecondaryAttack" );
		float scale;
		if (airblasttime < 0.0)
			TF2Attrib_SetByDefIndex(iWeapon, 255, 0.1);
		else
		{
			if (airblasttime > 2.0)
				airblasttime = 2.0;

			scale = 0.1 + (0.45 * airblasttime);
			if (scale >= 0.9999999)
				TF2Attrib_RemoveByDefIndex(iWeapon, 255);
			else TF2Attrib_SetByDefIndex(iWeapon, 255, scale);
		}
	}
}

public MRESReturn CTFFlameThrower_FireAirblast(int iWeapon)
{
	int iClient = GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity");
	if (!(0 < iClient <= MaxClients))
		return;

	float flSpeed = GetEntPropFloat( iClient, Prop_Send, "m_flMaxspeed" );
	if( flSpeed > 0.0 && flSpeed < 5.0 )
		return;
	
	if( GetEntProp( iClient, Prop_Data, "m_nWaterLevel" ) > 1 )
		return;
	
	if( (GetClientButtons(iClient) & IN_ATTACK2) != IN_ATTACK2 )
		return;

	int idx = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
	if (idx == 1178)
		return;

	if (GetEntPropFloat(iWeapon, Prop_Send, "m_flNextSecondaryAttack") < GetGameTime())
		return;

	if( (GetEntityFlags(iClient) & FL_ONGROUND) == FL_ONGROUND )
		return;

	float scale = 1.0;
	Address attrib = TF2Attrib_GetByDefIndex(iWeapon, 255);
	if (attrib != Address_Null)
		scale = TF2Attrib_GetValue(attrib);

	float vecAngles[3], vecVelocity[3];
	float myvec[3];
	GetClientEyeAngles( iClient, vecAngles );
	GetEntPropVector( iClient, Prop_Data, "m_vecVelocity", myvec );
	vecAngles[0] = DegToRad( -1.0 * vecAngles[0] );
	vecAngles[1] = DegToRad( vecAngles[1] );
	vecVelocity[0] -= flZVelocity * Cosine( vecAngles[0] ) * Cosine( vecAngles[1] );
	vecVelocity[1] -= flZVelocity * Cosine( vecAngles[0] ) * Sine( vecAngles[1] );
	vecVelocity[2] -= flZVelocity * Sine( vecAngles[0] );

	if (idx == 40 ||  idx == 1146)
		ScaleVector(vecVelocity, 1.25);

//	PrintToChat(iClient, "%.2f", scale);
	ScaleVector(vecVelocity, scale);

	float vec[3];
	int healeridx;
	int healers = GetEntProp(iClient, Prop_Send, "m_nNumHealers");
	for (int i = 0; i < healers; ++i)
	{
		if (0 < (healeridx = GetHealerByIndex(iClient, i)) <= MaxClients && GetIndexOfWeaponSlot(healeridx, 1) == 411)
		{
			GetEntPropVector(healeridx, Prop_Data, "m_vecVelocity", vec);
			AddVectors(vecVelocity, vec, vec);
			TeleportEntity(healeridx, NULL_VECTOR, NULL_VECTOR, vec);
		}
	}

	AddVectors(vecVelocity, myvec, myvec);
	TeleportEntity( iClient, NULL_VECTOR, NULL_VECTOR, myvec );
//	RequestFrame(DoDelay, EntIndexToEntRef(iWeapon));
}

stock bool IsValidClient( int iClient )
{
	if( iClient <= 0 ) return false;
	if( iClient > MaxClients ) return false;
	return IsClientInGame(iClient);
}

stock int GetHealerByIndex(int client, int index)
{
	int m_aHealers = FindSendPropInfo("CTFPlayer", "m_nNumHealers") + 12;

	Address m_Shared = GetEntityAddress(client) + view_as<Address>(m_aHealers);
	Address aHealers = view_as<Address>(LoadFromAddress(m_Shared, NumberType_Int32));

	return (LoadFromAddress(aHealers + view_as<Address>(index * 0x24), NumberType_Int32) & 0xFFF);
}

stock int GetIndexOfWeaponSlot(int client, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	return weapon > MaxClients && IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1;
}

stock Handle DHookCreateDetourEx(GameData conf, const char[] name, CallingConvention callConv, ReturnType returntype, ThisPointerType thisType)
{
	Handle h = DHookCreateDetour(Address_Null, callConv, returntype, thisType);
	if (h)
		if (!DHookSetFromConf(h, conf, SDKConf_Signature, name))
			LogError("Could not set %s from config!", name);
	return h;
}
