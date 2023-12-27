#include <sourcemod>

BecomeIntoShake(entity)
{
	if (entity<=0 ||!IsValidEdict(entity))return;

	SetEntityRenderColor(entity,255,0,255,255);
	nType[EntTypeCount] = Type_Shake;
	EntProp[EntTypeCount] = entity;	
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackShake_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackShake_Touched);
	EntTypeCount++;
}

ShakePlayer(client)
{
	if (client>MaxClients || !IsPlayerAlive(client))return;
	decl Float:vecOrigin[3];
	GetClientAbsOrigin(client,vecOrigin);
	new entity = CreateEntityByName("env_shake");
	if(entity==-1)return;
	DispatchKeyValue(entity,"amplitude","16");
	DispatchKeyValue(entity,"duration","1");
	DispatchKeyValue(entity,"frequency","2.5");
	DispatchKeyValue(entity,"radius","40");	
	DispatchSpawn(entity);
	TeleportEntity(entity,vecOrigin,NULL_VECTOR,NULL_VECTOR);
	AcceptEntityInput(entity,"StartShake",entity,entity);
	AcceptEntityInput(entity,"kill");
}

public SDKCallBackShake_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Shake)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackShake_Touched);
		return;
	}
	ShakePlayer(toucher);
}
