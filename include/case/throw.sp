#include <sourcemod>

new Float:throwpower[MAXENTTYPE];
new bool:bThrow[MAXPLAYERS+1];

BecomeIntoThrow(entity,Float:power)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	
	SetEntityRenderColor(entity,0,255,0,255);
	throwpower[EntTypeCount] = power;
	nType[EntTypeCount] = Type_Throw;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackThrow_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackThrow_Touched);
	SDKUnhook(entity,SDKHook_EndTouch,SDKCallBackThrow_EndTouch);
	SDKHook(entity,SDKHook_EndTouch,SDKCallBackThrow_EndTouch);	
}

ThrowPerson(person,Float:power=1.0,Float:origin[3],Float:angles[3])
{
	if (person>MaxClients || bThrow[person])return;
	new Handle:pack = CreateDataPack();
	WritePackCell(pack,person);
	WritePackFloat(pack,power);
	WritePackFloat(pack,origin[0]);	
	WritePackFloat(pack,origin[1]);	
	WritePackFloat(pack,origin[2]);	
	WritePackFloat(pack,angles[0]);	
	WritePackFloat(pack,angles[1]);
	WritePackFloat(pack,angles[2]);		
	CreateTimer(0.3,TimerThrow,pack);
	bThrow[person] = true;
}

public Action:TimerThrow(Handle:timer,any:pack)
{
	ResetPack(pack);
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	new person = ReadPackCell(pack);
	if (!bThrow[person])return;
	new Float:power = ReadPackFloat(pack)*3.0;	

	vOrigin[0] = ReadPackFloat(pack);
	vOrigin[1] = ReadPackFloat(pack);
	vOrigin[2] = ReadPackFloat(pack);
	vAngles[0] = ReadPackFloat(pack);
	vAngles[1] = ReadPackFloat(pack);
	vAngles[2] = ReadPackFloat(pack);
	
	decl Float:VecOrigin[3],Float:pos[3];
	GetClientEyePosition(person, VecOrigin);
	TR_TraceRayFilter(VecOrigin, vAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, person);
	if(TR_DidHit(INVALID_HANDLE))
	{
		TR_GetEndPosition(pos);
	}
	
	decl Float:volicity[3];
	SubtractVectors(pos, vOrigin, volicity);
	ScaleVector(volicity,power);
	volicity[2] = FloatAbs(volicity[2]);
	TeleportEntity(person, NULL_VECTOR, NULL_VECTOR, volicity);
	bThrow[person] = false;	
	EmitSoundFromPlayer(person,"buttons/blip1.wav");		
}

public SDKCallBackThrow_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Throw)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackThrow_Touched);
		SDKUnhook(entity,SDKHook_EndTouch,SDKCallBackThrow_EndTouch);	
		return;
	}

	if (toucher<MaxClients && !IsPlayerAlive(toucher))
		return;
	decl Float:ori[3],Float:ang[3];
	GetEntPropVector(entity,Prop_Send,"m_vecOrigin",ori);
	GetEntPropVector(entity,Prop_Send,"m_angRotation",ang);	
	ThrowPerson(toucher,throwpower[id],ori,ang);
}

public SDKCallBackThrow_EndTouch(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Throw)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackThrow_Touched);
		SDKUnhook(entity,SDKHook_EndTouch,SDKCallBackThrow_EndTouch);	
		return;
	}
	if (toucher<MaxClients)
	{
		bThrow[toucher] = false;
	}
}

ShowChooseThrowPowerMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseThrowPower);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择投掷板的力度,编号:%d",entity);
	AddMenuItem(menu,"1.0","小");
	AddMenuItem(menu,"1.3","较小");
	AddMenuItem(menu,"2.0","中");	
	AddMenuItem(menu,"2.5","大");
	AddMenuItem(menu,"3.0","最大");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}


public MenuHandler_ChooseThrowPower(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			decl String:sType[64];
			new Float:power =0.0;
			GetMenuItem(menu,item,sType,sizeof sType);
			power = StringToFloat(sType);
			if (power<0.0)return;
			BecomeIntoThrow(NowEntity,power);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

public bool:TraceRayDontHit(entity, mask, any:data)
{
	if(entity == data) // Check if the TraceRay hit the itself.
	{
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}