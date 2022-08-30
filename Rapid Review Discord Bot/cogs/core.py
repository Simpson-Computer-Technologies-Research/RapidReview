from datetime import datetime as datetime
from discord.ext import commands
from discord_components import *
import discord, asyncio, json
from _cache import *
from _sql import *

class Core(commands.Cog):
    def __init__(self, client):
        self.client = client
        self.currently_applying = {}
        
    def indent(self):
        return "‏‏‎ ‎"

    def request_user(self, res):
        return res.author.name+res.author.discriminator

    def get_user(self, code:str):
        return code.split("-")[0]
    
    def form_code(self, code:str):
        return code.split("-")[1]

    # // Setup command
    @commands.command(aliases=["s"])
    @commands.has_permissions(administrator=True)
    async def setup(self, ctx):
        await ctx.message.delete()
        try:
            # // Get the form code
            _msg = await ctx.send(embed=discord.Embed(
                description=f"{ctx.author.mention} respond with the form code you want to use", color=4669430
            ), delete_after=10)
            _code = await self.client.wait_for(
                "message", 
                check=lambda m: m.channel == ctx.channel and m.author == ctx.author, 
                timeout=10
            )
            code = _code.content
            await _code.delete()
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
                
                
        # // Check if code length is greater than 10
        if len(code) < 10:
            embed=discord.Embed(description=f"{ctx.author.mention} invalid code, please copy the code from the form edit section", color=15158588)
            embed.set_footer(text=f"Example: 822f3d5b9c91b570a4f1848c5d147b4709d2fb96-wNAxH")
            return await ctx.send(embed=embed, delete_after=3)
        else:
            if not await SQL_CLASS().exists(f"SELECT * FROM connections WHERE user_id = {ctx.author.id} AND user_hash = '{code.split('-')[0]}'"):
                await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} required verification sent to your dm's", color=4669430), delete_after=3)
                try:
                    # // Send the embeds and wait for a response
                    await ctx.author.send(embed=discord.Embed(
                        title="Confirmation  [15 Seconds]", 
                        description=f"{ctx.author.mention} enter the confirmation code from the **Rapid Review** app", color=4669430
                    ))
                    _confirmation = await self.client.wait_for(
                        "message", 
                        check=lambda m: isinstance(m.channel, discord.channel.DMChannel) and m.author == ctx.author, 
                        timeout=15
                    )
                except asyncio.TimeoutError:
                    return await ctx.author.send(embed=discord.Embed(description=f"{ctx.author.mention} you did not respond in time", color=15158588))
                
                # // Check if the confirmation code is correct
                if not await Auth().check_confirmation_code(code.split("-")[0], _confirmation.content):
                    return await ctx.author.send(embed=discord.Embed(description=f"{ctx.author.mention} incorrect confirmation code", color=15158588))
                
            # // Create the new setup embed
            await Cache().launch()
            await ctx.author.send(embed=discord.Embed(title="Success", description=f"If you update the form, please run the setup command again", color=3066992))
            embed=discord.Embed(title=ctx.guild.name,description=f"Apply for{self.indent()}{role.mention}{self.indent()}{self.indent()}<a:blueverify:919714552642437142>", color=4669430)
            embed.set_footer(text=f"{code}")
            return await ctx.send(embed=embed, components=[Button(style=ButtonStyle.blue, label="Apply", custom_id="apply")])
        
        
    # // When the user starts an application function
    async def start_application(self, res, code:str, role):
        if code not in self.currently_applying:
            self.currently_applying[code] = {}
        self.currently_applying[code][self.request_user(res)] = {}
        
        # // Get the questions from the cached database
        _temp = await Cache().fetch_user("form-codes", self.get_user(code))
        for question in list(_temp[self.form_code(code)]):
            await res.author.send(embed=discord.Embed(title=question, description="Maximum of 500 characters allowed!", color=4669430))
            
            # // Check answer attachements
            answer = await self.client.wait_for("message", check=lambda m: m.author == res.author)
            if answer.attachments:
                self.currently_applying[code][self.request_user(res)].update(
                    {question: " * ".join((str(e.url)) for e in answer.attachments)})
            else:
                while(len(answer.content) > 500):
                    await res.author.send(embed=discord.Embed(description=f"Maximum of 500 characters allowed!", color=15158588))
                    answer = await self.client.wait_for("message", check=lambda m: m.author == res.author)
                self.currently_applying[code][self.request_user(res)].update({question: answer.content})
        
        # // When the user finishes the application
        await res.author.send(embed=discord.Embed(title="Rapid", description="Successfully submitted your application", color=4669430))
        if await Data().check(code.split("-")[0]) != "":
           await self.send_discord_application(res, code, role)
        await self.end_application(res, code, role)
    

    # // Send an application to the request channel
    async def send_discord_application(self, res, code:str, role):
        embed = discord.Embed(title=f"[PENDING] {res.author}", description=f"{role.mention}", color=4669430, timestamp=datetime.utcnow())
        embed.set_footer(text=code+":"+res.author.id)
        map = self.currently_applying[code][self.request_user(res)]
        for i in map:
            embed.add_field(name=i, value=map[i])
        channel = res.guild.get_channel(await Data().get(code.split("-")[0]))
        await channel.send(embed=embed, components=[[Button(style=ButtonStyle.green, label="Accept", custom_id="accept_request"), 
                                                     Button(style=ButtonStyle.red, label="Decline", custom_id="decline_request")]])
    
    
    # // The end of the application function
    async def end_application(self, res, code, role):
        if await Cache().requests_check(self.get_user(code), self.request_user(res)):
            # // Create a new temp map
            _temp = await Cache().fetch_user_from_database("pending-requests", self.get_user(code))
            temp = _temp["requests"]
            
            # // Update the temp map
            temp[self.request_user(res)] = {
                "values": self.currently_applying[code][self.request_user(res)],
                "data": {
                    "user_id": str(res.author.id),
                    "role_id": str(role.id),
                    "role_name": str(role.name),
                    "guild_id": str(res.guild.id),
                    "guild_name": res.guild.name,
                    "avatar_url": str(res.author.avatar_url).replace(".webp", ".jpg")
                }
            }
            # // Update the cache and database
            await Cache().update_requests(self.get_user(code), json.dumps(temp))
            del self.currently_applying[code][self.request_user(res)]
    
    
    
    # // Check when the application button is pressed
    @commands.Cog.listener()
    async def on_button_click(self, res):
        if not res.author.bot:
            if res.component.id == "apply":
                role_id = str(res.message.embeds[0].description).split("&")[1].split(">")[0]
                role = res.guild.get_role(int(role_id))
                code = res.message.embeds[0].footer.text
                user_hash = code.split('-')[0]
                if await SQL_CLASS().exists(f"SELECT blocked_user FROM blocked_users WHERE user_hash = '{user_hash}' AND blocked_user = '{res.author.name+res.author.discriminator}'"):
                    return await res.send(embed=discord.Embed(description=f"{res.author.mention} you are blocked from creating a new application", color=15158588))
                await res.send(embed=discord.Embed(description=f"{res.author.mention} application process started, proceed to dm's", color=4669430))
                
                # // Start the application
                await self.start_application(res, code, role)
                

            if res.component.id in ["decline_request", "accept_requests", "_accept_request", "_decline_request", "undo_request"]:
                role_id = str(res.message.embeds[0].description).split("&")[1].split(">")[0]
                user_id = res.message.embeds[0].footer.text.split(":")[1]
                user = res.guild.get_member(int(user_id))
                role = res.guild.get_role(int(role_id))
                
                if res.component.id == "decline_request":
                    code = res.message.embeds[0].footer.text.split(":")[0]
                    if res.author.top_role.position > role.position:
                        await Cache().delete_request(code.split("-")[0], str(user))
                        embed = res.message.embeds[0]
                        embed.title = "[DECLINED] "+embed.title.split(" ")[1]
                        embed.color = 15158588
                        await res.message.delete()
                        await res.send(embed=discord.Embed(description=f"{res.author.mention} successfully declined {user.mention}'s request", color=4669430))
                        return await res.channel.send(embed=embed, components=[Button(style=ButtonStyle.blue, label="Undo", custom_id="undo_request")])
                    return await res.send(embed=discord.Embed(description=f"{res.author.mention} to decline this request you need a role above {role.mention}", color=15158588))
                
                if res.component.id == "accept_request":
                    code = res.message.embeds[0].footer.text.split(":")[0]
                    if res.author.top_role.position > role.position:
                        await Cache().delete_request(code.split("-")[0], (str(user).replace("#", "")))
                        await user.add_roles(role)
                        
                        embed = res.message.embeds[0]
                        embed.title = "[ACCEPTED] "+embed.title.split(" ")[1]
                        embed.color = 3066992
                        await res.message.delete()
                        await res.send(embed=discord.Embed(description=f"{res.author.mention} successfully accepted {user.mention}'s request", color=4669430))
                        return await res.channel.send(embed=embed, components=[Button(style=ButtonStyle.blue, label="Undo", custom_id="undo_request")])
                    return await res.send(embed=discord.Embed(description=f"{res.author.mention} to accept this request you need a role above {role.mention}", color=15158588))
                
                if res.component.id == "_accept_request":
                    if res.author.top_role.position > role.position:
                        await user.add_roles(role)
                        
                        embed = res.message.embeds[0]
                        embed.title = "[ACCEPTED] "+embed.title.split(" ")[1]
                        embed.color = 3066992
                        await res.message.delete()
                        await res.send(embed=discord.Embed(description=f"{res.author.mention} successfully accepted {user.mention}'s request", color=4669430))
                        return await res.channel.send(embed=embed, components=[Button(style=ButtonStyle.blue, label="Undo", custom_id="undo_request")])
                    return await res.send(embed=discord.Embed(description=f"{res.author.mention} to accept this request you need a role above {role.mention}", color=15158588))
                
                if res.component.id == "_decline_request":
                    if res.author.top_role.position > role.position:
                        embed = res.message.embeds[0]
                        embed.title = "[DECLINED] "+embed.title.split(" ")[1]
                        embed.color = 15158588
                        await res.message.delete()
                        await res.send(embed=discord.Embed(description=f"{res.author.mention} successfully declined {user.mention}'s request", color=4669430))
                        return await res.channel.send(embed=embed, components=[Button(style=ButtonStyle.blue, label="Undo", custom_id="undo_request")])
                    return await res.send(embed=discord.Embed(description=f"{res.author.mention} to decline this request you need a role above {role.mention}", color=15158588))
                
                if res.component.id == "undo_request":
                    embed = res.message.embeds[0]
                    if "ACCEPTED" in embed.title:
                        await user.remove_roles(role)
                    embed.title = "[PENDING] "+embed.title.split(" ")[1]
                    embed.color = 4669430
                    await res.message.delete()
                    await res.send(embed=discord.Embed(description=f"{res.author.mention} successfully undone the decision towards {user.mention}'s request", color=4669430))
                    return await res.channel.send(embed=embed, components=[[Button(style=ButtonStyle.green, label="Accept", custom_id="_accept_request"), 
                                                     Button(style=ButtonStyle.red, label="Decline", custom_id="_decline_request")]])
                
                
                
def setup(client):
    client.add_cog(Core(client))