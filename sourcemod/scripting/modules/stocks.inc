#define EF_BONEMERGE                (1 << 0)
#define EF_PARENT_ANIMATES          (1 << 9)

public char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
public char extensionsb[2][5] = { ".vtf", ".vmt" };

stock int GetHealingTarget(const int client)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (medigun == -1)
		return -1;
	char cls[32]; GetEntityClassname(medigun, cls, sizeof(cls));
	if (!strncmp(cls, "tf_weapon_medi", 14, false)) {
		if ( GetEntProp(medigun, Prop_Send, "m_bHealing") )
			return GetEntPropEnt( medigun, Prop_Send, "m_hHealingTarget" );
	}
	return -1;
}
stock int GetActiveWep(const int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (IsValidEntity(weapon))
		return weapon;
	return -1;
}
stock float GetMediCharge(const int medigun)
{
	if (IsValidEntity(medigun))
		return GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	return -1.0;
}
stock void SetMediCharge(const int medigun, const float val)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun))
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}
stock bool IsNearSpencer(const int client)
{
	int numhealers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	for (int i = 0; i < numhealers; ++i)
	{
		if (IsDispenserHeal(client, i))
			return true;
	}
	return false;
}
//Prepare content stocks
stock void CheckDownload(const char[] dlpath)
{
	if ( FileExists(dlpath) )
		AddFileToDownloadsTable(dlpath);
}
//Following 'Prepare' stocks taken from VSH1
//'Prepare' stocks will precache && add to the downloads table (if file exists).
stock void PrepareSound(const char[] szSoundPath) //For single custom sound files
{
	PrecacheSound(szSoundPath, true);
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "sound/%s", szSoundPath);
	CheckDownload(s);
}
stock void DownloadSoundList(const char[][] szFileList, int iSize) //For arrays of custom sounds
{
	for (int i = 0; i < iSize; i++)
	{
		PrepareSound(szFileList[i]);
	}
}
stock void PrecacheSoundList(const char[][] szFileList, int iSize) //For arrays of stock TF2 sounds
{
	for (int i = 0; i < iSize; i++)
	{
		PrecacheSound(szFileList[i], true);
	}
}
stock void PrepareMaterial(const char[] szMaterialPath) //For single custom materials, omit file extensions as it prepares VMT + VTF
{
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%s", szMaterialPath, ".vtf");
	CheckDownload(s);
	Format(s, sizeof(s), "%s%s", szMaterialPath, ".vmt");
	CheckDownload(s);
}
stock void DownloadMaterialList(const char[][] szFileList, int iSize) //For arrays of custom materials
{
	char s[PLATFORM_MAX_PATH];
	for (int i = 0; i < iSize; i++)
	{
		strcopy(s, sizeof(s), szFileList[i]);
		CheckDownload(s);
	}
}
stock int PrepareModel(const char[] szModelPath, bool bMdlOnly = false) //For custom models, do !omit .MDL extension
{
	char szBase[PLATFORM_MAX_PATH];
	char szPath[PLATFORM_MAX_PATH];
	int i;
	strcopy(szBase, sizeof(szBase), szModelPath);
	SplitString(szBase, ".mdl", szBase, sizeof(szBase)); //Kind of redundant, but eh.
	
	if (!bMdlOnly)
	{
		for (i = 0; i < sizeof(extensions); i++)
		{
			Format(szPath, PLATFORM_MAX_PATH, "%s%s", szBase, extensions[i]);
			CheckDownload(szPath);
		}
	}
	else
		CheckDownload(szModelPath);
	
	return PrecacheModel(szModelPath, true);
}
//End 'Prepare' stocks
public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	return (entity != data);
}
stock void ForceTeamWin(const int team)
{
	int entity = FindEntityByClassname(-1, "team_control_point_master");
	if (entity <= 0) {
		entity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}
stock int GetItemIndex(const int item)
{
	if (IsValidEntity(item) && HasEntProp(item, Prop_Send, "m_iItemDefinitionIndex"))
		return GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
	return -1;
}
stock int GetItemQuality(const int item)
{
	if (IsValidEntity(item))
		return GetEntProp(item, Prop_Send, "m_iEntityQuality");
	return -1;
}
stock int GetIndexOfWeaponSlot(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	return GetItemIndex(weapon);
}
stock bool IsInRange(const int entity, const int target, const float dist, bool pTrace = false)
{
	float entitypos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", entitypos);
	float targetpos[3]; GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetpos);

	if ( GetVectorDistance(entitypos, targetpos) <= dist )
	{
		if (!pTrace)
			return true;
		else {
			TR_TraceRayFilter( entitypos, targetpos, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, entity );
			if ( TR_GetFraction() > 0.98 )
				return true;
		}
	}
	return false;
}
stock int AttachParticle(const int ent, const char[] particleType, float offset = 0.0, bool battach = true, bool remove = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[32];
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach) {
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	if (remove)
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(particle));
	return particle;
}
stock void CreateParticles(char[] particlename, float Pos[3] = NULL_VECTOR, float time)
{
	int particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle)) {
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, Pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(time, RemoveEnt, EntIndexToEntRef(particle));
	}
	else LogError("CreateParticles: **** Couldn't Create 'info_particle_system Entity' ****");
}
stock void SetWeaponInvis(const int client, const int alpha)
{
	int transparent = alpha;
	for (int i = 0; i < 5; i++) {
		int entity = GetPlayerWeaponSlot(client, i); 
		if ( IsValidEntity(entity) )
		{
			if (transparent > 255)
				transparent = 255;
			if (transparent < 0)
				transparent = 0;
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
			SetEntityRenderColor(entity, 150, 150, 150, transparent); 
		}
	}
	return;
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		static int iAmmoTable;
		if (!iAmmoTable)
			iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		static int iAmmoTable;
		if (!iAmmoTable)
			iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if (IsValidEntity(weapon))
	{
		return GetEntProp(weapon, Prop_Send, "m_iClip1");
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if (IsValidEntity(weapon))
	{
		SetEntProp(weapon, Prop_Send, "m_iClip1", ammo, 4, true);
	}
	return 0;
}
stock int ShootRocket(const int client, bool bCrit = false, float vPosition[3], float vAngles[3], const float flSpeed, const float dmg, const char[] model, bool arc=false)
{
//new String:strEntname[45] = "tf_projectile_spellfireball";
/*
switch (spell)
	{
		case FIREBALL: 		strEntname = "tf_projectile_spellfireball";
		case LIGHTNING: 	strEntname = "tf_projectile_lightningorb";
		case PUMPKIN: 		strEntname = "tf_projectile_spellmirv";
		case PUMPKIN2: 		strEntname = "tf_projectile_spellpumpkin";
		case BATS: 			strEntname = "tf_projectile_spellbats";
		case METEOR: 		strEntname = "tf_projectile_spellmeteorshower";
		case TELE: 			strEntname = "tf_projectile_spelltransposeteleport";
		case BOSS:			strEntname = "tf_projectile_spellspawnboss";
		case ZOMBIEH:		strEntname = "tf_projectile_spellspawnhorde";
		case ZOMBIE:		strEntname = "tf_projectile_spellspawnzombie";
	}
	switch(spell)
	{
		//These spells have arcs.
		case BATS, METEOR, TELE:
		{
			vVelocity[2] += 32.0;
		}
	}

CTFGrenadePipebombProjectile m_bCritical
CTFProjectile_Rocket m_bCritical
CTFProjectile_SentryRocket m_bCritical
CTFWeaponBaseGrenadeProj m_bCritical
CTFMinigun m_bCritShot
CTFFlameThrower m_bCritFire
CTFProjectile_Syringe
CTFPlayer m_iCritMult
SetEntPropFloat(iProjectile, Prop_Send, "m_flDamage", dmg);
	}
*/
	int iTeam = GetClientTeam(client);
	int iProjectile = CreateEntityByName("tf_projectile_rocket");
	
	if (!IsValidEdict(iProjectile))
		return 0;

	float vVelocity[3];
	GetAngleVectors(vAngles, vVelocity, NULL_VECTOR, NULL_VECTOR);

	if (!arc)
		NormalizeVector(vVelocity, vVelocity);
	else
		vVelocity[2] -= 0.025;

	ScaleVector(vVelocity, flSpeed);
	SetEntPropEnt(iProjectile,	Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iProjectile,		Prop_Send, "m_bCritical", (bCrit ? 1 : 0));
	SetEntProp(iProjectile,		Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,		Prop_Send, "m_nSkin", (iTeam-2));

	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);

	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	if (arc)
		SetEntityMoveType(iProjectile, MOVETYPE_FLYGRAVITY);
	if ( model[0] != '\0' )
		SetEntityModel(iProjectile, model);
	return iProjectile;
}

