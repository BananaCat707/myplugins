#include <sourcemod>

#define MaxLiftPath 20

//0是电梯的模型索引 1是电梯的速度 2是电梯的路径总数
new liftinfo[MAXENTTYPE][3];
new liftpath[MAXENTTYPE][MaxLiftPath];
new bool:liftshowbeam[MAXENTTYPE];
new bool:liftdamage[MAXENTTYPE];
new Float:liftpathpos[MAXENTTYPE][MaxLiftPath][3];

new liftbeamcolor[4];

new g_sprite = 0;

BecomeIntoLift(entity,speed=100,pathcount,Float:pos[][3],bool:damage=false,sp=0)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	decl String:sTemp[256],String:sFirst[256],Float:ang[3],String:model[256],String:sName[256];
	GetEntPropVector(entity,Prop_Data,"m_angRotation",ang);
	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));

	if(!IsValidEdict(entity))return;
	
	new lift = CreateEntityByName("func_tracktrain");
	if (lift == -1)return;	
	Format(sName,sizeof(sName),"train_%d",entity);	
	for (new i = 0;i<pathcount;i++)
	{
		new path = CreateEntityByName("path_track");
		if(path==-1)continue;
		Format(sTemp,sizeof(sTemp),"path%d_%d",entity,i);
		if (i==0)
		{
			strcopy(sFirst,sizeof sFirst,sTemp);	
			HookSingleEntityOutput(path,"OnPass",EntityOutput_OnPass_Start);
		}
		DispatchKeyValue(path,"targetname",sTemp);
		
		if (i<pathcount-1)
		{
			Format(sTemp,sizeof(sTemp),"path%d_%d",entity,i+1);
			DispatchKeyValue(path,"target",sTemp);	
		}	
		else if (i == pathcount-1)
		{
			Format(sTemp,sizeof(sTemp),"path%d_%d",entity,0);
			HookSingleEntityOutput(path,"OnPass",EntityOutput_OnPass_End);
		}
		
		DispatchKeyValue(path, "parentname", sName);	

		DispatchSpawn(path);
		TeleportEntity(path,pos[i],NULL_VECTOR,NULL_VECTOR);
		liftpath[EntTypeCount][i]=path;
		CopyVector(liftpathpos[EntTypeCount][i],pos[i],3);	
	}
	for (new b = 0;b<pathcount;b++)
		ActivateEntity(liftpath[EntTypeCount][b]);
	DispatchKeyValue(lift, "targetname", sName);	
	new prop = CreateEntityByName("prop_dynamic");
	DispatchKeyValue(prop, "model", model);
	DispatchKeyValue(prop,"parentname",sName);
	DispatchKeyValue(prop,"solid","6");	
	DispatchSpawn(prop);
	SetVariantString(sName);
	AcceptEntityInput(prop,"SetParent",prop,prop);
	Format(sTemp,sizeof(sTemp),"%d",speed);	
	DispatchKeyValue(lift, "speed", sTemp);
	DispatchKeyValue(lift, "target", sFirst);		
	if (damage)
		DispatchKeyValue(lift,"dmg","1");
	DispatchKeyValue(lift, "spawnflags", "17");

	DispatchSpawn(lift);
	ActivateEntity(lift);

	SetEntityModel(lift, model);
	TeleportEntity(lift,pos[0],ang,NULL_VECTOR);
	
	SetEntProp(lift, Prop_Send, "m_nSolidType", 2);

	new enteffects = GetEntProp(lift, Prop_Send, "m_fEffects");
	enteffects |= 32;
	SetEntProp(lift, Prop_Send, "m_fEffects", enteffects);  

	AcceptEntityInput(lift,"StartForward");
	
	if (sp != StringToInt(sp_enable))
		AcceptEntityInput(lift,"Toggle");
	SpawnFlags[entity] = sp;
	nType[EntTypeCount] = Type_Lift;	
	liftinfo[EntTypeCount][0] = lift;	
	liftinfo[EntTypeCount][1] = speed;
	liftinfo[EntTypeCount][2] = pathcount;
	liftdamage[EntTypeCount] = damage;	
	
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
}

public EntityOutput_OnPass_Start(const String:output[], path, lift, Float:delay)
{
	if (IsValidEdict(lift))
		AcceptEntityInput(lift,"StartForward");
}

public EntityOutput_OnPass_End(const String:output[], path, lift, Float:delay)
{
	if (IsValidEdict(lift))
		AcceptEntityInput(lift,"StartBackward");
}

ShowChooseLiftFlagsMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseLiftFlags);
	SetMenuExitButton(menu,true);
	decl String:sTemp[256];
	SetMenuTitle(menu,"请设置电梯板的类型。编号:%d",entity);
	
	Format(sTemp,sizeof sTemp,"<重要>速度+10.目前:%d",liftinfo[EntTypeCount][1]);
	AddMenuItem(menu,"item1",sTemp);
	Format(sTemp,sizeof sTemp,"<重要>速度-10.目前:%d",liftinfo[EntTypeCount][1]);	
	AddMenuItem(menu,"item2",sTemp);
	Format(sTemp,sizeof sTemp,"是否显示路径(不建议):%d",liftshowbeam[EntTypeCount]);	
	AddMenuItem(menu,"item3",sTemp);	
	Format(sTemp,sizeof sTemp,"卡住时伤害(防止玩家卡电梯):%d",liftdamage[EntTypeCount]);	
	AddMenuItem(menu,"item4",sTemp);		
	Format(sTemp,sizeof sTemp,"<重要>添加路径点,目前有%d个(MAX:%d).选择它们可以删除",liftinfo[EntTypeCount][2],MaxLiftPath);		
	AddMenuItem(menu,"item5",sTemp);	
	if (liftinfo[EntTypeCount][2]>0)
	{
		for (new i = 0;i<liftinfo[EntTypeCount][2];i++)
		{
			Format(sTemp,sizeof sTemp,"路径点%d:坐标->%d,%d,%d",i,RoundToFloor(liftpathpos[EntTypeCount][i][0]),RoundToFloor(liftpathpos[EntTypeCount][i][1]),RoundToFloor(liftpathpos[EntTypeCount][i][2]));	
			decl String:sTemp2[256];
			Format(sTemp2,sizeof sTemp2,"%d",i);	
			AddMenuItem(menu,sTemp2,sTemp);
		}
	}
	AddMenuItem(menu,"item6","完成");		
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseLiftFlags(Handle:menu, MenuAction:action, client, item)
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
					liftinfo[EntTypeCount][1]+=10;
					ShowChooseLiftFlagsMenu(client,NowEntity);
				}
				case 1:
				{
					if (liftinfo[EntTypeCount][1]>10)
					{
						liftinfo[EntTypeCount][1]-=10;
					}
					ShowChooseLiftFlagsMenu(client,NowEntity);
				}
				case 2:
				{
					liftshowbeam[EntTypeCount] = !liftshowbeam[EntTypeCount];				
					ShowChooseLiftFlagsMenu(client,NowEntity);
				}
				case 3:
				{
					liftdamage[EntTypeCount] = !liftdamage[EntTypeCount];				
					ShowChooseLiftFlagsMenu(client,NowEntity);					
				}
				case 4:
				{
					if (liftinfo[EntTypeCount][2] >= MaxLiftPath)
					{
						PrintToChat(client,"\x03没有空余的路径点了。");
						ShowChooseLiftFlagsMenu(client,NowEntity);
						return;
					}
					GetClientAbsOrigin(client,liftpathpos[EntTypeCount][liftinfo[EntTypeCount][2]]);
					liftinfo[EntTypeCount][2]++;
					ShowChooseLiftFlagsMenu(client,NowEntity);
				}	
				
			}
			if(item>4 && item<GetMenuItemCount(menu)-1)
			{
				decl String:sItem[256],item2;
				GetMenuItem(menu,item,sItem,sizeof sItem);
				item2 = StringToInt(sItem);
				for (new i = item2;i<liftinfo[EntTypeCount][2]-item2;i++)
				{
					if (i==liftinfo[EntTypeCount][2]-1)
						continue;
					liftpathpos[EntTypeCount][i][0] = liftpathpos[EntTypeCount][i+1][0];
					liftpathpos[EntTypeCount][i][1] = liftpathpos[EntTypeCount][i+1][1];
					liftpathpos[EntTypeCount][i][2] = liftpathpos[EntTypeCount][i+1][2];					
				}
				liftinfo[EntTypeCount][2]--;
				ShowChooseLiftFlagsMenu(client,NowEntity);
			}
			else if (item == GetMenuItemCount(menu)-1)
			{
				if (liftinfo[EntTypeCount][2] > MaxLiftPath)
				{
					PrintToChat(client,"\x03创建失败!太多的路径点了。");
					ShowChooseLiftFlagsMenu(client,NowEntity);
					return;
				}
				else if (liftinfo[EntTypeCount][1]<10)
				{
					PrintToChat(client,"\x03创建失败!速度不正确。");
					ShowChooseLiftFlagsMenu(client,NowEntity);
					return;					
				}
				else if (liftinfo[EntTypeCount][2]<2)
				{
					PrintToChat(client,"\x03创建失败!路径点不足(>=2)。");
					ShowChooseLiftFlagsMenu(client,NowEntity);
					return;					
				}				
				else BecomeIntoLift(NowEntity,liftinfo[EntTypeCount][1],liftinfo[EntTypeCount][2],liftpathpos[EntTypeCount],liftdamage[EntTypeCount],SpawnFlags[NowEntity]);
			}
			
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

ShowLiftPathBeam()
{
	for (new id = 0;id<MAXENTTYPE;id++)
	{
		if (liftshowbeam[id] && liftinfo[id][2]>=2)
		{
			for (new path = 0;path<liftinfo[id][2];path++)
			{
				if (path == liftinfo[id][2]-1)
					continue;
				else
					TE_SetupBeamPoints(liftpathpos[id][path],liftpathpos[id][path+1],g_sprite,0,0,0,0.1,2.0,2.0,1,0.0,liftbeamcolor,0);
				TE_SendToAll();
			}
		}
	}
}