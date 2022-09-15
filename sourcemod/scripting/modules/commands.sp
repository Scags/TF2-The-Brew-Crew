public Action QueuePanelCmd(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (!client) {
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	QueuePanel(client);
	return Plugin_Handled;
}

public void QueuePanel(const int client)
{
	Panel panel = new Panel();
	char strBossList[512];
	Format(strBossList, 512, "VSH2 Boss Queue:");
	panel.SetTitle(strBossList);

	BaseBoss Boss = gamemode.GetRandomBoss(false);
	if (Boss) {
		Format(strBossList, sizeof(strBossList), "%N - %i", Boss.index, Boss.iQueue);
		panel.DrawItem(strBossList);
	}
	else panel.DrawItem("None");

	for (int i=0; i<8; ++i) {
		Boss = gamemode.FindNextBoss();	// Using Boss to look at the next boss
		if (Boss) {
			Format(strBossList, 128, "%N - %i", Boss.index, Boss.iQueue);
			panel.DrawItem(strBossList);
			Boss.bSetOnSpawn = true;	// This will have VSHGameMode::FindNextBoss() skip this guy when looping again
		}
		else panel.DrawItem("-");
	}
	
	for (int n=MaxClients ; n ; --n) {	// Ughhh, reset shit...
		if (!IsClientValid(n))
			continue;
		Boss = BaseBoss(n);
		if (!Boss.bIsBoss)
			Boss.bSetOnSpawn = false;
	}

	Format(strBossList, 64, "Your queue points: %i (select to set to 0)", BaseBoss(client).iQueue );
	panel.DrawItem(strBossList);
	panel.Send(client, QueuePanelH, 9001);
	delete (panel);
}
public int QueuePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select && param2 == 10)
		TurnToZeroPanel(param1);
	return false;
}

public Action ResetQueue(int client, int args)
{
	if( !bEnabled.BoolValue )
		return Plugin_Continue;
	if( !client ) 
	{
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	BaseBoss(client).iQueue = 0;
	CPrintToChat(client, "{olive}[VSH 2]{default} Your Queue has been set to 0!");
	BaseBoss nextBoss = gamemode.FindNextBoss(); //int cl = FindNextHaleEx();
	if (nextBoss)
		SkipBossPanelNotify(nextBoss.index);
	return Plugin_Handled;
}
 
public void TurnToZeroPanel(const int client)
{
	Panel panel = new Panel();
	char strPanel[128];
	//SetGlobalTransTarget(client);
	Format(strPanel, 128, "Are you sure you want to set your queue points to 0?");
	panel.SetTitle(strPanel);
	Format(strPanel, 128, "YES");
	panel.DrawItem(strPanel);
	Format(strPanel, 128, "NO");
	panel.DrawItem(strPanel);
	panel.Send(client, TurnToZeroPanelH, 9001);
	delete (panel);
}
public int TurnToZeroPanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select && param2 == 1)
	{
		BaseBoss player = BaseBoss(param1);
		if ( player.iQueue ) {
			player.iQueue = 0;
			CPrintToChat(param1, "{olive}[VSH 2]{default} You have reset your queue points to {olive}0{default}");
			BaseBoss nextBoss = gamemode.FindNextBoss(); //int cl = FindNextHaleEx();
			if (nextBoss)
				SkipBossPanelNotify(nextBoss.index);
		}
	}
}
/* FINALLY THE PANEL TRAIN HAS ENDED! */
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int param2)
{
	/*if ( IsValidAdmin(client, "b") )
		SetBossMenu( client, -1 );
	else CommandSetSkill( client, -1 );*/
}
public Action SetNextSpecial(int client, int args)
{
	if (bEnabled.BoolValue) {
		char arg[32]; GetCmdArgString( arg, sizeof(arg) );
		char buffer[MAX_BOSS_NAME_LENGTH];
		int type = ManageSetBossArgs(arg, buffer);

		gamemode.iSpecial = type;
		CPrintToChat(client, "{olive}[VSH 2]{default} You have set the next special as {olive}%s{default}!", buffer);
	}
	return Plugin_Handled;
}

public Action ChangeHealthBarColor(int client, int args)
{
	if (bEnabled.BoolValue) {
		char number[4]; GetCmdArg( 1, number, sizeof(number) );
		int type = StringToInt(number);

		gamemode.iHealthBarState = type;
		PrintToChat(client, "iHealthBarState = %i", gamemode.iHealthBarState);
	}
	return Plugin_Handled;
}

