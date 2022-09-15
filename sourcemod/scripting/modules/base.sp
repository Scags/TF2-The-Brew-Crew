int
	//Queue[PLYR],		// old Queue system but this array is a backup incase cookies haven't cached yet.
	//PresetBossType[PLYR],	// If the upcoming boss set their boss from SetBoss command, this array will hold that data
	AmmoTable[2049],	// saved max ammo size of the weapon
	ClipTable[2049]		// saved max clip size of the weapon
;

float flHolstered[MAXPLAYERS+1][3];	// New mechanic for VSH 2, holster reloading for certain classes and weapons

//	Gonna leave these here so we can reduce stack memory for calling boss specific Download function calls
// public char snd[PLATFORM_MAX_PATH]; //How is this even used?

// Moved to stocks.inc
// public char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
// public char extensionsb[2][5] = { ".vtf", ".vmt" };

#define MAXMESSAGE	4096

public char gameMessage[512];	// Just incase...
public char BackgroundSong[34][PLATFORM_MAX_PATH];

char strGestures[][] =
{
	"taunt_russian",
	"taunt_aerobic_b",
	"disco_fever",
	"taunt_laugh"
};

/*
When making new properties, remember to base it off this StringMap AND do not forget to initialize it in OnClientPutInServer()
*/
StringMap hPlayerFields[MAXPLAYERS+1];

