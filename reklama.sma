/* Plugin generated by AMXX-Studio */

#include <amxmodx>

#define PLUGIN "Zakaz reklamy w nicku"
#define VERSION "1.0"
#define AUTHOR "Mochi"

#define KICKREASON "Zmien NICK i wbij ponownie!"
//test
new cvar,zezwolone[32]
new const reklama[][] = { 
	
	"http:",
	"https:", 
	":26",
	":27",
	":28",
	":29",
	": 2 6",
	": 2 7",
	": 2 8",
	": 2 9",
	": 26",
	": 27",
	": 28",
	": 29",
	"www.",
	".net",
	".com",
	".ua",
	".ru",
	".info",
	".org",
	".tv",
	".su",
	".biz",
	".eu",
	".uc",
	".ee",
	".name",
	".rf",
	".ucoz",
	".net",
	".de",
	".co.uk",
	".lv",
	".at",
	".3dn",
	".myl",
	".su",
	".do",
	".am",
	".es",
	".hu",
	".ae",
	".po",
	".pl",
	"skype",
	"icq",
	"connect"
} 

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar = register_cvar("amx_reklama_www","www.csfifka.pl")
	
}

public client_putinserver(id)
{
/*	if(is_user_hltv(id))
	{
		return PLUGIN_HANDLED
	}*/
	new name[32]
	get_user_name(id,name,31);
	get_pcvar_string(cvar,zezwolone,31)
	if(containi(name,zezwolone) != -1)
	{
		return PLUGIN_HANDLED
	}
	new userid2 = get_user_userid(id);
	for(new i = 0; i < sizeof(reklama); i++) 
	{
		if(containi(name, reklama[i]) != -1)
		{
			server_cmd("kick #%d ^"%s^"",userid2,KICKREASON)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}
public client_infochanged(id)
{
	new name[32]
	get_user_info(id, "name", name,31)
	get_pcvar_string(cvar,zezwolone,31)
	if(containi(name,zezwolone) != -1)
	{
		return PLUGIN_HANDLED
	}
	new userid2 = get_user_userid(id);
	for(new i = 0; i < sizeof(reklama); i++) 
	{ 		
		if(containi(name, reklama[i]) != -1)
		{
			server_cmd("kick #%d ^"%s^"",userid2,KICKREASON)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}
