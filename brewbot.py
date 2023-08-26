#/usr/bin/python3

import discord
import mysql.connector
import sys
import datetime
import a2s
import yaml
import cbpro
import d20

from mysql.connector import Error
from time import time, strftime, gmtime
from random import randint, choice
from mcstatus import MinecraftServer
from math import ceil

DATA = None
client = discord.Client(intents=discord.Intents.default())
SQL = None
COMMANDS = {}
CMDDELAY = 0
CRYPTO_CLIENT = cbpro.PublicClient()

async def ccommand(message, msg, args):
	global COMMANDS
	func = COMMANDS.get(msg, None)

	if func is None:
		return

	await func(message, args)

@client.event
async def on_message(message):
	if message.author.bot:
		return

#	if message.channel.type == discord.ChannelType.private:
#		if message.content.lower() == "ireland":
#			await message.channel.send("You got it. It's Ireland!\nYou're next question is a riddle.\n\n\"" + 
#				"Those who make it don't want it. Those who buy it don't use it. Those you use it don't know it. " +
#				"What am I?\"\n\nNote that you must type in the answer in PMs.")
#		elif message.content.lower() == "crypt" or message.content.lower() == "casket" or message.content.lower() == "coffin":
#			await message.channel.send("Bingo. It's a coffin (casket and crypt also valid answers).\nHow about one more?\n\n" + 
#				"An African unladen swallow is traveling in a circular path at 23km/hr. Its starting direction is tangent to the arc-cosine of 23.3. " + 
#				"Its mass is 0.5kg. It has a bone density of 12.3g/cm^3. It is carrying 2 coconuts both of which weighing 4lbs. "
#				"After 12 minutes of traveling, it is now at a 90 degree angle from its original starting angle. " + 
#				"If the swallow's speed remains unchanged for the entire flight, how long will it take to accomplish its circuit? " + 
#				"Please state your answer in seconds."
#				"\n\nNote that you must type in the answer in PMs")
#		elif message.content.lower().startswith("2880"):
#			await message.channel.send("Good one, loser. If it took you a while, then you definitely are one.\n" + 
#				"Congratulations, you are now almost kinda sorta halfway to the end. But then again I might be lying...\n" + 
#				"You're getting a passcode now. Don't lose it. It is CRUCIALLY IMPORTANT\n" + 
#				"You're passcode is `" + "".join([chr(randint(0x21, 0x5F)) for i in range(8)]) + "`\n\n" +
#				"Your next hint is #announcements. Good luck!"
#				)
#		return

	if not message.content:
		return

	if not (message.content[0] == "`" or message.content[0] == "'"):
		return
	
	s = message.content.split()
	msg = s[0][1:].lower()
	args = ""
	try:
		args = message.content[len(msg) + 2:]	# Prefix + space
	except:
		args = ""

	await ccommand(message, msg, args)


def create_connection(host_name, user_name, user_password):
	connection = None
	try:
		connection = mysql.connector.connect(
			host = host_name,
			user = user_name,
			passwd = user_password
		)
		print("Connection to MySQL DB successful")
	except Exception as e:
		print(e)

	return connection

async def _setgame(message, args):
	await doset(message, args, discord.ActivityType.playing)

async def _setstream(message, args):
	await doset(message, args, discord.ActivityType.streaming)

async def _setwatch(message, args):
	await doset(message, args, discord.ActivityType.watching)

async def _setlisten(message, args):
	await doset(message, args, discord.ActivityType.listening)

async def doset(message, name, _type):
	if message.author.id == 538161773841350679:
		url = None
		if _type == discord.ActivityType.streaming:
			url = "https://www.twitch.tv/streamerhouse"
			s = "streaming"
		elif _type == discord.ActivityType.playing:
			s = "playing"
		elif _type == discord.ActivityType.watching:
			s = "watching"
		elif _type == discord.ActivityType.listening:
			s = "listening to"
		await client.change_presence(activity = discord.Activity(name = name, type = _type, url = url))

		await message.channel.send(f"I'm {s} {name}.")

		global DATA
		DATA["game"]["game"] = name
		DATA["game"]["gametype"] = int(_type)
		DATA["game"]["url"] = url

		with open("brewbot.yml", "w") as f:
			yaml.safe_dump(DATA, f, default_flow_style = False, width = 999999)
	else:
		await message.channel.send("You can't do this :(")

