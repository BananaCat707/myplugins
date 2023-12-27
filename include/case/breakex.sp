#include <sourcemod>

new bool:bShot[MAXENTTYPE];
new bool:bTouch[MAXENTTYPE];

BecomeIntoBreakEx(entity,bool:shot=false,bool:touch=true)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	bShot[EntTypeCount] = shot;
	bTouch[EntTypeCount] = touch;
	
	nType[EntTypeCount] = Type_BreakEx;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreakEx_Damage);
	SDKHook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreakEx_Damage);
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackBreakEx_Touch);
	SDKHook(entity,SDKHook_Touch,SDKCallBackBreakEx_Touch);	
}

ShowChooseBreakExFlagsMenu(client,entity)
{
	new String:sTemp[64];
	new Handle:menu = CreateMenu(MenuHandler_ChooseBreakExFlags);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择破碎板的属性,编号:%d",entity);
	Format(sTemp,sizeof sTemp,"受到伤害就破碎:%d",bShot[EntTypeCount]);
	AddMenuItem(menu,"item1",sTemp);
	Format(sTemp,sizeof sTemp,"触碰就破碎:%d",bTouch[EntTypeCount]);	
	AddMenuItem(menu,"item2",sTemp);
	AddMenuItem(menu,"item3","完成");	
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseBreakExFlags(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			switch(item)
			{
				case 0:bShot[EntTypeCount] = !bShot[EntTypeCount];
				case 1:bTouch[EntTypeCount] = !bTouch[EntTypeCount];
				case 2:BecomeIntoBreakEx(NowEntity,bShot[EntTypeCount],bTouch[EntTypeCount]);
			}
			if (item==0 || item==1)
				ShowChooseBreakExFlagsMenu(client,NowEntity);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

public SDKCallBackBreakEx_Damage(entity, attacker, inflictor, Float:damage, damagetype)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_BreakEx)
	{
		SDKUnhook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreak_Damage);
		return;
	}
	if (!bShot[id])return;
	SDKUnhook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreak_Damage);	
	BreakItEx(entity);
}

public SDKCallBackBreakEx_Touch(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_BreakEx)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackBreakEx_Touch);
		return;
	}
	if (!bTouch[id])return;	
	BreakItEx(entity);
}

stock BreakItEx(entity)
{
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackBreakEx_Touch);	
	RemoveEdict(entity);
	if(!IsSoundPrecached("physics/glass/glass_sheet_break3.wav"))
		PrecacheSound("physics/glass/glass_sheet_break3.wav");
	EmitSoundToAll("physics/glass/glass_sheet_break3.wav");	
}