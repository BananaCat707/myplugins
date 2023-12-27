
BecomeIntoHaiMian(entity,type=0)
{
	if (!IsValidEdict(entity) || !entity)return;
	new String:szModel[256],Float:vecMaxs[3],Float:vecMins[3],Float:vecOrigin[3],Float:vecAngles[3];
	GetEntPropString(entity,Prop_Data,"m_ModelName",szModel,sizeof(szModel));
	GetEntPropVector(entity,Prop_Send,"m_vecMaxs",vecMaxs);	
	GetEntPropVector(entity,Prop_Send,"m_vecMins",vecMins);	
	GetEntPropVector(entity,Prop_Send,"m_vecOrigin",vecOrigin);
	GetEntPropVector(entity,Prop_Send,"m_angRotation",vecAngles);	

	new trigger = CreateEntityByName("trigger_multiple");
	if (trigger==-1)ThrowError("¥¥Ω®trigger ß∞‹!");
	DispatchKeyValue(trigger,"spawnflags","1");
	DispatchSpawn(trigger);
	ActivateEntity(trigger);
	
	vecOrigin[2]+=50.0;
	TeleportEntity(trigger,vecOrigin,vecAngles,NULL_VECTOR);
	SetEntityModel(trigger,szModel);
	SetEntPropVector(trigger,Prop_Send,"m_vecMins",vecMins);	
	SetEntPropVector(trigger,Prop_Send,"m_vecMaxs",vecMaxs);	
	
	SetEntProp(trigger, Prop_Send, "m_nSolidType", 2);
	new enteffects = GetEntProp(trigger, Prop_Send, "m_fEffects");
	enteffects |= 32;
	SetEntProp(trigger, Prop_Send, "m_fEffects", enteffects);  
	LogMessage("%.1f,%.1f,%.1f",vecMins[0],vecMins[1],vecMins[2]);
	LogMessage("%.1f,%.1f,%.1f",vecMaxs[0],vecMaxs[1],vecMaxs[2]);	
	
	HookSingleEntityOutput(trigger,"OnStartTouch",EntityOutput_OnStartTouch);
	nType[EntTypeCount] = Type_HaiMian;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
}

public EntityOutput_OnStartTouch(const String:output[], trigger, client, Float:delay)
{
	new Float:vecOrigin[3];
	GetEntPropVector(client,Prop_Send,"m_vecOrigin",vecOrigin);
 	decl Float:vec[3];
	vec[0]=GetRandomFloat(-1.0, 1.1);
	vec[1]=GetRandomFloat(-1.0, 1.1);
	vec[2]=GetRandomFloat(-1.0, 1.1);
	TE_SetupSparks(vecOrigin,vec,10, 3);
	TE_SendToAll();
	
	SDKUnhook(client,SDKHook_OnTakeDamage,SDKCallBack_OnTakeDamge);
	SDKHook(client,SDKHook_OnTakeDamage,SDKCallBack_OnTakeDamge);	
	
}

public Action:SDKCallBack_OnTakeDamge(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	PrintToChatAll("%d,%.1f",damagetype,damage);
	SDKUnhook(client,SDKHook_OnTakeDamage,SDKCallBack_OnTakeDamge);
	return Plugin_Handled;
}