public Action Command_GetHPCmd(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	if (gamemode.iRoundState != StateRunning)
		return Plugin_Handled;
	
	BaseBoss player = BaseBoss(client);
	ManageBossCheckHealth(player);	// in handler.sp
	return Plugin_Handled;
}
public Action CommandBossSelect(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	if (!args) {
		gamemode.hNextBoss = BaseBoss(client);
		ReplyToCommand(client, "[VSH 2] You've set yourself as the next Boss!");
		return Plugin_Handled;
	}
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	if ( !strcmp(targetname, "@me", false) && IsClientValid(client) ) {
		gamemode.hNextBoss = BaseBoss(client);
		ReplyToCommand(client, "[VSH 2] You've set yourself as the next Boss!");
	}
	else {
		int target = FindTarget(client, targetname);
		if (IsClientValid(target)) {
			gamemode.hNextBoss = BaseBoss(target);
			ReplyToCommand(client, "[VSH 2] %N is set as next Boss!", gamemode.hNextBoss.index);
		}
		else gamemode.hNextBoss = view_as< BaseBoss >(0);
	}
	return Plugin_Handled;
}
public Action SetBossMenu(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;
	if ( args )
	{
		char arg[MAX_BOSS_NAME_LENGTH], buffer[MAX_BOSS_NAME_LENGTH];
		GetCmdArgString(arg, sizeof(arg));
		int type;
		if (IsStringNumeric(arg))
		{
			type = StringToInt(arg);
			BaseBoss(client).iPresetType = type;
			CReplyToCommand(client, "{olive}[VSH 2]{default} Boss ID set to %d.", type);
			return Plugin_Handled;
		}
		type = ManageSetBossArgs(arg, buffer);
		BaseBoss(client).iPresetType = type;
		if (type == -1)
			CReplyToCommand(client, "{olive}[VSH 2]{default} Invalid Boss specified. Setting to random.");
		else CReplyToCommand(client, "{olive}[VSH 2]{default} You've set your boss as {olive}%s{default}!", buffer);
	}

	else
	{
		Menu bossmenu = new Menu(MenuHandler_PickBosses);
		bossmenu.SetTitle("Set Boss Menu: ");
		bossmenu.AddItem("-1", "None (Random Boss)");
		ManageMenu( bossmenu ); // in handler.sp
		bossmenu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public int MenuHandler_PickBosses(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select) {
		char info1[16];
		char info2[MAX_BOSS_NAME_LENGTH];
		menu.GetItem(select, info1, sizeof(info1), _, info2, sizeof(info2));
		BaseBoss player = BaseBoss(client);
		player.iPresetType = StringToInt(info1);
		CPrintToChat(client, "{olive}[VSH 2]{default} You've set your boss as {olive}%s{default}!", info2);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action MusicTogglePanelCmd(int client, int args)
{
	if (!bEnabled.BoolValue || !client)
		return Plugin_Handled;
	MusicPanel(client);
	return Plugin_Handled;
}

public void MusicPanel(const int client)
{
	Panel panel = new Panel();
	panel.SetTitle("VSH2 Music Settings");

	char buffer[64];
	BaseBoss player = BaseBoss(client);

	FormatEx(buffer, sizeof(buffer), "Toggle Music (Current: %s)", player.bNoMusic ? "Off" : "On");
	panel.DrawItem(buffer);

	FormatEx(buffer, sizeof(buffer), "Toggle Volume (Current: %.0f%%)", player.flMusicVolume*100.0);
	panel.DrawItem(buffer);

	panel.DrawItem("Exit");
	panel.Send(client, MusicPanelH, 9001);
	delete panel;
}

public int MusicPanelH(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		if (select == 1)
		{
			BaseBoss player = BaseBoss(client);
			player.bNoMusic = !player.bNoMusic;
			CPrintToChat(client, "{olive}[VSH 2]{default} You've turned %s the VS Saxton Hale Music.", (player.bNoMusic ? "Off" : "On"));
			if (player.bNoMusic)
			{
				if (BackgroundSong[client][0] != '\0')
					StopSound(client, SNDCHAN_AUTO, BackgroundSong[client]);
			}
			else player.flMusicTime = 0.0;
			MusicPanel(client);
		}
		else if (select == 2)
			VolumeTogglePanel(client);
	}
}

public void VolumeTogglePanel(const int client)
{
	Panel panel = new Panel();
	panel.SetTitle("Select a Volume (Customize with /halevol <n>)");
	panel.DrawItem("25%");
	panel.DrawItem("50%");
	panel.DrawItem("75%");
	panel.DrawItem("100%");
	panel.DrawItem("Exit");
	panel.Send(client, VolumeTogglePanelH, 9001);
	delete panel;
}

public int VolumeTogglePanelH(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		BaseBoss player = BaseBoss(client);
		if (select != 5)
		{
			player.flMusicVolume = (select * 25.0) / 100.0;
			CPrintToChat(client, "{olive}[VSH 2]{default} You've set your Music Volume to %.0f%%.", player.flMusicVolume*100.0);
		}
	}
}
public void MusicTogglePanel(const int client)
{
	Panel panel = new Panel();
	panel.SetTitle("Turn the VS Saxton Hale Music...");
	panel.DrawItem("On?");
	panel.DrawItem("Off?");
	panel.DrawItem("Exit");
	panel.Send(client, MusicTogglePanelH, 9001);
	delete (panel);
}
public int MusicTogglePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (IsClientValid(param1))
	{
		if (action == MenuAction_Select)
		{
			BaseBoss player = BaseBoss(param1);
			if (param2 == 1)
			{
				player.bNoMusic = false;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned On the VS Saxton Hale Music.");
				player.flMusicTime = 0.0;
			}
			else if (param2 == 2)
			{
				player.bNoMusic = true;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned Off the VS Saxton Hale Music.");
				if (BackgroundSong[param1][0] != '\0')
					StopSound(param1, SNDCHAN_AUTO, BackgroundSong[param1]);
			}
		}
	}
}

public Action BossSelect(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	BossTogglePanel(client);
	return Plugin_Handled;
}

public void BossTogglePanel(const int client)
{
	if (!bEnabled.BoolValue || !IsClientValid(client))
		return;
	Panel panel = new Panel();
	panel.SetTitle("Be Selected As a Boss?");
	panel.DrawItem("Yes");
	panel.DrawItem("No");
	panel.Send(client, TogglePanel, 9001);
	delete (panel);
}

public int TogglePanel(Menu menu, MenuAction action, int param1, int param2)
{
	if (IsClientValid(param1)) {
		if (action == MenuAction_Select) {
			BaseBoss player = BaseBoss(param1);
			if (param2 == 1) {
				player.bQueueOff = false;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned VSH2 Boss Toggling {lightgreen}on{default}.");
			} else {
				player.bQueueOff = true;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned VSH2 Boss Toggling {lightgreen}off{default}.");
			}
		}
	}
}

