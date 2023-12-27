#include <sourcemod>

BecomeIntoChuanSong(entity,const Float:angles[3]={0.0,0.0,0.0})
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	new String:model[256],String:szConName[256],Float:pos[3],Float:ang[3];
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	new con = CreateEntityByName("func_conveyor");
	if (con==-1)ThrowError("创建传送带失败!");
	DispatchKeyValueVector(con,"movedir",angles);
	DispatchKeyValue(con,"speed","100");
	Format(szConName,sizeof(szConName),"con%d",entity);
	DispatchKeyValue(con,"targetname",szConName);
	DispatchKeyValueVector(con,"angles",ang);
	DispatchSpawn(con);
	ActivateEntity(con);
	SetEntityModel(con, model);
	new Float:vMins[3] = { -50.0, -50.0, -50.0 }, Float:vMaxs[3] = { 50.0, 50.0, 50.0 };
	GetEntPropVector(entity, Prop_Send, "m_vecMins", vMins);
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vMaxs);		
	SetEntPropVector(con, Prop_Send, "m_vecMins", vMins);
	SetEntPropVector(con, Prop_Send, "m_vecMaxs", vMaxs);	
	SetEntProp(con, Prop_Send, "m_nSolidType", 2);
	new enteffects = GetEntProp(con, Prop_Send, "m_fEffects");
	enteffects |= 32;
	SetEntProp(con, Prop_Send, "m_fEffects", enteffects);  	
	
	TeleportEntity(con,pos,ang,NULL_VECTOR);
}