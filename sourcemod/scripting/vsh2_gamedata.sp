#include <scag>
#include <dhooks>
#include <sdktools>
#include <sdkhooks>
#include <vsh2>
#include <tf2powups>
#include <tf2attributes>
#include <tf2items>

Handle hJump;
Handle hItemCanBeTouchedByPlayer;
Handle hGetSwordSpeedMod;
Handle hHasSpeedBoost;
Handle hHasDamageBoost;
//Handle hGetProjectileSpeed;
//Handle hGetProjectileGravity;

//Handle hGetMaxAmmo;
//Handle hTakeHealth;
bool bHit[34];

ArrayList
	hSpawnLocs
;

int g_DonkNew = 0xE990;
int g_DonkOld;
Address g_Donk;

DynamicHook g_hDHookItemIterateAttribute;
int g_iCEconItem_m_Item;
int g_iCEconItemView_m_bOnlyIterateItemViewAttributes;

int g_HookIDs[2][2048];

public void OnPluginStart()
{
	GameData conf = LoadGameConfigFile("tf2.vsh2");
	hJump = DHookCreate(0, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, CBasePlayer_Jump);
	if (!DHookSetFromConf(hJump, conf, SDKConf_Virtual, "CBasePlayer::Jump"))
		SetFailState("Could not load hook for CBasePlayer::Jump!");

	Handle hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_CBaseEntity);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CWeaponMedigun::AllowedToHealTarget");
	DHookAddParam(hook, HookParamType_CBaseEntity);
	if (!hook || !DHookEnableDetour(hook, false, Hook_AllowedToHealTarget))
		SetFailState("Could not load hook for CWeaponMedigun::AllowedToHealTarget!");

	hItemCanBeTouchedByPlayer = DHookCreate(0, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, CItem_ItemCanBeTouchedByPlayer);
	DHookSetFromConf(hItemCanBeTouchedByPlayer, conf, SDKConf_Virtual, "CItem::ItemCanBeTouchedByPlayer");
	DHookAddParam(hItemCanBeTouchedByPlayer, HookParamType_CBaseEntity);
	if (!hItemCanBeTouchedByPlayer)
		SetFailState("Could not load hook for CItem::ItemCanBeTouchedByPlayer!");

	hGetSwordSpeedMod = DHookCreateEx(conf, "CTFSword::GetSwordSpeedMod", HookType_Entity, ReturnType_Float, ThisPointer_CBaseEntity, CTFSword_GetSwordSpeedMod);
	hHasSpeedBoost = DHookCreateEx(conf, "CTFShovel::HasSpeedBoost", HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, CTFShovel_HasSpeedBoost);
	hHasDamageBoost = DHookCreateEx(conf, "CTFShovel::HasDamageBoost", HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, CTFShovel_HasDamageBoost);

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFStunBall::ApplyBallImpactDamageEffectToVictim");
	DHookAddParam(hook, HookParamType_CBaseEntity);
	if (!DHookEnableDetour(hook, false, CTFStunBall_ApplyBallImpactDamageEffectToVictim))
		SetFailState("Could not load hook for CTFStunBall::ApplyBallImpactDamageEffectToVictim!");

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFPlayer::AddCustomAttribute");
	DHookAddParam(hook, HookParamType_CharPtr);
	DHookAddParam(hook, HookParamType_Float);
	DHookAddParam(hook, HookParamType_Float);
	if (!DHookEnableDetour(hook, false, CTFPlayer_AddCustomAttribute))
		SetFailState("Could not load hook for CTFPlayer::AddCustomAttribute!");

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFLunchBox::ApplyBiteEffects");
	DHookAddParam(hook, HookParamType_CBaseEntity);
	if (!DHookEnableDetour(hook, false, CTFLunchBox_ApplyBiteEffects))
		SetFailState("Could not load hook for CTFLunchBox::ApplyBiteEffects!");
	DHookEnableDetour(hook, true, CTFLunchBox_ApplyBiteEffects_Post);

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Int, ThisPointer_CBaseEntity);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFPlayer::TakeHealth");
	DHookAddParam(hook, HookParamType_Float);
	DHookAddParam(hook, HookParamType_Int);
	if (!DHookEnableDetour(hook, false, CBaseEntity_TakeHealth))
		SetFailState("Could not load hook for CBaseEntity::TakeHealth!");

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFPlayer::DoTauntAttack");
	if (!DHookEnableDetour(hook, false, CTFPlayer_DoTauntAttack) || !DHookEnableDetour(hook, true, CTFPlayer_DoTauntAttack_Post))
		SetFailState("Could not load hook for CTFPlayer::DoTauntAttack!");

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFPlayerShared::AddCond");
	DHookAddParam(hook, HookParamType_Int);
	DHookAddParam(hook, HookParamType_Float);
	DHookAddParam(hook, HookParamType_CBaseEntity);
	if (!DHookEnableDetour(hook, false, CTFPlayerShared_AddCond))
		SetFailState("Could not load hook for CTFPlayerShared::AddCond!");

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CAmmoPack::MyTouch");
	DHookAddParam(hook, HookParamType_CBaseEntity);
	if (!DHookEnableDetour(hook, false, CAmmoPack_MyTouch) || !DHookEnableDetour(hook, true, CAmmoPack_MyTouch_Post))
		SetFailState("Could not load hook for CAmmoPack::MyTouch!");

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFPlayerShared::AddToSpyCloakMeter");
	DHookAddParam(hook, HookParamType_Float);
	DHookAddParam(hook, HookParamType_Bool);
	if (!DHookEnableDetour(hook, false, CTFPlayerShared_AddToSpyCloakMeter))
		SetFailState("Could not load hook for CTFPlayerShared::AddToSpyCloakMeter!");

