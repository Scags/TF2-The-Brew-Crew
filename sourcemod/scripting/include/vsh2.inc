#if defined _vsh2_included
	#endinput
#endif
#define _vsh2_included

#define MAX_BOSS_NAME_LENGTH 64

enum
{
	ROUND_SURVIVAL = (1 << 0),
	ROUND_MANNPOWER = (1 << 1),
	ROUND_HVH = (1 << 2),
	ROUND_MULTI = (1 << 3),
	ROUND_CLASSRUSH = (1 << 4)
};

enum
{
	GM_NORMAL = 0,
	GM_OBJECTIVE = (1 << 0)
};


enum
{	/* VSH2 Round States */
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning = 1,
	StateEnding = 2,
};

methodmap VSH2Player	
{
	/** [ C O N S T R U C T O R ]
	 * Constructs an instance of the BaseBoss internal methodmap
	 * @param ind			index (or the userid) of a player
	 * @param uid		if using userid instead of player index, set this param to true
	 * @return			a player instance of the VSH2Player methodmap
	*/
	public VSH2Player(const int ind, bool uid = false)
	{
		int player = 0;
		if (uid && GetClientOfUserId(ind) > 0)
			player = ind;
		else if (0 < ind <= MaxClients && IsClientInGame(ind))
			player = GetClientUserId(ind);
		return view_as< VSH2Player >(player);
	}

	/* **** **** [ P R O P E R T I E S ] **** **** */
	
	/**
	 * gets the userid of the vsh2 player instance
	 * @return			the bare player userid integer
	*/
	property int userid
	{
		public get()
		{ return view_as< int >(this); }
	}
	
	/**
	 * gets the index of the vsh2 player instance
	 * @return			the bare player index integer
	*/
	property int index
	{
		public get()
		{ return view_as< int >(GetClientOfUserId(this.userid)); }
	}

	property int iPresetType
	{
		public native get();
		public native set(const int i);
	}
	
	/**
         * sets the property of the internal VSH2 methodmap
         * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name		name of property you want to access data from.
	 * @param item			reference to use of the variable to overwrite with data from the property.
         * @return		
        */
	public native any GetProperty(const char prop_name[64]);
	
	/**
         * sets the property of the internal VSH2 methodmap
	 * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name		name of the property you want to override data from (works like StringMap).
	 * @param value			data you want the property to hold.
         * @noreturn
        */	
	public native void SetProperty(const char prop_name[64], any value);

	property StringMap hMap
	{
		public native get();
	}

	property int iQueue
	{
		public get() 				{ return this.GetProperty("iQueue"); }
		public set(const int i)	{ this.SetProperty("iQueue", i); }
	}
	property int iKills
	{
		public get() 				{ return this.GetProperty("iKills"); }
		public set(const int i)	{ this.SetProperty("iKills", i); }
	}
	property int iHits
	{
		public get() 				{ return this.GetProperty("iHits"); }
		public set(const int i)	{ this.SetProperty("iHits", i); }
	}
	property int iLives
	{
		public get() 				{ return this.GetProperty("iLives"); }
		public set(const int i)	{ this.SetProperty("iLives", i); }
	}
	property int iState
	{
		public get() 				{ return this.GetProperty("iState"); }
		public set(const int i)	{ this.SetProperty("iState", i); }
	}
	property int iDamage
	{
		public get() 				{ return this.GetProperty("iDamage"); }
		public set(const int i)	{ this.SetProperty("iDamage", i); }
	}
	property int iAirDamage
	{
		public get() 				{ return this.GetProperty("iAirDamage"); }
		public set(const int i)	{ this.SetProperty("iAirDamage", i); }
	}
	property int iSongPick
	{
		public get() 				{ return this.GetProperty("iSongPick"); }
		public set(const int i)	{ this.SetProperty("iSongPick", i); }
	}
	property int iHealTarget
	{
		public get() 				{ return this.GetProperty("iHealTarget"); }
		public set(const int i)	{ this.SetProperty("iHealTarget", i); }
	}
	property int iOwnerBoss
	{
		public get() 				{ return GetClientOfUserId(this.GetProperty("iOwnerBoss")); }
		public set(const int i)	{ this.SetProperty("iOwnerBoss", i); }
	}
	property int iUberTarget
	{
		public get() 				{ return this.GetProperty("iUberTarget"); }
		public set(const int i)	{ this.SetProperty("iUberTarget", i); }
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
	property bool bNearDispenser
	{
		public get() 				{ return this.GetProperty("bNearDispenser"); }
		public set(const bool i)	{ this.SetProperty("bNearDispenser", i); }
	}
	property bool bIsMinion
	{
		public get() 				{ return this.GetProperty("bIsMinion"); }
		public set(const bool i)	{ this.SetProperty("bIsMinion", i); }
	}
	property bool bInJump
	{
		public get() 				{ return this.GetProperty("bInJump"); }
		public set(const bool i)	{ this.SetProperty("bInJump", i); }
	}
	property float flGlowtime
	{
		public get() 				{ return this.GetProperty("flGlowtime"); }
		public set(const float i)	{ this.SetProperty("flGlowtime", i); }
	}
	property float flLastHit
	{
		public get() 				{ return this.GetProperty("flLastHit"); }
		public set(const float i)	{ this.SetProperty("flLastHit", i); }
	}
	property float flLastShot
	{
		public get() 				{ return this.GetProperty("flLastShot"); }
		public set(const float i)	{ this.SetProperty("flLastShot", i); }
	}
	property int iHealth
	{
		public get() 				{ return this.GetProperty("iHealth"); }
		public set(const int i)	{ this.SetProperty("iHealth", i); }
	}
	property int iMaxHealth
	{
		public get() 				{ return this.GetProperty("iMaxHealth"); }
		public set(const int i)	{ this.SetProperty("iMaxHealth", i); }
	}
	property int iType
	{
		public get() 				{ return this.GetProperty("iType"); }
		public set(const int i)	{ this.SetProperty("iType", i); }
	}
	property int iPureType
	{
		public get() 				{ return this.GetProperty("iPureType"); }
		public set(const int i)	{ this.SetProperty("iPureType", i); }
	}
	property int iClimbs
	{
		public get() 				{ return this.GetProperty("iClimbs"); }
		public set(const int i)	{ this.SetProperty("iClimbs", i); }
	}
	property int iStabbed
	{
		public get() 				{ return this.GetProperty("iStabbed"); }
		public set(const int i)	{ this.SetProperty("iStabbed", i); }
	}
	property int iMarketted
	{
		public get() 				{ return this.GetProperty("iMarketted"); }
		public set(const int i)	{ this.SetProperty("iMarketted", i); }
	}
	property int iDifficulty
	{
		public get() 				{ return this.GetProperty("iDifficulty"); }
		public set(const int i)	{ this.SetProperty("iDifficulty", i); }
	}
	property int iSpecial
	{
		public get() 				{ return this.GetProperty("iSpecial"); }
		public set(const int i)	{ this.SetProperty("iSpecial", i); }
	}
	property int iSpecial2
	{
		public get() 				{ return this.GetProperty("iSpecial2"); }
		public set(const int i)	{ this.SetProperty("iSpecial2", i); }
	}
	property int iRespawnTime
	{
		public get() 				{ return this.GetProperty("iRespawnTime"); }
		public set(const int i)	{ this.SetProperty("iRespawnTime", i); }
	}
	property bool bIsBoss
	{
		public get() 				{ return this.GetProperty("bIsBoss"); }
		public set(const bool i)	{ this.SetProperty("bIsBoss", i); }
	}
	property bool bSetOnSpawn
	{
		public get() 				{ return this.GetProperty("bSetOnSpawn"); }
		public set(const bool i)	{ this.SetProperty("bSetOnSpawn", i); }
	}
	property bool bUsedUltimate
	{
		public get() 				{ return this.GetProperty("bUsedUltimate"); }
		public set(const bool i)	{ this.SetProperty("bUsedUltimate", i); }
	}
	property bool bNoRagdoll
	{
		public get() 				{ return this.GetProperty("bNoRagdoll"); }
		public set(const bool i)	{ this.SetProperty("bNoRagdoll", i); }
	}
	property float flSpeed
	{
		public get() 				{ return this.GetProperty("flSpeed"); }
		public set(const float i)	{ this.SetProperty("flSpeed", i); }
	}
	property float flCharge
	{
		public get() 				{ return this.GetProperty("flCharge"); }
		public set(const float i)	{ this.SetProperty("flCharge", i); }
	}
	property float flRAGE
	{
		public get() 				{ return this.GetProperty("flRAGE"); }
		public set(const float i)	{ this.SetProperty("flRAGE", i); }
	}
	property float flKillSpree
	{
		public get() 				{ return this.GetProperty("flKillSpree"); }
		public set(const float i)	{ this.SetProperty("flKillSpree", i); }
	}
	property float flWeighDown
	{
		public get() 				{ return this.GetProperty("flWeighDown"); }
		public set(const float i)	{ this.SetProperty("flWeighDown", i); }
	}
	property float flSpecial
	{
		public get() 				{ return this.GetProperty("flSpecial"); }
		public set(const float i)	{ this.SetProperty("flSpecial", i); }
	}
	property float flSpecial2
	{
		public get() 				{ return this.GetProperty("flSpecial2"); }
		public set(const float i)	{ this.SetProperty("flSpecial2", i); }
	}
	property ArrayList hSpecial
	{
		public get() 				{ return this.GetProperty("hSpecial"); }
		public set(const ArrayList i)	{ this.SetProperty("hSpecial", i); }
	}
	property int iOtherTeam
	{
		public get()
		{
			switch (GetClientTeam(this.index))
			{
				case 2:return 3;
				case 3:return 2;
				default:return 0;
			}
		}
	}


	/*		AVAILABLE PROPERTIES
	property int iQueue
	property int iPresetType
	property int iKills
	property int iHits
	property int iLives
	property int iState
	property int iDamage
	property int iAirDamage
	property int iSongPick
	property int iHealTarget	// returns -1 is there's no valid player
	property int iOwnerBoss
	property int iUberTarget	// please use userid on this; convert to client index if you want but userid is safer
	property int bGlow		// use like a bool
	property bool bNearDispenser
	property bool bIsMinion
	property bool bInJump
	property float flGlowtime
	property float flLastHit
	property float flLastShot
	
	// 	ALL PROPERTIES AFTER THIS COMMENT ONLY ACCOUNT FOR BOSSES BUT CAN STILL APPLY ON NON-BOSSES AND MINIONS
	property int iHealth
	property int iMaxHealth
	property int iType
	property int iClimbs
	property int iStabbed
	property int iMarketted
	property int iDifficulty
	property bool bIsBoss
	property bool bSetOnSpawn
	property bool bUsedUltimate	// Not an overwatch reference lol; purpose is for a use-once ability but you can reset it
	property float flSpeed	// if you boss needs a set amount of speed, use this obviously
	property float flCharge
	property float flRAGE
	property float flKillSpree
	property float flWeighDown
	*/
		
	public native void ConvertToMinion(const float spawntime, const VSH2Player owner);
	public native int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att, bool visible = true);
	public native int GetWeaponSlotIndex(const int slot);
	public native void SetWepInvis(const int alpha);
	public native void SetOverlay(const char[] strOverlay);
	public native void TeleToSpawn(int team = 0);
	public native void IncreaseHeadCount();
	public native void SpawnSmallHealthPack(int ownerteam = 0);
	public native void ForceTeamChange(const int team);
	public native bool ClimbWall(const int weapon, const float upwardVel, const float health, const bool attackdelay);
	public native void HelpPanelClass();
	
	// Boss oriented natives
	public native void ConvertToBoss();
	public native void GiveRage(const int damage);
	public native void MakeBossAndSwitch(const int type, const bool callEvent);
	public native void DoGenericStun(const float rageDist);
	public native void DoGenericThink(bool jump = false, bool sound = false, char[] strSound = "", int random = 0, bool mp3 = true, bool showhud = true, float weighdowntime = 3.0, float vol = 1.0);
	public native void PreEquip();
	public native void ReceiveGenericRage();
	public native void RemoveGenericRage(bool jarate = true);
};


