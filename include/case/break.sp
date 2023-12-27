#include <sourcemod>

new MaxHealth[MAXENTTYPE];
new Health[MAXENTTYPE];

BecomeIntoBreak(entity,health)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	Health[EntTypeCount] = health;
	MaxHealth[EntTypeCount] = health;
	SetEntityRenderFx(entity,    RENDERFX_EXPLODE);
	nType[EntTypeCount] = Type_Break;
	EntProp[EntTypeCount] = entity;
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreak_Damage);
	SDKHook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreak_Damage);
}

ShowChooseBreakHealthMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseBreakHealth);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择血量板的耐久度,编号:%d",entity);
	AddMenuItem(menu,"100","100HP");
	AddMenuItem(menu,"1000","1000HP");
	AddMenuItem(menu,"5000","5000HP");	
	AddMenuItem(menu,"10000","10000HP");
	AddMenuItem(menu,"20000","20000HP");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseBreakHealth(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			decl String:sType[64];
			new power =0;
			GetMenuItem(menu,item,sType,sizeof sType);
			power = StringToInt(sType);
			if (power<0)return;
			BecomeIntoBreak(NowEntity,power);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

public SDKCallBackBreak_Damage(entity, attacker, inflictor, Float:damage, damagetype)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Break)
	{
		SDKUnhook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreak_Damage);
		return;
	}
	Health[id]-= RoundToFloor(damage);
	if (Health[id]<=0)
	{
		BreakIt(entity);
	}
	PrintCenterText(attacker,"这堵墙还有 %d 耐久度",Health[id]);

}

stock BreakIt(entity)
{
	if(!IsSoundPrecached("physics/glass/glass_sheet_break3.wav"))
		PrecacheSound("physics/glass/glass_sheet_break3.wav");
	EmitSoundToAll("physics/glass/glass_sheet_break3.wav");	
	RemoveEdict(entity);
	SDKUnhook(entity,SDKHook_OnTakeDamagePost,SDKCallBackBreak_Damage);
	new id = FindIdEntPropByEntity(entity);
	if (id==-1)return;
	Health[id] = 0;
	EntProp[id] = 0;
	nType[id] = 0;
}