stock void SetClientOverlay(const int client, const char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}

stock bool IsValidClient(const int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients)
		return false;
	if (!IsClientInGame(client))
		return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching"))
		return false;
	if (replaycheck)
		if (IsClientSourceTV(client) || IsClientReplay(client))
			return false;
	if (TF2_GetPlayerClass(client) == TFClass_Unknown)
		return false;
	return true;
}
stock int GetOwner(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock int GetBuilder(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hBuilder");
	return -1;
}
stock int GetGroundEntity(const int client)
{
	if ( IsValidClient(client, false))
		return GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	return -1;
}
stock int FindTeleOwner(const int client)
{
	int teleporter = GetGroundEntity(client);
	char classname[32];
	if (IsValidEntity(teleporter) && GetEdictClassname(teleporter, classname, sizeof(classname)) && !strcmp(classname, "obj_teleporter", false))
	{
		int owner = GetBuilder(teleporter);
		if (IsValidClient(owner, false))
			return owner;
	}
	return -1;
}
stock void TeleportToSpawn(const int client, int team = 0)	// Props to Chdata!
{
	int iEnt = -1;
	float vPos[3], vAng[3];
	ArrayList hArray = new ArrayList();
	while ((iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1)
	{
		if (GetEntProp(iEnt, Prop_Data, "m_bDisabled"))
			continue;
		if (team <= 1)
			hArray.Push(iEnt);
		else {
			int iSpawnTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
			if (iSpawnTeam == team)
				hArray.Push(iEnt);
		}
	}
	iEnt = hArray.Get(GetRandomInt(0, hArray.Length - 1));
	hArray.Close();

	// Technically you'll never find a map without a spawn point. !a good map at least.
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(client, vPos, vAng, NULL_VECTOR);

	/*if (Special == VSHSpecial_HHH) //reserved for HHH boss
	{
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(iEnt, "ghost_appearation", _, false)));
		EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
	}*/
}
stock void DoExplosion(const int owner, const int damage, const int radius, float pos[3], int inflictor = 0)
{
	int explode = CreateEntityByName("env_explosion");
	if ( !IsValidEntity(explode) )
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

stock float[] nSubtractVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] - vec2[0];
	result[1] = vec1[1] - vec2[1];
	result[2] = vec1[2] - vec2[2];
	return result;
}
stock float[] nAddVectors(const float vec1[3], const float vec2[3])
{
	float result[3];
	result[0] = vec1[0] + vec2[0];
	result[1] = vec1[1] + vec2[1];
	result[2] = vec1[2] + vec2[2];
	return result;
}
stock float[] nScaleVector(const float vec[3], const float scale)
{
	float result[3];
	result[0] = vec[0] * scale;
	result[1] = vec[1] * scale;
	result[2] = vec[2] * scale;
	return result;
}
stock float[] nNegateVector(const float vec[3])
{
	float result[3];
	result[0] = -vec[0];
	result[1] = -vec[1];
	result[2] = -vec[2];
	return result;
}
stock bool VectorCompare (const float v1[3], const float v2[3])
{
	for (int i=0 ; i<3 ; i++)
		if (v1[i] != v2[i])
			return false;
			
	return true;
}
stock bool OnlyScoutsAndSpiesLeft(const int team)
{
	for (int i=MaxClients ; i ; --i) {
		if ( !IsClientInGame(i) || !IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) != team)
			continue;

		if (TF2_GetPlayerClass(i) == TFClass_Scout || TF2_GetPlayerClass(i) == TFClass_Spy)
			continue;

		return false;
	}
	return true;
}
stock int GetLivingPlayers(const int team)
{
	int AlivePlayers = 0;
	for (int i=MaxClients ; i ; --i) {
		if ( IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == team )
			++AlivePlayers;
	}
	return AlivePlayers;
}
stock int GetDeadPlayers()
{
	int players;
	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i) && !IsPlayerAlive(i))
			++players;
	}
	return players;
}
stock int GetDeadPlayerArray(int[] array)
{
	int players;
	for (int i = MaxClients; i; --i)
	{
		if (IsClientInGame(i) && !IsPlayerAlive(i))
			array[players++] = i;
	}
	return players;
}
stock int GetRandomPlayer(bool alive = true)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (alive && !IsPlayerAlive(i))
			continue;
		else if (!alive && IsPlayerAlive(i))
			continue;
		clients[clientCount++] = i;
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}
stock int GetRandomClient(int team, bool alive = true)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;
		if (alive && !IsPlayerAlive(i))
			continue;
		if (GetClientTeam(i) != team)
			continue;

		clients[clientCount++] = i;
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}
stock void IncrementHeadCount(const int client, bool addhealth = true, int addheads = 1, int headmult = 15)
{
	if ( (TF2_GetPlayerClass(client) == TFClass_DemoMan) &&  ! TF2_IsPlayerInCondition(client, TFCond_DemoBuff) )
		TF2_AddCondition(client, TFCond_DemoBuff, TFCondDuration_Infinite); //Apply this condition to Demomen to give them their glowing eye effect.
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations + addheads);
	if ( addhealth )
	{
		if( addhealth )
			TF2_HealPlayer(client, headmult * addheads, true);
	}
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
}
stock void SpawnSmallHealthPackAt(const int client, int ownerteam = 0)
{
	if (!IsClientValid(client) || !IsPlayerAlive(client))
		return;
	int healthpack = CreateEntityByName("item_healthkit_small");
	if ( IsValidEntity(healthpack) ) {
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
		//CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
	}
}
stock void SpawnMedHealthPackAt(const int client, int ownerteam = 0)
{
	if (!IsClientValid(client) || !IsPlayerAlive(client))
		return;
	int healthpack = CreateEntityByName("item_healthkit_medium");
	if ( IsValidEntity(healthpack) ) {
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
		//CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
	}
}
public void SickleClimbWalls(const int client, const int weapon, const float upwardvel, const float health, const bool attackdelay)
//Credit to Mecha the Slag
{
	if ( !IsValidClient(client) || (GetClientHealth(client) <= health) )
		return;

	char classname[64];
	float vecClientEyePos[3];
	float vecClientEyeAng[3];
	GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
	GetClientEyeAngles(client, vecClientEyeAng);	   // Get the angle the player == looking

	//Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

	if ( !TR_DidHit(null) )
		return;

	int TRIndex = TR_GetEntityIndex(null);
	GetEdictClassname(TRIndex, classname, sizeof(classname));
	if (!StrEqual(classname, "worldspawn"))
		return;

	float fNormal[3];
	TR_GetPlaneNormal(null, fNormal);
	GetVectorAngles(fNormal, fNormal);

	if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0)
		return;
	if (fNormal[0] <= -30.0)
		return;

	float pos[3];
	TR_GetEndPosition(pos);
	float distance = GetVectorDistance(vecClientEyePos, pos);

	if (distance >= 100.0)
		return;

	float fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

	fVelocity[2] = upwardvel;

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);

	SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));

	//if (!IsBoss[client])
	//	ClientCommand(client, "playgamesound \"%s\"", "player\\taunt_clip_spin.wav");

	if (attackdelay)
		SetPawnTimer(NoAttacking, 0.1, EntIndexToEntRef(weapon));
}
public void NoAttacking(const int wepref)
{
	int weapon = EntRefToEntIndex(wepref);
	SetNextAttack(weapon, 1.56);
}
stock void SetNextAttack(const int weapon, float duration = 0.0)
{
	if (weapon <= MaxClients || !IsValidEntity(weapon))
		return;
	float next = GetGameTime()+duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}