/**
 * Registers a plugin to be able to use VSH2's forwards
 * NOTE: The purpose of this native is to register boss subplugins, you don't need to register plugins to use forwards, simply hook what forward you need.
 * @param plugin_name			module name you want your calling plugin to be identified under
 * @return				integer of the plugin array index
 */
native int VSH2_RegisterPlugin(const char plugin_name[64]);

enum		//FwdCompat
{
	Fwd_OnBossTakeDamage,
	Fwd_OnBossDealDamage,
	Fwd_OnSoundHook
};

enum
{		//VSH2HookType	
	OnCallDownloads=0,
	OnBossSelected,
	OnTouchPlayer,
	OnTouchBuilding,
	OnBossThink,
	OnBossModelTimer,
	OnBossDeath,
	OnBossEquipped,
	OnBossInitialized,
	OnMinionInitialized,
	OnBossPlayIntro,
	OnBossTakeDamage,
	OnBossDealDamage,
	OnPlayerKilled,
	OnPlayerAirblasted,
	OnTraceAttack,
	OnBossMedicCall,
	OnBossTaunt,
	OnBossKillBuilding,
	OnBossJarated,
	//OnHookSound,
	OnMessageIntro,
	OnBossPickUpItem,
	OnVariablesReset,
	OnUberDeployed,
	OnUberLoop,
	OnMusic,
	OnRoundEndInfo,
	OnLastPlayer,
	OnBossHealthCheck,
	OnControlPointCapped,
	OnBossMenu,
	OnPrepRedTeam,
	OnBossBackstabbed,
	OnBossWin,
	OnBossGiveBackRage,
	OnBossSetName,
	OnPlayerHurt,
	OnMinionHurt,
	OnRedPlayerThink,
	OnActualBossDeath,
	OnSetBossArgs,
	OnHealthBarUpdate,
	OnFighterDeadThink,
	VSH2FWD_LEN
};

