#include <sourcemod>

new Float:Pos[MAXENTTYPE][3];

BecomeIntoTeleport(entity,Float:pos[3])
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	SetEntityRenderColor(entity,0,0,150,255);
	Pos[EntTypeCount] = pos;
	nType[EntTypeCount] = Type_Teleport;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackTele_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackTele_Touched);
}

stock TeleportPlayer(entity,Float:pos[3])
{
	TeleportEntity(entity,pos,NULL_VECTOR,NULL_VECTOR);
	if (entity<MaxClients)
		EmitSoundFromPlayer(entity,"level/startwam.wav");			
}

public SDKCallBackTele_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Teleport)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackTele_Touched);
		return;
	}
	TeleportPlayer(toucher,Pos[id]);

}

ShowChooseTelePosMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseTelePos);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请移动到要传送的地方,然后选择。编号:%d",entity);
	AddMenuItem(menu,"item1","把当前位置当作传送点");
	AddMenuItem(menu,"item2","把鼠标位置当作传送点");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseTelePos(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			decl Float:pos[3];
			switch(item)
			{
				case 0:
					GetClientAbsOrigin(client,pos);
				case 1:
					GetClientCurPos(client,pos);	
			}
			BecomeIntoTeleport(NowEntity,pos);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}