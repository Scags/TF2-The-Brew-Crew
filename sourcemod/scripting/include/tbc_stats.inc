#if defined _tbc_stats_included
	#endinput
#endif

#define _tbc_stats_included

native void TBC_GiveCredits(int client, int amount);

public SharedPlugin __pl_tbc_stats = {
	name = "tbc_stats",
	file = "tbc_stats.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_tbc_stats_SetNTVOptional()
{
	MarkNativeAsOptional("TBC_GiveCredits");
}
#endif