stock void ResetPlayer(const int client)
{
	TF2_RegeneratePlayer(client);
	SetEntityHealth( client, GetEntProp(client, Prop_Data, "m_iMaxHealth") );
	SetEntProp( client, Prop_Send, "m_iHealth", GetEntProp(client, Prop_Data, "m_iMaxHealth") );
}


/**
 * Wrapper function for easily setting up non-repeating timers
 *
 * @param func			Function pointer to call desired function when time elapses
 * @param thinktime		time in seconds when timer function will be called
 * @param param1		1st param for the call back function
 * @param param2		2nd param for the call back function
 *
 * @noreturn
 */

/*
If you need to use this and your function uses 3 parameters, modify it if necessary.
BUG/GLITCH: For some strange reason, SetPawnTimer doesn't work when u attempt to callback stock functions, interesting...
*/
stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);

	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();

	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );

	any param1 = hndl.ReadCell();
	if ( param1 != -999 )
		Call_PushCell(param1);

	any param2 = hndl.ReadCell();
	if ( param2 != -999 )
		Call_PushCell(param2);

	Call_Finish();
	return Plugin_Continue;
}

stock bool DoSuperJump(const int client, const float charge, const float JumpAngle, int& changecharge, const int subtractCharge)
{
	float ang[3]; GetClientEyeAngles(client, ang);
	if ( ang[0] <= JumpAngle ) // default JumpAngle = -45.0
	{
		float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
		vel[2] = 750 + charge * 13.0;
		SetEntProp(client, Prop_Send, "m_bJumping", 1);
		vel[0] *= (1+Sine(charge * FLOAT_PI / 50));
		vel[1] *= (1+Sine(charge * FLOAT_PI / 50));
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		changecharge = subtractCharge;
		return true;
	}
	return false;
}


