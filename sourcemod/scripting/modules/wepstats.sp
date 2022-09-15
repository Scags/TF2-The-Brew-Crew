Menu
	hWepMenus[9][3]
;

#define MENUPARAMS 		Menu menu, MenuAction action, int client, int select

public void BuildWepMenus()
{
	int i, u;
	char buffer[64], id[4];
	for (i = 0; i < 9; ++i)
	{
		IntToString(i, id, sizeof(id));
		for (u = 0; u < 3; ++u)
		{
			hWepMenus[i][u] = new Menu(StatHandler);

			TF2_GetClassName(view_as< TFClassType >(i+1), buffer, sizeof(buffer), true);
			hWepMenus[i][u].AddItem(id, buffer, ITEMDRAW_IGNORE);
			Format(buffer, sizeof(buffer), "VSH2 Weapon Stats | %s", buffer);

			hWepMenus[i][u].SetTitle(buffer);
			hWepMenus[i][u].ExitBackButton = true;
		}
	}

	hWepMenus[0][0].AddItem("13", "Scattergun");
	hWepMenus[0][0].AddItem("45", "Force-a-Nature");
	hWepMenus[0][0].AddItem("220", "Shortstop");
	hWepMenus[0][0].AddItem("448", "Soda Popper");
	hWepMenus[0][0].AddItem("772", "BFB");
	hWepMenus[0][0].AddItem("1103", "Back Scatter");
	hWepMenus[0][1].AddItem("23", "Pistol");
	hWepMenus[0][1].AddItem("46", "Bonk! Atomic Punch");
	hWepMenus[0][1].AddItem("163", "Crit-a-Cola");
	hWepMenus[0][1].AddItem("449", "Winger");
	hWepMenus[0][1].AddItem("773", "PBPP");
	hWepMenus[0][1].AddItem("812", "Flying Guillotine");
	hWepMenus[0][1].AddItem("222", "Mad Milk");
	hWepMenus[0][2].AddItem("0", "Bat");
	hWepMenus[0][2].AddItem("44", "Sandman");
	hWepMenus[0][2].AddItem("221", "Holy Mackerel");
	hWepMenus[0][2].AddItem("317", "Candy Cane");
	hWepMenus[0][2].AddItem("325", "Boston Basher");
	hWepMenus[0][2].AddItem("349", "SOAS");
	hWepMenus[0][2].AddItem("355", "Fan O' War");
	hWepMenus[0][2].AddItem("450", "Atomizer");
	hWepMenus[0][2].AddItem("452", "Three-Rune Blade");
	hWepMenus[0][2].AddItem("648", "Wrap Assassin");

	hWepMenus[1][0].AddItem("14", "Sniper Rifle");
	hWepMenus[1][0].AddItem("56", "Huntsman");
	hWepMenus[1][0].AddItem("230", "Sydney Sleeper");
	hWepMenus[1][0].AddItem("526", "Machina");
	hWepMenus[1][0].AddItem("402", "Bazaar Bargain");
	hWepMenus[1][0].AddItem("752", "Hitman's Heatmaker");
	hWepMenus[1][0].AddItem("1098", "Classic");
	hWepMenus[1][1].AddItem("16", "SMG");
	hWepMenus[1][1].AddItem("57", "Razorback");
	hWepMenus[1][1].AddItem("58", "Jarate");
	hWepMenus[1][1].AddItem("231", "DDS");
	hWepMenus[1][1].AddItem("642", "Cozy Camper");
	hWepMenus[1][1].AddItem("751", "Cleaner's Carbine");
	hWepMenus[1][2].AddItem("3", "Kukri");
	hWepMenus[1][2].AddItem("232", "Bushwacka");
	hWepMenus[1][2].AddItem("171", "Tribalman's Shiv");
	hWepMenus[1][2].AddItem("401", "Shahanshah");

	hWepMenus[2][0].AddItem("18", "Rocket Launcher");
	hWepMenus[2][0].AddItem("127", "Direct Hit");
	hWepMenus[2][0].AddItem("228", "Black Box");
	hWepMenus[2][0].AddItem("237", "Rocket Jumper");
	hWepMenus[2][0].AddItem("414", "Liberty Launcher");
	hWepMenus[2][0].AddItem("441", "Cow Mangler");
	hWepMenus[2][0].AddItem("730", "Beggar's Bazooka");
	hWepMenus[2][0].AddItem("1104", "Air Strike");
	hWepMenus[2][1].AddItem("10", "Shotgun");
	hWepMenus[2][1].AddItem("129", "Buff Banner");
	hWepMenus[2][1].AddItem("133", "Gunboats");
	hWepMenus[2][1].AddItem("226", "Battalion's Backup");
	hWepMenus[2][1].AddItem("354", "Concheror");
	hWepMenus[2][1].AddItem("415", "Reserve Shooter");
	hWepMenus[2][1].AddItem("442", "Righteous Bison");
	hWepMenus[2][1].AddItem("444", "Mantreads");
	hWepMenus[2][1].AddItem("1101", "B.A.S.E. Jumper");
	hWepMenus[2][1].AddItem("1153", "Panic Attack");
	hWepMenus[2][2].AddItem("6", "Shovel");
	hWepMenus[2][2].AddItem("128", "Equalizer");
	hWepMenus[2][2].AddItem("154", "Pain Train");
	hWepMenus[2][2].AddItem("357", "Half-Zatoichi");
	hWepMenus[2][2].AddItem("416", "Market Gardener");
	hWepMenus[2][2].AddItem("447", "Disciplinary Action");
	hWepMenus[2][2].AddItem("775", "Escape Plan");

	hWepMenus[3][0].AddItem("19", "Grenade Launcher");
	hWepMenus[3][0].AddItem("308", "Loch-n-Load");
	hWepMenus[3][0].AddItem("405", "Boots");
	hWepMenus[3][0].AddItem("996", "Loose Cannon");
	hWepMenus[3][0].AddItem("1101", "B.A.S.E. Jumper");
	hWepMenus[3][0].AddItem("1151", "Iron Bomber");
	hWepMenus[3][1].AddItem("20", "Stickybomb Launcher");
	hWepMenus[3][1].AddItem("130", "Scottish Resistance");
	hWepMenus[3][1].AddItem("131", "Chargin' Targe");
	hWepMenus[3][1].AddItem("265", "Sticky Jumper");
	hWepMenus[3][1].AddItem("406", "Splendid Screen");
	hWepMenus[3][1].AddItem("1099", "Tide Turner");
	hWepMenus[3][1].AddItem("1150", "Quickiebomb Launcher");
	hWepMenus[3][2].AddItem("154", "Pain Train");
	hWepMenus[3][2].AddItem("132", "Eyelander");
	hWepMenus[3][2].AddItem("307", "Ullapool Caber");
	hWepMenus[3][2].AddItem("327", "Claidheamh Mor");
	hWepMenus[3][2].AddItem("404", "Persian Persuader");
	hWepMenus[3][2].AddItem("609", "Scottish Handshake");
	hWepMenus[3][2].AddItem("172", "Scotsman's Skullcutter");

	hWepMenus[4][0].AddItem("36", "Blutsauger");
	hWepMenus[4][0].AddItem("305", "Crusader's Crossbow");
	hWepMenus[4][0].AddItem("412", "Overdose");
	hWepMenus[4][1].AddItem("29", "Medigun");
	hWepMenus[4][1].AddItem("35", "Kritzkrieg");
	hWepMenus[4][1].AddItem("411", "Quick-Fix");
	hWepMenus[4][1].AddItem("998", "Vaccinator");
	hWepMenus[4][2].AddItem("8", "Bonesaw");
	hWepMenus[4][2].AddItem("37", "Ubersaw");
	hWepMenus[4][2].AddItem("173", "Vita-Saw");
	hWepMenus[4][2].AddItem("304", "Amputator");
	hWepMenus[4][2].AddItem("413", "Solemn Vow");

	hWepMenus[5][0].AddItem("15", "Minigun");
	hWepMenus[5][0].AddItem("41", "Natascha");
	hWepMenus[5][0].AddItem("312", "Brass Beast");
	hWepMenus[5][0].AddItem("424", "Tomislav");
	hWepMenus[5][0].AddItem("811", "Huo-Long Heater");
	hWepMenus[5][1].AddItem("10", "Shotgun");
	hWepMenus[5][1].AddItem("42", "Sandvich");
	hWepMenus[5][1].AddItem("159", "Dalokohs Bar");
	hWepMenus[5][1].AddItem("311", "Buffalo Steak Sandvich");
	hWepMenus[5][1].AddItem("433", "Fishcake");
	hWepMenus[5][1].AddItem("425", "Family Business");
	hWepMenus[5][1].AddItem("1153", "Panic Attack");
	hWepMenus[5][1].AddItem("1190", "Second Banana");
	hWepMenus[5][2].AddItem("5", "Fists");
	hWepMenus[5][2].AddItem("43", "KGB");
	hWepMenus[5][2].AddItem("239", "GRU");
	hWepMenus[5][2].AddItem("310", "Warrior's Spirit");
	hWepMenus[5][2].AddItem("331", "Fists of Steel");
	hWepMenus[5][2].AddItem("426", "Eviction Notice");
	hWepMenus[5][2].AddItem("656", "Holiday Punch");

	hWepMenus[6][0].AddItem("21", "Flamethrower");
	hWepMenus[6][0].AddItem("40", "Backburner");
	hWepMenus[6][0].AddItem("594", "Phlogistinator");
	hWepMenus[6][0].AddItem("1178", "Dragon's Fury");
	hWepMenus[6][1].AddItem("10", "Shotgun");
	hWepMenus[6][1].AddItem("39", "Flare Gun");
	hWepMenus[6][1].AddItem("351", "Detonator");
	hWepMenus[6][1].AddItem("415", "Reserve Shooter");
	hWepMenus[6][1].AddItem("595", "Manmelter");
	hWepMenus[6][1].AddItem("1153", "Panic Attack");
	hWepMenus[6][1].AddItem("1179", "Thermal Thruster");
	hWepMenus[6][1].AddItem("1180", "Gas Passer");
	hWepMenus[6][2].AddItem("2", "Fire Axe");
	hWepMenus[6][2].AddItem("153", "Homewrecker");
	hWepMenus[6][2].AddItem("326", "Back Scratcher");
	hWepMenus[6][2].AddItem("348", "Sharpened Volcano Fragment");
	hWepMenus[6][2].AddItem("457", "Postal Pummeler");
	hWepMenus[6][2].AddItem("593", "Third Degree");
	hWepMenus[6][2].AddItem("813", "Neon Annihilator");
	hWepMenus[6][2].AddItem("1181", "Hot Hand");

	hWepMenus[7][0].AddItem("24", "Revolver");
	hWepMenus[7][0].AddItem("61", "Ambassador");
	hWepMenus[7][0].AddItem("224", "Letranger");
	hWepMenus[7][0].AddItem("460", "Enforcer");
	hWepMenus[7][0].AddItem("525", "Diamondback");
	hWepMenus[7][1].AddItem("735", "Sapper");
	hWepMenus[7][1].AddItem("810", "Red-Tape Recorder");
	hWepMenus[7][2].AddItem("4", "Knife");
	hWepMenus[7][2].AddItem("356", "Conniver's Kunai");
	hWepMenus[7][2].AddItem("225", "YER");
	hWepMenus[7][2].AddItem("461", "Big Earner");
	hWepMenus[7][2].AddItem("649", "Spy-Cicle");

	hWepMenus[8][0].AddItem("9", "Shotgun");
	hWepMenus[8][0].AddItem("141", "Frontier Justice");
	hWepMenus[8][0].AddItem("527", "Widowmaker");
	hWepMenus[8][0].AddItem("588", "Pomson");
	hWepMenus[8][0].AddItem("997", "Rescue Ranger");
	hWepMenus[8][0].AddItem("1153", "Panic Attack");

	hWepMenus[8][1].AddItem("22", "Pistol");
	hWepMenus[8][1].AddItem("140", "Wrangler");
	hWepMenus[8][1].AddItem("528", "Short Circuit");

	hWepMenus[8][2].AddItem("7", "Wrench");
	hWepMenus[8][2].AddItem("142", "Gunslinger");
	hWepMenus[8][2].AddItem("155", "Southern Hospitality");
	hWepMenus[8][2].AddItem("329", "Jag");
	hWepMenus[8][2].AddItem("589", "Eureka Effect");
	hWepMenus[8][2].AddItem("169", "Fake Golden Wrench");
}