methodmap BaseFighter	/* Player Interface that Opposing team and Boss team derives from */
/*
Property Organization
Ints
Bools
Floats
Misc properties
Methods
*/
{
	public BaseFighter(const int ind, bool uid=false)
	{
		int player=0;	// If you're using a userid and you know 100% it's valid, then set uid to true
		if (uid && GetClientOfUserId(ind) > 0)
			player = (ind);
		else if (IsClientValid(ind))
			player = GetClientUserId(ind);
		return view_as< BaseFighter >(player);
	}
	///////////////////////////////

	/* [ P R O P E R T I E S ] */

	property int userid
	{
		public get()				{ return view_as< int >(this); }
	}
	property int index
	{
		public get()				{ return GetClientOfUserId(view_as< int >(this)); }
	}
	property int iQueue
	{
		public get()
		{
			int player = this.index;
			if (!player)
				return 0;
			else if (!AreClientCookiesCached(player) || IsFakeClient(player))
			{	// If the coookies aren't cached yet, use array
				int i; hPlayerFields[player].GetValue("iQueue", i);
				return i; //return Queue[player];
			}
			char strPoints[10];	// HOW WILL OUR QUEUE SURPASS OVER 9 DIGITS?
			GetClientCookie(player, PointCookie, strPoints, sizeof(strPoints));
			int points = StringToInt(strPoints);
			hPlayerFields[player].SetValue("iQueue", points); //Queue[player] = StringToInt(strPoints);
			return points ; //Queue[player];
		}
		public set(const int val)
		{
			int player = this.index;
			if (!player)
				return;
			else if (!AreClientCookiesCached(player) || IsFakeClient(player))
			{
				hPlayerFields[player].SetValue("iQueue", val); //Queue[player] = val;
				return;
			}
			hPlayerFields[player].SetValue("iQueue", val); //Queue[player] = val;
			char strPoints[10];
			IntToString(val, strPoints, sizeof(strPoints));
			SetClientCookie(player, PointCookie, strPoints);
		}
	}
	property int iPresetType
	{
		public get()				
		{
			int player = this.index;
			if (!AreClientCookiesCached(player) || IsFakeClient(player))
			{
				int i; hPlayerFields[player].GetValue("iPresetType", i);
				return i;
			}
			char strPoints[8];
			GetClientCookie(player, PresetCookie, strPoints, sizeof(strPoints));
			int points = StringToInt(strPoints);
			hPlayerFields[player].SetValue("iPresetType", points);
			return points;
		}
		public set(const int val)
		{
			int player = this.index;
			if (!player)
				return;
			else if (!AreClientCookiesCached(player) || IsFakeClient(player))
			{
				hPlayerFields[player].SetValue("iPresetType", val);
				return;
			}
			hPlayerFields[player].SetValue("iPresetType", val);
			char strPoints[8];
			IntToString(val, strPoints, sizeof(strPoints));
			SetClientCookie(player, PresetCookie, strPoints);
		}
	}
	property int iKills
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iKills", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iKills", val);
		}
	}
	property int iKillCount
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iKillCount", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iKillCount", val);
		}
	}
	property int iRespawnTime
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iRespawnTime", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iRespawnTime", val);
		}
	}
	property int iHits
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iHits", i);
			if (i < 0)	// No unsigned integers yet, clamp Hits to 0 if under
				i = 0;
			return i;
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iHits", val);
		}
	}
	property int iLives
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iLives", i);
			if (i < 0)
				i = 0;
			//if (Lives[this.index] < 0)
			//	Lives[this.index] = 0;
			return i;
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iLives", val);
		}
	}
	property int iState
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iState", i);
			return i;
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iState", val);
		}
	}
	property int iDamage
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iDamage", i);
			return i;
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iDamage", val);
		}
	}
	property int iAirDamage
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iAirDamage", i);
			return i;
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iAirDamage", val);
		}
	}
	property int iSongPick
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iSongPick", i);
			return i;
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iSongPick", val);
		}
	}
	property int iHealTarget
	{
		public get()
		{
			int medigun = GetPlayerWeaponSlot(this.index, TFWeaponSlot_Secondary);
			if (!IsValidEdict(medigun) || !IsValidEntity(medigun))
				return -1;
			char s[32]; GetEdictClassname(medigun, s, sizeof(s));
			if (!strcmp(s, "tf_weapon_medigun", false))
			{
				if (GetEntProp(medigun, Prop_Send, "m_bHealing"))
					return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
			}
			return -1;
		}
	}
	property int iOwnerBoss
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iOwnerBoss", i);
			return GetClientOfUserId(i);
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iOwnerBoss", val);
		}
	}
	property int iUberTarget	/* please use userid on this; convert to client index if you want but userid is safer */
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iUberTarget", i);
			return i;
		}
		public set(const int val)		
		{
			hPlayerFields[this.index].SetValue("iUberTarget", val);
		}
	}
	property int bGlow
	{
		public get()			{ return GetEntProp(this.index, Prop_Send, "m_bGlowEnabled"); }
		public set(const int val)
		{
			int boolean = ((val) ? 1 : 0) ;
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", boolean);
		}
	}
	
	property int iShieldDmg
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iShieldDmg", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iShieldDmg", val);
		}
	}
	property int iAirShots
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iAirShots", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iAirShots", val);
		}
	}
 
	property bool bNearDispenser
	{
		public get()
		{
			int player = this.index;
			int medics=0;
			for (int i=MaxClients ; i ; --i)
			{
				if (!IsValidClient(i))
					continue;
				if (GetHealingTarget(i) == player)
					medics++;
			}
			return (GetEntProp(player, Prop_Send, "m_nNumHealers") > medics);
		}
	}
	property bool bIsMinion
	{
		public get()				
		{
			bool i; hPlayerFields[this.index].GetValue("bIsMinion", i);
			return i;
		}
		public set(const bool val)		
		{
			hPlayerFields[this.index].SetValue("bIsMinion", val);
		}
	}
	property bool bInJump
	{
		public get()				
		{
			bool i; hPlayerFields[this.index].GetValue("bInJump", i);
			return i;
		}
		public set(const bool val)		
		{
			hPlayerFields[this.index].SetValue("bInJump", val);
		}
	}
	property bool bNoMusic
	{
		public get()
		{
			if (!AreClientCookiesCached(this.index))
				return false;
			char musical[6];
			GetClientCookie(this.index, MusicCookie, musical, sizeof(musical));
			return (StringToInt(musical) == 1);
		}
		public set(const bool val)
		{
			if (!AreClientCookiesCached(this.index))
				return;
			int value;
			if (val)
				value = 1;
			else value = 0;
			char musical[6];
			IntToString(value, musical, sizeof(musical));
			SetClientCookie(this.index, MusicCookie, musical);
		}
	}
	
	property bool bQueueOff
	{
		public get()
		{
			if (!AreClientCookiesCached(this.index))
				return false;
			char selection[6];
			GetClientCookie(this.index, QueueCookie, selection, sizeof(selection));
			return (StringToInt(selection) == 1);
		}
		public set(const bool val)
		{
			if (!AreClientCookiesCached(this.index))
				return;
			int value;
			if (val)
				value = 1;
			else value = 0;
			char selection[6];
			IntToString(value, selection, sizeof(selection));
			SetClientCookie(this.index, QueueCookie, selection);
		}
	}

	property float flGlowtime
	{
		public get()
		{
			float i; hPlayerFields[this.index].GetValue("flGlowtime", i);
			if (i < 0.0)
				i = 0.0;
			return i;
		}
		public set(const float val)		
		{
			hPlayerFields[this.index].SetValue("flGlowtime", val);
		}
	}
	property float flLastHit
	{
		public get()				
		{
			float i; hPlayerFields[this.index].GetValue("flLastHit", i);
			return i;
		}
		public set(const float val)		
		{
			hPlayerFields[this.index].SetValue("flLastHit", val);
		}
	}
	property float flLastShot
	{
		public get()				
		{
			float i; hPlayerFields[this.index].GetValue("flLastShot", i);
			return i;
		}
		public set(const float val)		
		{
			hPlayerFields[this.index].SetValue("flLastShot", val);
		}
	}

	property int iOtherTeam
	{
		public get()
		{
			switch (GetClientTeam(this.index))
			{
				case RED:return BLU;
				case BLU:return RED;
				default:return 0;
			}
		}
	}
	
	public void ConvertToMinion(const float time, const BaseFighter owner)
	{
		this.iOwnerBoss = owner.userid;
		this.bIsMinion = true;
		SetPawnTimer(_MakePlayerMinion, time, this.userid);
	}

	/**
	 * creates and spawns a weapon to a player, regardless if boss or not
	 *
	 * @param name		entity name of the weapon, example: "tf_weapon_bat"
	 * @param index		the index of the desired weapon
	 * @param level		the level of the weapon
	 * @param qual		the weapon quality of the item
	 * @param att		the nested attribute string, example: "2 ; 2.0" - increases weapon damage by 100% aka 2x.
	 * @return		entity index of the newly created weapon
	 */
	public int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att, bool visible = true)
	{
		Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
		if (hWeapon == null)
			return -1;

		int client = this.index;
		TF2Items_SetClassname(hWeapon, name);
		TF2Items_SetItemIndex(hWeapon, index);
		TF2Items_SetLevel(hWeapon, level);
		TF2Items_SetQuality(hWeapon, qual);
		char atts[32][32];
		int count = ExplodeString(att, " ; ", atts, 32, 32);
		count &= ~1;
		if (count > 0)
		{
			TF2Items_SetNumAttributes(hWeapon, count/2);
			int i2 = 0;
			for (int i = 0 ; i < count; i += 2) 
			{
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
				i2++;
			}
		}
		else TF2Items_SetNumAttributes(hWeapon, 0);

		int entity = TF2Items_GiveNamedItem(client, hWeapon);
		if (visible)
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
		else
		{
			SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", -1);
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
			SetEntityRenderMode(entity, RENDER_NONE);
		}

		delete hWeapon;
		EquipPlayerWeapon(client, entity);
		return entity;
	}
	/**
	 * gets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded max ammo of the weapon
	 */
	public int getAmmotable(const int wepslot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			return AmmoTable[weapon];
		return -1;
	}
	
	/**
	 * sets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max ammo should be
	 * @noreturn
	 */
	public void setAmmotable(const int wepslot, const int val)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			AmmoTable[weapon] = val;
	}
	/**
	 * gets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded clipsize ammo of the weapon
	 */
	public int getCliptable(const int wepslot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			return ClipTable[weapon];
		return -1;
	}
	
	/**
	 * sets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max clipsize should be
	 * @noreturn
	 */
	public void setCliptable(const int wepslot, const int val)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients && IsValidEntity(weapon))
			ClipTable[weapon] = val;
	}
	public int GetWeaponSlotIndex(const int slot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, slot);
		return GetItemIndex(weapon);
	}
	public void SetWepInvis(const int alpha)
	{
		int transparent = alpha;
		int entity;
		for (int i=0; i<5; i++)
		{
			entity = GetPlayerWeaponSlot(this.index, i); 
			if (IsValidEntity(entity))
			{
				if (transparent > 255)
					transparent = 255;
				if (transparent < 0)
					transparent = 0;
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
				SetEntityRenderColor(entity, 150, 150, 150, transparent); 
			}
		}
	}
	public void SetOverlay(const char[] strOverlay)
	{
		int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);
		ClientCommand(this.index, "r_screenoverlay \"%s\"", strOverlay);
	}
	public void TeleToSpawn(int team = 0)	// Props to Chdata!
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
			else
			{
				if (GetEntProp(iEnt, Prop_Send, "m_iTeamNum") == team)
					hArray.Push(iEnt);
			}
		}
		iEnt = hArray.Get(GetRandomInt(0, hArray.Length-1));
		delete hArray;

		// Technically you'll never find a map without a spawn point. Not a good map at least.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		TeleportEntity(this.index, vPos, vAng, NULL_VECTOR);

		/*if (gamemode.iSpecial == HHHjr) //reserved for HHH boss
		{
			CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(iEnt, "ghost_appearation", _, false)));
			EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
		}*/
	}
	public void IncreaseHeadCount()
	{
		if (!TF2_IsPlayerInCondition(this.index, TFCond_DemoBuff))
			TF2_AddCondition(this.index, TFCond_DemoBuff, -1.0);
		int heads = GetEntProp(this.index, Prop_Send, "m_iDecapitations");
		SetEntProp(this.index, Prop_Send, "m_iDecapitations", ++heads);
		int health = GetClientHealth(this.index);
		//health += (decapitations >= 4 ? 10 : 15);
		if (health < 300)
			health += 15;
		SetEntProp(this.index, Prop_Data, "m_iHealth", health);
		SetEntProp(this.index, Prop_Send, "m_iHealth", health);
		TF2_AddCondition(this.index, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
	}
	public void SpawnSmallHealthPack(int ownerteam=0)
	{
		if (!IsValidClient(this.index) || !IsPlayerAlive(this.index))
			return;
		int healthpack = CreateEntityByName("item_healthkit_small");
		if (IsValidEntity(healthpack))
		{
			float pos[3]; GetClientAbsOrigin(this.index, pos);
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
	public void ForceTeamChange(const int team)
	{
		// Living Spectator Bug:
		// If you force a player onto a team with their tfclass !set, they'll appear as a "living" spectator
		if (TF2_GetPlayerClass(this.index) > TFClass_Unknown)
		{
			SetEntProp(this.index, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(this.index, team);
			SetEntProp(this.index, Prop_Send, "m_lifeState", 0);
			TF2_RespawnPlayer(this.index);
		}
	}
	public bool ClimbWall(const int weapon, const float upwardvel, const float health, const bool attackdelay)
	//Credit to Mecha the Slag
	{
		if (GetClientHealth(this.index) <= health)	// Have to baby players so they don't accidentally kill themselves trying to escape
			return false;

		int client = this.index;
		char classname[64];
		float vecClientEyePos[3];
		float vecClientEyeAng[3];
		GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
		GetClientEyeAngles(client, vecClientEyeAng);	   // Get the angle the player is looking

		//Check for colliding entities
		TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

		if (!TR_DidHit(null))
			return false;

		int TRIndex = TR_GetEntityIndex(null);
		GetEdictClassname(TRIndex, classname, sizeof(classname));
		if (!(StrEqual(classname, "worldspawn") || !strncmp(classname, "prop_", 5)))
			return false;

		float fNormal[3];
		TR_GetPlaneNormal(null, fNormal);
		GetVectorAngles(fNormal, fNormal);

		if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0)
			return false;
		if (fNormal[0] <= -30.0)
			return false;

		float pos[3]; TR_GetEndPosition(pos);
		float distance = GetVectorDistance(vecClientEyePos, pos);

		if (distance >= 100.0)
			return false;

		float fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = upwardvel;

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, 0);

		if (attackdelay)
		{
			TF2Attrib_SetByDefIndex(weapon, 236, 1.0);
			SetPawnTimer(UndoHealBlock, 1.6, EntIndexToEntRef(weapon));
			SetPawnTimer(NoAttacking, 0.1, EntIndexToEntRef(weapon));
		}

		return true;
	}
};

methodmap BaseBoss < BaseFighter
/*
the methodmap/interface for all bosses to use. Use this if you're making a totally different boss
Property Organization
Ints
Bools
Floats
Methods
*/
{
	public BaseBoss(const int ind, bool uid=false)
	{
		return view_as< BaseBoss >(BaseFighter(ind, uid));
	}
	
	///////////////////////////////
	/* [ P R O P E R T I E S ] */

	property int iHealth
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iHealth", i);
			if (i < 0)
				i = 0;
			return i; //Health[ this.index ];
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iHealth", val);
		}
	}
	property int iMaxHealth
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iMaxHealth", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iMaxHealth", val);
		}
	}
	property int iType
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iType", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iType", val);
		}
	}
	property int iPureType
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iPureType", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iPureType", val);
		}
	}
	property int iClimbs
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iClimbs", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iClimbs", val);
		}
	}
	property int iStabbed
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iStabbed", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iStabbed", val);
		}
	}
	property int iStabs
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iStabs", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iStabs", val);
		}
	}
	property int iMarketted
	{
		public get()				
		{
			int i; hPlayerFields[this.index].GetValue("iMarketted", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iMarketted", val);
		}
	}
	property int iStreaks
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iStreaks", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iStreaks", val);
		}
	}
	property int iStreakCount
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iStreakCount", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iStreakCount", val);
		}
	}
	property int iSpecial
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iSpecial", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iSpecial", val);
		}
	}
	property int iSpecial2
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iSpecial2", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iSpecial2", val);
		}
	}
	property int iTime
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iTime", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iTime", val);
		}
	}
