
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define Version "1.0"

new bool:bChoseModel[MAXPLAYERS+1];
new Clone[MAXPLAYERS+1];

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
	RegConsoleCmd("sm_3", Cmdthird,"第三人称展示");
}

public OnClientConnected(client)
{
	bChoseModel[client] = false;
}

public Action:Cmdthird(client,args)
{
	if (IsPlayerAlive(client) && GetClientTeam(client)==2 && Clone[client]<=0) //3为感染者使用，2为幸存者使用
	{
		if (bChoseModel[client])
			ThirdPerson(client);
		else PrintToChat(client,"\x04[提示]\x05你还没变身，不能第三人称!");
	}
}

public Action:Command_modme(Client, args)
{ 
	new Ent = GetClientAimTarget(Client, false);
	for (new client = 1;client<=MaxClients;client++)
	if (client>0 && IsPlayerAlive(client))
	{
		if (GetClientTeam(client) == 2) //3为感染者使用，2为幸存者使用
		{
			if (IsValidEntity(Ent))
			{
				decl String:modelname[128];
				GetEntPropString(Ent, PropType:1, "m_ModelName", modelname, 128, 0);
				SetEntityModel(Client, modelname);
				PrintToChat(Client, "\x04[提示]\x05把自己变成\x01 %s \n\x05输入!3查看效果", modelname);
				bChoseModel[Client] = true;
				ThirdPerson(Client);
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

stock Action:ThirdPerson(client)
{
	if (!IsPlayerAlive(client))return;
	new c=CreateClone(client); 
	if (c>0)
	{
		GotoThirdPerson(client);
		VisiblePlayer(client,false);
		Clone[client] = c;
		SetEntityMoveType(client,MOVETYPE_NONE);
		CreateTimer(3.0,Timer1,client);
	}	
}

GotoThirdPerson(client)
{
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
}

GotoFirstPerson(client)
{
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", -1);
	SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
}

public Action:Timer1(Handle:timer,any:client)
{
	GotoFirstPerson(client);
	VisiblePlayer(client);
	SetEntityMoveType(client,MOVETYPE_WALK);	
	if (IsValidEntity(Clone[client]))
	{
		RemoveEdict(Clone[client]);
		Clone[client] = 0;
	}
}

CreateClone(client)
{
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	GetClientAbsOrigin(client,vOrigin);
	GetClientAbsAngles(client, vAngles);	 
	decl String:playerModel[256]; 
	GetEntPropString(client, Prop_Data, "m_ModelName", playerModel, sizeof(playerModel)); 
	if (!IsModelPrecached(playerModel))
		PrecacheModel(playerModel);
	new clone=0;
	clone = CreateEntityByName("prop_dynamic_override"); //prop_dynamic
	SetEntityModel(clone, playerModel);  
 
	decl Float:vPos[3], Float:vAng[3];
	vPos[0] = -0.0; 
	vPos[1] = -0.0;
	vPos[2] = -30.0;
	
	vAng[2] = 0.0;
	vAng[0] = 0.0;
	vAng[1] =0.0;
 
	TeleportEntity(clone,  vOrigin, vAngles, NULL_VECTOR); 

	return clone;
}

VisiblePlayer(client, bool:visible=true)
{
	if(visible)
	{
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);		 
	}
	else
	{
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 0, 0, 0, 0);
	} 
}