async def _stats(message, args):
	if not(len(args)):
		await message.channel.send("Usage: `'stats <name>`")
		return

	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return
	try:
		find = args.replace("'", '"')
		CMDDELAY = time() + 1.0

		if not SQL.is_connected():
			SQL.reconnect()

		cursor = SQL.cursor()

		table = None
		if find.isnumeric():
			cursor.execute(f"SELECT playtime, first_played, last_played, playername, authid FROM scag_stats.tbc_playtime WHERE authid = {find} LIMIT 1;")
			table = cursor.fetchone()
		if table is None:
			cursor.execute(f"SELECT playtime, first_played, last_played, playername, authid FROM scag_stats.tbc_playtime WHERE playername = '{find}' LIMIT 1;")
			table = cursor.fetchone()
			if table is None:
				cursor.execute(f"SELECT playtime, first_played, last_played, playername, authid FROM scag_stats.tbc_playtime WHERE playername LIKE '%%{find}%%' LIMIT 1;")
				table = cursor.fetchone()

		if table is None:
			await message.channel.send(f"Could not find a player named `{args}`.")
			return

		playername = table[3]
		authid = table[4]
		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = f"Stats for '{table[3]}'")

		embed.add_field(name = f"Playtime: {table[0]} minutes", \
			value = f"First seen: {datetime.datetime.utcfromtimestamp(int(table[1]))}\nLast seen: {datetime.datetime.utcfromtimestamp(int(table[2]))}", inline = False)

		cursor.execute(f"SELECT gimgims FROM scag_stats.tbc_stats WHERE authid = {authid};")

		table = cursor.fetchone()
		s2 = "Not Found"
		if table is None:
			s = "Not Found"
		else:
			s = table[0]

			cursor.execute(f"SELECT 1 + COUNT(*) AS rank FROM scag_stats.tbc_stats WHERE gimgims > (SELECT gimgims FROM scag_stats.tbc_stats WHERE authid = {authid});")

			table = cursor.fetchone()

			if len(table):
				s2 = table[0]

		embed.add_field(name = f"Overall Gimgims: {s}", value = f"Overall rank: {s2}", inline = False)

		cursor.execute(f"SELECT gimgims FROM scag_stats.tbc_stats_monthly WHERE authid = {authid};")

		table = cursor.fetchone()
		s2 = "Not Found"
		if table is None:
			s = "Not Found"
		else:
			s = table[0]

			cursor.execute(f"SELECT 1 + COUNT(*) AS rank FROM scag_stats.tbc_stats_monthly WHERE gimgims > (SELECT gimgims FROM scag_stats.tbc_stats_monthly WHERE authid = {authid});")

			table = cursor.fetchone()

			if len(table):
				s2 = table[0]

		embed.add_field(name = f"This Month's Gimgims: {s}", value = f"This month's rank: {s2}", inline = False)

		cursor.execute(f"SELECT goombas FROM scag_goombas.goomba_tracker WHERE playername = '{playername}' LIMIT 1;")

		table = cursor.fetchone()
		s2 = "Not Found"
		if table is None:
			s = "Not Found"
		else:
			s = table[0]

			cursor.execute(f"SELECT 1 + COUNT(*) AS rank FROM scag_goombas.goomba_tracker WHERE goombas > (SELECT goombas FROM scag_goombas.goomba_tracker WHERE playername = '{playername}' LIMIT 1);")

			table = cursor.fetchone()

			if table != None:
				s2 = table[0]

		embed.add_field(name = f"Goombas: {s}", value = f"Goomba rank: {s2}", inline = False)

		await message.channel.send(embed = embed)
	except Exception as e:
		try:
			SQL.reconnect()
		except:
			pass
		print(e)
		await message.channel.send("Could not query database, try again?")

async def servertop(message, args, tbl):
	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return

	try:
		CMDDELAY = time() + 1.0

		if not SQL.is_connected():
			SQL.reconnect()

		cursor = SQL.cursor()
		cursor.execute(f"SELECT playername, gimgims FROM scag_stats.{tbl} ORDER BY gimgims DESC LIMIT 10")
		table = cursor.fetchall()

		if table is None:
			await message.channel.send("There's no one here!")
			return

		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = f"Gimgim {'Monthly ' if tbl == 'tbc_stats_monthly' else ''}Top 10")

		ranks = ""
		names = ""
		gimgims = ""
		for i, val in enumerate(table):
			ranks += f"\n{i + 1}"
			names += f"\n{val[0]}"
			gimgims += f"\n{val[1]}"

		embed.add_field(name = "Rank", value = ranks)
		embed.add_field(name = "Name", value = names)
		embed.add_field(name = "Gimgims", value = gimgims)

		await message.channel.send(embed = embed)
	except Exception as e:
		try:
			SQL.reconnect()
		except:
			pass
		print(e)
		await message.channel.send("Could not query database, try again?")

