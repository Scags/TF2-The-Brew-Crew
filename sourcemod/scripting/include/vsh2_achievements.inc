#if defined _vsh2ach_included
  #endinput
#endif

#define _vsh2ach_included

enum
{
	A_CloseCall = 0,
	A_BigStun,
	A_Ova9k,
	A_Soloer,
	A_Invincible,
	A_HaleKiller,
	A_HaleGenocide,
	A_HaleExtinction,
	A_MercKiller,
	A_MercGenocide,
	A_MercExtinction,
	A_Telefragger,
	A_TelefragMachine,
	A_FrogMan,
	A_MasterFrogMan,
	A_Veteran,
	A_Battlescarred,
	A_Master,
	A_BrewMaster,
	A_Rager,
	A_EMasher,
	A_RageNewb,
	A_Backstabber,
	A_Gardener,
	A_PointWhore,
	A_Damager,
	A_DamageKing,
	A_BeyondTheGrave,
	A_Minion1,
	A_Alternate,
	A_BeepBoop,
	A_NotOP,
	A_LivedToTell,
	A_DeRage,
	A_Embarrassed,
	A_Overkill,
	A_Pulverised,
	A_HurtBack,

	MAX_ACHIEVEMENTS
};

native void VSH2Ach_AddTo(const int client, const int idx, const int amt);
native void VSH2Ach_Toggle(bool status);

public SharedPlugin __pl_vsh2ach = {
	name = "VSH2Ach",
	file = "vsh2_achievements.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vsh2_achievements_SetNTVOptional()
{
	MarkNativeAsOptional("VSH2Ach_AddTo");
	MarkNativeAsOptional("VSH2Ach_Toggle");
}
#endif