/*
	IF YOU'RE USING THE HOOKING SYSTEM FOR A BOSS, YOU HAVE TO REGISTER YOUR PLUGIN WITH VSH2 BECAUSE YOU NEED THE MODULE INDEX TRACKED
*/

typeset VSH2HookCB
{
	/*
		OnBossSelected
		OnBossThink
		OnBossModelTimer
		OnBossDeath
		OnBossEquipped
		OnMinionInitialized
		OnBossPlayIntro
		OnBossMedicCall
		OnBossTaunt
		OnVariablesReset
		OnBossHealthCheck
		OnPrepRedTeam
		OnRedPlayerThink
		OnLastPlayer
		OnFighterDeadThink
	*/
	function void (const VSH2Player Player);
	
	/*
		OnTouchPlayer
		OnBossJarated
		OnUberDeployed	// Victim is uber target, attacker is medic
		OnUberLoop	// Victim is uber target, attacker is medic
	*/
	function void (const VSH2Player Victim, const VSH2Player Attacker);

	//	OnBossBackstabbed
	function Action (const VSH2Player Victim, const VSH2Player Attacker);
	
	//	OnTouchBuilding
	function void (const VSH2Player Attacker, const int BuildingRef);
	
	//	OnBossKillBuilding
	function void (const VSH2Player Attacker, const int building, Event event);
	
	//	OnBossTakeDamage , OnBossDealDamage
	function Action (VSH2Player Victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom);
	
	/*
		OnPlayerKilled
		OnPlayerAirblasted
	*/
	function void (const VSH2Player Player, const VSH2Player Victim, Event event);
	
	//	OnTraceAttack
	function void (const VSH2Player Victim, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	
	//	OnMusic
	function void (char song[PLATFORM_MAX_PATH], float& time, const VSH2Player Player);
	
	//	OnControlPointCapped
	function void (char cappers[MAXPLAYERS+1], const int team);
	
	//	OnCallDownloads
	function void ();

	// OnHealthBarUpdate
	function Action ();
	
	//	OnBossPickUpItem
	function void (const VSH2Player Player, const char item[64]);

	//	OnMessageIntro
	function void (const VSH2Player Player, char message[512]);

	/*
		OnBossHealthCheck 	bossBool determines if command user was the boss
		OnRoundEndInfo 		bossBool determines if boss won the round
	*/
	function void (const VSH2Player Player, bool bossBool, char message[512]);

	//	OnBossMenu
	function void (Menu& menu);

	//	OnBossInitialized
	function void (const VSH2Player Player, bool override);

	//	OnBossWin
	function void (const VSH2Player player, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch);

	//	OnBossGiveBackRage
	function Action (const VSH2Player player);

	//	OnBossSetName
	function void (const VSH2Player player, char name[MAX_BOSS_NAME_LENGTH]);

	//	OnMinionHurt
	function void (const VSH2Player victim, const VSH2Player attacker, int &damage, Event event);

	//	OnSetBossArgs
	function void (const char[] bossname, int &type, char[] buffer);
};

// Use hooktype enum on these.
native void VSH2_Hook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_HookEx(const int callbacktype, VSH2HookCB callback);

native void VSH2_Unhook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_UnhookEx(const int callbacktype, VSH2HookCB callback);


native any VSH2GameMode_GetProperty(const char prop_name[64]);
native void VSH2GameMode_SetProperty(const char prop_name[64], any value);

/*	Available properties
property int iRoundState
property int iSpecial
property int iTotalMaxHealth
property int iTimeLeft
property int iRoundCount
property int iHealthChecks
property int iCaptures
property bool bSteam		// Only useable if SteamTools is enabled and used.
property bool bTF2Attribs	// Only useable if TF2Attributes is enabled and used
property bool bPointReady
property bool bMedieval
property float flHealthTime
property float flMusicTime
property VSH2Player hNextBoss
*/

native VSH2Player VSH2GameMode_FindNextBoss();
native VSH2Player VSH2GameMode_GetRandomBoss(const bool IsAlive);
native VSH2Player VSH2GameMode_GetBossByType(const bool IsAlive, const int BossType);
native int VSH2GameMode_CountMinions(const bool IsAlive);
native int VSH2GameMode_CountBosses(const bool IsAlive);
native int VSH2GameMode_GetTotalBossHealth();
native void VSH2GameMode_SearchForItemPacks();
native void VSH2GameMode_UpdateBossHealth();
native void VSH2GameMode_GetBossType();
native int VSH2GameMode_GetTotalRedPlayers();
native void VSH2GameMode_GiveBackRage(int userid);
native Handle VSH2_JumpHud();
native Handle VSH2_BossHud();
native void VSH2_AddToFwdC(int fwd, int type);
native Handle VSH2_Self();
native int VSH2GameMode_MaxBoss();
native void VSH2_UnCycle(int idx);

public SharedPlugin __pl_vsh2 =
{
	name = "VSH2",
	file = "vsh2.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vsh2_SetNTVOptional()
{
	MarkNativeAsOptional("VSH2_RegisterPlugin");
	MarkNativeAsOptional("VSH2Player.VSH2Player");
	
	MarkNativeAsOptional("VSH2Player.userid.get");
	MarkNativeAsOptional("VSH2Player.index.get");
	
	MarkNativeAsOptional("VSH2Player.GetProperty");
	MarkNativeAsOptional("VSH2Player.SetProperty");
	
	MarkNativeAsOptional("VSH2Player.ConvertToMinion");
	MarkNativeAsOptional("VSH2Player.SpawnWeapon");
	MarkNativeAsOptional("VSH2Player.GetWeaponSlotIndex");
	MarkNativeAsOptional("VSH2Player.SetWepInvis");
	MarkNativeAsOptional("VSH2Player.SetOverlay");
	MarkNativeAsOptional("VSH2Player.TeleToSpawn");
	MarkNativeAsOptional("VSH2Player.IncreaseHeadCount");
	MarkNativeAsOptional("VSH2Player.SpawnSmallHealthPack");
	MarkNativeAsOptional("VSH2Player.ForceTeamChange");
	MarkNativeAsOptional("VSH2Player.ClimbWall");
	MarkNativeAsOptional("VSH2Player.HelpPanelClass");
	MarkNativeAsOptional("VSH2Player.ConvertToBoss");
	MarkNativeAsOptional("VSH2Player.GiveRage");
	MarkNativeAsOptional("VSH2Player.MakeBossAndSwitch");
	MarkNativeAsOptional("VSH2Player.DoGenericThink");
	MarkNativeAsOptional("VSH2Player.PreEquip");
	MarkNativeAsOptional("VSH2Player.ReceiveGenericRage");
	MarkNativeAsOptional("VSH2Player.RemoveGenericRage");
	MarkNativeAsOptional("VSH2Player.TakeGenericDamage");
	MarkNativeAsOptional("VSH2Player.DealGenericDamage");
	MarkNativeAsOptional("VSH2Player.iPresetType.get");
	MarkNativeAsOptional("VSH2Player.iPresetType.set");
	MarkNativeAsOptional("VSH2Player.hMap.get");

	MarkNativeAsOptional("VSH2_Hook");
	MarkNativeAsOptional("VSH2_HookEx");
	MarkNativeAsOptional("VSH2_Unhook");
	MarkNativeAsOptional("VSH2_UnhookEx");
	
	MarkNativeAsOptional("VSH2GameMode_GetProperty");
	MarkNativeAsOptional("VSH2GameMode_SetProperty");
	MarkNativeAsOptional("VSH2GameMode_FindNextBoss");
	MarkNativeAsOptional("VSH2GameMode_GetRandomBoss");
	MarkNativeAsOptional("VSH2GameMode_GetBossByType");
	MarkNativeAsOptional("VSH2GameMode_CountMinions");
	MarkNativeAsOptional("VSH2GameMode_CountBosses");
	MarkNativeAsOptional("VSH2GameMode_GetTotalBossHealth");
	MarkNativeAsOptional("VSH2GameMode_SearchForItemPacks");
	MarkNativeAsOptional("VSH2GameMode_UpdateBossHealth");
	MarkNativeAsOptional("VSH2GameMode_GetBossType");
	MarkNativeAsOptional("VSH2GameMode_GetTotalRedPlayers");
}
#endif