async def serverstatus(message, addr):
	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return

	CMDDELAY = time() + 1.0
	try:
		server = a2s.info(addr)
		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_thumbnail(url = f"https://brewcrew.tf/images/{server.map_name}.jpg")

		names = ""
		scores = ""
		count = 0
		for player in sorted(a2s.players(addr), key = lambda p: p.duration, reverse = True):
			if player.name != "" and player.name != None:
				count += 1
				names += f"\n{player.name}"
				scores += f"\n{strftime('%M:%S', gmtime(int(player.duration))) if player.duration < 3600.0 else strftime('%H:%M:%S', gmtime(int(player.duration)))}"

		embed.set_author(name = f"{server.server_name} ({count}/{server.max_players})", icon_url = "https://brewcrew.tf/images/tbc_nobackground.png")

		embed.add_field(name = "Name", value = "N/A" if count == 0 else names)
		embed.add_field(name = "Duration", value = "N/A" if count == 0 else scores)
		embed.add_field(name = "Map", value = server.map_name)

		await message.channel.send(embed = embed)
	except Exception as e:
		print(e)
		await message.channel.send("Query failed. Server down?")

async def _top(message, args):
	await servertop(message, args, "tbc_stats")

async def _topm(message, args):
	await servertop(message, args, "tbc_stats_monthly")

async def _vsh(message, args):
	await serverstatus(message, ("198.58.117.191", 27015))

async def _vsh2(message, args):
	await serverstatus(message, ("45.33.12.110", 27015))

async def _surf(message, args):
	await serverstatus(message, ("45.33.25.169", 27015))

async def _goombas(message, args):
	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return

	try:
		CMDDELAY = time() + 1.0

		if not SQL.is_connected():
			SQL.reconnect()

		cursor = SQL.cursor()
		cursor.execute("SELECT steamid, playername, goombas FROM scag_goombas.goomba_tracker ORDER BY goombas DESC LIMIT 10")
		table = cursor.fetchall()

		if table is None:
			await message.channel.send("There's no one here!")
			return

		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = "Goomba Top 10")

		ranks = ""
		names = ""
		goombas = ""
		for i, val in enumerate(table):
			ranks += f"\n{i + 1}"
			names += f"\n{val[0] if val[1] is None else val[1]}"
			goombas += f"\n{val[2]}"

		embed.add_field(name = "Rank", value = ranks)
		embed.add_field(name = "Name", value = names)
		embed.add_field(name = "Goombas", value = goombas)

		await message.channel.send(embed = embed)
	except (Error) as e:
		try:
			SQL.reconnect()
		except:
			print("")
		print(e)
		await message.channel.send("Could not query database, try again?")


async def _help(message, args):
	embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
	embed.set_author(name = "Commands", icon_url = "https://brewcrew.tf/images/tbc_nobackground.png")

	embed.add_field(name = "'stats/'rank", value = "View Gimgims and Goombas from players", inline = False)
	embed.add_field(name = "'top/'top10", value = "View the top 10 overall players", inline = False)
	embed.add_field(name = "'topm/'top10m", value = "View the top 10 monthly players", inline = False)
	embed.add_field(name = "'goomba/'goombas", value = "View the top 10 Goomba stompers", inline = False)
	embed.add_field(name = "'vsh/'vsh2/'hale/'hale2", value = "View the number of players and map on the VSH server", inline = False)
	embed.add_field(name = "'surf", value = "View the number of players and map on the Surf server", inline = False)
	embed.add_field(name = "'boss/'bc", value = "View the current boss playcount", inline = False)
	embed.add_field(name = "'ach/'achievements", value = "View someone's VSH Achievements", inline = False)
	embed.add_field(name = "'achtop", value = "View the first people to accomplish a VSH achievement", inline = False)
	embed.add_field(name = "'help", value = "See this message", inline = False)
	embed.add_field(name = "'minecrafter", value = "Join or leave the Minecrafter role", inline = False)
	embed.add_field(name = "'talk", value = "Make me talk", inline = False)
	embed.add_field(name = "'map", value = "View most popular VSH maps", inline = False)
	embed.add_field(name = "'c/crypto", value = "View a crypto-currency's price", inline = False)
	embed.add_field(name = "'mc", value = "View players on the Minecraft server", inline = False)
	embed.add_field(name = "'r", value = "Roll some dice", inline = False)

	await message.author.send(embed = embed)