public void WepStatsMenu_Root(int client)
{
	Menu menu = new Menu(WepMenu_Root);
	menu.SetTitle("VSH2 Weapon Stats");
	menu.AddItem("1", "Scout");
	menu.AddItem("2", "Sniper");
	menu.AddItem("3", "Soldier");
	menu.AddItem("4", "Demoman");
	menu.AddItem("5", "Medic");
	menu.AddItem("6", "Heavy");
	menu.AddItem("7", "Pyro");
	menu.AddItem("8", "Spy");
	menu.AddItem("9", "Engineer");
 	menu.Display(client, 0);
}

public int WepMenu_Root(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char id[4];
			char item[32]; menu.GetItem(select, id, 4, _, item, sizeof(item));
			WepStatsMenu_Slot(client, id, item);
		}
		case MenuAction_End:delete menu;
	}
}

public void WepStatsMenu_Slot(int client, const char[] id, const char[] name)
{
	Menu menu = new Menu(WepMenu_Slot);
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "VSH2 Weapon Stats | %s", name);
	menu.SetTitle(buffer);
	menu.AddItem("-1", id, ITEMDRAW_IGNORE);
	menu.AddItem("0", "Primary");
	menu.AddItem("1", "Secondary");
	menu.AddItem("2", "Melee");
