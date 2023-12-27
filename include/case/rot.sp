#include <sourcemod>

new rotspeed[MAXENTTYPE];
new Float:rotpoint[MAXENTTYPE][3];
new Float:rotentpoint[MAXENTTYPE][3];
new rotrot[MAXENTTYPE];
new rotent[MAXENTTYPE];

BecomeIntoRotating(entity,speed=100,Float:point[3],Float:entpoint[3],sp=0)
{
	decl String:sTemp[256],Float:ang[3],String:model[256];
	GetEntPropVector(entity,Prop_Data,"m_angRotation",ang);
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
	
	new prop = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(prop, "model", model);
	DispatchKeyValueVector(prop, "angles", ang);	
	DispatchKeyValue(prop,"solid","6");	
	Format(sTemp,sizeof sTemp,"prop_%d_%d",entity,prop);
	DispatchKeyValue(prop,"targetname",sTemp);	
	DispatchSpawn(prop);
	TeleportEntity(prop,entpoint,ang,NULL_VECTOR);
	
	new rot = CreateEntityByName("func_rotating");
	Format(sTemp,sizeof sTemp,"%d",speed);	
	DispatchKeyValue(rot,"maxspeed",sTemp);
	DispatchKeyValue(rot,"fanfriction","20");	
	DispatchKeyValueVector(rot,"origin",point);
	Format(sTemp,sizeof sTemp,"rot_%d_%d",entity,rot);
	DispatchKeyValue(rot,"targetname",sTemp);
	DispatchSpawn(rot);
	TeleportEntity(rot,point,NULL_VECTOR,NULL_VECTOR);	
	SetVariantString(sTemp);
	AcceptEntityInput(prop,"SetParent",prop,prop);
	if (sp == StringToInt(sp_enable))
		AcceptEntityInput(rot,"Start");	
	SpawnFlags[entity] = sp;
	nType[EntTypeCount] = Type_Rot;
	rotspeed[EntTypeCount] = speed;
	rotpoint[EntTypeCount] = point;
	rotentpoint[EntTypeCount] = entpoint;
	rotrot[EntTypeCount] = rot;
	rotent[EntTypeCount] = prop;	
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
}

ShowChooseRotFlagsMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseRotFlags);
	SetMenuExitButton(menu,true);
	decl String:sTemp[256];
	SetMenuTitle(menu,"请设置旋转板的类型。编号:%d\n地球(实体点)绕着太阳(圆心)转且自转",EntTypeCount);
	
	Format(sTemp,sizeof sTemp,"<重要>旋转速度+10,目前:%d",rotspeed[EntTypeCount]);
	AddMenuItem(menu,"item1",sTemp);
	Format(sTemp,sizeof sTemp,"<重要>旋转速度-10,目前:%d",rotspeed[EntTypeCount]);
	AddMenuItem(menu,"item2",sTemp);
	Format(sTemp,sizeof sTemp,"<重要>把当前位置定义为圆心(%d %d %d)",RoundToFloor(rotpoint[EntTypeCount][0]),RoundToFloor(rotpoint[EntTypeCount][1]),RoundToFloor(rotpoint[EntTypeCount][2]));
	AddMenuItem(menu,"item3",sTemp);	
	Format(sTemp,sizeof sTemp,"<重要>把当前位置定义为实体点(%d %d %d)",RoundToFloor(rotentpoint[EntTypeCount][0]),RoundToFloor(rotentpoint[EntTypeCount][1]),RoundToFloor(rotentpoint[EntTypeCount][2]));
	AddMenuItem(menu,"item4",sTemp);
	AddMenuItem(menu,"item5","完成");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseRotFlags(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			switch(item)
			{
				case 0:
				{
					rotspeed[EntTypeCount]+=10;
					ShowChooseRotFlagsMenu(client,NowEntity);
				}
				case 1:
				{
					if (rotspeed[EntTypeCount]>10)
						rotspeed[EntTypeCount]-=10;
					ShowChooseRotFlagsMenu(client,NowEntity);
				}
				case 2:
				{
					GetClientAbsOrigin(client,rotpoint[EntTypeCount]);
					ShowChooseRotFlagsMenu(client,NowEntity);
				}
				case 3:
				{
					GetClientAbsOrigin(client,rotentpoint[EntTypeCount]);
					ShowChooseRotFlagsMenu(client,NowEntity);
				}
				case 4:
				{
					if (rotspeed[EntTypeCount]<10)
					{
						PrintToChat(client,"\x03创建失败!速度不正确.");
						ShowChooseRotFlagsMenu(client,NowEntity);
						return;
					}
					else if (rotpoint[EntTypeCount][0] == 0.0 && rotpoint[EntTypeCount][1] == 0.0 && rotpoint[EntTypeCount][2] == 0.0)
					{
						PrintToChat(client,"\x03创建失败!圆心不正确.");
						ShowChooseRotFlagsMenu(client,NowEntity);
						return;						
					}
					else if (rotentpoint[EntTypeCount][0] == 0.0 && rotentpoint[EntTypeCount][1] == 0.0 && rotentpoint[EntTypeCount][2] == 0.0)
					{
						PrintToChat(client,"\x03创建失败!实体点不正确.");
						ShowChooseRotFlagsMenu(client,NowEntity);
						return;						
					}
					else BecomeIntoRotating(NowEntity,rotspeed[EntTypeCount],rotpoint[EntTypeCount],rotentpoint[EntTypeCount],SpawnFlags[NowEntity]);
				}	
				
			}
			
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}