async def _boss(message, args):
	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return

	try:
		CMDDELAY = time() + 1.0

		if not SQL.is_connected():
			SQL.reconnect()

		cursor = SQL.cursor()
		cursor.execute("SELECT * FROM scag_bosstracker.vsh2_bosstracker ORDER BY `count` DESC")
		table = cursor.fetchall()

		embed = discord.Embed(colour=discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))

		names = ""
		counts = ""
		for i in table:
			if not i[0]:
				continue
			names += f"\n{i[0]}"
			counts += f"\n{i[1]}"

		embed.add_field(name = "Boss", value = names)
		embed.add_field(name = "Playcount", value = counts)

		await message.channel.send(embed = embed)
	except (Error) as e:
		try:
			SQL.reconnect()
		except:
			print("")
		print(e)
		await message.channel.send("Could not query database, try again?")

ACH_MSG = {}
ACHS = {
	"Close Call": 1,
	"Big Stun": 1,
	"Ova 9000": 1,
	"Soloer": 1,
	"Invincible": 1,
	"Hale Killer": 10,
	"Hale Genocide": 100,
	"Hale Extinction": 1000,
	"Merc Killer": 100,
	"Merc Genocide": 1000,
	"Merc Extinction": 10000,
	"Telefragger": 1,
	"Telefrag Machine": 10,
	"Frog-Man": 100,
	"Masterful Frog-Man": 1000,
	"Veteran": 100,
	"Battlescarred": 1000,
	"Master": 10000,
	"Brew Master": 100000,
	"Rager": 100,
	"E Masher": 1000,
	"Rage Newb": 10000,
	"Backstabber": 100,
	"Gardener": 100,
	"Point Whore": 1000000,
	"Damager": 100000,
	"Damage King": 10000000,
	"Beyond the Grave": 1,
	"#1 Minion": 1,
	"Alternate Targeting": 1,
	"Beep Boop, Maggot": 1,
	"Not OP at all": 1,
	"And Lived to Tell About it": 1,
	"De-Rage-Inator": 1000,
	"Embarrassed": 1,
	"Overkill": 1,
	"Hey Man, Big Fan": 1,
	"My Back Hurts": 1
}

async def _ach(message, args):
	if not(len(args)):
		await message.channel.send("Usage: `'ach <name>`")
		return

	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return

	find = args.replace("'", '"')

	CMDDELAY = time() + 1.0

	if not SQL.is_connected():
		SQL.reconnect()

	cursor = SQL.cursor(dictionary = True)
	table = None
	if find.isnumeric():
		cursor.execute(f"SELECT * FROM scag_haleach.vsh2_achievements WHERE accountid = '{find}';")
		table = cursor.fetchone()
	if table is None:
		cursor.execute(f"SELECT * FROM scag_haleach.vsh2_achievements WHERE playername = '{find}' LIMIT 1;")
		table = cursor.fetchone()
		if table is None:
			cursor.execute(f"SELECT * FROM scag_haleach.vsh2_achievements WHERE playername LIKE '%%{find}%%' LIMIT 1;")
			table = cursor.fetchone()

	if table is None:
		await message.channel.send(f"Could not find a player named `{args}`.")
		return

	cursor.execute(f"SELECT * FROM scag_haleach.vsh2_achievements_timestamp WHERE accountid = {table['accountid']}")
	stamps = cursor.fetchone()

	embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
	embed.set_author(name = f"Achievements for {table['playername']} (#{table['accountid']})")
	embed.set_footer(text = "#[1/4]")

	names = ""
	progress = ""
	stampss = ""
	for i, tup in enumerate(table.items()):
		if i < 3:
			continue

		key, value = tup
		names += f"\n{key}"
		progress += f"\n{value}/{ACHS[key]}"
		stampss += f"\n{'N/A' if stamps[key] == 0 else datetime.datetime.utcfromtimestamp(stamps[key])}"

		if i == 12:
			break

	embed.add_field(name = "Achievement", value = names)
	embed.add_field(name = "Progress", value = progress)
	embed.add_field(name = "Completed", value = stampss)

	msg = await message.channel.send(embed = embed)

	await msg.add_reaction("⏪")
	await msg.add_reaction("⬅️")
	await msg.add_reaction("➡️")
	await msg.add_reaction("⏩")

	ACH_MSG["msg"] = msg
	ACH_MSG["author"] = message.author
	ACH_MSG["page"] = 1
	ACH_MSG["table"] = table
	ACH_MSG["stamps"] = stamps
	ACH_MSG["embed"] = embed