stock void ForceClientTeamChange(const int client, const int iTeam)
{
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, iTeam);
	SetEntProp(client, Prop_Send, "m_lifeState", 0);
	TF2_RespawnPlayer(client);
}
stock int CalcBossHealth(const float initial, const int playing, const float subtract, const float exponent, const float additional)
{
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}
stock bool IsVSHMap()	// just use arena maps as vsh/ff2 maps
{
	char config[PLATFORM_MAX_PATH], currentmap[99];
	GetCurrentMap(currentmap, sizeof(currentmap));
	if ( FileExists("bNextMapToFF2") )
		{return true;}
	else if ( FileExists("bNextMapToHale") )
		{return true;}

	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/maps.cfg");	// Compatibility :)
	if (!FileExists(config)) {
		BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_maps.cfg");
		if (!FileExists(config)) {
			LogError("[VSH 2] ERROR: **** Unable to find VSH/FF2 Compatibility Map Configs, Disabling VSH 2 ****");
			return false;
		}
	}

	File file = OpenFile(config, "r");
	if ( !file ) {
		LogError("[VSH 2] **** Error Reading Maps from %s Config, Disabling VSH Engine ****", config);
		return false;
	}

	int tries;
	while ( file.ReadLine(config, sizeof(config)) && tries < 100 )
	{
		++tries;
		if (tries == 100) {
			LogError("[VSH 2] **** Breaking Loop Looking For a Map ****");
			return false;
		}

		Format(config, strlen(config)-1, config);
		if ( !strncmp(config, "//", 2, false) )
			continue;

		if ( StrContains(currentmap, config, false) != -1 || StrContains(config, "all", false) != -1 )
		{
			file.Close();
			return true;
		}
	}
	delete file;
	return false;
	//if (FindEntityByClassname(-1, "tf_logic_arena") != -1) return true;
	//return false;
}
stock void SetArenaCapEnableTime(const float time)
{
	int ent = -1;
	char strTime[32]; FloatToString(time, strTime, sizeof(strTime));
	if ( (ent = FindEntityByClassname(-1, "tf_logic_arena")) != -1 )
		DispatchKeyValue(ent, "CapEnableDelay", strTime);
}
stock void SetClientGlow(const int client, const float time1, float clampfl = 0.0, float &glowtimer)
{
	if (IsValidClient(client)) {
		glowtimer += time1;
		if (clampfl > 0.0)
			glowtimer = clampfl;
		if (glowtimer <= 0.0) {
			glowtimer = 0.0;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
		else SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
	}
}
stock void SetControlPoint(const bool enable)
{
	int CPm = -1;
	while ( (CPm = FindEntityByClassname(CPm, "team_control_point")) != -1 )
	{
		if (CPm > MaxClients && IsValidEdict(CPm)) {
			AcceptEntityInput(CPm, (enable ? "ShowModel" : "HideModel"));
			SetVariantInt(enable ? 0 : 1);
			AcceptEntityInput(CPm, "SetLocked");
		}
	}
}
public void EnableCap()
{
	SetControlPoint(true);
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_door")) != -1)
	{
		AcceptEntityInput(ent, "Open");
		AcceptEntityInput(ent, "Unlock");
		//AcceptEntityInput(ent, "Kill");
	}
	//if (doorchecktimer == null)
	//	doorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}
stock void SpawnRandomAmmo()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	int spawned;
	int maxlim = cvarVSH2[AmmoKitLimitMax].IntValue;
	int minlim = cvarVSH2[AmmoKitLimitMin].IntValue;
	while( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 ) {
		if( minlim )
			if( spawned >= minlim )
				if( GetRandomInt(0, 3) )
					continue;
		if( maxlim )
			if( spawned >= maxlim )
				break;
		// Technically you'll never find a map without a spawn point.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		int ammo = CreateEntityByName("item_ammopack_small");
		TeleportEntity(ammo, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(ammo);
		SetEntProp(ammo, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
		++spawned;
	}
}
stock void SpawnRandomHealth()
{
	int iEnt = MaxClients+1;
	float vPos[3], vAng[3];
	int spawned;
	int maxlim = cvarVSH2[HealthKitLimitMax].IntValue;
	int minlim = cvarVSH2[HealthKitLimitMin].IntValue;
	while( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 ) {
		if( minlim )
			if( spawned >= minlim )
				if( GetRandomInt(0, 3) )
					continue;
		if( maxlim )
			if( spawned >= maxlim )
				break;
		// Technically you'll never find a map without a spawn point.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		int healthkit = CreateEntityByName("item_healthkit_small");
		TeleportEntity(healthkit, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(healthkit);
		SetEntProp(healthkit, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
		++spawned;
	}
}
stock int GetTeamPlayerCount(const int team)
{
	int count = 0;
	for (int i=MaxClients ; i ; --i) {
		if (IsValidClient(i) && GetClientTeam(i) == team)
			{count++;}
	}
	return count;
}
stock int GetClientCloakIndex(const int client)
{
	if (!IsValidClient(client))
		return -1;
	int wep = GetPlayerWeaponSlot(client, 4);
	if (wep == -1)
		return -1;
	return GetItemIndex(wep);
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if ( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			{return i;}
	}
	return -1;
}
stock bool RemoveDemoShield(int client) //Taken from VSH1
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
			&& !strcmp(buffer, "tf_wearable_demoshield"))
			{
				TF2_RemoveWearable(client, ent);
				return true;
			}
		}
	}
	return false; //...and returns False if one wasn't found.
}
stock void RemovePlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return;
	int numwearables = TF2_GetNumWearables(client);
	if (numwearables > 0)
	{
		int ent;
		int i;
		for (i = numwearables-1; i >= 0; --i)
		{
			ent = TF2_GetWearable(client, i);
			if (ent == -1)
				continue;

			if (!GetEntProp(ent, Prop_Send, "m_bDisguiseWearable"))
			{
				int idx = GetItemIndex(ent);
				for (int u = 0; u < len; ++u)
					if (idx == indices[u])
						TF2_RemoveWearable(client, ent);
			}
		}
	}
}
stock int FindPlayerBack(int client, int[] indices, int len)
{
	if (len <= 0)
		return -1;
	int numwearables = TF2_GetNumWearables(client);
	if (numwearables > 0)
	{
		int ent;
		int i;
		for (i = numwearables-1; i >= 0; --i)
		{
			ent = TF2_GetWearable(client, i);
			if (ent == -1)
				continue;

			if (!GetEntProp(ent, Prop_Send, "m_bDisguiseWearable"))
			{
				int idx = GetItemIndex(ent);
				for (int u = 0; u < len; ++u)
					if (idx == indices[u])
						return ent;
			}
		}
	}
	return -1;
}
stock int FindSentry(const int client)
{
	return TF2_GetObjectOfType(client, TFObject_Sentry);
}
stock bool TF2_IsPlayerCritBuffed(const int client)
{
	return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
			|| TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
			|| TF2_IsPlayerInCondition(client, TFCond_CritCanteen)
//			|| TF2_IsPlayerInCondition(client, view_as<TFCond>(35))
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
			|| TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnDamage)
			);
}
stock void OverNineThousand()
{
	EmitSoundToAll("saxton_hale/9000.wav");
	EmitSoundToAll("saxton_hale/9000.wav");
}
public void _NoHonorBound(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client) && IsPlayerAlive(client)) {
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[32];
		if ( IsValidEdict(active) )
			GetEdictClassname(active, classname, sizeof(classname));
		if ( index == 357 && active == weapon && !strcmp(classname, "tf_weapon_katana", false) )
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
				SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
}
stock int GetMaxAmmo(const int client, const int slot)
{
	if (!IsValidClient(client))
		return 0;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		switch (slot)
		{ //FindDataMapInfo(client, "m_iAmmo");
			case TFWeaponSlot_Primary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+4);
			case TFWeaponSlot_Secondary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+8);
			case TFWeaponSlot_Melee: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+12);
		}
	}
	return 0;
}
stock Handle PrepareItemHandle(Handle hItem, char[] name = "", int index = -1, const char[] att = "", bool dontpreserve = false)
{
	static Handle hWeapon = null;
	int addattribs = 0;

	char weaponAttribsArray[32][32];
	int attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

	int flags = OVERRIDE_ATTRIBUTES;
	if (!dontpreserve)
		flags |= PRESERVE_ATTRIBUTES;

	if ( !hWeapon )
		hWeapon = TF2Items_CreateItem(flags);
	else TF2Items_SetFlags(hWeapon, flags);
//	Handle hWeapon = TF2Items_CreateItem(flags);	//null;

	if (hItem != null) {
		addattribs = TF2Items_GetNumAttributes(hItem);
		if (addattribs) {
			for (int i=0; i < 2*addattribs; i+=2) {
				bool dontAdd = false;
				int attribIndex = TF2Items_GetAttributeId(hItem, i);
				for (int z=0; z < attribCount+i; z += 2)
				{
					if (StringToInt(weaponAttribsArray[z]) == attribIndex)
					{
						dontAdd = true;
						break;
					}
				}
				if (!dontAdd) {
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(hItem, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2*addattribs;
		}
		delete hItem;
	}

	if (name[0] != '\0') {
		flags |= OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(hWeapon, name);
	}
	if (index != -1) {
		flags |= OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(hWeapon, index);
	}
	if (attribCount > 1)
	{
		TF2Items_SetNumAttributes(hWeapon, attribCount/2);
		int i2 = 0;
		for (int i=0; i<attribCount && i<32; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);
	TF2Items_SetFlags(hWeapon, flags);
	return hWeapon;
}
stock bool IsWeaponSlotActive(const int client, const int slot)
{
	return GetPlayerWeaponSlot(client, slot) == GetActiveWep(client);
}
public void _StopTickle(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")))
		TF2_RemoveCondition(client, TFCond_Taunting);
}
stock bool MapHasMusic(bool forceRecalc = false)	// Does this even work?
{
	static bool hasMusic;
	static bool found = false;
	if (forceRecalc) {
		found = false;
		hasMusic = false;
	}
	if (!found) {
		int i = -1;
		char name[64];
		while ((i = FindEntityByClassname(i, "info_target")) != -1)
		{
			GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
			if ( !strcmp(name, "hale_no_music", false) )
				hasMusic = true;
		}
		found = true;
	}
	return hasMusic;
}
stock bool IsValidAdmin(const int client, const char[] flags)
{
	if (!IsClientInGame(client))
		return false;
	int ibFlags = ReadFlagString(flags);
	if (!StrEqual(flags, "")) {
		if ( (GetUserFlagBits(client) & ibFlags) == ibFlags )
			return true;
	}
	if ( GetUserFlagBits(client) & ADMFLAG_ROOT )
		return true;
	return false;
}
stock int AttachProjectileModel(const int entity, const char[] strModel, char[] strAnim = "")
{
	if (!IsValidEntity(entity))
		return -1;
	int model = CreateEntityByName("prop_dynamic");
	if (IsValidEdict(model)) {
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
		TeleportEntity(model, pos, ang, NULL_VECTOR);
		DispatchKeyValue(model, "model", strModel);
		DispatchSpawn(model);
		SetVariantString("!activator");
		AcceptEntityInput(model, "SetParent", entity, model, 0);
		if (strAnim[0] != '\0') {
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetDefaultAnimation");
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetAnimation");
		}
		SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
		return model;
	}
	else LogError("(AttachProjectileModel): Could not create prop_dynamic");
	return -1;
}
stock bool GetRandomBool()
{
	return ( !GetRandomInt(0, 1) ? false : true );
}
stock void SetAmmo(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}
stock void SetClip(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
}
stock int GetAmmo(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(client, iAmmoTable+iOffset);
	}
	return 0;
}
stock int GetClip(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock void _SetCapOwner(const int iCapTeam, float flEnableTime = 30.0)
{
	int i = -1;
	int cap_master = FindEntityByClassname(-1, "team_control_point_master");
	while ( (i = FindEntityByClassname(i, "team_control_point")) != -1 )
	{
		if (IsValidEntity(i)) {	//Adapted from Arena:Respawn
			SetVariantInt(iCapTeam);
			AcceptEntityInput(i, "SetOwner", -1, cap_master); //Must have team_control_point_master as the activator, less it will just ignore the Input
			SetVariantInt(1);
			AcceptEntityInput(i, "SetLocked");
			SetPawnTimer(EnableCap, flEnableTime);
		}
	}
}
stock bool StrStarts(const char[] szStr, const char[] szSubStr, bool bCaseSensitive = true)
{
	return !StrContains(szStr, szSubStr, bCaseSensitive);
}
stock bool ValidateName(const char[] name)
{
	int length = strlen(name);
	for (int i=0 ; i<length ; ++i) {
		int holder = name[i];
		// Invalid name, names may only contains numbers, underscores && normal letters
		if (!(IsCharAlpha(holder) || IsCharNumeric(holder) || holder == '_'))
			return false;
	}
	// A name is, of course, only valid if it's 1 or more chars long, though longer == recommended
	return (length > 0);
}
stock bool RemoveParachute(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return false;
		
	if (TF2_IsPlayerInCondition(client, TFCond_Parachute))
	{
		TF2_RemoveCondition(client, TFCond_Parachute);
		return true;
	}
	return false;
}
stock void SpawnSmallAmmoPackAt(const int client, int ownerteam = 0)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	int pack = CreateEntityByName("item_ammopack_small");
	if (IsValidEntity(pack))
	{
		float pos[3]; GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		DispatchKeyValue(pack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(pack);
		SetEntProp(pack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(pack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(pack, pos, NULL_VECTOR, vel);
	}
	return;
}
stock float[] Vec_SubtractVectors(const float vec1[3], const float vec2[3])
{
	float result[3]; SubtractVectors(vec1, vec2, result);
	return result;
}
stock float[] Vec_NormalizeVector(const float vec[3])
{
	float output[3]; NormalizeVector(vec, output);
	return output;
}
stock int GetConditionProvider(int client, TFCond cond)
{
	static int m_Shared;
	if (!m_Shared)
		m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	
	Address aCondSource   = view_as< Address >(ReadInt(GetEntityAddress(client) + view_as< Address >(m_Shared + 8)));
	Address aCondProvider = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (3 * 4));
	
	int iProvider = 0;
	if(TF2_IsPlayerInCondition(client, cond))
	{
		iProvider = (ReadInt(aCondProvider) & 0xFFF);
	}
	
	return iProvider;
}
stock int ReadInt(Address pAddr)
{
	if (pAddr == Address_Null)
	{
		return -1;
	}
	
	return LoadFromAddress(pAddr, NumberType_Int32);
}
stock void LoadoutPanel(const int client)
{
	if ( IsVoteInProgress() )
		return;
	Panel panel = new Panel();

	char buffer[512] = "[VSH 2] Your Loadout:";
	char buffercpy[256];
	TFClassType class = TF2_GetPlayerClass(client);

	int wep = GetItemIndex(GetPlayerWeaponSlot(client, 0));
	GetWeaponStat(wep, buffercpy, sizeof(buffercpy), class);
	if (buffercpy[0] != '\0')
		Format(buffer, sizeof(buffer), "%s\n%s", buffer, buffercpy);

	wep = GetItemIndex(GetPlayerWeaponSlot(client, 1));
	GetWeaponStat(wep, buffercpy, sizeof(buffercpy), class);
	if (buffercpy[0] != '\0')
		Format(buffer, sizeof(buffer), "%s\n%s", buffer, buffercpy);

	wep = GetItemIndex(FindPlayerBack(client, { 133, 405, 608, 444, 57, 231, 632, 131, 1144, 406, 1099 }, 11));
	GetWeaponStat(wep, buffercpy, sizeof(buffercpy), class);
	if (buffercpy[0] != '\0')
		Format(buffer, sizeof(buffer), "%s\n%s", buffer, buffercpy);

	wep = GetItemIndex(GetPlayerWeaponSlot(client, 2));
	GetWeaponStat(wep, buffercpy, sizeof(buffercpy), class);
	if (buffercpy[0] != '\0')
		Format(buffer, sizeof(buffer), "%s\n%s", buffer, buffercpy);

	if (class == TFClass_Sniper)
		Format(buffer, sizeof(buffer), "%s: Climb walls by hitting them. No healing allowed while climbing", buffer);
//	else if (class == TFClass_Medic)
//		Format(buffer, sizeof(buffer), "%s\nIf you have at least 90%% ubercharge, you can block 1 hit by Hale.", buffer);
	else if (class == TFClass_Pyro && GetIndexOfWeaponSlot(client, 0) != 30474)
		Format(buffer, sizeof(buffer), "%s\nYou can airblast jump!", buffer);
	else if (class == TFClass_Medic && GetIndexOfWeaponSlot(client, 1) != 411)
		Format(buffer, sizeof(buffer), "%s\nGain ubershield with >= 100%% charge", buffer);

	panel.SetTitle(buffer);

	panel.DrawItem( "Exit" );
	panel.Send(client, HintPanel, 20);
	delete panel;
}

stock int GetRandomIntExcept(const int start, const int end, const int exception)
{
	int endnum = GetRandomInt(start, end);
	if (endnum == exception)
		return GetRandomIntExcept(start, end, exception);
	return endnum;
}

stock void PrintToScag(char[] s, any ...)
{
	char buffer[256];
	VFormat(buffer, sizeof(buffer), s, 2);
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (GetSteamAccountID(i) != 125236808)
			continue;

		CPrintToChat(i, s);
		break;
	}
}

stock void PrintToScagC(char[] s, any ...)
{
	char buffer[256];
	VFormat(buffer, sizeof(buffer), s, 2);
	for (int i = MaxClients; i; --i)
	{
		if (!IsClientInGame(i))
			continue;

		if (GetSteamAccountID(i) != 125236808)
			continue;

		PrintToConsole(i, s);
		break;
	}
}

stock bool IsClientScag(const int client)
{
	return GetSteamAccountID(client) == 125236808;
}

stock int GetHealerByIndex(int client, int index)
{
	static int m_aHealers;
	if (!m_aHealers)
		m_aHealers = FindSendPropInfo("CTFPlayer", "m_nNumHealers") + 12;

	Address m_Shared = GetEntityAddress(client) + view_as<Address>(m_aHealers);
	Address aHealers = view_as<Address>(LoadFromAddress(m_Shared, NumberType_Int32));

	return (LoadFromAddress(aHealers + view_as<Address>(index * 0x24), NumberType_Int32) & 0xFFF);
}

stock bool IsDispenserHeal(int client, int index)
{
	static int m_aHealers;
	if (!m_aHealers)
		m_aHealers = FindSendPropInfo("CTFPlayer", "m_nNumHealers") + 12;

	Address m_Shared = GetEntityAddress(client) + view_as<Address>(m_aHealers);
	Address aHealers = view_as<Address>(LoadFromAddress(m_Shared, NumberType_Int32));

	return !!LoadFromAddress(aHealers + view_as<Address>(index * 0x24 + 20), NumberType_Int8);	
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
	return entity > MaxClients || !entity;
}

public void BuildingHit(int client, int ent)
{
	int index = GetItemIndex(GetActiveWep(client));
	if (index == 153 || index == 466) //If using Homewrecker, Maul, or Neon Annihilator
	{
		if (GetEntPropFloat(ent, Prop_Send, "m_flPercentageConstructed") >= 1.0)
		{
			int health = GetEntProp(ent, Prop_Send, "m_iHealth");
			int maxhealth = GetEntProp(ent, Prop_Send, "m_iMaxHealth");
			int newhealth;

			if (health < maxhealth) //Heal building
			{
				newhealth = health+30;

				if (newhealth > maxhealth)
					newhealth = maxhealth;

				SetEntProp(ent, Prop_Send, "m_iHealth", newhealth);
			}
			int buildlevel = GetEntProp(ent, Prop_Send, "m_iUpgradeLevel");
			int buildmetal = GetEntProp(ent, Prop_Send, "m_iUpgradeMetal");
			int metal = GetEntProp(client, Prop_Send, "m_iAmmo", _, 3);

			if (buildlevel < 3) //Don't build up max level building
			{
				if (metal >= 20) //Enough metal for a full hit
				{
					if (buildmetal+20 < 199) //If this hit won't make the  building hit max upgrade level
					{
						SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", buildmetal+20);
						SetEntProp(client, Prop_Send, "m_iAmmo", metal-20, _, 3);
					}
					else if (buildmetal+20 >= 199) // if it will take the building to max upgrade level (199)
					{
						SetEntProp(client, Prop_Send, "m_iAmmo", metal-(199-buildmetal), _, 3);
						SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", 199);
					}
				}
				else //if you have less than 25 metal
				{
					if (buildmetal+metal < 199) //If this hit won't make the building hit max upg level
					{
						SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", buildmetal+metal);
						SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, 3);
					}
					else //If it will make the building hit max upg level
					{
						SetEntProp(client, Prop_Send, "m_iAmmo", metal-(199-buildmetal), _, 3);
						SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", 199);
					}
				}
			}
		}
	}
}

stock bool IsClientStuck(const int iEntity, const float flOrigin[3], bool ignoreplayers = false)
{
	//float flOrigin[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", flOrigin);
	float flMins[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecMins", flMins);
	float flMaxs[3]; GetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", flMaxs);

	TR_TraceHullFilter(flOrigin, flOrigin, flMins, flMaxs, MASK_PLAYERSOLID, ignoreplayers ? TraceRayDontHitSelf : TraceEntityFilterPlayer, iEntity);
	return TR_DidHit();
}
stock bool TF2_IsKillable(int entity)
{
	bool bResult = true;

	if(entity > 0 && entity <= MaxClients)
	{
		if(TF2_IsPlayerInCondition(entity, TFCond_Ubercharged) 
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedHidden) 
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedCanteen)
		|| TF2_IsPlayerInCondition(entity, TFCond_Bonked)
		|| TF2_IsPlayerInCondition(entity, TFCond_PasstimeInterception))
		{
			bResult = false;
		}
	}

	if(GetEntProp(entity, Prop_Data, "m_takedamage") != 2)
	{
		bResult = false;
	}

	return bResult;
}
stock void TF2_GetClassName(TFClassType class, char[] name, int size, bool capitalize)
{
	switch (class)
	{
		case TFClass_Unknown: strcopy(name, size, "none");
		case TFClass_Scout: strcopy(name, size, "scout");
		case TFClass_Sniper: strcopy(name, size, "sniper");
		case TFClass_Soldier: strcopy(name, size, "soldier");
		case TFClass_DemoMan: strcopy(name, size, "demoman");
		case TFClass_Medic: strcopy(name, size, "medic");
		case TFClass_Heavy: strcopy(name, size, "heavy");
		case TFClass_Pyro: strcopy(name, size, "pyro");
		case TFClass_Spy: strcopy(name, size, "spy");
		case TFClass_Engineer: strcopy(name, size, "engineer");
	}

	if (capitalize)
	{
		name[0] = CharToUpper(name[0]);
	}
}

stock char[] TF2_GetClassName2(TFClassType class, bool cap = false)
{
	char name[16];
	switch (class)
	{
		case TFClass_Unknown: strcopy(name, 16, "none");
		case TFClass_Scout: strcopy(name, 16, "scout");
		case TFClass_Sniper: strcopy(name, 16, "sniper");
		case TFClass_Soldier: strcopy(name, 16, "soldier");
		case TFClass_DemoMan: strcopy(name, 16, "demoman");
		case TFClass_Medic: strcopy(name, 16, "medic");
		case TFClass_Heavy: strcopy(name, 16, "heavy");
		case TFClass_Pyro: strcopy(name, 16, "pyro");
		case TFClass_Spy: strcopy(name, 16, "spy");
		case TFClass_Engineer: strcopy(name, 16, "engineer");
	}

	if (cap)
	{
		name[0] = CharToUpper(name[0]);
	}
	return name;
}

stock bool BringClientToSide(const int client, const float flOrigin[3], bool z = true)
{
	float vec_modifier[3];
	const float flMove = 70.0;
	vec_modifier = flOrigin; vec_modifier[0] += flMove;	// check x-axis
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	vec_modifier = flOrigin; vec_modifier[0] -= flMove;
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	vec_modifier = flOrigin; vec_modifier[1] += flMove;	// check y-axis
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	vec_modifier = flOrigin; vec_modifier[1] -= flMove;
	if (!IsClientStuck(client, vec_modifier)) {
		TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
		return true;
	}

	if (z)
	{
		vec_modifier = flOrigin; vec_modifier[2] += flMove;	// check z-axis
		if (!IsClientStuck(client, vec_modifier)) {
			TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
			return true;
		}
		vec_modifier = flOrigin; vec_modifier[2] -= flMove;
		if (!IsClientStuck(client, vec_modifier)) {
			TeleportEntity(client, vec_modifier, NULL_VECTOR, NULL_VECTOR);
			return true;
		}
	}
	return false;
}

stock float GetConditionDuration(int client, TFCond cond)
{
	static int m_Shared;
	if (!m_Shared)
		m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	
	Address aCondSource   = view_as< Address >(ReadInt(GetEntityAddress(client) + view_as< Address >(m_Shared + 8)));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	
	float flDuration = 0.0;
	if(TF2_IsPlayerInCondition(client, cond))
	{
		flDuration = view_as<float>(LoadFromAddress(aCondDuration, NumberType_Int32));
	}
	
	return flDuration;
}

stock float DamageForce( const float size[3], float damage, float scale )
{ 
	float force = damage * ((48 * 48 * 82.0) / (size[0] * size[1] * size[2])) * scale;
	
	if ( force > 1000.0) 
		force = 1000.0;

	return force;
}

stock bool TF2_IsNextToWall(int client, bool touching = false)
{
	float flPos[3];
	GetClientAbsOrigin(client, flPos);
	
	float flMaxs[3], flMins[3];
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", flMaxs);
	GetEntPropVector(client, Prop_Send, "m_vecMins", flMins);
	
	if (touching)
	{
		flMaxs[0] += 2.5;
		flMaxs[1] += 2.5;
		flMins[0] -= 2.5;
		flMins[1] -= 2.5;		
	}

//	flPos[2] += 18.0;
	
	//Perform a wall check to see if we are near any obstacles we should try jump over
	Handle trace = TR_TraceHullFilterEx(flPos, flPos, flMins, flMaxs, MASK_SOLID, TraceEntityFilterPlayer, client);
	
	bool bHit = TR_DidHit(trace);	
	
	delete trace;
	
	return bHit;
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

stock void TE_SendBeam(int client, float m_vecMins[3], float m_vecMaxs[3], float flDur = 0.1, int color[4])
{
	TE_SetupBeamPoints(m_vecMins, m_vecMaxs, g_iLaserMaterial, g_iHaloMaterial, 0, 0, flDur, 1.0, 1.0, 1, 0.0, color, 0);
	TE_SendToClient(client);
}

public bool WorldOnly(int entity, int contentsMask, any iExclude)
{
	return entity <= 0;
}

stock bool IsStringNumeric(const char[] str)
{
	int n;
	while (str[n] != '\0')
		if (!IsCharNumeric(str[n++]))
			return false;
	return true;
}

stock void SetConVarIntHidden(ConVar cvar, const int value)
{
	char cvar_name[64];
	char value_string[32];
	int flags = cvar.Flags;

	cvar.Flags = flags & ~FCVAR_NOTIFY;
	cvar.SetInt(value);
	cvar.GetName(cvar_name, sizeof(cvar_name));
	IntToString(value, value_string, sizeof(value_string));
	Steam_SetRule(cvar_name, value_string);
	cvar.Flags = flags;
}

stock Address GetStudioHdr(int npc)
{
	return view_as<Address>(GetEntData(npc, FindDataMapInfo(npc, "m_flFadeScale") + 28));
}

stock int EquipItem(int ent, const char[] attachment, const char[] model, const char[] anim = "", int skin = 0, float flScale = 1.0)
{
	int item = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(item, "model", model);
	DispatchKeyValueFloat(item, "modelscale", flScale == 1.0 ? GetEntPropFloat(ent, Prop_Send, "m_flModelScale") : flScale);
	DispatchSpawn(item);
	
	SetEntProp(item, Prop_Send, "m_nSkin", skin);
	SetEntProp(item, Prop_Send, "m_hOwnerEntity", ent);
	SetEntProp(item, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES|16);	// EF_NOSHADOW

	if(!StrEqual(anim, ""))
	{
		SetVariantString(anim);
		AcceptEntityInput(item, "SetAnimation");
	}

	SetVariantString("!activator");
	AcceptEntityInput(item, "SetParent", ent);
	
	SetVariantString(attachment);
	AcceptEntityInput(item, "SetParentAttachmentMaintainOffset"); 
	
	return item;
}
stock float clamp( float val, float minVal, float maxVal )
{
	if ( maxVal < minVal )
		return maxVal;
	else if( val < minVal )
		return minVal;
	else if( val > maxVal )
		return maxVal;
	else
		return val;
}
stock float RemapVal( float val, float A, float B, float C, float D)
{
	if ( A == B )
		return val >= B ? D : C;
	return C + (D - C) * (val - A) / (B - A);
}
stock float RemapValClamped( float val, float A, float B, float C, float D)
{
	if ( A == B )
		return val >= B ? D : C;
	float cVal = (val - A) / (B - A);
	cVal = clamp( cVal, 0.0, 1.0 );

	return C + (D - C) * cVal;
}
stock float SimpleSpline( float value )
{
	float valueSquared = value * value;

	// Nice little ease-in, ease-out spline-like curve
	return (3 * valueSquared - 2 * valueSquared * value);
}
// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
stock float SimpleSplineRemapVal( float val, float A, float B, float C, float D)
{
	if ( A == B )
		return val >= B ? D : C;
	float cVal = (val - A) / (B - A);
	return C + (D - C) * SimpleSpline( cVal );
}
// remaps a value in [startInterval, startInterval+rangeInterval] from linear to
// spline using SimpleSpline
stock float SimpleSplineRemapValClamped( float val, float A, float B, float C, float D )
{
	if ( A == B )
		return val >= B ? D : C;
	float cVal = (val - A) / (B - A);
	cVal = clamp( cVal, 0.0, 1.0 );
	return C + (D - C) * SimpleSpline( cVal );
}
stock float fmax(float v1, float v2)
{
	return v1 > v2 ? v1 : v2;
}
stock float fmin(float v1, float v2)
{
	return v1 < v2 ? v1 : v2;
}
stock bool TF2_HealPlayer(int client, int nHealAmount, bool overheal = false, bool notify = false, int healer = 0)
{
	int nHealth = GetClientHealth(client);
	int nMaxHealth = TF2_GetPlayerMaxHealth(client);

	if (nHealth > RoundFloat(nMaxHealth * 1.5))
		return false;

	// cap heals to max health
	if (!overheal && nHealAmount > nMaxHealth - nHealth)
		nHealAmount = nMaxHealth - nHealth;
	
	if (nHealAmount > 0)
	{
		SetEntityHealth(client, nHealth + nHealAmount);
		
		// player health HUD notification
		if (notify)
		{
			Event event;
			if (healer)
			{
				event = CreateEvent("player_healed");
				if (event)
				{
					event.SetInt("amount", nHealAmount);
					event.SetInt("patient", GetClientUserId(client));
					if (IsClientValid(healer))
						event.SetInt("healer", GetClientUserId(healer));
					event.SetBool("sourcemod", true);
					event.Fire();
				}
			}
			else
			{
				event = CreateEvent("player_healonhit");
				if (event)
				{
					event.SetInt("amount", nHealAmount);
					event.SetInt("entindex", client);
					event.SetBool("sourcemod", true);					
					event.FireToClient(client);
					event.Cancel();
				}
			}
		}
		
		return true;
	}
	return false;
}
stock int TF2_GetPlayerMaxHealth(int client)
{
	return GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, client);
}
stock bool TF2_UnstuckPlayer(int client, float scale = 1.0, float searchScale = 1.0, const float position[3] = NULL_VECTOR)
{
	float vecMins[3], vecMaxs[3], vecPosition[3], vecDestination[3];
	GetEntPropVector(client, Prop_Data, "m_vecMinsPreScaled", vecMins);
	GetEntPropVector(client, Prop_Data, "m_vecMaxsPreScaled", vecMaxs);
	
	ScaleVector(vecMins, scale);
	ScaleVector(vecMaxs, scale);
	
	if (IsNullVector(position))
		GetClientAbsOrigin(client, vecPosition);
	else vecPosition = position;
	
	if (FindNonCollideHullPosition(vecPosition, vecMins, vecMaxs, vecDestination, MASK_PLAYERSOLID, _UnstuckTraceFilter, client))
	{
		TeleportEntity(client, vecDestination, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	
	// check a little higher for slopes
	vecPosition[2] += 10.0;
	if (FindNonCollideHullPositionExtent(vecPosition, vecMins, vecMaxs, vecDestination, MASK_PLAYERSOLID, _UnstuckTraceFilter, client, searchScale))
	{
		TeleportEntity(client, vecDestination, NULL_VECTOR, NULL_VECTOR);
		return true;
	}
	
	return false;
}

/**
 * Return true if teleport should be stopped.
 */
static stock bool _UnstuckTraceFilter(int entity, int contents, int self)
{
	return entity > 0 && (self == -1 || self != entity);
}
stock bool FindNonCollideHullPosition(const float vecPosition[3],
		const float vecMins[3], const float vecMaxs[3], float vecDestination[3],
		int flags, TraceEntityFilter filter, any data, float searchScale = 1.0)
{
	
	Handle trace = TR_TraceHullFilterEx(vecPosition, vecPosition, vecMins, vecMaxs,
			flags, filter, data);
	
	bool valid = !TR_DidHit(trace);
	delete trace;
	
	if (valid) {
		vecDestination = vecPosition;
		return true;
	}
	
	return FindNonCollideHullPositionExtent(vecPosition, vecMins, vecMaxs, vecDestination,
			flags, filter, data, searchScale);
}

enum EHullExtent {
	HullExtent_Center,
	HullExtent_Minimum,
	HullExtent_Maximum
};

/**
 * Checks the perimeter bounded by vecMins and vecMaxs for a position that doesn't hit anything.
 * At the worst case, this function performs 8 hull traces.
 */
stock bool FindNonCollideHullPositionExtent(const float vecPosition[3],
		const float vecMins[3], const float vecMaxs[3], float vecDestination[3],
		int flags, TraceEntityFilter filter, any data, float searchScale = 1.0)
{
	float vecCenter[3];
	for (int i; i < sizeof(vecCenter); i++) {
		vecCenter[i] = (vecMaxs[i] + vecMins[i]) / 2;
	}
	
	float vecScaledMins[3], vecScaledMaxs[3];
	vecScaledMins = vecMins;
	vecScaledMaxs = vecMaxs;
	
	ScaleVector(vecScaledMins, searchScale);
	ScaleVector(vecScaledMaxs, searchScale);
	
	/** 
	 * Basically we treat the corners and center edges of the bounding box as potential
	 * unstuck position candidates.
	 */
	
	for (EHullExtent x = HullExtent_Center; x <= HullExtent_Maximum; x++) {
		for (EHullExtent y = HullExtent_Center; y <= HullExtent_Maximum; y++) {
			// we assume the center has already been checked
			if (x == HullExtent_Center && y == HullExtent_Center) {
				continue;
			}
			
			float vecOffset[] = { 0.0, 0.0, 10.0 };
			
			switch (x) {
				case HullExtent_Minimum: { vecOffset[0] = vecScaledMins[0]; }
				case HullExtent_Maximum: { vecOffset[0] = vecScaledMaxs[0]; }
				case HullExtent_Center:  { vecOffset[0] = vecCenter[0]; }
			}
			
			switch (y) {
				case HullExtent_Minimum: { vecOffset[1] = vecScaledMins[1]; }
				case HullExtent_Maximum: { vecOffset[1] = vecScaledMaxs[1]; }
				case HullExtent_Center:  { vecOffset[0] = vecCenter[0]; }
			}
			
			float vecTestPosition[3];
			AddVectors(vecPosition, vecOffset, vecTestPosition);
			
			Handle trace = TR_TraceHullFilterEx(vecTestPosition, vecTestPosition,
					vecMins, vecMaxs, flags, filter, data);
			
			bool valid = !TR_DidHit(trace);
			
			delete trace;
			
			if (valid) {
				vecDestination = vecTestPosition;
				return true;
			}
		}
	}
	return false;
}
// CTFPlayer::GetObjectCount()
stock int TF2_GetObjectCount(int client)
{
	// CUtlVector<CBaseObject*, CUtlMemory<CBaseObject*, int>>
	return GetEntData(client, FindSendPropInfo("CTFPlayer", "m_flMvMLastDamageTime") + 48 + 12);
}

// CTFPlayer::GetObject(int)
stock int TF2_GetObject(int client, int objidx)
{
	//8568 linux
	//8560 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMvMLastDamageTime") + 48;
	Address m_aObjects = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(offset), NumberType_Int32));
	return LoadFromAddress(m_aObjects + view_as< Address >(4 * objidx), NumberType_Int32) & 0xFFF;
}

// CTFPlayer::GetObjectOfType(int, int)
stock int TF2_GetObjectOfType(int client, TFObjectType objtype, TFObjectMode objmode = TFObjectMode_None, bool incdisposables = false)
{
	int numobjs = TF2_GetObjectCount(client);
	if (numobjs <= 0)
		return -1;

	int obj;
	int count;
	do
	{
		obj = TF2_GetObject(client, count);
		if (TF2_GetObjectType(obj) == objtype
		&& TF2_GetObjectMode(obj) == objmode
		&& !(GetEntProp(obj, Prop_Send, "m_bDisposableBuilding") && !incdisposables))
		{
			return obj;
		}

	}	while ++count < numobjs;
	return -1;
}

// CTFPlayer::GetNumObjects(int, int)
stock int TF2_GetNumObjects(int client, TFObjectMode objmode, TFObjectType objtype, bool incdisposables = false)
{
	int objects;
	int count;
	int objcount = TF2_GetObjectCount(client);
	int obj;
	if (objtype == view_as< TFObjectType >(-1))
	{
		while (count < objcount)
		{
			obj = TF2_GetObject(client, count);
			if (!(GetEntProp(obj, Prop_Send, "m_bDisposableBuilding") && !incdisposables))
			{
				if (TF2_GetObjectMode(obj) == objmode)
					++objects;
			}
			++count;
		}
	}
	else
	{
		while (objcount > count)
		{
			obj = TF2_GetObject(client, count);
			if (!(GetEntProp(obj, Prop_Send, "m_bDisposableBuilding") && !incdisposables))
			{
				if (TF2_GetObjectMode(obj) == objmode && TF2_GetObjectType(obj) == objtype)
					++objects;
			}
			++count;
		}
	}
	return objects;
}
stock int TF2_GetNumWearables(int client)
{
	// 3552 linux
	// 3532 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMaxspeed") - 20 + 12;
	return GetEntData(client, offset);
}
stock int TF2_GetWearable(int client, int wearableidx)
{
	// 3540 linux
	// 3520 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMaxspeed") - 20;
	Address m_hMyWearables = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(offset), NumberType_Int32));
	int ent =  LoadFromAddress(m_hMyWearables + view_as< Address >(4 * wearableidx), NumberType_Int32) & 0xFFF;
	if (!ent || ent == 0xFFF)
		return -1;
	return ent;
}