// MILK
// 	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
// 	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFWeaponBase::ApplyOnHitAttributes");
// 	DHookAddParam(hook, HookParamType_CBaseEntity);
// 	DHookAddParam(hook, HookParamType_CBaseEntity);
// 	DHookAddParam(hook, HookParamType_Int);
// 	if (!DHookEnableDetour(hook, false, CTFWeaponBase_ApplyOnHitAttributes) || !DHookEnableDetour(hook, true, CTFWeaponBase_ApplyOnHitAttributes_Post))
// 		SetFailState("Could not load hook for CTFWeaponBase::ApplyOnHitAttributes!");

// 	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Float, ThisPointer_CBaseEntity);
// 	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFWeaponBaseGun::GetProjectileSpeed");
// 	DHookEnableDetour(hook, false, CTFWeaponBaseGun_GetProjectileSpeed);

// 	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Float, ThisPointer_CBaseEntity);
// 	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFWeaponBaseGun::GetProjectileGravity");
// 	DHookEnableDetour(hook, false, CTFWeaponBaseGun_GetProjectileGravity);

//	StartPrepSDKCall(SDKCall_Entity);
//	PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTFPlayer::GetMaxAmmo");
//	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
//	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
//	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
//	if (!(hGetMaxAmmo = EndPrepSDKCall()))
//		SetFailState("Could not load call to CTFPlayer::GetMaxAmmo");