ACHTOP_TABLES = []

async def _achtop(message, args):
	if not(len(args)):
		await message.channel.send("Usage: `'ach <name>`")
		return

	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return

	if not SQL.is_connected():
		SQL.reconnect()

	find = args.replace("'", '"')
	cursor = SQL.cursor()

	CMDDELAY = time() + 1.0

	global ACHTOP_TABLES
	if not len(ACHTOP_TABLES):
		cursor.execute("DESC scag_haleach.vsh2_achievements;")
		table = cursor.fetchall()

		for i, val in enumerate(table):
			if i < 3:
				continue

			ACHTOP_TABLES.append(str(val[0]))

	ach = ""
	for i in ACHTOP_TABLES:
		if args.lower() == i.lower():
			ach = i
			break

	if not len(ach):
		for i in ACHTOP_TABLES:
			if args.lower() in i.lower():
				ach = i
				break

	if not len(ach):
		await message.channel.send(f"Could not find an achievement named `{args}`")
		return

	cursor.execute(f"SELECT playername, `{ach}` FROM scag_haleach.vsh2_achievements_timestamp WHERE `{ach}` != 0 ORDER BY `{ach}` ASC LIMIT 10;")
	table = cursor.fetchall()

	if table is None or not len(table):
		cursor.execute(f"SELECT playername, `{ach}` FROM scag_haleach.vsh2_achievements ORDER BY `{ach}` DESC LIMIT 10;")
		table = cursor.fetchall()
		if table is None or not len(table) or table[0] == 0:
			await message.channel.send("No one has completed this achievement!")
			return

		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = f"{ach} Completion Progress")

		names = ""
		progress = ""
		for i in table:
			names += f"\n{i[0]}"
			progress += f"\n{i[1]}/{ACHS[ach]}"

		embed.add_field(name = "Name", value = names)
		embed.add_field(name = "Progress", value = progress)

		await message.channel.send(embed = embed)
		return

	embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
	embed.set_author(name = f"{ach} Completion Times")

	names = ""
	stamps = ""
	for i in table:
		names += f"\n{i[0]}"
		stamps += f"\n{datetime.datetime.utcfromtimestamp(i[1])}"

	embed.add_field(name = "Name", value = names)
	embed.add_field(name = "Completed", value = stamps)

	if len(table) < 10:
		cursor.execute(f"SELECT playername, `{ach}` FROM scag_haleach.vsh2_achievements WHERE `{ach}` <> {ACHS[ach]} ORDER BY `{ach}` DESC LIMIT {10 - len(table)};")
		table = cursor.fetchall()
		if table is None or not len(table) or table[0] == 0:
			await message.channel.send(embed = embed)
			return

		names = ""
		progress = ""
		for i in table:
			names += f"\n{i[0]}"
			progress += f"\n{i[1]}/{ACHS[ach]}"

		embed.add_field(name = "\u200b", value = "\u200b")		
		embed.add_field(name = "Name", value = names)
		embed.add_field(name = "Progress", value = progress)

	await message.channel.send(embed = embed)

async def _talk(message, args):
	lines = open("chat.txt").read().splitlines()
	await message.channel.send(str(choice(lines)))

async def _minecrafter(message, args):
	minecrafter = discord.utils.get(message.guild.roles, id = 792865964164251669)
	found = minecrafter in message.author.roles

	if found:
		await message.author.remove_roles(minecrafter)
	else:
		await message.author.add_roles(minecrafter)
	await message.add_reaction("👍")

