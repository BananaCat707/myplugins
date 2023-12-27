#include <sourcemod>

new Float:icespeed[MAXENTTYPE];

BecomeIntoIce(entity,Float:speed)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	
	SetEntityRenderColor(entity,0,0,100,255);
	icespeed[EntTypeCount] = speed;
	nType[EntTypeCount] = Type_Ice;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackIce_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackIce_Touched);
}

SetPlayerSpeed(client,Float:speed=1.0)
{
	SetEntPropFloat(client,Prop_Data,"m_flLaggedMovementValue",speed);
}

ShowChooseIceSpeedMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseIceSpeed);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择滑冰板的速度,编号:%d",entity);
	AddMenuItem(menu,"0.2","0.2");
	AddMenuItem(menu,"0.8","0.8");
	AddMenuItem(menu,"1.0","标准速度");	
	AddMenuItem(menu,"1.5","1.5");
	AddMenuItem(menu,"5.0","5.0");
	AddMenuItem(menu,"10.0","10.0");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseIceSpeed(Handle:menu, MenuAction:action, client, item)
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
			BecomeIntoIce(NowEntity,speed);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

public SDKCallBackIce_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Ice)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackIce_Touched);
		return;
	}
	if (toucher<MaxClients && IsPlayerAlive(toucher))
	{
		SetPlayerSpeed(toucher,icespeed[id]);
	}
}