from discord.ext import commands
from discord_components import *
from _cache import *
from _sql import *
import discord, os

intents = discord.Intents(messages=True, guilds=True, reactions=True, members=True, presences=True)
client = commands.Bot(command_prefix='!', intents=intents)
client.remove_command('help')

# // ON GUILD JOIN
# ////////////////////
@client.event
async def on_guild_join(guild):
    await client.change_presence(activity=discord.Activity(type=discord.ActivityType.watching, name=f"{len(client.guilds)} Servers"))

@client.event
async def on_ready():
    SQL_CLASS()
    await Cache().launch()
    # run the bot
    DiscordComponents(client)
    await client.change_presence(activity=discord.Activity(type=discord.ActivityType.watching, name=f"{len(client.guilds)} Servers"))
    print(f'Launched: {client.user.name} // {client.user.id}')

for filename in os.listdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'cogs')):
    if filename.endswith('.py'):
        client.load_extension(f'cogs.{filename[:-3]}')
        print(f'Loaded: cog.{filename[:-3]}')


client.run('BOT TOKEN')