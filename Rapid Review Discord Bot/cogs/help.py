from datetime import datetime as datetime
from discord_components import *
from discord.ext import commands
import discord

class Help(commands.Cog):
    def __init__(self, client):
        self.client = client
        
        # // Support embed
        self.support_embed = discord.Embed(color=4669430, timestamp=datetime.utcnow())
        self.support_embed.set_author(
            name="Rapid Support", 
            icon_url="https://cdn.discordapp.com/attachments/855448636880191499/920723959954153472/discord_wave_logo.png"
        )
        self.support_embed.add_field(
            name=f"Forms", 
            value=f"""
                {self.indent()}Create a form in the **Rapid Review** app on your phone, next 
                {self.indent()}**click the copy button** and use the copied code with the setup command
                {self.indent()}the code will look different than what it was in the app
            """
        )
        self.support_embed=self.embed_indents(self.support_embed, 5)
        self.support_embed.add_field(
            name="Form Verification", 
            value=f"""
                {self.indent()}When you use the **setup command**, you will be asked to enter
                {self.indent()}a **verification code**, to get this code, head over to the
                {self.indent()}**Rapid Review** app on your phone and scroll left on the bottom cards
                {self.indent()}until you see **Confirmations**, next, dm **Rapid** with the **4 digit code**
            """
        )
        self.support_embed=self.embed_indents(self.support_embed, 5)
        self.support_embed.add_field(
            name="Application Requests", 
            value=f"""
                {self.indent()}When an user clicks **Apply**, they will be asked the questions
                {self.indent()}from the form that you created from your phone, after they have
                {self.indent()}finished answering the questions, a new request will be sent
                {self.indent()}to your phone, **accepting** the request will give them
                {self.indent()}the role entered from the **setup command**
            """
        )
        self.support_embed=self.embed_indents(self.support_embed, 5)
        self.support_embed.add_field(
            name="Account Linking", 
            value=f"""
                {self.indent()}To link your rapid account to your discord account, you can
                {self.indent()}either link it from the **settings page** in the **Rapid Review** app
                {self.indent()}or you can use the **link command**
            """
        )
        self.support_embed=self.embed_indents(self.support_embed, 5)
        self.support_embed.add_field(
            name="Show Requests", 
            value=f"""
                {self.indent()}If you want to share you requests with other people, you can use the
                {self.indent()}**show requests** command and all future requests will show up
                {self.indent()}in that channel. **Anyone with a role higher than the pending request's
                {self.indent()}role can accept/decline the request**
            """
        )
        self.support_embed2 = discord.Embed(color=4669430, timestamp=datetime.utcnow())
        self.support_embed2.add_field(
            name="Auto Requests", 
            value=f"""
                {self.indent()}Whenever someone types a message in a certain channel, it will
                {self.indent()}send the message to another channel of your choice with accept/decline
                {self.indent()}buttons. 
            """
        )
        
        # // Commands embed
        self.commands_embed = discord.Embed(color=4669430, timestamp=datetime.utcnow())
        self.commands_embed.set_author(
            name="Rapid Commands", 
            icon_url="https://cdn.discordapp.com/attachments/855448636880191499/920723959954153472/discord_wave_logo.png"
        )
        self.commands_embed.add_field(
            name="Setup", 
            value=f"""
                {self.indent()}**Command:** !setup
                {self.indent()}**Description:** Next enter the form code, then mention the role
                {self.indent()}you want to give when you accept the users request
            """
        )
        self.commands_embed=self.embed_indents(self.commands_embed, 5)
        self.commands_embed.add_field(
            name="Link Rapid Account", 
            value=f"""
                {self.indent()}**Command:** !link (rapid user id)
                {self.indent()}**Description:** Link your discord account to your rapid account
            """
        )
        self.commands_embed=self.embed_indents(self.commands_embed, 5)
        self.commands_embed.add_field(
            name="UnLink Rapid Account", 
            value=f"""
                {self.indent()}**Command:** !unlink (rapid user id)
                {self.indent()}**Description:** Unlink your discord account from your rapid account
            """
        )
        self.commands_embed=self.embed_indents(self.commands_embed, 5)
        self.commands_embed.add_field(
            name="Show Requests", 
            value=f"""
                {self.indent()}**Command:** !show requests (rapid user id)
                {self.indent()}**Description:** Show all future requests from that user in that channel
            """
        )
        self.commands_embed=self.embed_indents(self.commands_embed, 5)
        self.commands_embed.add_field(
            name="Auto Requests", 
            value=f"""
                {self.indent()}**Command:** !autorequests enable/disable
                {self.indent()}**Description:** Any messages sent in the current channel will be sent
                {self.indent()}to the given channel with accept/decline buttons
            """
        )
        
    def indent(self):
        return "‏‏‎ ‎"
    
    def embed_indents(self, embed, amount:int):
        for _ in range(amount):
            embed.add_field(name="\u200b", value="\u200b")
        return embed
    
    @commands.command()
    async def help(self, ctx):
        await ctx.message.add_reaction("<a:blueverify:919714552642437142>")
        await ctx.send(embed=discord.Embed(description=f"{ctx.author.mention} ┃ **Rapid Support Menu**", color=33023),
                components=[
                    Select(
                        placeholder="Options",
                        options=[
                            SelectOption(emoji='🔵', label="Support", value="support"),
                            SelectOption(emoji='🔵', label="Commands", value="commands"),
                        ])])
        



    # // SELECT MENU LISTENER
    # //////////////////////////////////////
    @commands.Cog.listener()
    async def on_select_option(self, res):
        if not res.author.bot:
            if res.values[0] == "support":
                await res.send(embed=discord.Embed(description=f"{res.author.mention} the support panel has been sent to your dm's", color=3066992))
                await res.author.send(embed=self.support_embed)
                return await res.author.send(embed=self.support_embed2)
            
            if res.values[0] == "commands":
                await res.send(embed=discord.Embed(description=f"{res.author.mention} the commands have been sent to your dm's", color=3066992))
                return await res.author.send(embed=self.commands_embed)


def setup(client):
    client.add_cog(Help(client))