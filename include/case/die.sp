#include <sourcemod>

BecomeIntoDie(entity)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	SetEntityRenderColor(entity,0,0,0,255);
	nType[EntTypeCount] = Type_Die;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackDie_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackDie_Touched);
}

KillPerson(person)
{
	if (!IsValidEdict(person))return;
	decl String:clsname[64];
	GetEdictClassname(person,clsname,sizeof clsname);
	if (person>MaxClients)
	{
		if (StrEqual(clsname,"infected"))
			AcceptEntityInput(person,"Kill");
		else return;	
	}
	else CheatCommand(person,"kill");
}

public SDKCallBackDie_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Die)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackDie_Touched);
		return;
	}
	KillPerson(toucher);
}