async def _mc(message, args):
	server = MinecraftServer("51.222.117.108", 25576)
	if server is None:
		await message.channel.send("Query failed. Try again?")
		return

	status = server.status()
	if status is None:
		await message.channel.send("Query failed. Try again?")
		return

	embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
	embed.set_author(name = f"The Brew Crew MC ({status.players.online}/{status.players.max})", icon_url = "https://brewcrew.tf/images/tbc_nobackground.png")

	names = ""
	if status.players.sample != None:
		for i in status.players.sample:
			names += f"\n{i.name}"

	embed.add_field(name = "Name", value = "N/A" if not names else names)
	await message.channel.send(embed = embed)

async def calc_page(rstr, page, maxpage):
	if rstr == "⏪":
		if page <= 1:
			return 0

		page = 1
	elif rstr == "⬅️":
		if page <= 1:
			return 0

		page -= 1
	elif rstr == "➡️":
		if page >= maxpage:
			return 0

		page += 1
	elif rstr == "⏩":
		if page >= maxpage:
			return 0

		page = maxpage
	else:
		return 0

	return page

async def on_reaction_ach(reaction, user, message):
	global ACH_MSG
	if user.id != ACH_MSG["author"].id:
		return

	currpage = ACH_MSG["page"]
	rstr = str(reaction)

	await message.remove_reaction(reaction, user)

	page = await calc_page(rstr, currpage, 4)
	if page == 0:
		return

	mult = (page-1) * 10 + 3

	table = ACH_MSG["table"]
	stamps = ACH_MSG["stamps"]

	global ACHS
	names = ""
	progress = ""
	stampss = ""
	for i, tup in enumerate(table.items()):
		if i < mult:
			continue

		key, value = tup
		names += f"\n{key}"
		progress += f"\n{value}/{ACHS[key]}"
		stampss += f"\n{'N/A' if stamps[key] == 0 else datetime.datetime.utcfromtimestamp(stamps[key])}"

		if i == mult + 9:
			break

	embed = ACH_MSG["embed"].copy()

	embed.clear_fields()

	embed.add_field(name = "Achievement", value = names)
	embed.add_field(name = "Progress", value = progress)
	embed.add_field(name = "Completed", value = stampss)
	embed.set_footer(text = f"#[{page}/4]")

	ACH_MSG["embed"] = embed
	ACH_MSG["page"] = page

	await message.edit(embed = embed)

async def on_reaction_crypto(reaction, user, message):
	global CRYPTO_LIST_MSG

	if user.id != CRYPTO_LIST_MSG["author"].id:
		return

	currpage = CRYPTO_LIST_MSG["page"]
	rstr = str(reaction)

	await message.remove_reaction(reaction, user)

	maxpage = ceil(CRYPTO_LIST_MSG["cryptolen"] / 10.0)
	page = await calc_page(rstr, currpage, maxpage)
	if page == 0:
		return

	names = ""
	symbols = ""
	i = 0
	for i in range((page-1) * 10, min((page-1) * 10 + 10, CRYPTO_LIST_MSG["cryptolen"])):
		names += f"{CRYPTO_LIST_MSG['cryptodata'][i]['name']}\n"
		symbols += f"{CRYPTO_LIST_MSG['cryptodata'][i]['id']}\n"

	embed = CRYPTO_LIST_MSG["embed"].copy()

	embed.clear_fields()

	embed.add_field(name = "Name", value = names)
	embed.add_field(name = "Symbol", value = symbols)
	embed.set_footer(text = f"#[{page}/{maxpage}]")

	CRYPTO_LIST_MSG["embed"] = embed
	CRYPTO_LIST_MSG["page"] = page

	await message.edit(embed = embed)

@client.event
async def on_reaction_add(reaction, user):
	message = reaction.message

	if ACH_MSG.get("msg", None) != None and message.id == ACH_MSG["msg"].id:
		await on_reaction_ach(reaction, user, message)
		return

	if CRYPTO_LIST_MSG.get("msg", None) != None and message.id == CRYPTO_LIST_MSG["msg"].id:
		await on_reaction_crypto(reaction, user, message)
		return

@client.event
async def on_raw_reaction_add(payload):
	messageid = payload.message_id
	if messageid == 853071419608924189:
		role = {"📣": 853071176586887186, "🪓": 792865964164251669, "💥": 995093040521805936}.get(str(payload.emoji), -1)
		if role != -1:
			guild = client.get_guild(278726843354447872)
			rolerole = discord.utils.get(guild.roles, id = role)
			user = await guild.fetch_member(payload.user_id)
			await user.add_roles(rolerole)

