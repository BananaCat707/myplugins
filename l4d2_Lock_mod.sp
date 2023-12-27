#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define Version "1.0"

new bool:bLock[MAXPLAYERS+1];
new Clone[MAXPLAYERS+1];

public Plugin:myinfo ={
	name="锁定自己",
	author="BananaCat707",
	description="",
	version=Version,
	url="https://github.com/BananaCat707/myplugins"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_on",lock,"锁定");
	RegConsoleCmd("sm_off",unlock,"解锁");
}

public OnClientConnected(client)
{
	bLock[client] = false;
}

public Action:lock(client,args)
{
	if (client>0 && IsPlayerAlive(client))
	{
		if (GetClientTeam(client) == 3) //3为感染者使用，2为幸存者使用
		{
			if (!bLock[client])
			{
				PrintHintText(client,"[提示]锁定成功,输入!off解锁");
				LOCKVIEW(client);
			}
			else
			{
				PrintHintText(client,"[提示]请输入!off解锁后再锁定");
			}
		}
		else if (GetClientTeam(client) == 2)
		{
			PrintToChat(client,"\x04[提示]\x05当前队伍不能使用");		
		}
	}
}

public Action:unlock(client,args)
{
	if (client>0 && IsPlayerAlive(client))
	{
		if (GetClientTeam(client) == 3)
		{
			if (!bLock[client])
			{
				PrintHintText(client,"[提示]请先锁定再使用解锁");
			}
			else
			{
				PrintHintText(client,"[提示]已解除锁定");
				UNLOCKVIEW(client);				
			}
		}
		else if (GetClientTeam(client) == 2)
		{
			PrintToChat(client,"\x04[提示]\x05当前队伍不能使用");				
		}
	}
}

stock LOCKVIEW(client)
{
	if (!IsPlayerAlive(client))return;
	new c=CreateClone(client); 
	if (c>0)
	{
		VisiblePlayer(client,false);
		Clone[client] = c;
		SetEntityMoveType(client,MOVETYPE_NONE);
		bLock[client] = true;
	}
}

stock UNLOCKVIEW(client)
{
	VisiblePlayer(client);
	SetEntityMoveType(client,MOVETYPE_WALK);	
	if (IsValidEntity(Clone[client]))
	{
		RemoveEdict(Clone[client]);
		Clone[client] = 0;
		bLock[client] = false;
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
	clone = CreateEntityByName("prop_dynamic_override"); 
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