public Action ForceBossRealtime(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;

	if (!client) {
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	if (args < 2) {
		ReplyToCommand(client, "[VSH 2] Usage: boss_force <target> <boss>");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState > StateStarting) {
		ReplyToCommand(client, "[VSH 2] You can't force a boss after a round started...");
		return Plugin_Handled;
	}
	
	
	char targetname[32];	GetCmdArg(1, targetname, sizeof(targetname));
	char strBossid[32];	GetCmdArg(2, strBossid, sizeof(strBossid));

	char buffer[MAX_BOSS_NAME_LENGTH];
	int type;
	if (IsStringNumeric(strBossid))
		type = StringToInt(strBossid);
	else type = ManageSetBossArgs(strBossid, buffer);

	if (type == -1)
	{
		CReplyToCommand(client, "{olive}[VSH 2]{default} Invalid boss specified.");
		return Plugin_Handled;
	}

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
		targetname,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	BaseBoss player;
	for (int i=0; i<target_count; i++) {
		if ( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.MakeBossAndSwitch(type, true);
			CPrintToChat(player.index, "{orange}[VSH 2]{default} an Admin has forced you to be a Boss!");
		}
	}
	ReplyToCommand(client, "[VSH 2] Forced %s as a Boss", target_name);
	return Plugin_Handled;
}

public Action CommandAddPoints(int client, int args)
{
	if ( !bEnabled.BoolValue )
		return Plugin_Continue;

	if (args < 2) {
		ReplyToCommand(client, "[VSH] Usage: hale_addpoints <target> <points>");
		return Plugin_Handled;
	}
	char targetname[32];	GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32];		GetCmdArg(2, s2, sizeof(s2));

	int points = StringToInt(s2);

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
		targetname,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	BaseBoss player;
	for (int i=0; i<target_count; i++) {
		if ( IsClientInGame(target_list[i]) )
		{
			player = BaseBoss(target_list[i]);
			player.iQueue += points;
			LogAction(client, target_list[i], "\"%L\" added %d VSH2 queue points to \"%L\"", client, points, target_list[i]);
		}
	}
	ReplyToCommand(client, "[VSH 2] Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}

public Action HelpPanelCmd(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	if (!client) {
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	//char strHelp[512];
	//Format(strHelp, 512, "Welcome to VS Saxton Hale Mode Version 2!\nOne or more players is selected each round to become a Boss.\nEveryone else must kill them!");
	Panel panel = new Panel();
	panel.SetTitle("What do you want, sir?");
	panel.DrawItem("Show Boss' health (/halehp)");
	panel.DrawItem("Show help about the Mode (/halehelp)");
	panel.DrawItem("Who is the next Hale? (/halenext)");
	panel.DrawItem("Reset Queue Points? (/resetq)");
	panel.DrawItem("Turn on/off the music (/halemusic)");
	panel.DrawItem("Toggle Boss selection (/haletoggle)");
//	panel.DrawItem("Choose Boss difficulty (/difficulty)");
	panel.Send(client, HelpPanelH, 9001);
	delete panel;
	return Plugin_Handled;
}
public int HelpPanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (gamemode.iRoundState == StateRunning) {
					BaseBoss player = BaseBoss(param1);
					ManageBossCheckHealth(player);
				}
				else CPrintToChat(param1, "{olive}[VSH 2]{default} There's no active boss/bosses...");
			}
			case 2:
			{
				Panel panel = new Panel();
				panel.SetTitle("Welcome to VS Saxton Hale Mode Version 2!\nOne or more players is selected each round to become a Boss.\nEveryone else must kill them!");
				panel.DrawItem("Exit");
				panel.Send(param1, HintPanel, -1);
			}
			case 3: QueuePanel(param1);
			case 4: {
				BaseBoss(param1).iQueue = 0;
				CPrintToChat(param1, "{olive}[VSH 2]{default} Your Queue has been set to 0!");
			}
			case 5: MusicTogglePanel(param1);
			case 6: BossTogglePanel(param1);
//			case 7: HardModeMenu(param1);
			default: return 0;
		}
	}
	return 0;
}

public Action MenuDoClassRush(int client, int args)
{
 	if (!bEnabled.BoolValue)
 		return Plugin_Continue;
 	if (!client) {
 		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
 		return Plugin_Handled;
 	}
 	
 	Menu rush = new Menu(MenuHandler_ClassRush);
 	rush.SetTitle("VSH2 Class Rush Menu");
 	rush.AddItem("1", "**** Scout ****");
 	rush.AddItem("2", "**** Sniper ****");
 	rush.AddItem("3", "**** Soldier ****");
	rush.AddItem("4", "**** Demoman ****");
 	rush.AddItem("5", "**** Medic ****");
 	rush.AddItem("6", "**** Heavy ****");
 	rush.AddItem("7", "**** Pyro ****");
 	rush.AddItem("8", "**** Spy ****");
 	rush.AddItem("9", "**** Engineer ****");
 	//rush.ExitBackButton = true;
 	rush.Display(client, MENU_TIME_FOREVER);
 	return Plugin_Handled;
}
 
public int MenuHandler_ClassRush(Menu menu, MenuAction action, int client, int pick)
{
 	char info[32]; GetMenuItem(menu, pick, info, sizeof(info));
	if (action == MenuAction_Select) {
 		int classtype = StringToInt(info);
		for( int i=MaxClients ; i ; --i ) {
 			if( !IsClientInGame(i) )
 				continue;
 			if( !IsPlayerAlive(i) || GetClientTeam(i) == gamemode.iHaleTeam )
 				continue;

 			if (TF2_GetPlayerClass(i) == view_as< TFClassType >(classtype))
				continue;

 			TF2_SetPlayerClass( i, view_as< TFClassType >(classtype), _, true );
 			TF2_RegeneratePlayer(i);
 			SetPawnTimer( PrepPlayers, 0.2, BaseBoss(i) );
		}
 	}
 	else if (action == MenuAction_End)
		delete menu;
}

public Action BossDifficulty(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Handled;
	if (!client)
		return Plugin_Handled;

	CReplyToCommand(client, "{olive}[VSH 2]{default} This has been disabled until further notice.");
/*
	if (BaseBoss(client).bIsBoss && IsPlayerAlive(client))
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} Sorry! You are currently a boss!");
		return Plugin_Handled;
	}

	HardModeMenu(client);
*/
	return Plugin_Handled;
}

#if 0
public void HardModeMenu(const int client)
{
	Menu menu = new Menu(DifficultyMenu);
	menu.SetTitle("VSH2 Boss Difficulty");
	menu.AddItem("0", "Normal");
	menu.AddItem("1", "Hard");
	menu.AddItem("2", "Insane");
	menu.AddItem("3", "IMPOSSIBLE");
	menu.AddItem("4", "No-Rage Mode");
	menu.AddItem("5", "Survival Mode");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int DifficultyMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			BaseBoss player = BaseBoss(client);
			switch (select)
			{
				case 0:
				{
					player.iActualDifficulty = 0;
					CPrintToChat(client, "{olive}[VSH 2]{default} Wuss.");
				}
				case 1:
				{
					player.iActualDifficulty = 2;
					CPrintToChat(client, "{olive}[VSH 2]{default} You've selected {unique}Hard Mode{default}.");
				}
				case 2:
				{
					player.iActualDifficulty = 3;
					CPrintToChat(client, "{olive}[VSH 2]{default} You've selected {lightgreen}INSANE Mode{default}.");
				}
				case 3:
				{
					player.iActualDifficulty = 4;
					CPrintToChat(client, "{olive}[VSH 2]{default} lol.");
				}
				case 4:
				{
					player.iActualDifficulty = -1;
					CPrintToChat(client, "{olive}[VSH 2]{default} You've selected {unique}No-Rage Mode{default}.");
				}
				case 5:
				{
					player.iActualDifficulty = -2;
					CPrintToChat(client, "{olive}[VSH 2]{default} You've selected {unique}Survival Mode{default}.\nEnemy players will continuously respawn!");
				}
			}
		}
		case MenuAction_End:delete menu;
	}
}
#endif
public Action GiveBossRage(int client, int args)
{
	if (!args && IsClientInGame(client))
	{
		BaseBoss(client).flRAGE = 100.0;
		return Plugin_Handled;
	}

	char arg[32]; GetCmdArg(1, arg, 32);
	BaseBoss target = BaseBoss(FindTarget(client, arg));

	if (target.bIsBoss)
		target.flRAGE = 100.0;

	return Plugin_Handled;
}

