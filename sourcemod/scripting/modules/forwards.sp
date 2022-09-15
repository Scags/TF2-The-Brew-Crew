PrivateForward
	g_hForwards[VSH2FWD_LEN]
;

void InitializeForwards()
{
	g_hForwards[OnCallDownloads] = new PrivateForward( ET_Ignore );
	g_hForwards[OnBossSelected] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnTouchPlayer] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
	g_hForwards[OnTouchBuilding] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
	g_hForwards[OnBossThink] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossModelTimer] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossDeath] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossEquipped] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossInitialized] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
	g_hForwards[OnMinionInitialized] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
	g_hForwards[OnBossPlayIntro] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossTakeDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_hForwards[OnBossDealDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_hForwards[OnPlayerKilled] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell );
	g_hForwards[OnPlayerAirblasted] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell );
	g_hForwards[OnTraceAttack] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell );
	g_hForwards[OnBossMedicCall] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossTaunt] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossKillBuilding] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell );
	g_hForwards[OnBossJarated] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
	//g_hForwards[OnHookSound] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnMessageIntro] = new PrivateForward( ET_Ignore, Param_Cell, Param_String );
	g_hForwards[OnBossPickUpItem] = new PrivateForward( ET_Ignore, Param_Cell, Param_String );
	g_hForwards[OnVariablesReset] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnUberDeployed] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
	g_hForwards[OnUberLoop] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
	g_hForwards[OnMusic] = new PrivateForward( ET_Ignore, Param_String, Param_FloatByRef, Param_Cell );
	g_hForwards[OnRoundEndInfo] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_String );
	g_hForwards[OnLastPlayer] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossHealthCheck] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_String );
	g_hForwards[OnControlPointCapped] = new PrivateForward( ET_Ignore, Param_String, Param_Cell );
	g_hForwards[OnPrepRedTeam] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnBossMenu] = new PrivateForward( ET_Ignore, Param_CellByRef );
	g_hForwards[OnBossBackstabbed] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell );
	g_hForwards[OnBossWin] = new PrivateForward( ET_Ignore, Param_Cell, Param_String, Param_CellByRef, Param_CellByRef );
	g_hForwards[OnBossGiveBackRage] = new PrivateForward( ET_Hook, Param_Cell );
	g_hForwards[OnBossSetName] = new PrivateForward( ET_Ignore, Param_Cell, Param_String );
	g_hForwards[OnPlayerHurt] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell );
	g_hForwards[OnMinionHurt] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_CellByRef, Param_Cell );
	g_hForwards[OnActualBossDeath] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell );
	g_hForwards[OnSetBossArgs] = new PrivateForward( ET_Ignore, Param_String, Param_CellByRef, Param_String );
	g_hForwards[OnRedPlayerThink] = new PrivateForward( ET_Ignore, Param_Cell );
	g_hForwards[OnHealthBarUpdate] = new PrivateForward( ET_Hook );
	g_hForwards[OnFighterDeadThink] = new PrivateForward( ET_Ignore, Param_Cell );
}