//	if (!strcmp(buffer, "Spy", false))
//		menu.AddItem("3", "Cloak");
//	menu.AddItem("3", "Class Bonuses");
	menu.ExitBackButton = true;

	menu.Display(client, 0);
}

public int WepMenu_Slot(MENUPARAMS)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char id[4]; menu.GetItem(0, "", 0, _, id, sizeof(id));
			char id2[4]; menu.GetItem(select, id2, sizeof(id2));
//			PrintToChatAll("%s %s", id, id2);
			hWepMenus[StringToInt(id)-1][StringToInt(id2)].Display(client, 0);
		}
		case MenuAction_Cancel:
		{
			if (select == MenuCancel_ExitBack)
				WepStatsMenu_Root(client);
		}
		case MenuAction_End:delete menu;
	}
}

public int StatHandler(MENUPARAMS)
{
	switch (action)
	{
		case MenuAction_Select:
		{
//			char name[32];
			char id[4]; menu.GetItem(0, id, sizeof(id));//, _, name, sizeof(name));
			char item[16], itemname[32]; menu.GetItem(select, item, sizeof(item), _, itemname, sizeof(itemname));
			char buffer[256];
			GetWeaponStat(StringToInt(item), buffer, sizeof(buffer), view_as< TFClassType >(StringToInt(id)));
			if (!strcmp(itemname, buffer, false))
				FormatEx(buffer, sizeof(buffer), "%s: Default stats.", itemname);
			else if (buffer[0] == '\0')
				FormatEx(buffer, sizeof(buffer), "{red}ERROR{default}: No stats found for {olive}%s{default}.", itemname);

			CPrintToChat(client, "{olive}[VSH 2]{default} %s", buffer);
			menu.DisplayAt(client, select - select % 8, 0);
		}
		case MenuAction_Cancel:
		{
			if (select == MenuCancel_ExitBack)
			{
				char name[32];
				char id[4]; menu.GetItem(0, id, sizeof(id), _, name, sizeof(name));
				IntToString(StringToInt(id)+1, id, sizeof(id));
				WepStatsMenu_Slot(client, id, name);
			}
		}
	}
}