@client.event
async def on_raw_reaction_remove(payload):
	messageid = payload.message_id
	if messageid == 853071419608924189:
		role = {"📣": 853071176586887186, "🪓": 792865964164251669, "💥": 995093040521805936}.get(str(payload.emoji), -1)
		if role != -1:
			guild = client.get_guild(278726843354447872)
			rolerole = discord.utils.get(guild.roles, id = role)
			user = await guild.fetch_member(payload.user_id)
			await user.remove_roles(rolerole)

async def _map(message, args):
	global CMDDELAY
	if CMDDELAY > time():
		await message.channel.send("Please wait before issuing more commands.")
		return

	if not SQL.is_connected():
		SQL.reconnect()

	cursor = SQL.cursor()
	CMDDELAY = time() + 1.0

	cursor.execute("SELECT * FROM scag_maptracker.maptracker ORDER BY mapcount DESC LIMIT 15;")
	table = cursor.fetchall()

	if table is None or not len(table):
		await message.channel.send("Something bad happened :(")
		return

	embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
	embed.set_author(name = "Map Popularity")

	maps = ""
	counts = ""
	for i in table:
		maps += f"\n{i[0]}"
		counts += f"\n{i[1]}"

	embed.add_field(name = "Name", value = maps)
	embed.add_field(name = "Playcount", value = counts)

	await message.channel.send(embed = embed)

CRYPTO_LIST_MSG = {}

async def print_crypto_list(message):
	try:
		root = CRYPTO_CLIENT.get_currencies()
		global CRYPTO_LIST_MSG
		CRYPTO_LIST_MSG = {}
		cryptodata = []
		for val in root:
			cdata = {}
			cdata["name"] = val["name"]
			cdata["id"] = val["id"]
#			cdata["online"] = val["status"] == "online"
			cryptodata.append(cdata)

		CRYPTO_LIST_MSG["cryptodata"] = cryptodata
		CRYPTO_LIST_MSG["cryptolen"] = len(root)

		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = f"Supported Coins")
		embed.set_footer(text = f"#[1/{ceil(len(root) / 10.0)}]")

		names = ""
		symbols = ""
		i = 0
		for i in range(10):
			names += f"{cryptodata[i]['name']}\n"
			symbols += f"{cryptodata[i]['id']}\n"

		embed.add_field(name = "Name", value = names)
		embed.add_field(name = "Symbol", value = symbols)

		msg = await message.channel.send(embed = embed)

		await msg.add_reaction("⏪")
		await msg.add_reaction("⬅️")
		await msg.add_reaction("➡️")
		await msg.add_reaction("⏩")

		CRYPTO_LIST_MSG["msg"] = msg
		CRYPTO_LIST_MSG["page"] = 1
		CRYPTO_LIST_MSG["data"] = cryptodata
		CRYPTO_LIST_MSG["embed"] = embed
		CRYPTO_LIST_MSG["author"] = message.author

	except Exception as e:
		print(e)
		await message.channel.send("Something bad happened!")



