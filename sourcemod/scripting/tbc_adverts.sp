#include <sourcemod>
#include <colorlib>
#include <tbc>
#include <advanced_motd>

public void OnPluginStart()
{
	RegConsoleCmd("sm_donate", CmdDonate, "View Donor perks or donate.");
	RegConsoleCmd("sm_discord", DiscordJoinCmd, "Join the Discord server.");
}

public void OnMapStart()
{
	CreateTimer(212.0, Timer_Advertise, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action Timer_Advertise(Handle timer)
{
	static int announcecount;
	char buffer[256];

	++announcecount;

	switch (announcecount)
	{
		case 1:strcopy(buffer, sizeof(buffer), "We have a Discord server! Type {orange}!discord{default} to join.");
		case 2:strcopy(buffer, sizeof(buffer), "Welcome to {unique}The Brew Crew{default}.");
		case 3:strcopy(buffer, sizeof(buffer), "Use {green}!d{default} to relay a message to the {green}Discord Server{default}.");
		case 4:strcopy(buffer, sizeof(buffer), "You can toggle Discord relay messages off with {lightgreen}!dpref{default}.");
		case 5:strcopy(buffer, sizeof(buffer), "Grind for {olive}Gimgims{default} each month for free donor! Type {green}!rank{default} to see where you stand!");
		case 6:
		{
			if (!GetRandomInt(0, 1))
				strcopy(buffer, sizeof(buffer), "Wanna switch it up? Check out some other game modes on {orange}Wonderland.tf{default}!");
			else strcopy(buffer, sizeof(buffer), "Looking for some Jailbreak? {orange}Wonderland.tf{default} has several servers to choose from!");
		}
		case 7:
		{
			strcopy(buffer, sizeof(buffer), "Our {unique}donors{default} get perks such as class limit immunity, custom titles, chat colors, and more! {orange}!donate{default} to help out!");
			announcecount = 0;
		}
	}

	CPrintToChatAll(TBC_TAG ... "%s", buffer);
	return Plugin_Continue;
}

public Action DiscordJoinCmd(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	AskDiscordPanel(client);

	return Plugin_Handled;
}

public void AskDiscordPanel(int client)
{
	Panel panel = new Panel();
	panel.SetTitle("Which Discord are you looking for?");
	panel.DrawItem("The Brew Crew");
	panel.DrawItem("Wonderland.tf");
	panel.Send(client, AskDiscordPanelHandler, 9001);
	delete panel;
}

public int AskDiscordPanelHandler(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		MenuHandler handler;
		switch (select)
		{
			case 2:handler = DiscordPanelWLN;
			default:handler = DiscordPanelTBC;
		}

		ShowDiscordPanel(client, handler);
	}
}

public void ShowDiscordPanel(int client, MenuHandler handler)
{
	Panel panel = new Panel();
	panel.SetTitle("This will open a Discord link MOTD.\nDo you wish to continue?");
	panel.DrawItem("Yes");
	panel.DrawItem("No, send the link in chat");
	panel.DrawItem("No");
	panel.Send(client, handler, 9001);
	delete panel;

}

public int DiscordPanelTBC(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
		switch (select)
		{
			case 1:AdvMOTD_ShowMOTDPanel(client, "TBC Discord", "https://discord.gg/R8DcdGU", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
			case 2:CPrintToChat(client, "{green}https://discord.gg/R8DcdGU");
		}
}

public int DiscordPanelWLN(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
		switch (select)
		{
			case 1:AdvMOTD_ShowMOTDPanel(client, "WLN Discord", "https://discord.gg/wln", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
			case 2:CPrintToChat(client, "{green}https://discord.gg/wln");
		}
}

public void OnMOTDFailure(int client, MOTDFailureReason reason)
{
	if(reason == MOTDFailure_Disabled) {
		PrintToChat(client, "[SM] You have HTML MOTDs disabled.");
	} else if(reason == MOTDFailure_Matchmaking) {
		PrintToChat(client, "[SM] You cannot view HTML MOTDs because you joined via Quickplay.");
	} else if(reason == MOTDFailure_QueryFailed) {
		PrintToChat(client, "[SM] Unable to verify that you can view HTML MOTDs.");
	} else {
		PrintToChat(client, "[SM] Unable to verify that you can view HTML MOTDs for an unknown reason.");
	}
}

stock bool IsValidClient(const int client, bool nobots = false)
{
	if (client <= 0 || client > MaxClients || (nobots && IsFakeClient(client)))
		return false;
	return IsClientInGame(client);
} 

public Action CmdDonate(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	Panel panel = new Panel();
	panel.SetTitle("This will send you do the donation MOTD.\nDo you wish to continue?");
	panel.DrawItem("Yes");
	panel.DrawItem("No");
	panel.Send(client, DonatePanel, 9001);
	delete panel;
	return Plugin_Handled;
}

public Action CmdSteamGroup(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	Panel panel = new Panel();
	panel.SetTitle("This will open the Steam Group MOTD.\nDo you wish to continue?");
	panel.DrawItem("Yes");
	panel.DrawItem("No, send the link in chat");
	panel.DrawItem("No");
	panel.Send(client, SteamGroupPanel, 9001);
	delete panel;
	return Plugin_Handled;
}

public int SteamGroupPanel(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
		switch (select)
		{
			case 1:AdvMOTD_ShowMOTDPanel(client, "TBC Steamgroup", "https://steamcommunity.com/groups/thebrewcrewcommunity", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
			case 2:CPrintToChat(client, "{green}https://steamcommunity.com/groups/thebrewcrewcommunity");
		}
}

public int DonatePanel(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
		if (select == 1)
			AdvMOTD_ShowMOTDPanel(client, "Donate", "https://www.paypal.me/scag225", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
}