//	property int iDifficulty
//	{
//		public get()
//		{
//			int i; hPlayerFields[this.index].GetValue("iDifficulty", i);
//			return i;
//		}
//		public set(const int val)
//		{
//			hPlayerFields[this.index].SetValue("iDifficulty", val);
//		}
//	}
//	property int iStartingDifficulty
//	{
//		public get()
//		{
//			int i; hPlayerFields[this.index].GetValue("iStartingDifficulty", i);
//			return i;
//		}
//		public set(const int val)
//		{
//			hPlayerFields[this.index].SetValue("iStartingDifficulty", val);
//		}
//	}
	property int iSurvKills
	{
		public get()
		{
			int i; hPlayerFields[this.index].GetValue("iSurvKills", i);
			return i;
		}
		public set(const int val)
		{
			hPlayerFields[this.index].SetValue("iSurvKills", val);
		}
	}
//	property int iActualDifficulty
//	{
//		public get()
//		{
//			int player = this.index;
//			if (!player)
//				return 0;
//			else if (!AreClientCookiesCached(player) || IsFakeClient(player))
//			{
//				int i; hPlayerFields[player].GetValue("iStartingDifficulty", i);
//				return i; 
//			}
//			char strPoints[10];	
//			GetClientCookie(player, DifficultyCookie, strPoints, sizeof(strPoints));
//			int points = StringToInt(strPoints);
//			hPlayerFields[player].SetValue("iStartingDifficulty", points);
//			return points ;
//		}
//		public set(const int val)
//		{
//			int player = this.index;
//			if (!player)
//				return;
//			else if (!AreClientCookiesCached(player) || IsFakeClient(player))
//			{
//				hPlayerFields[player].SetValue("iStartingDifficulty", val); 
//				return;
//			}
//			hPlayerFields[player].SetValue("iStartingDifficulty", val); 
//			char strPoints[4];
//			IntToString(val, strPoints, sizeof(strPoints));
//			SetClientCookie(player, DifficultyCookie, strPoints);
//		}
//	}

	property bool bIsBoss
	{
		public get()				
		{
			bool i; hPlayerFields[this.index].GetValue("bIsBoss", i);
			return i;
		}
		public set(const bool val)
		{
			hPlayerFields[this.index].SetValue("bIsBoss", val);
		}
	}
	property bool bSetOnSpawn
	{
		public get()				
		{
			bool i; hPlayerFields[this.index].GetValue("bSetOnSpawn", i);
			return i;
		}
		public set(const bool val)
		{
			hPlayerFields[this.index].SetValue("bSetOnSpawn", val);
		}
	}
	property bool bUsedUltimate
	{
		public get()				
		{
			bool i; hPlayerFields[this.index].GetValue("bUsedUltimate", i);
			return i;
		}
		public set(const bool val)
		{
			hPlayerFields[this.index].SetValue("bUsedUltimate", val);
		}
	}
	property bool bNoRagdoll
	{
		public get()				
		{
			bool i; hPlayerFields[this.index].GetValue("bNoRagdoll", i);
			return i;
		}
		public set(const bool val)
		{
			hPlayerFields[this.index].SetValue("bNoRagdoll", val);
		}
	}

	property float flSpeed
	{
		public get()				
		{
			float i; hPlayerFields[this.index].GetValue("flSpeed", i);
			return i;
		}
		public set(const float val)
		{
			hPlayerFields[this.index].SetValue("flSpeed", val);
		}
	}
	property float flCharge
	{
		public get()				
		{
			float i; hPlayerFields[this.index].GetValue("flCharge", i);
			return i;
		}
		public set(const float val)
		{
			hPlayerFields[this.index].SetValue("flCharge", val);
		}
	}
	property float flRAGE
	{
		public get()
		{		/* Rage should never exceed or "inceed" 0.0 and 100.0 */
			float i; hPlayerFields[this.index].GetValue("flRAGE", i);
			if (i > 100.0)
				i = 100.0;
			else if (i < 0.0)
				i = 0.0;
			return i;
		}
		public set(const float val)
		{
			hPlayerFields[this.index].SetValue("flRAGE", val);
		}
	}
	property float flWeighDown
	{
		public get()				
		{
			float i; hPlayerFields[this.index].GetValue("flWeighDown", i);
			return i;
		}
		public set(const float val)
		{
			hPlayerFields[this.index].SetValue("flWeighDown", val);
		}
	}
	property float flSpecial
	{
		public get() 
		{
			float i; hPlayerFields[this.index].GetValue("flSpecial", i);
			return i;
		}
		public set(const float val)
		{
			hPlayerFields[this.index].SetValue("flSpecial", val);
		}
	}
	property float flSpecial2
	{
		public get() 
		{
			float i; hPlayerFields[this.index].GetValue("flSpecial2", i);
			return i;
		}
		public set(const float val)
		{
			hPlayerFields[this.index].SetValue("flSpecial2", val);
		}
	}
	property float flMusicTime
	{
		public get() 
		{
			float i; hPlayerFields[this.index].GetValue("flMusicTime", i);
			return i;
		}
		public set(const float val)
		{
			hPlayerFields[this.index].SetValue("flMusicTime", val);
		}
	}
	property float flMusicVolume
	{
		public get()
		{
			int player = this.index;
			if (!player)
				return 0.0;
			else if (!AreClientCookiesCached(player) || IsFakeClient(player))
			{
				float i; hPlayerFields[player].GetValue("flMusicVolume", i);
				return i; 
			}
			char strPoints[8];	
			GetClientCookie(player, VolumeCookie, strPoints, sizeof(strPoints));
			float points = StringToFloat(strPoints);
			hPlayerFields[player].SetValue("flMusicVolume", points);
			return points;
		}
		public set(float val)
		{
			int player = this.index;
			if (!player)
				return;

			if (val < 0.0)
				val = 0.0;
			else if (val > 1.0)
				val = 1.0;

			if (!AreClientCookiesCached(player) || IsFakeClient(player))
			{
				hPlayerFields[player].SetValue("flMusicVolume", val); 
				return;
			}
			hPlayerFields[player].SetValue("flMusicVolume", val); 
			char strPoints[8];
			FloatToString(val, strPoints, sizeof(strPoints));
			SetClientCookie(player, VolumeCookie, strPoints);
		}
	}

	property ArrayList hSpecial
	{
		public get() 
		{
			ArrayList i; hPlayerFields[this.index].GetValue("hSpecial", i);
			return i;
		}
		public set(const ArrayList val)
		{
			hPlayerFields[this.index].SetValue("hSpecial", val);
		}
	}

	public void ConvertToBoss()
	{
		this.bIsBoss = this.bSetOnSpawn;
		this.flRAGE = 0.0;
		this.flSpecial = 0.0;
		SetEntityHealth(this.index, 3000);
		SetPawnTimer(_MakePlayerBoss, 0.1, this.userid);
	}

	public void GiveRage(const int damage)
	{
//		if (-1 < this.iDifficulty <= 2)
			this.flRAGE += (damage/SquareRoot(30000.0)*4.0);
//		else this.flRAGE = 0.0;
	}
	public void MakeBossAndSwitch(const int type, const bool callEvent)
	{
		this.bSetOnSpawn = true;
		this.iType = type;
		this.iPureType = type;
		if (callEvent)
			ManageOnBossSelected(this);
		this.ConvertToBoss();
		if (!(VSH2GameMode_GetProperty("iSpecialRound") & ROUND_HVH) && GetClientTeam(this.index) != VSH2GameMode_GetProperty("iHaleTeam"))
			this.ForceTeamChange(VSH2GameMode_GetProperty("iHaleTeam"));
	}
	public void DoGenericStun(const float rageDist)
	{
		int i, count;
		int[] clients = new int[MaxClients];

		float pos[3], pos2[3], distance;
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", pos);
		for(i=MaxClients ; i ; --i)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i) || i == this.index)
				continue;
			else if(GetClientTeam(i) == GetClientTeam(this.index))
				continue;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if(!TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < rageDist)
			{
				clients[count++] = i;
				CreateTimer(5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				TF2_StunPlayer(i, 5.0, _, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, this.index);
			}
		}

		if (bAch)
		{
			if (count >= 15)
				VSH2Ach_AddTo(this.index, A_BigStun, 1);
			else if (count == 1)
				SetPawnTimer(CheckForSingleRage, 11.0, GetClientUserId(clients[0]), VSH2GameMode_GetProperty("iRoundCount"));
		}

		i = -1;
		while((i = FindEntityByClassname(i, "obj_sentrygun")) != -1)
		{
			if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(this.index))
				continue;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if(distance < rageDist)
			{
				SetEntProp(i, Prop_Send, "m_bDisabled", 1);
				AttachParticle(i, "yikes_fx", 75.0);
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
				SetPawnTimer(EnableSG, 8.0, EntIndexToEntRef(i)); //CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
			}
		}
		i = -1;
		while((i = FindEntityByClassname(i, "obj_dispenser")) != -1)
		{
			if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(this.index))
				continue;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if(distance < rageDist)
			{
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		i = -1;
		while((i = FindEntityByClassname(i, "obj_teleporter")) != -1)
		{
			if (GetEntProp(i, Prop_Send, "m_iTeamNum") == GetClientTeam(this.index))
				continue;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if(distance < rageDist)
			{
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
	}
	public void PreEquip()
	{
		int client = this.index;
		TF2_RemovePlayerDisguise(client);
		int ent;
		int numwearables = TF2_GetNumWearables(client);
		for (int i = numwearables-1; i >= 0; --i)
			if ((ent = TF2_GetWearable(client, i)) != -1)
				TF2_RemoveWearable(client, ent);

		TF2_RemoveAllWeapons(client);
	}
	public void DoGenericThink(bool jump = false, bool sound = false, char[] strSound = "", int random = 0, bool mp3 = true, bool showhud = true, float weighdowntime = 3.0, float vol = 1.0)
	{
		if (!IsPlayerAlive(this.index))
			return;

		int client = this.index;

		int buttons = GetClientButtons(client);
		//float currtime = GetGameTime();
		int flags = GetEntityFlags(client);

		//int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
		int health = this.iHealth;
		float speed = 340.0 + 0.7 * (100-health*100/this.iMaxHealth);
		SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", speed);

		if (this.flGlowtime > 0.0)
		{
			this.bGlow = 1;
			this.flGlowtime -= 0.1;
		}
		else if (this.flGlowtime <= 0.0)
			this.bGlow = 0;

		if (OnlyScoutsAndSpiesLeft(this.iOtherTeam))// && this.iDifficulty <= 2)
			this.flRAGE += 0.25;

		if (jump)
		{
			if (((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (this.flCharge >= 0.0))
			{
				if (this.flCharge+2.5 < 25.0)
					this.flCharge += 1.25;
				else this.flCharge = 25.0;
			}
			else if (this.flCharge < 0.0)
			{
//				if (this.iDifficulty <= 3)
					this.flCharge += 2.0;
//				else this.flCharge += 1.25;
			}
			else
			{
				float EyeAngles[3]; GetClientEyeAngles(client, EyeAngles);
				if (this.flCharge > 1.0 && EyeAngles[0] < -5.0)
				{
					float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
					bool big = RTD_GetRollType(client) == PERK_JUMP;
					int v = big ? 1000 : 750;
					vel[2] = v + this.flCharge * 13.0;

					SetEntProp(client, Prop_Send, "m_bJumping", 1);
					vel[0] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
					vel[1] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
					if (big)
					{
						vel[0] *= 1.2;
						vel[1] *= 1.2;
					}
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
					this.flCharge = -100.0;
					if (sound)
					{
						char snd[PLATFORM_MAX_PATH];
						float pos[3]; GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
						if (random)
							Format(snd, PLATFORM_MAX_PATH, "%s%d.%s", strSound, GetRandomInt(1, random), mp3 ? "mp3" : "wav");
						else strcopy(snd, PLATFORM_MAX_PATH, strSound);
						EmitSoundToAll(snd, _, SNDCHAN_VOICE, SNDLEVEL_DISHWASHER, vol != 1.0 ? SND_CHANGEVOL : SND_NOFLAGS, vol, 100, this.index, pos, NULL_VECTOR, false, 0.0);
						EmitSoundToAll(snd, _, SNDCHAN_ITEM, SNDLEVEL_DISHWASHER, vol != 1.0 ? SND_CHANGEVOL : SND_NOFLAGS, vol, 100, this.index, pos, NULL_VECTOR, false, 0.0);
					}
				}
				else this.flCharge = 0.0;
			}
		}

		if (flags & FL_ONGROUND)
			this.flWeighDown = 0.0;
		else this.flWeighDown += 0.1;

		if ((buttons & IN_DUCK) && this.flWeighDown >= weighdowntime)// && this.iDifficulty <= 3)
		{
			float ang[3]; GetClientEyeAngles(client, ang);
			if (ang[0] > 60.0)
			{
				SetEntityGravity(client, 6.0);
				SetPawnTimer(SetGravityNormal, 1.0, this.userid);
				this.flWeighDown = 0.0;
			}
		}
		if (showhud)
		{
			SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
			float jmp = this.flCharge;
			if (jmp > 0.0)
				jmp *= 4.0;
			if (this.flRAGE >= 100.0)
				ShowSyncHudText(client, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", this.iType == HHHjr ? RoundFloat(jmp)/2 : RoundFloat(jmp));
			else ShowSyncHudText(client, hHudText, "Jump: %i | Rage: %0.1f", this.iType == HHHjr ? RoundFloat(jmp)/2 : RoundFloat(jmp), this.flRAGE);
		}
	}
	public void ReceiveGenericRage()
	{
		this.flRAGE += cvarVSH2[AirblastRage].FloatValue;
	}
	public void RemoveGenericRage(int provider, bool jarate = true)
	{
		int val = jarate ? JarateRage : FanoWarRage;
		float fval = cvarVSH2[val].FloatValue;
		this.flRAGE -= fval;
		if (bAch)
			VSH2Ach_AddTo(provider, A_DeRage, RoundFloat(fval));
	}

	public bool GetName(char[] buffer)
	{
		return hPlayerFields[this.index].GetString("strBossName", buffer, MAX_BOSS_NAME_LENGTH);
	}
	public void SetName(const char[] buffer)
	{
		hPlayerFields[this.index].SetString("strBossName", buffer);
	}
};

public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return 0;
}

public void CheckForSingleRage(const int userid, const int roundcount)
{
	if (roundcount != VSH2GameMode_GetProperty("iRoundCount"))
		return;
	int client = GetClientOfUserId(userid);
	if (client && IsPlayerAlive(client))
		VSH2Ach_AddTo(client, A_LivedToTell, 1);
}