from datetime import datetime as datetime
from discord.ext import commands
from _cache import *
from _sql import *
import discord

class Show(commands.Cog):
    def __init__(self, client):
        self.client = client
        
        
    @commands.command()
    @commands.has_permissions(administrator=True)
    async def show(self, ctx, option:str, user_hash:str):
        if option == "logs":
            pass
        
        if option == "requests":
            if await SQL_CLASS().exists(f"SELECT * FROM connections WHERE user_hash = '{user_hash}' AND user_id = {ctx.author.id}"):
                await Data().update(user_hash, ctx.channel.id)
                return await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} now showing future pending requests in {ctx.channel.mention}", color=4669430))
            return await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} that rapid user id is not linked to your account", color=15158588))
            

    @commands.command()
    async def hide(self, ctx, option:str, user_hash:str):
        if option == "logs":
            pass
        
        if option == "requests":
            if await Data().check(user_hash) != "":
                channel = ctx.guild.get_channel(int(await Data().get(user_hash)))
                await Data().delete(user_hash)
            return await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} no longer showing pending requests in {channel.mention}"))
            

def setup(client):
    client.add_cog(Show(client))