// 	Address addr = conf.GetAddress("ApplyOnDamageAliveModifyRules");
// 	int len = conf.GetOffset("ApplyOnDamageAliveModifyRules_PatchLength");
// 	for (int i = 0; i < len; ++i)
// 		StoreToAddress(addr + view_as< Address >(i), 0x90, NumberType_Int8);

	Address addr = conf.GetAddress("CTFProjectile_Cleaver::OnHit");
	StoreToAddress(addr, 3.0, NumberType_Int32);

	g_Donk = conf.GetAddress("CTFGameRules::ApplyOnDamageModifyRules");
	g_DonkOld = LoadFromAddress(g_Donk, NumberType_Int16);

	hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_Address);
	DHookAddParam(hook, HookParamType_Int);
	DHookAddParam(hook, HookParamType_Int);
	DHookAddParam(hook, HookParamType_Bool);
	DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFGameRules::ApplyOnDamageModifyRules");
	DHookEnableDetour(hook, false, CTFGameRules_ApplyOnDamageModifyRules);
	DHookEnableDetour(hook, true, CTFGameRules_ApplyOnDamageModifyRules_Post);

	int iOffset = conf.GetOffset("CEconItemView::IterateAttributes");
	PrintToChatAll("%d",iOffset);
	g_hDHookItemIterateAttribute = new DynamicHook(iOffset, HookType_Raw, ReturnType_Void, ThisPointer_Address);
	if (g_hDHookItemIterateAttribute == null)
		SetFailState("Failed to create hook CEconItemView::IterateAttributes offset from TF2 gamedata!");
	g_hDHookItemIterateAttribute.AddParam(HookParamType_ObjectPtr);

	g_iCEconItem_m_Item = FindSendPropInfo("CEconEntity", "m_Item");
	FindSendPropInfo("CEconEntity", "m_bOnlyIterateItemViewAttributes", _, _, g_iCEconItemView_m_bOnlyIterateItemViewAttributes);

	delete conf;

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			OnClientPutInServer(i);

	for (int i = 0; i < 2048; ++i)
	{
		g_HookIDs[0][i] = INVALID_HOOK_ID;
		g_HookIDs[1][i] = INVALID_HOOK_ID;
	}

	HookEvent("arena_round_start", OnRoundStart);

	hSpawnLocs = new ArrayList();

	RegAdminCmd("sm_makerune", CmdMakeRune, ADMFLAG_ROOT);
}

public Action CmdMakeRune(int client, int args)
{
	float pos[3]; GetAimPos(client, pos);

	int type;
	if (!args)
		type = GetRandRune();
	else
	{
		char arg[4]; GetCmdArg(1, arg, sizeof(arg));
		type = StringToInt(arg);
	}
	MakeRune(view_as< RuneTypes >(type), pos);
	return Plugin_Handled;
}

public void OnLibraryAdded(const char[] name)
{
	if (!strcmp(name, "VSH2", true))
	{
		VSH2_Hook(OnRedPlayerThink, fwdOnRedPlayerThink);
		VSH2_Hook(OnFighterDeadThink, fwdOnDeadPlayerThink);
//		VSH2_Hook(OnPrepRedTeam, fwdOnPrepPlayers);
	}
}

public void fwdOnDeadPlayerThink(const VSH2Player player)
{
	BuildingThink(player.index);
}

public void fwdOnRedPlayerThink(const VSH2Player player)
{
	BuildingThink(player.index);
	SetEntData(player.index, GetEntSendPropOffs(player.index, "m_iSpawnCounter")+0x02, 0);
}

public void BuildingThink(int iClient)
{
	const int iObjectType = 4;	//view_as<int>(TFObjectType);
	const int iObjectMode = 2;	//view_as<int>(TFObjectMode);
	int iBuilding[iObjectType][iObjectMode];	//Building index built from client

	TFTeam nTeam = TF2_GetClientTeam(iClient);

	//Get buildings that were healed
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && TF2_GetClientTeam(i) == nTeam)
		{
			int iPatient = GetHealingTarget(i);
			if (iPatient > MaxClients)
			{
				if (HasEntProp(iPatient, Prop_Send, "m_iUpgradeLevel") && GetEntPropEnt(iPatient, Prop_Send, "m_hBuilder") == iClient)
				{
					TFObjectType nType = view_as<TFObjectType>(GetEntProp(iPatient, Prop_Send, "m_iObjectType"));
					TFObjectType nMode = view_as<TFObjectType>(GetEntProp(iPatient, Prop_Send, "m_iObjectMode"));
					iBuilding[nType][nMode] = iPatient;
				}
			}
		}
	}

	//Sentry
	if (iBuilding[TFObject_Sentry][TFObjectMode_None] > MaxClients)
		TF2Attrib_SetByDefIndex(iClient, 343, 0.5);
	else TF2Attrib_SetByDefIndex(iClient, 343, 1.0);

	//Dispenser
	if (iBuilding[TFObject_Dispenser][TFObjectMode_None] > MaxClients && !GetEntProp(iBuilding[TFObject_Dispenser][TFObjectMode_None], Prop_Send, "m_bBuilding"))
	{
		int metal = GetEntProp(iBuilding[TFObject_Dispenser][TFObjectMode_None], Prop_Send, "m_iAmmoMetal");
		if (metal < 400)
			SetEntProp(iBuilding[TFObject_Dispenser][TFObjectMode_None], Prop_Send, "m_iAmmoMetal", metal+1);
	}

	//Teleporter
	int ent = iBuilding[TFObject_Teleporter][TFObjectMode_Entrance];
	if (ent > MaxClients)
		IncCharge(ent);
	ent = iBuilding[TFObject_Teleporter][TFObjectMode_Exit];
	if (ent > MaxClients)
		IncCharge(ent);
}

