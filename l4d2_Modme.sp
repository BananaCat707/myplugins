
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define Version "1.0"


public Plugin:myinfo =
{
	name="把自己变成准星物体",
	author="BananaCat707",
	description="",
	version=Version,
	url="https://github.com/BananaCat707/myplugins"
};


public OnPluginStart()
{
	RegConsoleCmd("sm_p", Command_modme);
}


public Action:Command_modme(Client, args)
{ 
	new Ent = GetClientAimTarget(Client, false);
	for (new client = 1;client<=MaxClients;client++)
	if (client>0 && IsPlayerAlive(client))
	{
		if (GetClientTeam(client) == 3) //3为感染者使用，2为幸存者使用
		{
			if (IsValidEntity(Ent))
			{
				decl String:modelname[128];
				GetEntPropString(Ent, PropType:1, "m_ModelName", modelname, 128, 0);
				SetEntityModel(Client, modelname);
				PrintToChat(Client, "\x04[提示]\x05把自己变成\x01 %s", modelname);
			}
			else
			{
				PrintToChat(Client, "\x04[提示]\x05准星不是有效物体");
			}
		}
		else
		{
			PrintToChat(client,"\x04[提示]\x05当前队伍不可以使用");
		}
		return;
	}
}