/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <engine>
//#include <zombieplague>
#include <zp50_ammopacks>

#define PLUGIN "[ZP] Donate Ammo Packs (edit by CSnajper)"
#define VERSION "1.0"
#define AUTHOR "r1laX , PomanoB"

new g_CvarAllowDonate
new SayText


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_CvarAllowDonate = register_cvar("zp_stats_allow_donate", "1")
	
	register_clcmd("say", "handleSay")
	register_clcmd("say_team", "handleSay")
	
	register_event("HLTV", "RoundStart", "a", "1=0", "2=0")

	SayText = get_user_msgid("SayText")
	
	//menu dawania ap
	register_impulse(201, "UzyjPrzedmiotu");

}

public RoundStart()
{
	if (get_pcvar_num(g_CvarAllowDonate))
		set_task(2.2, "MsgOnRoundStart")
		
}

public MsgOnRoundStart()
{
	if(get_pcvar_num(g_CvarAllowDonate))
		client_printcolor(0, "!g[ZP] !yAby przekazac graczom AP wpisz !g/daj nick iloscAP")
		
}

public handleSay(id)
{
	new args[64]
	
	read_args(args, charsmax(args))
	remove_quotes(args)
	
	new arg1[16]
	new arg2[32]
	
	strbreak(args, arg1, charsmax(arg1), arg2, charsmax(arg2))
	if (get_pcvar_num(g_CvarAllowDonate) && (equal(arg1,"/donate", 7) || equal(arg1,"/daj", 7)))
		donate(id, arg2)
	
}

public donate(id, arg[])
{
	new to[32], count[10]
	strbreak(arg, to, 31, count, 9)
	
	if (!to[0] || !count[0])
	{
		client_printcolor(id, "!g[ZP] !yUzycie: say /daj <name> <amount>")
		return
	}
	new ammo_sender = zp_ammopacks_get(id)
	new ammo
	if (equal(count, "all"))
		ammo = ammo_sender
	else
		ammo = str_to_num(count)
	if (ammo <= 0)
	{
		client_printcolor(id, "!g[ZP] !yNiepoprawna liczba AP!")
		return
	}
	ammo_sender -= ammo
	if (ammo_sender < 0)
	{
		ammo+=ammo_sender
		ammo_sender = 0
		
	}
	new reciever = cmd_target(id, to, (CMDTARGET_ALLOW_SELF))
	if (!reciever || reciever == id)
	{
		client_printcolor(id, "!g[ZP] !yGracz !g%s !ynie zostal znaleziony na serwerze!", to)
		return
	}
	
	zp_ammopacks_set(reciever, zp_ammopacks_get(reciever) + ammo)
	zp_ammopacks_set(id, ammo_sender)
	new aName[32], vName[32]
	
	get_user_name(id, aName, 31)
	get_user_name(reciever, vName, 31)
	
	client_printcolor(0, "!g[ZP] !t%s !yprzekazal !g %i  !yAP graczowi !t %s!", aName, ammo, vName)
	
}