stock void IncCharge(int ent)
{
	float time = GetEntPropFloat(ent, Prop_Send, "m_flRechargeTime")-0.1;
	if (time > GetGameTime())
	{
		SetEntPropFloat(ent, Prop_Send, "m_flRechargeTime", time);
		ent = TF2_GetMatchingTeleporter(ent);
		if (ent > MaxClients)
			SetEntPropFloat(ent, Prop_Send, "m_flRechargeTime", time);
	}
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (VSH2GameMode_GetProperty("iSpecialRound") & ROUND_MANNPOWER)
	{
		hSpawnLocs.Clear();
		int i = -1;
		while ((i = FindEntityByClassname(i, "item_healthkit_*")) != -1)
			hSpawnLocs.Push(i);

		i = -1;
		while ((i = FindEntityByClassname(i, "item_ammopack_*")) != -1)
			hSpawnLocs.Push(i);

		int loc, rune;
		int len = hSpawnLocs.Length > 8 ? 8 : hSpawnLocs.Length;
		float pos[3];
		for (i = 0; i < len; ++i)
		{
			loc = hSpawnLocs.Get(GetRandomInt(0, hSpawnLocs.Length-1));
			GetEntPropVector(loc, Prop_Send, "m_vecOrigin", pos);

			rune = MakeRune(GetRandRune(), pos);
			if (!(VSH2GameMode_GetProperty("iSpecialRound") & ROUND_HVH))
				SetEntProp(rune, Prop_Send, "m_iTeamNum", VSH2GameMode_GetProperty("iOtherTeam"));
			SetEntProp(rune, Prop_Send, "m_nSkin", 0);
		}

		SetPawnTimer(DoCreateRune, 30.0, VSH2GameMode_GetProperty("iRoundCount"));
	}
}

public void DoCreateRune(int roundcount)
{
	if (VSH2GameMode_GetProperty("iRoundState") != StateRunning)
		return;

	if (roundcount != VSH2GameMode_GetProperty("iRoundCount"))
		return;

	int pack = hSpawnLocs.Get(GetRandomInt(0, hSpawnLocs.Length-1));
	float pos[3];
	GetEntPropVector(pack, Prop_Send, "m_vecOrigin", pos);
	int rune = MakeRune(GetRandRune(), pos);
	if (!(VSH2GameMode_GetProperty("iSpecialRound") & ROUND_HVH))
		SetEntProp(rune, Prop_Send, "m_iTeamNum", VSH2GameMode_GetProperty("iOtherTeam"));
	SetEntProp(rune, Prop_Send, "m_nSkin", 0);
	SetPawnTimer(DoCreateRune, 30.0, VSH2GameMode_GetProperty("iRoundCount"));
}

public void OnClientPutInServer(int client)
{
	DHookEntity(hJump, true, client);
//	DHookEntity(hTakeHealth, false, client);
//	DHookEntity(hHook_SetSequence, false, client);
	bHit[client] = false;
}

public int TF2Items_OnGiveNamedItem_Post(int iClient, char[] sClassname, int iItemDefIndex, int iLevel, int iQuality, int iEntity)
{
	switch (iItemDefIndex)
	{
		case 220,	// Shortstop
			 772, 	// BFB
			 239, 1084, 1100,	// GRU
			 415, 	// Reserve Shooter
			 331,	// Fists of Steel
			 413,	// Solemn Vow
			 224,	// Letranger
			 60,	// Cloak and Dagger
			 730, 	// Beggar's
			 41:	// Natascha
		{
			Address pCEconItemView = GetEntityAddress(iEntity) + view_as<Address>(g_iCEconItem_m_Item);
			g_HookIDs[0][iEntity] = g_hDHookItemIterateAttribute.HookRaw(Hook_Pre, pCEconItemView, CEconItemView_IterateAttributes);
			g_HookIDs[1][iEntity] = g_hDHookItemIterateAttribute.HookRaw(Hook_Post, pCEconItemView, CEconItemView_IterateAttributes_Post);
		}
	}
}