stock void GetWeaponStat(int idx, char[] buffer, int maxlen, TFClassType class = TFClass_Unknown)
{
	buffer[0] = '\0';
	if (idx == -1)
		return;
	switch (idx)
	{
		case 13, 200, 669, 799, 808, 888, 897, 906, 915, 964, 973, 15002, 15015, 15021, 15029, 15036, 15053, 15065, 15069, 15106, 15107, 15108, 15131, 15151, 15157:strcopy(buffer, maxlen, "Scattergun");
		case 45, 1078:strcopy(buffer, maxlen, "Force-a-Nature: Less accurate. Always applies self knockback");
		case 220:strcopy(buffer, maxlen, "Shortstop: All stats are constantly active rather than while equipped.");
		case 448:strcopy(buffer, maxlen, "Soda Popper: Gain mini-crits on hype.");
		case 772:strcopy(buffer, maxlen, "BFB: Accurate, powerful, 1 clip size.");
		case 1103:strcopy(buffer, maxlen, "Back Scatter: Crits whenever it would mini-crit.");
		case 18, 205, 513, 658, 800, 809, 889, 898, 907, 916, 965, 974, 15006, 15014, 15028, 15043, 15052, 15057, 15081, 15104, 15105, 15130, 15150:strcopy(buffer, maxlen, "Rocket Launcher: Mini-crits airborne players.");
		case 127:strcopy(buffer, maxlen, "Direct Hit: Crits whenever it would mini-crit.");
		case 228, 1085:strcopy(buffer, maxlen, "Black Box: Gain up to 35 hp on hit.");
		case 414:strcopy(buffer, maxlen, "Liberty Launcher");
		case 441:strcopy(buffer, maxlen, "Cow Mangler");
		case 730:strcopy(buffer, maxlen, "Beggar's Bazooka: No longer overloads. +80% firing speed. Less accurate. Less damage.");
		case 1104:strcopy(buffer, maxlen, "Air Strike: Increase clip size for every 200 damage.");
		case 21, 208, 659, 741, 798, 807, 887, 896, 905, 914, 963, 972, 15005, 15030, 15034, 15049, 15054, 15066, 15067, 15068, 15089, 15090, 15115, 15141, 304747:strcopy(buffer, maxlen, "Flamethrower");
		case 40, 1146:strcopy(buffer, maxlen, "Backburner: Doubled airblast jump velocity.");
		case 215:strcopy(buffer, maxlen, "Degreaser");
		case 594:strcopy(buffer, maxlen, "Phlogistinator: Reduced damage while Mmmmph'd, removed flare crits.");
		case 1178:strcopy(buffer, maxlen, "Dragon's Fury");
		case 19, 206, 1007, 15077, 15079, 15091, 15092, 15116, 15117, 15142, 15158:strcopy(buffer, maxlen, "Grenade Launcher");
		case 308:strcopy(buffer, maxlen, "Loch-n-Load: Ignite on hit.");
		case 996:strcopy(buffer, maxlen, "Loose Cannon");
		case 1151:strcopy(buffer, maxlen, "Iron Bomber");
		case 15, 202, 298, 654, 793, 802, 850, 882, 891, 900, 909, 958, 967, 15004, 15020, 15026, 15031, 15040, 15055, 15086, 15087, 15088, 15098, 15099, 15123, 15124, 15125, 15147:strcopy(buffer, maxlen, "Minigun: Receive +25% damage while being healed by a Medic.");
		case 41:strcopy(buffer, maxlen, "Natascha: Fires mini rockets.");
		case 312:strcopy(buffer, maxlen, "Brass Beast");
		case 424:strcopy(buffer, maxlen, "Tomislav");
		case 811, 832:strcopy(buffer, maxlen, "Huo-Long Heater: +50 % damage versus burning players.");
		case 9, 199, 1141, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152:strcopy(buffer, maxlen, "Shotgun");
		case 141, 1004:strcopy(buffer, maxlen, "Frontier Justice: Gain crits while your sentry is aiming at a Boss.");
		case 527:strcopy(buffer, maxlen, "Widowmaker");
		case 588:strcopy(buffer, maxlen, "Pomson: Full crits. Greater knockback.");
		case 997:strcopy(buffer, maxlen, "Rescue Ranger: Full crits.");
		case 1153:strcopy(buffer, maxlen, "Panic Attack");
		case 17, 204:strcopy(buffer, maxlen, "Syringe Gun: Gain 3% uber on hit.");
		case 36:strcopy(buffer, maxlen, "Blutsauger: Gain 1% uber on hit, can overheal.");
		case 412:strcopy(buffer, maxlen, "Overdose: Gain 1% uber on hit. +5% speed boost when active.");
		case 305, 1079:strcopy(buffer, maxlen, "Crusader's Crossbow: +45% damage. Full Crits. +10% uber on hit.");
		case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154:strcopy(buffer, maxlen, "Sniper Rifle: Hits cause Bosses to glow, scales with charge.");
		case 56, 1005, 1092:strcopy(buffer, maxlen, "Huntsman: Doubled ammo reserve. Full crits.");
		case 230:strcopy(buffer, maxlen, "Sydney Sleeper");
		case 526, 30665:strcopy(buffer, maxlen, "Machina");
		case 402:strcopy(buffer, maxlen, "Bazaar Bargain: Gain heads on headshot.");
		case 752:strcopy(buffer, maxlen, "Hitman's Heatmaker: Gain rage on hit, can headshot while unscoped.");
		case 1098:strcopy(buffer, maxlen, "Classic: Deal extra damage on headshot.");
		case 24, 210, 161, 1142, 15011, 15027, 15042, 15051, 15062, 15063, 15064, 15103, 15128, 15149:strcopy(buffer, maxlen, "Revolver: Receive mini-crits.");
		case 61, 1006:strcopy(buffer, maxlen, "Ambassador: Deal extra damage on headshot.");
		case 224:strcopy(buffer, maxlen, "L'Etrangeur: Fires syringes that cause Bosses to glow on hit.");
		case 460:strcopy(buffer, maxlen, "Enforcer: Increased cloak regen speed, less damage.");
		case 525:strcopy(buffer, maxlen, "Diamondback: Receive 2 crits on backstab.");
		case 15129:
		{
			if (class == TFClass_Soldier)
				strcopy(buffer, maxlen, "Rocket Launcher: Mini-crits airborne players.");
			else strcopy(buffer, maxlen, "Revolver: Receive mini-crits.");
		}
		case 1101:strcopy(buffer, maxlen, "B.A.S.E. Jumper");
		case 237:strcopy(buffer, maxlen, "Rocket Jumper: Lost secondary, less healing from all sources");
		case 133:strcopy(buffer, maxlen, "Gunboats: Reduced fall damage.");
		case 444:strcopy(buffer, maxlen, "Mantreads: Produce greater rocketjumps. Deal stomp damage to Bosses. Reduced fall damage.");
		case 57:strcopy(buffer, maxlen, "Razorback: Block a single hit from a Boss.");
		case 231:strcopy(buffer, maxlen, "DDS: +50 max HP.");
		case 642:strcopy(buffer, maxlen, "Cozy Camper: Gain SMG that causes bleed on hit.");
		case 131, 1144:strcopy(buffer, maxlen, "Chargin' Targe: Block one hit from a Boss. +66% damage resistance to ranged");
		case 406:strcopy(buffer, maxlen, "Splendid Screen: Block one hit from a Boss. +400% charge damage");
		case 1099:strcopy(buffer, maxlen, "Tide Turner: Block one hit from a Boss.");
		case 405, 608:strcopy(buffer, maxlen, "Boots: Deal stomp damage to Bosses. Reduced fall damage.");
		case 23:
		{
			if (class == TFClass_Scout)
				strcopy(buffer, maxlen, "Pistol: Receive mini-crits.");
			else strcopy(buffer, maxlen, "Nailgun: Syringe-firing pistol.");
		}
		case 22, 209, 294, 15013, 15018, 15035, 15041, 15046, 15056, 15060, 15061, 15100, 15101, 15102, 15126, 15148, 30666:FormatEx(buffer, maxlen, "Pistol: Receive %scrits.", class == TFClass_Scout || class == TFClass_Engineer ? "mini-" : "full ");
		case 46, 1145:strcopy(buffer, maxlen, "Bonk! Atomic Punch: Bonk effect replaced with speed boost.");
		case 163:strcopy(buffer, maxlen, "Crit-a-Cola: Recieve crits instead of mini-crits.");
		case 449:strcopy(buffer, maxlen, "Winger: Increased damage boost. +25% air control.");
		case 773:strcopy(buffer, maxlen, "PBPP: Faster firing speed, less damage.");
		case 812, 833:strcopy(buffer, maxlen, "Flying Guillotine: Full crits; speed boost on hit; bonus primary ammo.");
		case 222, 1121:strcopy(buffer, maxlen, "Mad Milk: Heals set to 30% damage. Can overheal.");
		case 10, 11, 12:FormatEx(buffer, maxlen, "Shotgun: Mini-crits airborne players.%s", (class == TFClass_Soldier || class == TFClass_Heavy) ? " Heals on hit." : "");
		case 129, 1001:strcopy(buffer, maxlen, "Buff Banner: 25% Faster rage gain.");
		case 226:strcopy(buffer, maxlen, "Battalion's Backup: Rage blocks Boss damage. Receive full Rage upon getting hit.");
		case 354:strcopy(buffer, maxlen, "Concheror: +15% basic speed boost.");
		case 415:strcopy(buffer, maxlen, "Reserve Shooter: Deals crits whenever it would mini-crit.");
		case 442:strcopy(buffer, maxlen, "Righteous Bison");
		case 39, 1081:strcopy(buffer, maxlen, "Flare Gun: Becomes MegaDetonator with full crits.");
		case 351:strcopy(buffer, maxlen, "Detonator: Becomes MegaDetonator with full crits.");
		case 595:strcopy(buffer, maxlen, "Manmelter: +33% faster firing speed, x2 afterburn damage.");
		case 1179:strcopy(buffer, maxlen, "Thermal Thruster: Instant switch to/from, able to relaunch while in-flight.");
		case 1180:strcopy(buffer, maxlen, "Gas Passer: Has the 'explode on ignite' attribute.");
		case 20, 207, 661, 797, 806, 886, 895, 904, 913, 962, 971, 15009, 15012, 15024, 15038, 15045, 15048, 15082, 15083, 15084, 15113, 15137, 15138, 15155:strcopy(buffer, maxlen, "Stickybomb Launcher");
		case 130:strcopy(buffer, maxlen, "Scottish Resistance: Much faster firing speed");
		case 265:strcopy(buffer, maxlen, "Sticky Jumper: Lose primary, less health from healers.");
		case 1150:strcopy(buffer, maxlen, "Quickiebomb Launcher: Instantly arms");
		case 42, 863, 1002:strcopy(buffer, maxlen, "Sandvich: Instantly grants 450 health");
		case 159:strcopy(buffer, maxlen, "Dalokohs Bar: Health boost is upped to 500, longer recharge time");
		case 433:strcopy(buffer, maxlen, "Fishcake");
		case 311:strcopy(buffer, maxlen, "Buffalo Steak Sandvich");
		case 425:strcopy(buffer, maxlen, "Family Business: Heals on hit.");
		case 1190:strcopy(buffer, maxlen, "Second Banana");
		case 140, 1086, 30668:strcopy(buffer, maxlen, "Wrangler");
		case 16, 203, 1149, 15001, 15022, 15032, 15037, 15058, 15076, 15110, 15134, 15153:strcopy(buffer, maxlen, "SMG");
		case 58, 1083, 1105:strcopy(buffer, maxlen, "Jarate: Remove 8% rage from Bosses.");
		case 751:strcopy(buffer, maxlen, "Cleaner's Carbine: Can deal headshots and grants greater headshot damage");
		case 528:strcopy(buffer, maxlen, "Short Circuit: +100 metal.");
		case 740:strcopy(buffer, maxlen, "Scorch Shot: Deals extra knockback");
		case 29, 211, 663, 796, 805, 885, 894, 903, 912, 961, 970, 15008, 15010, 15025, 15039, 15050, 15078, 15097, 15121, 15122, 15145, 15146:strcopy(buffer, maxlen, "Medigun: Grants crits + uber.");
		case 35:strcopy(buffer, maxlen, "Kritzkrieg: Grants crits + uber.");
		case 411:strcopy(buffer, maxlen, "Quick-Fix: Uber grants defense buff. Patient gains defence buff perpetually.");
		case 998:strcopy(buffer, maxlen, "Vaccinator: Has MVM shield, can heal buildings");
		case 0, 190, 660, 30667:strcopy(buffer, maxlen, "Bat");
		case 44:strcopy(buffer, maxlen, "Sandman: Ball stuns reduce Boss superjump based on travel distance.");
		case 221, 999:strcopy(buffer, maxlen, "Holy Mackerel: 40% faster swing speed, 40% damage penalty");
		case 264:strcopy(buffer, maxlen, "Frying Pan");
		case 317:strcopy(buffer, maxlen, "Candy Cane: Fast swing speed, less damage, drop HP pack on hit.");
		case 325:strcopy(buffer, maxlen, "Boston Basher: Heal on hit.");
		case 349:strcopy(buffer, maxlen, "SOAS: Ignite on hit.");
		case 355:strcopy(buffer, maxlen, "Fan O' War: Remove 5% rage on hit");
		case 423:strcopy(buffer, maxlen, "Saxxy");
		case 450:strcopy(buffer, maxlen, "Atomizer: Greater jump height when active.");
		case 452:strcopy(buffer, maxlen, "Three-Rune Blade: Heal on hit.");
		case 474:strcopy(buffer, maxlen, "Conscientious Objector");
		case 572:strcopy(buffer, maxlen, "Unarmed Combat");
		case 648:strcopy(buffer, maxlen, "Wrap Assassin: Gain extra balls.");
		case 880:strcopy(buffer, maxlen, "Freedom Staff");
		case 939:strcopy(buffer, maxlen, "Bat Outta Hell");
		case 954:strcopy(buffer, maxlen, "Memory Maker");
		case 1013:strcopy(buffer, maxlen, "Ham Shank");
		case 1071:strcopy(buffer, maxlen, "Golden Pan: You are a rich man.");
		case 1123:strcopy(buffer, maxlen, "Necro Smasher");
		case 1127:strcopy(buffer, maxlen, "Crossing Guard");
		case 30758:strcopy(buffer, maxlen, "Prinny Machete");
		case 6, 196:strcopy(buffer, maxlen, "Shovel");
		case 128:strcopy(buffer, maxlen, "Equalizer: Inherits Escape Plan abilities. No healing while active.");
		case 154:strcopy(buffer, maxlen, "Pain Train: +50% primary ammo.");
		case 357:FormatEx(buffer, maxlen, "Half-Zatoichi: Gain 35 health on hit. Overheal to a max of %s.", class == TFClass_Soldier ? "+25" : "+100");
		case 416:strcopy(buffer, maxlen, "Market Gardener: Deal about 10% of a Boss's total health in damage upon a Market Garden.");
		case 447:strcopy(buffer, maxlen, "Disciplinary Action: Gain a speed boost on hit");
		case 775:strcopy(buffer, maxlen, "Escape Plan: Inherits Equalizer abilities.");
		case 2, 192:strcopy(buffer, maxlen, "Fire Axe");
		case 153:strcopy(buffer, maxlen, "Homewrecker: Repair/upgrade friendly buildings.");
		case 214:strcopy(buffer, maxlen, "Powerjack: Gain health on hit.");
		case 326:strcopy(buffer, maxlen, "Back Scratcher");
		case 348:strcopy(buffer, maxlen, "Sharpened Volcano Fragment: +33% afterburn damage.");
		case 457:strcopy(buffer, maxlen, "Postal Pummeler: Increased damage vs burning players.");
		case 466:strcopy(buffer, maxlen, "Maul: Repair/upgrade friendly buildings.");
		case 593:strcopy(buffer, maxlen, "Third Degree: On hit, boost uber of healing medics.");
		case 739:strcopy(buffer, maxlen, "Lollichop");
		case 813, 843:strcopy(buffer, maxlen, "Neon Annihilator: Gain a primary ammo boost.");
		case 38, 1000:strcopy(buffer, maxlen, "Axtinguisher: Increased damage vs burning players.");
		case 1, 191:strcopy(buffer, maxlen, "Bottle");
		case 132, 482, 1082:strcopy(buffer, maxlen, "Eyelander: Gain heads on hit.");
		case 266:strcopy(buffer, maxlen, "HHH Headtaker: Gain heads on hit.");
		case 307:strcopy(buffer, maxlen, "Ullapool Caber: Deal a large amount of damage. Kills you in the process.");
		case 404:strcopy(buffer, maxlen, "Persian Persuader: Drop a small ammo pack on hit.");
		case 327:strcopy(buffer, maxlen, "Claidheamh Mor: 2 sec increased charge time.");
		case 609:strcopy(buffer, maxlen, "Scottish Handshake: Has Market Gardener properties.");
		case 172:strcopy(buffer, maxlen, "Scotsman's Skullcutter: Gain a speed boost on hit.");
		case 5, 195, 587:strcopy(buffer, maxlen, "Fists");
		case 43:strcopy(buffer, maxlen, "KGB: Gain crits on hit.");
		case 239, 1084, 1100:strcopy(buffer, maxlen, "GRU: Go 1.75x speed while active. Take 30 damage/sec.");
		case 310:strcopy(buffer, maxlen, "Warrior's Spirit: Reduced max hp, regens hp over time. Gain +50 hp on hit.");
		case 331:strcopy(buffer, maxlen, "Fists of Steel: Take reduced damage while active.");
		case 426:strcopy(buffer, maxlen, "Eviction Notice: Faster swing speed. Does not drain max hp.");
		case 656:strcopy(buffer, maxlen, "Holiday Punch: Critical hits cause Bosses to laugh.");
		case 7, 197, 662, 795, 804, 884, 893, 902, 911, 960, 969, 15073, 15074, 15075, 15139, 15140, 15114, 15156:strcopy(buffer, maxlen, "Wrench: +25 health.");
		case 142:strcopy(buffer, maxlen, "Gunslinger: +50 health.");
		case 155:strcopy(buffer, maxlen, "Southern Hospitality: Grants two-way teleporters, 25% slower swing speed.");
		case 329:strcopy(buffer, maxlen, "Jag: +25 health.");
		case 589:strcopy(buffer, maxlen, "Eureka Effect: Build custom teleporters! Reload/M3 to cycle.");
		case 169:strcopy(buffer, maxlen, "Fake Golden Wrench: Lost primary, +25% swing speed, +50% repair rate, +30% sentry resistance.");
		case 8, 198, 1143:strcopy(buffer, maxlen, "Bonesaw");
		case 37, 1003:strcopy(buffer, maxlen, "Ubersaw");
		case 173:strcopy(buffer, maxlen, "Vita-Saw: Medi-charge reset is expanded.");
		case 304:strcopy(buffer, maxlen, "Amputator: Players in taunt range gain a defence buff.");
		case 413:strcopy(buffer, maxlen, "Solemn Vow: Faster swing speed. Gain 10% uber on hit. Loses crits.");
		case 3, 193:strcopy(buffer, maxlen, "Kukri");
		case 171:strcopy(buffer, maxlen, "Tribalman's Shiv");
		case 232:strcopy(buffer, maxlen, "Bushwacka");
		case 401:strcopy(buffer, maxlen, "Shahanshah");
		case 4, 194, 638, 665, 727, 794, 803, 883, 892, 901, 910, 959, 968, 15094, 15095, 15096, 15118, 15119, 15143, 15144:strcopy(buffer, maxlen, "Knife: Backstabs deal about 10% of a Boss's total health in damage.");
		case 356:strcopy(buffer, maxlen, "Conniver's Kunai: Gain +180 health upon a backstab; Less max HP.");
		case 225:strcopy(buffer, maxlen, "YER: Silent decloak. Cloaked on backstab.");
		case 461:strcopy(buffer, maxlen, "Big Earner: Gain full cloak on a backstab.");
		case 574:strcopy(buffer, maxlen, "Wanga Prick: Silent decloak. Cloaked on backstab.");
		case 649:strcopy(buffer, maxlen, "Spy-Cicle: Rage loss on backstab; decreased backstab damage");
		case 1181:strcopy(buffer, maxlen, "Hot Hand: Deal greater damage to burning players.");
		case 735, 736:strcopy(buffer, maxlen, "Sapper");
		case 810, 831:strcopy(buffer, maxlen, "Red-Tape Recorder: Disallows goomba stomping.");
	}
}