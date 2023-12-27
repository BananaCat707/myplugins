#include <sourcemod>

new Float:heavypower[MAXENTTYPE];

BecomeIntoHeavy(entity,Float:power)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	
	SetEntityRenderColor(entity,50,150,100,255);
	heavypower[EntTypeCount] = power;
	nType[EntTypeCount] = Type_Heavy;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackHea_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackHea_Touched);
}

SetPlayerHeavy(client,Float:power=1.0)
{
	SetEntityGravity(client,power);
}

ShowChooseHeaPowerMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseHeaSpeed);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择重力板的速度,编号:%d",entity);
	AddMenuItem(menu,"0.2","0.2");
	AddMenuItem(menu,"0.8","0.8");
	AddMenuItem(menu,"1.0","标准重力");	
	AddMenuItem(menu,"1.5","1.5");
	AddMenuItem(menu,"5.0","5.0");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseHeaSpeed(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			decl String:sType[64];
			new Float:speed =0.0;
			GetMenuItem(menu,item,sType,sizeof sType);
			speed = StringToFloat(sType);
			if (speed<0.0)return;
			BecomeIntoHeavy(NowEntity,speed);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

public SDKCallBackHea_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Heavy)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackHea_Touched);
		return;
	}
	if (toucher<MaxClients && IsPlayerAlive(toucher))
	{
		SetPlayerHeavy(toucher,heavypower[id]);
	}
}