public void OnEntityDestroyed(int ref)
{
	int ent = ref & 0x7FF;
	if (g_HookIDs[0][ent] != INVALID_HOOK_ID)
	{
		DynamicHook.RemoveHook(g_HookIDs[0][ent]);
		g_HookIDs[0][ent] = INVALID_HOOK_ID;
	}
	if (g_HookIDs[1][ent] != INVALID_HOOK_ID)
	{
		DynamicHook.RemoveHook(g_HookIDs[1][ent]);
		g_HookIDs[1][ent] = INVALID_HOOK_ID;
	}
}

public MRESReturn CBasePlayer_Jump(int pThis)
{
	if (GetEntProp(pThis, Prop_Send, "m_iAirDash") != 2)
		bHit[pThis] = false;
	else
	{
		int wep = GetEntPropEnt(pThis, Prop_Send, "m_hActiveWeapon");
		if (IsValidEntity(wep) && GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex") == 450 && !bHit[pThis])
		{
			SDKHooks_TakeDamage(pThis, 0, 0, 15.0, DMG_PREVENT_PHYSICS_FORCE);
			bHit[pThis] = true;
		}
	}
	return MRES_Ignored;
}

public MRESReturn Hook_AllowedToHealTarget(int pThis, Handle hReturn, Handle hParams)
{
	if (GetItemIndex(pThis) != 998)
		return MRES_Ignored;

	int iHealTarget = DHookGetParam(hParams, 1);
	int iClient = GetEntPropEnt(pThis, Prop_Send, "m_hOwnerEntity");
	
	if (0 < iClient <= MaxClients && IsClientInGame(iClient) && iHealTarget > MaxClients && GetEntProp(iHealTarget, Prop_Send, "m_iTeamNum") == GetClientTeam(iClient))
	{
		char cls[64]; GetEntityClassname(iHealTarget, cls, sizeof(cls));
		if (!strcmp(cls, "obj_teleporter", false) || !strcmp(cls, "obj_sentrygun", false) || !strcmp(cls, "obj_dispenser", false))
		{
			DHookSetReturn(hReturn, true);
			return MRES_Supercede;
		}
	}

	return MRES_Ignored;
}

public MRESReturn CTFRune_MyTouch(int pThis, Handle hParams)
{
	int client = DHookGetParam(hParams, 1);
	if (0 < client <= MaxClients)
		if (VSH2Player(client).bIsBoss)
			return MRES_Supercede;
	return MRES_Ignored;
}

stock RuneTypes GetRandRune()
{
	int val;
	do
		val = GetRandomInt(0, 11);
		while (val == 10 || val == 8);
	return view_as< RuneTypes >(val);
}

public void OnEntityCreated(int ent, const char[] classname)
{
	if (!strncmp(classname, "item_", 5, false))
		DHookEntity(hItemCanBeTouchedByPlayer, false, ent);
	else if (!strcmp(classname, "tf_weapon_sword", false))
		DHookEntity(hGetSwordSpeedMod, false, ent);
	else if (!strcmp(classname, "tf_weapon_shovel", false))
	{
		DHookEntity(hHasDamageBoost, false, ent);
		DHookEntity(hHasSpeedBoost, false, ent);
	}
// 	else if (!strcmp(classname, "tf_weapon_handgun_scout_primary", false))
// 	{
// 		DHookEntity(hGetProjectileSpeed, false, ent);
// 		DHookEntity(hGetProjectileGravity, false, ent);
// 	}
}

public MRESReturn CItem_ItemCanBeTouchedByPlayer(int pThis, Handle hReturn, Handle hParams)
{
	int other = DHookGetParam(hParams, 1);
	if (0 < other <= MaxClients)
		if (VSH2Player(other).bIsBoss)
		{
			DHookSetReturn(hReturn, false);
			return MRES_Supercede;
		}
	return MRES_Ignored;
}

public MRESReturn CTFSword_GetSwordSpeedMod(int pThis, Handle hReturn)
{
	int owner = GetEntPropEnt(pThis, Prop_Send, "m_hOwnerEntity");
	if (!(0 < owner <= MaxClients))
		return MRES_Ignored;

	int heads = GetEntProp(owner, Prop_Send, "m_iDecapitations");
	if (heads <= 0)
		return MRES_Ignored;

	if (heads > 16)
		heads = 16;

	float val = 1.0 + SquareRoot(float(heads)) * 0.08;
	DHookSetReturn(hReturn, val);
	return MRES_Supercede;
}

public MRESReturn CTFStunBall_ApplyBallImpactDamageEffectToVictim(int pThis, Handle hParams)
{
	int owner = GetEntPropEnt(pThis, Prop_Send, "m_hOwnerEntity");
	if (!(0 < owner <= MaxClients))
		return MRES_Ignored;

	int other = DHookGetParam(hParams, 1);
	if (!(0 < other <= MaxClients))
		return MRES_Ignored;

	if (!TF2_IsKillable(other))
		return MRES_Ignored;

	VSH2Player player = VSH2Player(other);
	if (player.bIsBoss)
	{
		float time = GetGameTime() - GetEntDataFloat(pThis, GetEntSendPropOffs(pThis, "m_iType")+4);	// Initial launch time
		if (time > 0.1)
		{
			if (time > 1.0)
				time = 1.0;

			player.flCharge -= 25.0*time;
//			PrintToChatAll("charge -= %.2f = %.2f", 25.0*time, player.flCharge);
		}
	}
	return MRES_Ignored;
}

float g_hp;
bool g_heal;

public MRESReturn CTFPlayer_AddCustomAttribute(int pThis, Handle hParams)
{
	if (!(0 < pThis <= MaxClients))
		return MRES_Ignored;

	char attrib[32]; DHookGetParamString(hParams, 1, attrib, sizeof(attrib));
	if (!strcmp(attrib, "hidden maxhealth non buffed", false) 
	&& view_as< float >(DHookGetParam(hParams, 2)) == 50.0
	&& view_as< float >(DHookGetParam(hParams, 3)) == 30.0)
	{
		DHookSetParam(hParams, 2, 200.0);
		int hp = GetEntProp(pThis, Prop_Send, "m_iHealth");
		if (hp < 500.0)
		{
			float scale;
			scale = 500.0 - hp;
			if (scale > 50.0)
				scale = 50.0;

			g_hp = scale;
		}
		else g_hp = 50.0;

		g_heal = true;
		return MRES_ChangedHandled;
	}
	return MRES_Ignored;
}

public MRESReturn CTFLunchBox_ApplyBiteEffects(int pThis, Handle hParams)
{
	int owner = DHookGetParam(hParams, 1);
	if (!(0 < owner <= MaxClients))
		return MRES_Ignored;

	int idx = GetEntProp(pThis, Prop_Send, "m_iItemDefinitionIndex");
	if (idx == 42 || idx == 863 || idx == 1002)
	{
		SetEntityHealth(owner, 450);
		SetEntPropFloat(owner, Prop_Send, "m_flItemChargeMeter", 0.0, 1);
		SetAmmo(owner, TFWeaponSlot_Secondary, 0);
	}
	return MRES_Ignored;
}

public MRESReturn CTFLunchBox_ApplyBiteEffects_Post(int pThis, Handle hParams)
{
	if (g_heal)
	{
		g_hp = 0.0;
		g_heal = false;
	}
	return MRES_Ignored;
}

bool g_Milked;

public MRESReturn CTFWeaponBase_ApplyOnHitAttributes(int pThis, DHookParam hParams)
{
	if (hParams.IsNull(1))
		return MRES_Ignored;

	int victim = hParams.Get(1);
	if (0 < victim <= MaxClients && IsClientInGame(victim))
	{
		if (TF2_IsPlayerInCondition(victim, TFCond_Milked))
			g_Milked = true;
	}

	return MRES_Ignored;
}

public MRESReturn CTFWeaponBase_ApplyOnHitAttributes_Post(int pThis, DHookParam hParams)
{
	g_Milked = false;
	return MRES_Ignored;
}

public MRESReturn CBaseEntity_TakeHealth(int pThis, Handle hReturn, DHookParam hParams)
{
	if (g_heal)
	{
		DHookSetParam(hParams, 1, g_hp);
		g_heal = false;
		return MRES_ChangedHandled;
	}
	else if (g_Milked)
	{
		int bits = hParams.Get(2);
		bits |= DMG_BULLET; // DMG_IGNORE_MAXHEALTH
		hParams.Set(2, bits);

		float hp = hParams.Get(1);

		int currhp = GetEntProp(pThis, Prop_Data, "m_iHealth");
		float maxmaxhp = GetEntProp(pThis, Prop_Data, "m_iMaxHealth") * 1.5;
		if (hp > maxmaxhp - currhp)
		{
			hp = maxmaxhp - currhp;
			if (currhp > hp)
			{
				DHookSetReturn(hReturn, 0);
				return MRES_Supercede;
			}
			hParams.Set(1, hp);
			return MRES_ChangedHandled;
		}
	}
	return MRES_Ignored;
}

int bonk;
public MRESReturn CTFPlayer_DoTauntAttack(int pThis)
{
	bonk = true;
	return MRES_Ignored;
}

public MRESReturn CTFPlayer_DoTauntAttack_Post(int pThis)
{
	bonk = false;
	return MRES_Ignored;
}

public MRESReturn CTFPlayerShared_AddCond(Address pThis, Handle hParams)
{
	if (!bonk)
		return MRES_Ignored;

	TFCond cond = DHookGetParam(hParams, 1);
	if (cond != TFCond_Bonked)
		return MRES_Ignored;

	DHookSetParam(hParams, 1, TFCond_SpeedBuffAlly);

	// Offset 400
//	Address m_pOuter = ptr(FindSendPropInfo("CTFPlayer", "m_nNumHealers") - FindSendPropInfo("CTFPlayer", "m_Shared") + 8);
//	int client = GetEntityFromAddress(ptr(ReadInt(pThis + m_pOuter)));

//	SetEntityHealth(client, 300);
	return MRES_ChangedHandled;
}

bool cloak;
public MRESReturn CAmmoPack_MyTouch(Handle hParams)
{
	cloak = true;
	return MRES_Ignored;
}
public MRESReturn CAmmoPack_MyTouch_Post(Handle hParams)
{
	cloak = false;
	return MRES_Ignored;
}
public MRESReturn CTFPlayerShared_AddToSpyCloakMeter(Handle hParams)
{
	if (cloak)
	{
		float val = DHookGetParam(hParams, 1);
		val /= 2.0;
		DHookSetParam(hParams, 1, val);
		return MRES_ChangedHandled;
	}
	return MRES_Ignored;
}

public MRESReturn CTFShovel_HasSpeedBoost(int pThis, DHookReturn hReturn)
{
	return _HasBoost(pThis, hReturn);
}
public MRESReturn CTFShovel_HasDamageBoost(int pThis, DHookReturn hReturn)
{
	return _HasBoost(pThis, hReturn);
}

public MRESReturn _HasBoost(int pThis, DHookReturn hReturn)
{
	int idx = GetEntProp(pThis, Prop_Send, "m_iItemDefinitionIndex");
	if (idx == 128 || idx == 775)
	{
		hReturn.Value = true;
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public MRESReturn CTFWeaponBaseGun_GetProjectileSpeed(int pThis, DHookReturn hReturn) {
	int idx = GetEntProp(pThis, Prop_Send, "m_iItemDefinitionIndex");
	if (idx != 220)
		return MRES_Ignored;
	hReturn.Value = 2400.0;
	return MRES_Supercede;
}

public MRESReturn CTFWeaponBaseGun_GetProjectileGravity(int pThis, DHookReturn hReturn) {
	int idx = GetEntProp(pThis, Prop_Send, "m_iItemDefinitionIndex");
	if (idx != 220)
		return MRES_Ignored;
	hReturn.Value = 0.2;
	return MRES_Supercede;
}

bool bDonk;

public MRESReturn CTFGameRules_ApplyOnDamageModifyRules(Address pThis, DHookReturn hReturn, DHookParam hParams)
{
	Address damageinfo = hParams.Get(1);
	int hWeapon = LoadFromAddress(damageinfo + view_as< Address >(0x2C), NumberType_Int32);
	if (hWeapon == -1)
		return MRES_Ignored;

	int weapon = GetEntityFromHandle(hWeapon);
	if (!IsValidEntity(weapon) || weapon == 0)
		return MRES_Ignored;

	int idx = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	if (idx == 996)
	{
		bDonk = true;
		StoreToAddress(g_Donk, g_DonkNew, NumberType_Int16);
	}
	return MRES_Ignored;
}

public MRESReturn CTFGameRules_ApplyOnDamageModifyRules_Post(Address pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (bDonk)
	{
		bDonk = false;
		StoreToAddress(g_Donk, g_DonkOld, NumberType_Int16);
	}
	return MRES_Ignored;
}


static MRESReturn CEconItemView_IterateAttributes(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(g_iCEconItemView_m_bOnlyIterateItemViewAttributes), true, NumberType_Int8, false);
	return MRES_Ignored;
}

static MRESReturn CEconItemView_IterateAttributes_Post(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(g_iCEconItemView_m_bOnlyIterateItemViewAttributes), false, NumberType_Int8, false);
	return MRES_Ignored;
}

stock Address GetStudioHdr(int ent)
{
	return view_as< Address >(GetEntData(ent, FindDataMapInfo(ent, "m_flFadeScale") + 28));
}

public Action TF2_OnRuneSpawn(float pos[3], RuneTypes &type, int &teammaybe, bool &thrown, bool &idk3, float idk4[3])
{
	teammaybe = -2;
	return Plugin_Changed;
}

// stock int LookupSequence(int ent, Address pStudioHdr, const char[] str)
// {
// 	return SDKCall(hLookupSequence, pStudioHdr, str);
// }

// stock void ResetSequence(int ent, int seq)
// {
// 	SDKCall(hResetSequence, ent, seq);
// }

stock int TF2_GetMatchingTeleporter(int iTele)	//Get the matching teleporter entity of a given Teleporter
{
	int iMatch = -1;
	
	if (IsValidEntity(iTele) && HasEntProp(iTele, Prop_Send, "m_bMatchBuilding"))
		iMatch = GetEntDataEnt2(iTele, FindSendPropInfo("CObjectTeleporter", "m_bMatchBuilding")+4);
	
	return iMatch;
}

stock Handle DHookCreateEx(GameData gc, const char[] key, HookType hooktype, ReturnType returntype, ThisPointerType thistype, DHookCallback callback)
{
	int iOffset = GameConfGetOffset(gc, key);
	if(iOffset == -1)
	{
		SetFailState("Failed to get offset of %s", key);
		return null;
	}
	
	return DHookCreate(iOffset, hooktype, returntype, thistype, callback);
}

stock int MakeRune(RuneTypes type, float pos[3], float ang[3] = NULL_VECTOR)
{
	int ent = CreateEntityByName("item_powerup_rune");
	TeleportEntity(ent, pos, ang, NULL_VECTOR);
	SetEntData(ent, FindDataMapInfo(ent, "m_iszModel")+24, type);
	DispatchSpawn(ent);
	SetEntData(ent, FindDataMapInfo(ent, "m_iszModel")+24, type);
	return ent;
}

//stock int SDK_GetMaxAmmo(int client, int slot, int idk = -1)
//{
//	return SDKCall(hGetMaxAmmo, client, slot, idk);
//}
stock int GetEntityFromHandle(any handle)
{
	int ent = handle & 0xFFF;
	if (ent == 0xFFF)
		ent = -1;
	return ent;
}