async def _crypto(message, args):
	if len(args):
		s = args.split()[0].lower()
	if not len(args) or s == "help":
		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = f"The Brew Crew's Crypto Connector")

		embed.add_field(name = "'c <coin>", value = "View the current price for a coin", inline = False)
		embed.add_field(name = "'c stats <coin>", value = "View the 24hr stats for a coin", inline = False)
		embed.add_field(name = "'c list", value = "View supported coins", inline = False)
		embed.add_field(name = "'c help", value = "See this message", inline = False)

		await message.channel.send(embed = embed)
	elif s == "list":
		await print_crypto_list(message)
		return
	elif s == "stats":
		crypto = args.split()[1].upper().strip()

		find = crypto
		if not "-" in crypto:
			find += "-USD"

		tree = CRYPTO_CLIENT.get_product_24hr_stats(find)
		successkey = find
		if tree.get("message", None) == "NotFound":
			tree = CRYPTO_CLIENT.get_product_24hr_stats(crypto)
			successkey = crypto
			if tree.get("message", None) == "NotFound":
				tree = CRYPTO_CLIENT.get_product_24hr_stats(crypto.split("-")[0] + "-BTC")
				successkey = crypto.split("-")[0] + "-BTC"
				if tree.get("message", None) == "NotFound":
					attempts = {find, crypto, crypto.split("-")[0] + "-BTC"}
					attempts.remove(crypto)
					await message.channel.send(f"Could not find coin {crypto} (Also searched for {attempts})")
					return

		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = f"24Hr Stats for {successkey}")

		embed.add_field(name = "Open", value = tree["open"])
		embed.add_field(name = "High", value = tree["high"])
		embed.add_field(name = "Low", value = tree["low"])
		embed.add_field(name = "Volume", value = tree["volume"])
		embed.add_field(name = "Last", value = tree["last"])
		embed.add_field(name = "Volume 30Day", value = tree["volume_30day"])

		await message.channel.send(embed = embed)
	else:
		crypto = args.upper().strip()

		find = crypto
		if not "-" in crypto:
			find += "-USD"

		tree = CRYPTO_CLIENT.get_product_ticker(find)
		successkey = find
		if tree.get("message", None) == "NotFound":
			tree = CRYPTO_CLIENT.get_product_ticker(crypto)
			successkey = crypto
			if tree.get("message", None) == "NotFound":
				tree = CRYPTO_CLIENT.get_product_ticker(crypto.split("-")[0] + "-BTC")
				successkey = crypto.split("-")[0] + "-BTC"
				if tree.get("message", None) == "NotFound":
					attempts = {find, crypto, crypto.split("-")[0] + "-BTC"}
					attempts.remove(crypto)
					await message.channel.send(f"Could not find coin {crypto} (Also searched for {attempts})")
					return

		embed = discord.Embed(colour = discord.Colour(randint(0, 0xFFFFFF)), timestamp = datetime.datetime.utcfromtimestamp(time()))
		embed.set_author(name = f"Ticker for {successkey}")

		embed.add_field(name = "Price", value = tree["price"])
		embed.add_field(name = "Size", value = tree["size"])
		embed.add_field(name = "Bid", value = tree["bid"])
		embed.add_field(name = "Ask", value = tree["ask"])
		embed.add_field(name = "Volume", value = tree["volume"])

		await message.channel.send(embed = embed)

async def _r(message, args):
	try:
		result = d20.roll(args)
		await message.channel.send(str(result))
	except:
		await message.channel.send("These are bad dice!")

async def _suggest(message, args):
	if message.channel.id not in (309775610149076993, 690645735158448159, 975250506790359040):
		return

	author = message.author
	banned = discord.utils.get(message.guild.roles, id = 975592893827924020)
	if banned in message.author.roles:
		await message.add_reaction("❌")
		return

	embed = discord.Embed(colour = discord.Colour(0x1e14c), description = message.content[8:], timestamp = datetime.datetime.utcfromtimestamp(time()))
	embed.set_author(name = message.author.nick or message.author.name, icon_url = author.avatar_url)

	channel = discord.utils.get(message.guild.channels, id = 975250506790359040)

	msg = await channel.send(embed = embed)
	await msg.add_reaction("👍")
	await msg.add_reaction("👎")

	await message.add_reaction("➡️")


@client.event
async def on_ready():
	print('Logged in as')
	print(client.user.name)
	print(client.user.id)
	print('------')

	await client.change_presence(activity = discord.Activity(name = DATA["game"]["game"], type = DATA["game"]["gametype"], url = DATA["game"]["url"]))
	global SQL
	SQL = create_connection(DATA["sql"]["host"], DATA["sql"]["user"], DATA["sql"]["pass"])

	global COMMANDS
	COMMANDS = {
		"setgame": _setgame,
		"setstream": _setstream,
		"setwatch": _setwatch,
		"setlisten": _setlisten,
		"stats": _stats,
		"rank": _stats,
		"top": _top,
		"top10": _top,
		"topm": _topm,
		"top10m": _topm,
		"vsh": _vsh,
		"vsh2": _vsh2,
		"hale": _vsh,
		"hale2": _vsh2,
		"surf": _surf,
		"goomba": _goombas,
		"goombas": _goombas,
		"help": _help,
		"boss": _boss,
		"bosses": _boss,
		"bc": _boss,
		"ach": _ach,
		"achievements": _ach,
		"achtop": _achtop,
		"atop": _achtop,
		"talk": _talk,
		"minecrafter": _minecrafter,
		"mc": _mc,
		"map": _map,
		"maps": _map,
		"c": _crypto,
		"crypto": _crypto,
		"r": _r,
		"suggest": _suggest
	}

with open("brewbot.yml") as f:
	DATA = yaml.safe_load(f)

client.run(DATA["token"])