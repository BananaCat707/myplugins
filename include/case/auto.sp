#include <sourcemod>

new bool:bRun[MAXPLAYERS+1];

BecomeIntoRun(entity)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	
	SetEntityRenderColor(entity,153,153,0,255);
	nType[EntTypeCount] = Type_Auto;
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackAuto_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackAuto_Touched);
}

RunPerson(person,Float:origin[3],Float:angles[3])
{
	if (person>MaxClients || bRun[person])return;
	new Handle:pack = CreateDataPack();
	WritePackCell(pack,person);
	WritePackFloat(pack,origin[0]);	
	WritePackFloat(pack,origin[1]);	
	WritePackFloat(pack,origin[2]);	
	WritePackFloat(pack,angles[0]);	
	WritePackFloat(pack,angles[1]);
	WritePackFloat(pack,angles[2]);		
	CreateTimer(0.1,TimerRun,pack);
	bRun[person] = true;
}

public Action:TimerRun(Handle:timer,any:pack)
{
	ResetPack(pack);
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	new person = ReadPackCell(pack);
	if (!bRun[person])return;

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
	new Float:velo[3];
	velo[0] = GetEntPropFloat(person, Prop_Send, "m_vecVelocity[0]");
	velo[1] = GetEntPropFloat(person, Prop_Send, "m_vecVelocity[1]");
	velo[2] = GetEntPropFloat(person, Prop_Send, "m_vecVelocity[2]");	
	
	SubtractVectors(pos, vOrigin, volicity);
	ScaleVector(volicity,0.4);
	volicity[2] = 0.0;
	AddVectors(velo,volicity,volicity);
	TeleportEntity(person, NULL_VECTOR, NULL_VECTOR, volicity);
	bRun[person] = false;	
}

public SDKCallBackAuto_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Auto)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackAuto_Touched);
		return;
	}
	if (toucher<MaxClients && !IsPlayerAlive(toucher))
	{
		return;
	}
	decl Float:ori[3],Float:ang[3];
	GetEntPropVector(entity,Prop_Send,"m_vecOrigin",ori);
	GetEntPropVector(entity,Prop_Send,"m_angRotation",ang);	
	RunPerson(toucher,ori,ang);
}