stock client_printcolor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4") // Green Color
	replace_all(msg, 190, "!y", "^1") // Default Color
	replace_all(msg, 190, "!t", "^3") // Team Color
	
	if (id) players[0] = id; else get_players(players, count, "ch") 
	{
		for ( new i = 0; i < count; i++ )
		{
			if ( is_user_connected(players[i]) )
			{
				message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}

//menu dawania ap
public UzyjPrzedmiotu(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	if(!zp_ammopacks_get(id))
		return PLUGIN_HANDLED;
	new gracz_na_celowniku, bodypart
	get_user_aiming(id, gracz_na_celowniku, bodypart)
	if(gracz_na_celowniku)
	{
		if(zp_core_is_zombie(id) && zp_core_is_zombie(gracz_na_celowniku) || !zp_core_is_zombie(id) && !zp_core_is_zombie(gracz_na_celowniku))
			menu_przekaz_ap(id, gracz_na_celowniku)
	}
	
	return PLUGIN_HANDLED;
}
public menu_przekaz_ap(id, gracz_na_celowniku)
{
	if(gracz_na_celowniku)
	{
		new name_gracz_na_celowniku[48]
		get_user_name(gracz_na_celowniku, name_gracz_na_celowniku, 47)
		new menu_wiad[51]
		formatex(menu_wiad, 50, "Ile AP chcesz przekazac graczowi %s?", name_gracz_na_celowniku)
		new Menu = menu_create(menu_wiad, "Menu_Przekaz_AP_Handle");
		new info[1]
		info[0] = gracz_na_celowniku
		menu_additem(Menu,"Przekaz 3 AP", info)
		menu_additem(Menu,"Przekaz 5 AP", info)
		menu_additem(Menu,"Przekaz 10 AP", info)
		menu_additem(Menu,"Przekaz 20 AP", info)
		menu_additem(Menu,"Przekaz Wszystkie AP", info)
		
		menu_display(id, Menu,0);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public Menu_Przekaz_AP_Handle(id, menu, item){
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new info[1], access, callback;
	menu_item_getinfo(menu, item, access, info, 1,_, _, callback);
	new gracz_na_celowniku = info[0]
	new name_id[48]
	get_user_name(id, name_id, 47)
	new name_gracz_na_celowniku[48]
	get_user_name(gracz_na_celowniku, name_gracz_na_celowniku, 47)
	switch(item){
		case 0:
		{
			if(zp_ammopacks_get(id) >= 3)
			{
				zp_ammopacks_set(id, zp_ammopacks_get(id) - 3)
				client_printcolor(id, "!g[ZP] !yPrzekazales graczowi !t%s !g3 !yAP", name_gracz_na_celowniku)
				zp_ammopacks_set(gracz_na_celowniku, zp_ammopacks_get(gracz_na_celowniku) + 3)
				client_printcolor(gracz_na_celowniku, "!g[ZP] !yDostales !g3 AP od gracza !t%s", name_id)
			}
			else client_printcolor(id, "!g[ZP] !yNie masz tyle !gAP")
			
		}
		case 1:
		{
			if(zp_ammopacks_get(id) >= 5)
			{
				zp_ammopacks_set(id, zp_ammopacks_get(id) - 5)
				client_printcolor(id, "!g[ZP] !yPrzekazales graczowi !t%s !g5 !yAP", name_gracz_na_celowniku)
				zp_ammopacks_set(gracz_na_celowniku, zp_ammopacks_get(gracz_na_celowniku) + 5)
				client_printcolor(gracz_na_celowniku, "!g[ZP] !yDostales !g5 AP od gracza !t%s", name_id)
			}
			else client_printcolor(id, "!g[ZP] !yNie masz tyle !gAP")
			
		}
		case 2:
		{
			if(zp_ammopacks_get(id) >= 10)
			{
				zp_ammopacks_set(id, zp_ammopacks_get(id) - 10)
				client_printcolor(id, "!g[ZP] !yPrzekazales graczowi !t%s !g10 !yAP", name_gracz_na_celowniku)
				zp_ammopacks_set(gracz_na_celowniku, zp_ammopacks_get(gracz_na_celowniku) + 10)
				client_printcolor(gracz_na_celowniku, "!g[ZP] !yDostales !g10 AP od gracza !t%s", name_id)
			}
			else client_printcolor(id, "!g[ZP] !yNie masz tyle !gAP")
		}
		case 3:
		{
			if(zp_ammopacks_get(id) >= 20)
			{
				zp_ammopacks_set(id, zp_ammopacks_get(id) - 20)
				client_printcolor(id, "!g[ZP] !yPrzekazales graczowi !t%s !g20 !yAP", name_gracz_na_celowniku)
				zp_ammopacks_set(gracz_na_celowniku, zp_ammopacks_get(gracz_na_celowniku) + 20)
				client_printcolor(gracz_na_celowniku, "!g[ZP] !yDostales !g20 AP od gracza !t%s", name_id)
			}
			else client_printcolor(id, "!g[ZP] !yNie masz tyle !gAP")
		}
		case 4:
		{
			if(zp_ammopacks_get(id))
			{
				zp_ammopacks_set(gracz_na_celowniku, zp_ammopacks_get(gracz_na_celowniku) + zp_ammopacks_get(id))
				client_printcolor(gracz_na_celowniku, "!g[ZP] !yDostales !g%i AP od gracza !t%s", zp_ammopacks_get(id), name_id);
				zp_ammopacks_set(id, 0);
				client_printcolor(id, "!g[ZP] !yPrzekazales !t%s !ywszystkie AP", name_gracz_na_celowniku)
			}
			else client_printcolor(id, "!g[ZP] !yNie masz !gAP")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/