void Call_OnCallDownloads()
{
	Call_StartForward(g_hForwards[OnCallDownloads]);
	Call_Finish();
}
void Call_OnBossSelected(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossSelected]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnTouchPlayer(const BaseBoss player, const BaseBoss otherguy)
{
	Call_StartForward(g_hForwards[OnTouchPlayer]);
	Call_PushCell(otherguy);
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnTouchBuilding(const BaseBoss player, const int buildRef)
{
	Call_StartForward(g_hForwards[OnTouchBuilding]);
	Call_PushCell(player);
	Call_PushCell(buildRef);
	Call_Finish();
}

void Call_OnBossThink(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossThink]);
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnBossModelTimer(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossModelTimer]);
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnBossDeath(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossDeath]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossEquipped(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossEquipped]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossInitialized(const BaseBoss player, bool override)
{
	Call_StartForward(g_hForwards[OnBossInitialized]);
	Call_PushCell(player);
	Call_PushCell(override);
	Call_Finish();
}
void Call_OnBossPlayIntro(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossPlayIntro]);
	Call_PushCell(player);
	Call_Finish();
}
Action Call_OnBossTakeDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result = Plugin_Continue;
	Call_StartForward(g_hForwards[OnBossTakeDamage]);
	Call_PushCell(player);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArray(damageForce,3);
	Call_PushArray(damagePosition,3);
	Call_PushCell(damagecustom);
	Call_Finish(result);
	return result;
}
Action Call_OnBossDealDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result = Plugin_Continue;
	Call_StartForward(g_hForwards[OnBossDealDamage]);
	Call_PushCell(player);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArray(damageForce,3);
	Call_PushArray(damagePosition,3);
	Call_PushCell(damagecustom);
	Call_Finish(result);
	return result;
}
void Call_OnPlayerKilled(const BaseBoss player, const BaseBoss victim, Event event)
{
	Call_StartForward(g_hForwards[OnPlayerKilled]);
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnPlayerAirblasted(const BaseBoss player, const BaseBoss victim, Event event)
{
	Call_StartForward(g_hForwards[OnPlayerAirblasted]);
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnTraceAttack(const BaseBoss player, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	Call_StartForward(g_hForwards[OnTraceAttack]);
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(ammotype);
	Call_PushCell(hitbox);
	Call_PushCell(hitgroup);
	Call_Finish();
}
void Call_OnBossMedicCall(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossMedicCall]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossTaunt(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnBossTaunt]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossKillBuilding(const BaseBoss player, const int building, Event event)
{
	Call_StartForward(g_hForwards[OnBossKillBuilding]);
	Call_PushCell(player);
	Call_PushCell(building);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnBossJarated(const BaseBoss player, const BaseBoss attacker)
{
	Call_StartForward(g_hForwards[OnBossJarated]);
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_Finish();
}
/*void Call_OnHookSound(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnHookSound]);
	Call_PushCell(player);
	Call_Finish();
}*/
void Call_OnMessageIntro(const BaseBoss player, char message[512])
{
	Call_StartForward(g_hForwards[OnMessageIntro]);
	Call_PushCell(player);
	Call_PushStringEx(message, 512, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnBossPickUpItem(const BaseBoss player, const char item[64])
{
	Call_StartForward(g_hForwards[OnBossPickUpItem]);
	Call_PushCell(player);
	//Call_PushArray(item, 64);
	Call_PushString(item);
	Call_Finish();
}
void Call_OnVariablesReset(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnVariablesReset]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnUberDeployed(const BaseBoss player, const BaseBoss target)
{
	Call_StartForward(g_hForwards[OnUberDeployed]);
	Call_PushCell(target);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnUberLoop(const BaseBoss player, const BaseBoss target)
{
	Call_StartForward(g_hForwards[OnUberLoop]);
	Call_PushCell(target);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnMusic(char song[PLATFORM_MAX_PATH], float& time, const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnMusic]);
	Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnRoundEndInfo(const BaseBoss player, bool bosswin, char message[512])
{
	Call_StartForward(g_hForwards[OnRoundEndInfo]);
	Call_PushCell(player);
	Call_PushCell(bosswin);
	Call_PushStringEx(message, 512, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnLastPlayer(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnLastPlayer]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossHealthCheck(const BaseBoss player, bool isBoss, char message[512])
{
	Call_StartForward(g_hForwards[OnBossHealthCheck]);
	Call_PushCell(player);
	Call_PushCell(isBoss);
	Call_PushStringEx(message, 512, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);	
	Call_Finish();
}
void Call_OnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	Call_StartForward(g_hForwards[OnControlPointCapped]);
	Call_PushString(cappers);
	Call_PushCell(team);
	Call_Finish();
}
void Call_OnPrepRedTeam(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnPrepRedTeam]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnRedPlayerThink(const BaseBoss player)
{
	Call_StartForward(g_hForwards[OnRedPlayerThink]);
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossMenu(Menu& menu)
{
	Call_StartForward(g_hForwards[OnBossMenu]);
	Call_PushCellRef(menu);
	Call_Finish();
}
Action Call_OnBossBackstabbed(const BaseBoss victim, const BaseBoss attacker)
{
	Action action = Plugin_Continue;
	Call_StartForward(g_hForwards[OnBossBackstabbed]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_Finish(action);
	return action;
}
void Call_OnBossWin(const BaseBoss boss, char s[PLATFORM_MAX_PATH], int &sndflags, int &pitch)
{
	Call_StartForward(g_hForwards[OnBossWin]);
	Call_PushCell(boss);
	Call_PushStringEx(s, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCellRef(sndflags);
	Call_PushCellRef(pitch);
	Call_Finish();
}
Action Call_OnBossGiveBackRage(const BaseBoss base)
{
	Action action = Plugin_Continue;
	Call_StartForward(g_hForwards[OnBossGiveBackRage]);
	Call_PushCell(base);
	Call_Finish(action);
	return action;
}
void Call_OnBossSetName(const BaseBoss base, char s[MAX_BOSS_NAME_LENGTH])
{
	Call_StartForward(g_hForwards[OnBossSetName]);
	Call_PushCell(base);
	Call_PushStringEx(s, MAX_BOSS_NAME_LENGTH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnPlayerHurt(const BaseBoss base, const BaseBoss victim, Event event)
{
	Call_StartForward(g_hForwards[OnPlayerHurt]);
	Call_PushCell(base);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnMinionHurt(const BaseBoss victim, const BaseBoss attacker, int &damage, Event event)
{
	Call_StartForward(g_hForwards[OnMinionHurt]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCellRef(damage);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnActualBossDeath(const BaseBoss victim, const BaseBoss attacker, Event event)
{
	Call_StartForward(g_hForwards[OnActualBossDeath]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnSetBossArgs(const char[] bossname, int &type, char[] buffer)
{
	Call_StartForward(g_hForwards[OnSetBossArgs]);
	Call_PushString(bossname);
	Call_PushCellRef(type);
	Call_PushStringEx(buffer, MAX_BOSS_NAME_LENGTH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
Action Call_OnHealthBarUpdate()
{
	Action action = Plugin_Continue;
	Call_StartForward(g_hForwards[OnHealthBarUpdate]);
	Call_Finish(action);
	return action;
}
void Call_OnFighterDeadThink(const BaseBoss fighter)
{
	Call_StartForward(g_hForwards[OnFighterDeadThink]);
	Call_PushCell(fighter);
	Call_Finish();
}
void Call_OnMinionInitialized(const BaseBoss player, const BaseBoss owner)
{
	Call_StartForward(g_hForwards[OnMinionInitialized]);
	Call_PushCell(player);
	Call_PushCell(owner);
	Call_Finish();
}