public Action MakeBossRage(int client, int args)
{
	if (!args && IsClientInGame(client))
	{
		BaseBoss(client).flRAGE = 100.0;
		ManageBossTaunt(BaseBoss(client));
		return Plugin_Handled;
	}

	char arg[32]; GetCmdArg(1, arg, 32);
	BaseBoss target = BaseBoss(FindTarget(client, arg));

	if (target.bIsBoss)
	{
		target.flRAGE = 100.0;
		ManageBossTaunt(target);
	}

	return Plugin_Handled;
}

public Action TipsToggle(int client, int args)
{
	if (!client || !AreClientCookiesCached(client))
		return Plugin_Handled;

	char strCookie[6]; GetClientCookie(client, ckTips, strCookie, sizeof(strCookie));
	if (StringToInt(strCookie) == 0)
	{
		SetClientCookie(client, ckTips, "1");
		CPrintToChat(client, "{olive}[VSH 2]{default} You've toggled tips {lightgreen}off{default}.");
	}
	else
	{
		SetClientCookie(client, ckTips, "0");
		CPrintToChat(client, "{olive}[VSH 2]{default} You've toggled tips {lightgreen}on{default}.");
	}
	return Plugin_Handled;
}

public Action UpdateList(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	static Menu menu;
	if (!menu)
	{
		menu = new Menu(HintPanel);
		char strTitle[64]; Format(strTitle, sizeof(strTitle), "VSH 2 What's New? V%s", PLUGIN_VERSION);
		menu.SetTitle(strTitle);

		menu.AddItem("", "Force a Nature deals less knockback");

		menu.AddItem("", "Spy nailguns are removed");
		menu.AddItem("", "Engineer pistols now only grant mini-crits");
		menu.AddItem("", "Equipping the Red-Tape Recorder disallows goomba stomping");
		menu.AddItem("", "Battalion's Backup damage reduction changed to 60% (from 70%)");
		menu.AddItem("", "Equalizer now prevents healing while in use");
		menu.AddItem("", "Overdose speed boost only applies while active");
		menu.AddItem("", "No-scope bodyshots deal 33% less damage");
		menu.AddItem("", "Soda Popper has been reverted to it's original, mini-crit hype");
		menu.AddItem("", "Black Box gains up to 35 hp on hit");
		menu.AddItem("", "Mad Milk heals are now 30% for both heal and overheal");
		menu.AddItem("", "Dalokohs Bar now recharges at a much slower rate");
		menu.AddItem("", "Winger prompts +25% air control");
		menu.AddItem("", "Flying Guillotine bleed time changed to 3 seconds");
		menu.AddItem("", "Saxxy's lunge now works at 0% jump charge");
		menu.AddItem("", "Dio is now !sethale only");

		menu.AddItem("", "V2.24 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Quick-Fix now only has damage resist during uber");
		menu.AddItem("", "Thanos' Soul Stone minions have been replaced with an AOE burn effect");
		menu.AddItem("", "Charging as Demoman now removes Hitler's Gas effect");
		menu.AddItem("", "Head resizes are no longer allowed when you are a boss");

		menu.AddItem("", "V2.23 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Removed Ditto and The Military Tank");
		menu.AddItem("", "Added Big Smoke");
		menu.AddItem("", "Gimgim gaining is now strictly time-based");
		menu.AddItem("", "Bonk! Atomic punch is removed and replaced with Crit-a-Cola");
		menu.AddItem("", "PBPP fires faster, deals less damage");
		menu.AddItem("", "GRU move speed nerfed to +75%");
		menu.AddItem("", "Shotgun heals nerfed to 50% dealt damage");
		menu.AddItem("", "SVF increases afterburn damage by 33%");
		menu.AddItem("", "Letranger fires 40% faster");
		menu.AddItem("", "Buff Banner rage requirement is 25% less");
		menu.AddItem("", "Enforcer increases cloak regen rate");
		menu.AddItem("", "Disciplinary Action gets speed boost on hit");
		menu.AddItem("", "Eviction Notice no longer drains max hp");
		menu.AddItem("", "Warrior's Spirit has hp regen, less max hp");
		menu.AddItem("", "Southern Hospitality grants 2-way teleporters");
		menu.AddItem("", "Market Garden/Chug Jug damage nerfed");
		menu.AddItem("", "Cloak collected while invisible is reduced by 50%");
		menu.AddItem("", "Self blast damage resistance now activates whilst hurting other players");

		menu.AddItem("", "V2.23 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Bonk! Atomic Punch effect now gains instant health");
		menu.AddItem("", "Fake Golden Wrench building health boost is replaced with metal regen");
		menu.AddItem("", "All Scout pistols have a +50% global accuracy boost");
		menu.AddItem("", "Candy Cane swings incredibly fast, but deals little damage");
		menu.AddItem("", "Shotgun/Blutsauger heals now calculate along damage resistances");
		menu.AddItem("", "C&D for the third time now has a decoy cloak type");
		menu.AddItem("", "Removed STAR_");
		menu.AddItem("", "Reoptimized Space Kook, his minions now spawn on a set timer");
		menu.AddItem("", "You now gain Gimgims based on damage dealt per round");
		menu.AddItem("", "Backburner airblast jumps now go slightly less further");

		menu.AddItem("", "V2.22 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Chargin Targe grants +67% damage resistance to ranged attacks");
		menu.AddItem("", "Splendid Screen deals +400% damage on shield bashes");
		menu.AddItem("", "Demoman head speed boost is reduced per head, maxes out at 16 heads");
		menu.AddItem("", "Quickiebomb Launcher has instant arm time");
		menu.AddItem("", "Scottish Resistance has +66% faster firing speed");
		menu.AddItem("", "Vaccinator gains assist damage while healing sentries");
		menu.AddItem("", "Heavy miniguns no longer slow while revved up");
		menu.AddItem("", "Sandvich instantly heals to max overheal");
		menu.AddItem("", "Dalokohs Bar grants +100 max health");
		menu.AddItem("", "Warrior's Spirit loses 50 max hp, regens over time");
		menu.AddItem("", "Eviction notice no longer depletes max hp, swings faster");
		menu.AddItem("", "YER depletes cloak 33% faster");

		menu.AddItem("", "V2.21 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Added Donald Trump");
		menu.AddItem("", "Removed Samurai Jack");
		menu.AddItem("", "Lowered Sauron's jump sound volume");
		menu.AddItem("", "Thanos' Time Stone has been reworked to somewhat reverse time");
		menu.AddItem("", "DIO no longer teleports to his spawn post-rage if he isn't stuck");
		menu.AddItem("", "L4D2 Tank's rage has been converted to a throwable stun");
		menu.AddItem("", "!sethale now works with boss names as arguments (!sethale saxton)");
		menu.AddItem("", "Lucky Sandvich hp no longer disappears when gaining hp through other methods");
		menu.AddItem("", "Stalin's voiceline is now silent during his rage");
		menu.AddItem("", "Hitler's rage now disorients players who are being choked");
		menu.AddItem("", "Axtinguisher's damage boost against burning players is increased");
		menu.AddItem("", "Kunai hp penalty is increased to -65");
		menu.AddItem("", "YER/Wanga Prick grant invisibility upon a successful backstab");
		menu.AddItem("", "Spy-Cicle backstabs remove 15% rage, but at a 33% damage penalty");
		menu.AddItem("", "All bosses have increased knockback resistance when in water");

		menu.AddItem("", "V2.20 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Added The Tank");
		menu.AddItem("", "Hitman's Heatmaker can now headshot while unscoped");
		menu.AddItem("", "Vaccinator stats are split, it can now heal buildings and use the MVM shield");
		menu.AddItem("", "Tank's wallclimb now works on props");
		menu.AddItem("", "All bosses have head hitboxes now!");
		menu.AddItem("", "DIO's rage has been nerfed, again");
		menu.AddItem("", "Difficulties have been patched to actually work now");
		menu.AddItem("", "Survival mode has been added as a difficulty");		
		menu.AddItem("", "Patched a bug with Stalin's Fog");

		menu.AddItem("", "V2.19 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Medigun reset % is reduced to 20%");
		menu.AddItem("", "Crusader's Crossbow uber % on hit is now 10%");
		menu.AddItem("", "Ubershields now require a full 100% charge to stop a hit");
		menu.AddItem("", "Samurai Jack's rage now stuns nearby players");
		menu.AddItem("", "Thanos' Reality Stone has been reverted to its former");
		menu.AddItem("", "Thanos' Power Stone now gives him a defence boost");
		menu.AddItem("", "Jumper reserve ammo is now its default, stock variant");
		menu.AddItem("", "Backstabs with the Big Earner grants a small speed buff");
		menu.AddItem("", "Sauron can Superjump now!");
		menu.AddItem("", "Added boss winstreaks");
		menu.AddItem("", "Added a command for winstreak tracking, !moststreaks");
		menu.AddItem("", "Added a VSH achievement for boss winstreaks");
		menu.AddItem("", "Upped the 'Alternate Targeting' achievement quota to 10");
		menu.AddItem("", "Sniper and Boss wallclimb now works on props");
		menu.AddItem("", "Diamondback crit gain is lowered to 2");

		menu.AddItem("", "V2.18 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Custom-spawned weapons are now visible");
		menu.AddItem("", "Applicable custom-spawned Boss weapons are now visible");
		menu.AddItem("", "Mediguns have been reverted to their original state");
		menu.AddItem("", "Quick-Fix's stats remain in their new state");
		menu.AddItem("", "Obama now has win voicelines");
		menu.AddItem("", "Thanos' Reality Stone has been changed to be more fitting");
		menu.AddItem("", "Lycanroc now has a win voiceline");
		menu.AddItem("", "Lycanroc's rage abilties are slightly slower than before");
		menu.AddItem("", "Ditto's damage has been buffed slightly");
		menu.AddItem("", "STAR_'s rocket launcher now has an infinite clip");
		menu.AddItem("", "Samurai Jack no longer takes knockback during his rage");
		menu.AddItem("", "Hitler's gas rage now flies more horizontally");
		menu.AddItem("", "Boss medic-call sounds no longer override rage sound bites");
		menu.AddItem("", "Bosses with weird ragdolls no longer spawn them on death");
		menu.AddItem("", "Boss code has been split into separate plugins to simplify updates");
		menu.AddItem("", "The Market Gardener formula has been reworked");
		menu.AddItem("", "Jumper weapons' damage vuln has been replaced with an ammo nerf");
		menu.AddItem("", "Backstabs no longer give uber + speed on success");
		menu.AddItem("", "Reserve shooter critical damage is affected by range");
		menu.AddItem("", "Airborne mini-crits no longer activate if a Boss is in water");
		menu.AddItem("", "Flare Gun now behaves exactly like the Detonator");

		menu.AddItem("", "V2.17.2 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Dio's rage now makes him throw knives during the timestop");
		menu.AddItem("", "Dio's timestop is now 5 seconds flat");
		menu.AddItem("", "Ubercharge sounds no longer stick if a medic dies during a Dio timestop");
		menu.AddItem("", "Tank got a minor speed increase");
		menu.AddItem("", "Tank's wall climb no longer triggers with traversable surfaces");
		menu.AddItem("", "Sauron's teleport now teleports you directly where you're aiming");
		menu.AddItem("", "Sauron's main rage now costs 100%");
		menu.AddItem("", "Sauron's main rage has its wallhack time doubled");
		menu.AddItem("", "STAR_'s rage now replenishes both of his clips");
		menu.AddItem("", "HHH Jr's teleport now displays an effect where he teleports from");
		menu.AddItem("", "Boss play statistics are now tracked");
		menu.AddItem("", "Goomba stomps are now tracked in chat");

		menu.AddItem("", "V2.17.1 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Theme update: Added a volume controller (/halevol)");
		menu.AddItem("", "Themes now start when you join the server");
		menu.AddItem("", "Toggling off music now stops the current song");
		menu.AddItem("", "End-Of-Round FF no longer spams the chat box");

		menu.AddItem("", "V2.17 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Added Joseph Stalin");
		menu.AddItem("", "STAR_ moves slower and reloads rockets manually");
		menu.AddItem("", "STAR_ is no longer in the random boss rotation");
		menu.AddItem("", "Projectiles remember their minicrit status");
		menu.AddItem("", "Mediguns no longer heal nor lose uber during Dio timestop");
		menu.AddItem("", "The Holy Mackerel swings quicker, but deals less damage");
		menu.AddItem("", "Removed Pyro shotgun heals");
		menu.AddItem("", "GRU holster speed has been further slowed");

		menu.AddItem("", "V2.16.1 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Removed Sewer Medic");
		menu.AddItem("", "Added Dio Brando");
		menu.AddItem("", "Added Sauron");
		menu.AddItem("", "Fixed a glitch with the Eureka Effect's pads");
		menu.AddItem("", "Added VSH Achievements (!haleach)");
		menu.AddItem("", "Split mediguns into their separate stats");
		menu.AddItem("", "Quick-Fix gives a damage reduction to healer and target");
		menu.AddItem("", "Vaccinator receives the MVM ubershield");
		menu.AddItem("", "All mediguns keep their weapon switch speed buff");

		menu.AddItem("", "V2.16 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Reverted Axtinguisher to stock stats");
		menu.AddItem("", "SVF now has the no fall damage attribute");
		menu.AddItem("", "End of round scoring now excludes players that dealt 0 damage");

		menu.AddItem("", "V2.15 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Removed Plague Doctor");
		menu.AddItem("", "Added the Military Tank");
		menu.AddItem("", "Added the Spooky Space Kook");
		menu.AddItem("", "Claidheamh Mor gets a +2 sec charge increase");
		menu.AddItem("", "Scotsmans Skullcutter gains a speed boost on hit");
		menu.AddItem("", "Fists of Steel movement debuff is lessened to 50%");
		menu.AddItem("", "DDS loses its SMG but you gain +50 max health instead");
		menu.AddItem("", "Winger damage boost is raised to +30%");
		menu.AddItem("", "*Non-Boss Damage* to deadringered/cloaked spies is increased to 25%");
		menu.AddItem("", "Eureka Effect grants custom teleporter creation");
		menu.AddItem("", "Jumper weapons give an increased damage vuln");
		menu.AddItem("", "****Pyro overhaul****");
		menu.AddItem("", "Gas passer recieves the 'Explode on Ignite' attribute");
		menu.AddItem("", "Thermal Thruster can be relaunched mid-flight");
		menu.AddItem("", "Powerjack has its stats applied at all times; + damage vuln");
		menu.AddItem("", "Sharpened Volcano Fragment grants +50% flare/fire resistance");
		menu.AddItem("", "All pyro shotguns (minus Reserve Shooter) gain health on hit");
		menu.AddItem("", "Axtinguisher/Postal Pummeler grant 0 fall damage");
		menu.AddItem("", "Homewrecker/Maul can repair/upgrade Engineer buildings");
		menu.AddItem("", "All pyro primaries (minus DF) can airblast jump");
		menu.AddItem("", "Backburner airblast jumping velocity is doubled");
		menu.AddItem("", "Manmelter gains double afterburn damage");

		menu.AddItem("", "V2.14 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Adjusted sniper damage falloff to where it's not op");
		menu.AddItem("", "Thanos' minions have decreased uber length on spawn");
		menu.AddItem("", "Ditto no longer flips out when rolling a failed Thanos rage");
		menu.AddItem("", "Ditto has stronger knockback resistance");
		menu.AddItem("", "Thermal Thruster has instant switch to/from");
		menu.AddItem("", "!sethale can be used by everyone for freeeeeeeeeee");
		menu.AddItem("", "mid-air minicrits no longer sometimes activate when Hale is on the ground");
		menu.AddItem("", "Saxxy tells you that he has FUCKING ABILITIES that NO ONE KNEW ABOUT for over a YEAR");
		menu.AddItem("", "Saxxys voiceline pitch has been lowered a tad");
		menu.AddItem("", "Cleaners Carbine is useful and can headshot");
		menu.AddItem("", "Star_ has had his shotgun damage decreased and rage nerfed");

		menu.AddItem("", "V2.13 ==============", ITEMDRAW_DISABLED);
		menu.AddItem("", "Star_, Ditto, Lycanroc, and Jack buff");
		menu.AddItem("", "Boot Stomp kill icons are fixed for Hale, Lycanroc, and Hitler");
		menu.AddItem("", "Condition effects (bleed, burn) should no longer instakill invisible spies");
		menu.AddItem("", "Damage once again shows while spectating");
		menu.AddItem("", "Engineer's Panic Attack grants a wrench boost at the cost of no primary");
		menu.AddItem("", "All Sniper melees now prevent Medic healing");
		menu.AddItem("", "Scout overhaul");
		menu.AddItem("", "Thanos");
	}
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public Action g_hPluginsRegisteredLength(int client, int args)
{
	CReplyToCommand(client, "%d", g_hPluginsRegistered.Length);
}

public Action MyType(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	char arg[64]; GetCmdArg(1, arg, 64);

	CPrintToChat(client, "%s type: %i", arg, VSH2Player(client).GetProperty(arg));

	return Plugin_Handled;
}

public Action MultiBoss(int client, int args)
{
	if (!args)
	{
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: sm_multihale <number>.");
		return Plugin_Handled;
	}

	char arg[16]; GetCmdArg(1, arg, sizeof(arg));
	int count = StringToInt(arg);

	if (!(0 < count < 8))
	{
		CReplyToCommand(client, "{olive}[VSH 2]{default} Let's be reasonable here.");
		return Plugin_Handled;
	}

	if (gamemode.iRoundState != StateStarting)
	{
		CPrintToChatAll("{orange}[VSH 2]{default} Multi-boss has been enabled for next round!");
		gamemode.iMulti = count;
	}
	else
	{
		BaseBoss replace;
		while (count-- > 1)
		{
			replace = gamemode.FindNextBoss();
			if (replace && replace.index)
				replace.MakeBossAndSwitch(replace.iPresetType == -1 ? GetRandomInt(Hale, MAXBOSS) : replace.iPresetType, false);
			else
			{
				CReplyToCommand(client, "{olive}[VSH 2]{default} Couldn't find enough bosses to satisfy amount, clamping.");
				break;
			}
		}
		CPrintToChatAll("{orange}[VSH 2]{default} Multi-boss has been enabled for this round!");
	}

	return Plugin_Handled;
}

public Action SetGameMode(int client, int args)
{
//	if (!args)
//	{
//		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: sm_vshmode <id>.");
//		return Plugin_Handled;
//	}

	GMMenu(client);

//	char arg[16]; GetCmdArg(1, arg, sizeof(arg));
//	int val;

//	if (IsStringNumeric(arg))
//		val = StringToInt(arg);
//	else
//	{
//	if (StrContains("normal", arg, false))
//		val = 0;
//	else if (StrContains("survival", arg, false))
//		val = ROUND_SURVIVAL;
//	else if (StrContains("mannpower", arg, false))
//		val = ROUND_MANNPOWER;
//	else if (StrContains("boss vs boss", arg, false))
//		val = ROUND_HVH;
//	}

	return Plugin_Handled;
}

public void GMMenu(const int client)
{
	if (IsVoteInProgress())
		return;

	int gmflags = gamemode.iSpecialRoundPreset;
	Menu menu = new Menu(GameModeMenu);
	menu.SetTitle("VSH2 Game Modes");
	menu.AddItem("0", "Clear all");
	menu.AddItem("1", "Survival\nRed players continuously respawn!", gmflags & ROUND_SURVIVAL ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem("2", "Mannpower\nPowerups! Grappling Hooks! Chaos!", gmflags & ROUND_MANNPOWER ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem("4", "Boss Vs Boss\n2 Teams with a boss. First to die, loses!", gmflags & ROUND_HVH ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	char s[64]; FormatEx(s, sizeof(s), "Multi-Boss\nCurrent boss count = %d", gamemode.iMulti);
	menu.AddItem("8", s);
	FormatEx(s, sizeof(s), "Class-Rush\nCurrent: %s", TF2_GetClassName2(gamemode.iRushPre, true));
	menu.AddItem("16", s);
	menu.Display(client, 0);
}

public int GameModeMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char s[8]; menu.GetItem(select, s, sizeof(s));
		int val = StringToInt(s);
		switch (val)
		{
			case 0:
			{
				gamemode.iSpecialRoundPreset = 0;
//				if (gamemode.iRoundState != StateStarting)
				CPrintToChatAll("{red}[VSH 2]{default} Next round has returned to a normal round.");
//				else CPrintToChatAll("{orange}[VSH 2]{default} This round has returned to a normal round.");
				gamemode.iMulti = 1;
				gamemode.iRushPre = TFClass_Unknown;
				GMMenu(client);
			}
			case ROUND_SURVIVAL:
			{
				gamemode.iSpecialRoundPreset |= ROUND_SURVIVAL;
				gamemode.iSpecialRoundPreset &= ~ROUND_HVH;
//				if (gamemode.iRoundState != StateStarting)
				CPrintToChatAll("{orange}[VSH 2]{default} Survival mode has been enabled for next round!");
//				else CPrintToChatAll("{orange}[VSH 2]{default} Survival mode has been enabled for this round!");
				GMMenu(client);
			}
			case ROUND_MANNPOWER:
			{
				gamemode.iSpecialRoundPreset |= ROUND_MANNPOWER;
//				if (gamemode.iRoundState != StateStarting)
				CPrintToChatAll("{orange}[VSH 2]{default} Mannpower Mode has been enabled for next round!");
//				else CPrintToChatAll("{orange}[VSH 2]{default} Mannpower Mode has been enabled for this round!");
				GMMenu(client);
			}
			case ROUND_HVH:
			{
				gamemode.iSpecialRoundPreset &= ~ROUND_SURVIVAL;
				gamemode.iSpecialRoundPreset |= ROUND_HVH;
//				if (gamemode.iRoundState != StateStarting)
				CPrintToChatAll("{orange}[VSH 2]{default} Boss Vs Boss mode has been enabled for next round!");
//				else CPrintToChatAll("{orange}[VSH 2]{default} Boss Vs Boss mode has been enabled for this round!");
				GMMenu(client);
			}
			case ROUND_MULTI:
			{
				Menu menu2 = new Menu(HowManyMenu);
				menu2.SetTitle("How many bosses?");
				menu2.AddItem("1", "1");
				menu2.AddItem("2", "2");
				menu2.AddItem("3", "3");
				menu2.AddItem("4", "4");
				menu2.AddItem("5", "5");
				menu2.AddItem("6", "6");
				menu2.ExitBackButton = true;
				menu2.Display(client, 0);
			}
			case ROUND_CLASSRUSH:
			{
				Menu menu2 = new Menu(ClassRushMenu);
				menu2.SetTitle("VSH 2 Class Rush Menu");
				menu2.AddItem("0", "**** NONE ****");
			 	menu2.AddItem("1", "**** Scout ****");
			 	menu2.AddItem("2", "**** Sniper ****");
			 	menu2.AddItem("3", "**** Soldier ****");
				menu2.AddItem("4", "**** Demoman ****");
			 	menu2.AddItem("5", "**** Medic ****");
			 	menu2.AddItem("6", "**** Heavy ****");
			 	menu2.AddItem("7", "**** Pyro ****");
			 	menu2.AddItem("8", "**** Spy ****");
			 	menu2.AddItem("9", "**** Engineer ****");
			 	menu2.ExitBackButton = true;
			 	menu2.Display(client, 0);
			}
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}

public int HowManyMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char s[4]; menu.GetItem(select, s, sizeof(s));
		int val = StringToInt(s);
		int oldmulti = gamemode.iMulti;
		gamemode.iMulti = val;
		if (oldmulti == 1 && gamemode.iMulti > 1)
		{
			gamemode.iSpecialRoundPreset |= ROUND_MULTI;
			CPrintToChatAll("{orange}[VSH 2]{default} Multi-boss has been enabled for next round!");
		}
		else if (oldmulti > 1 && gamemode.iMulti == 1)
			CPrintToChatAll("{red}[VSH 2]{default} Multi-boss has been disabled for next round.");

		GMMenu(client);
	}
	else if (action == MenuAction_Cancel)
	{
		if (select == MenuCancel_ExitBack)
			GMMenu(client);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public int ClassRushMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char item[4]; menu.GetItem(select, item, 4);
		TFClassType oldrush = gamemode.iRushPre;
		gamemode.iRushPre = view_as< TFClassType >(StringToInt(item));
		if (oldrush == TFClass_Unknown && gamemode.iRushPre != TFClass_Unknown)
		{
			gamemode.iSpecialRoundPreset |= ROUND_CLASSRUSH;
			CPrintToChatAll("{orange}[VSH 2]{default} A %s class-rush has been activated for next round!", TF2_GetClassName2(gamemode.iRushPre, true));
		}
		else if (oldrush != TFClass_Unknown && gamemode.iRushPre == TFClass_Unknown)
			CPrintToChatAll("{red}[VSH 2]{default} The class rush has been canceled for next round.");
		GMMenu(client);
	}
	else if (action == MenuAction_Cancel)
	{
		if (select == MenuCancel_ExitBack)
			GMMenu(client);
	}
	else if (action == MenuAction_End)
		delete menu;
}

public Action VSHVote(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	if (IsVoteInProgress())
		return Plugin_Handled;

	if (gamemode.iRushPre != TFClass_Unknown)
	{
		CPrintToChat(client, "{olive}[VSH 2]{default} There is already a class rush active for next round!");
		return Plugin_Handled;
	}

	Menu menu = new Menu(VSHVoteMenu);
	menu.SetTitle("[VSH 2] Select a gamemode");
	menu.AddItem("0", "Class Rush");
	menu.AddItem("1", "Survival Mode");
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int VSHVoteMenu(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsVoteInProgress())
				return 0;

			char item[4]; menu.GetItem(select, item, 4);
			int val = StringToInt(item);

			switch (val)
			{
				case 0:
				{
					CPrintToChatAll("{olive}[VSH 2]{default} %N has voted to start a class rush.", client);
					Menu menu2 = new Menu(Vote_Menu);
					menu2.SetTitle("VSH 2 Class Rush Menu");
					menu2.AddItem("0", "**** NONE ****");
				 	menu2.AddItem("1", "**** Scout ****");
				 	menu2.AddItem("2", "**** Sniper ****");
				 	menu2.AddItem("3", "**** Soldier ****");
					menu2.AddItem("4", "**** Demoman ****");
				 	menu2.AddItem("5", "**** Medic ****");
				 	menu2.AddItem("6", "**** Heavy ****");
				 	menu2.AddItem("7", "**** Pyro ****");
				 	menu2.AddItem("8", "**** Spy ****");
				 	menu2.AddItem("9", "**** Engineer ****");
				 	menu2.VoteResultCallback = RushVoteMenuCB;
				 	menu2.DisplayVoteToAll(10);
				}
				case 1:
				{
					if (gamemode.iRoundState == StateEnding)
					{
						CPrintToChat(client, "{olive}[VSH 2]{default} Too late!");
						return 0;
					}

					BaseBoss player = BaseBoss(client);
					if (gamemode.FindNextBoss() != player)
					{
						CPrintToChat(client, "{olive}[VSH 2]{default} You can only select this if you are the next boss!");
						return 0;
					}

					gamemode.hNextBoss = player;
					Menu menu2 = new Menu(Vote_Menu);
					char s[32]; FormatEx(s, sizeof(s), "VSH 2 Survival Mode for %N", client);
					menu2.SetTitle(s);

					if (GetRandomInt(0, 1))
					{
						menu2.AddItem("1", "YES");
						menu2.AddItem("0", "NO");
					}
					else
					{
						menu2.AddItem("0", "NO");
						menu2.AddItem("1", "YES");
					}

					menu2.VoteResultCallback = SurvivalVoteMenuCB;
					menu2.DisplayVoteToAll(10);
				}
			}
		}
	}
	return 0;
}
public int Vote_Menu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_End)
		delete menu;

	return 0;
}

