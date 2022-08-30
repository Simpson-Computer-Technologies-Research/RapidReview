from datetime import datetime as datetime
from discord.ext import commands
import discord, asyncio
from _cache import *
from _sql import *


class Linking(commands.Cog):
    def __init__(self, client):
        self.client = client
    
    # // Link their account
    @commands.command()
    async def link(self, ctx, user_hash:str):
        await ctx.message.delete()
        await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} required verification sent to your dm's", color=4669430), delete_after=3)
        
        try:
            await ctx.author.send(embed=discord.Embed(
                title="Confirmation  [15 Seconds]", 
                description=f"{ctx.author.mention} enter the confirmation code from the **Rapid Review** app", color=4669430
            ))
            _confirmation = await self.client.wait_for(
                "message", 
                check=lambda m: isinstance(m.channel, discord.channel.DMChannel) and m.author == ctx.author, 
                timeout=15
            )
            
        # // If the user doesn't respond, return with an error embed
        except asyncio.TimeoutError:
            return await ctx.author.send(embed=discord.Embed(description=f"{ctx.author.mention} you did not respond in time", color=15158588))
        
        # // Check if the code is valid and update database
        _temp = await Cache().fetch_user_from_database("confirmations", user_hash)
        if _confirmation.content == _temp["codes"][1].split("   |   ")[1]:
            if not await SQL_CLASS().exists(f"SELECT * FROM connections WHERE user_id = {ctx.author.id}"):
                await SQL_CLASS().execute(f"INSERT INTO connections (user_hash, user_id, user_name) VALUES ('{user_hash}', {ctx.author.id}, '{ctx.author}')")
            else:
                await SQL_CLASS().execute(f"UPDATE connections SET user_hash = '{user_hash}' WHERE user_id = {ctx.author.id}")
            return await ctx.author.send(embed=discord.Embed(description=f"{ctx.author.mention} successfully linked your discord account", color=4669430))
        return await ctx.author.send(embed=discord.Embed(description=f"{ctx.author.mention} invalid code", color=15158588))

    # // Unlink their account
    @commands.command()
    async def unlink(self, ctx, user_hash:str):
        await ctx.message.delete()
        if await SQL_CLASS().exists(f"SELECT * FROM connections WHERE user_id = {ctx.author.id} AND user_hash = '{user_hash}'"):
            await SQL_CLASS().execute(f"DELETE FROM connections WHERE user_id = {ctx.author.id} AND user_hash = '{user_hash}'")
            return await ctx.author.send(embed=discord.Embed(description=f"{ctx.author.mention} successfully unlinked your discord account", color=4669430))
        return await ctx.author.send(embed=discord.Embed(description=f"{ctx.author.mention} that rapid user id is not linked to your account", color=15158588))
    
    
    
def setup(client):
    client.add_cog(Linking(client))