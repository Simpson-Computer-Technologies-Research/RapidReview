from datetime import datetime as datetime
from discord_components import *
from discord.ext import commands
import discord, asyncio
from _cache import *

class Requests(commands.Cog):
    def __init__(self, client):
        self.client = client
        
        
    @commands.command()
    @commands.has_permissions(administrator=True)
    async def autorequests(self, ctx, option:str):
        if option == "enable":
            try:
                _msg = await ctx.send(embed=discord.Embed(
                    description=f"{ctx.author.mention} respond with the channel you want to send the requests to", color=4669430
                ), delete_after=10)
                _channel = await self.client.wait_for(
                    "message", 
                    check=lambda m: m.channel == ctx.channel and m.author == ctx.author, 
                    timeout=10
                )
                channel = ctx.guild.get_channel(int(_channel.content.split("#")[1].split(">")[0]))
                await _channel.delete()
                await _msg.delete()
                
                # // Get the accept role
                _msg = await ctx.send(embed=discord.Embed(
                    description=f"{ctx.author.mention} mention the role you want to give when the user gets accepted", color=4669430
                ), delete_after=10)
                _role = await self.client.wait_for(
                    "message", 
                    check=lambda m: m.channel == ctx.channel and m.author == ctx.author, 
                    timeout=10
                )
                role = ctx.guild.get_role(int(_role.content.split("&")[1].split(">")[0]))
                await _role.delete()
                await _msg.delete()
            except asyncio.TimeoutError:
                return await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} you did not respond in time", color=15158588), delete_after=2)
            
            # // Update channel topic and return success
            await ctx.channel.edit(topic=f"{role.id}:{channel.id}:{Auth().encode_sha1(str(ctx.channel.id))}")
            return await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} any messages in this channel will be sent to {channel.mention} as a request", color=4669430))
        
        if option == "disable":
            await ctx.channel.edit(topic=f"")
            return await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} disabled auto requests for this channel", color=4669430))
        

    @commands.Cog.listener()
    async def on_message(self, message):
        if not isinstance(message.channel, discord.channel.DMChannel):
            if message.channel.topic and not message.author.bot:
                if Auth().encode_sha1(str(message.channel.id)) in message.channel.topic:
                    if not message.content.startsWith("!"):
                        role = message.guild.get_role(int(message.channel.topic.split(":")[0]))
                        channel = message.guild.get_channel(int(message.channel.topic.split(":")[1]))
                        
                        # // Send the requets to the channel
                        embed = discord.Embed(title=f"[PENDING] {message.author}", description=f"{role.mention}", color=4669430, timestamp=datetime.utcnow())
                        embed.add_field(name="Message", value=message.content)
                        embed.set_footer(text=":"+str(message.author.id))
                        await channel.send(embed=embed, components=[[Button(style=ButtonStyle.green, label="Accept", custom_id="_accept_request"), 
                                                                Button(style=ButtonStyle.red, label="Decline", custom_id="_decline_request")]])
                        await message.channel.send(embed=discord.Embed(description=f"{message.author.mention} successfully submitted your application", color=4669430), delete_after=2)
            
    
def setup(client):
    client.add_cog(Requests(client))