public void RushVoteMenuCB(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	int winner;
	if (num_items > 1 && (item_info[0][VOTEINFO_ITEM_VOTES] == item_info[1][VOTEINFO_ITEM_VOTES]))
		winner = GetRandomInt(0, 1);

	char item[4]; menu.GetItem(item_info[winner][VOTEINFO_ITEM_INDEX], item, sizeof(item));
	gamemode.iRushPre = view_as< TFClassType >(StringToInt(item));

	if (gamemode.iRushPre != TFClass_Unknown)
	{
		char name[32]; TF2_GetClassName(gamemode.iRushPre, name, 32, true);
		CPrintToChatAll("{olive}[VSH 2]{default} A {lightgreen}%s{default} Class Rush has been activated for %s round!", name, gamemode.iRoundState == StateStarting ? "this" : "next");
	}
	else CPrintToChatAll("{olive}[VSH 2]{default} The class rush vote has failed with %d/%d votes (%d%%).", item_info[0][VOTEINFO_ITEM_VOTES], num_votes, RoundFloat(float(item_info[0][VOTEINFO_ITEM_VOTES])/float(num_votes)*100));
}

public void SurvivalVoteMenuCB(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	int winner;
	if (num_items > 1 && (item_info[0][VOTEINFO_ITEM_VOTES] == item_info[1][VOTEINFO_ITEM_VOTES]))
		winner = GetRandomInt(0, 1);

	char item[4]; menu.GetItem(item_info[winner][VOTEINFO_ITEM_INDEX], item, sizeof(item));
	if (StringToInt(item))
	{
		gamemode.iSpecialRoundPreset |= ROUND_SURVIVAL;
		if (gamemode.iRoundState != StateStarting)
			CPrintToChatAll("{olive}[VSH 2]{default} Survival Mode has been enabled for next round!");
		else CPrintToChatAll("{olive}[VSH 2]{default} Survival Mode has been enabled for this round!");
	}
	else CPrintToChatAll("{olive}[VSH 2]{default} The Survival Mode vote has failed.");
}

public Action nSequence(int client, int args)
{
	if (!args || !client)
		return Plugin_Handled;

	char arg[8]; GetCmdArg(1, arg, 8);
	SetEntProp(client, Prop_Send, "m_nSequence", StringToInt(arg));
	return Plugin_Handled;
}

public Action StuckSpec(int client, int args)
{
	if (client && GetClientTeam(client) <= SPEC)
	{
		ChangeClientTeam(client, RED);
		TF2_SetPlayerClass(client, view_as< TFClassType >(GetRandomInt(1, 9)));
		ShowVGUIPanel(client, "class_red");
	}
	return Plugin_Handled;
}

public Action VolumeTogglePanelCmd(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	if (!args)
	{
		VolumeTogglePanel(client);
		return Plugin_Handled;
	}

	char arg[8]; GetCmdArg(1, arg, sizeof(arg));
	BaseBoss player = BaseBoss(client);
	player.flMusicVolume = StringToFloat(arg) / 100.0;
	CPrintToChat(client, "{olive}[VSH 2]{default} You have set your Music Volume to %.0f.", player.flMusicVolume*100.0);
	return Plugin_Handled;
}

public Action WepStats(int client, int args)
{
	WepStatsMenu_Root(client);
	return Plugin_Handled;
}