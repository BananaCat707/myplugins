#define MaxEvent 20
new TargetEventCount[MAXENTTYPE];
new TargetObject[MAXENTTYPE][MaxEvent];
new String:TargetEventName[MAXENTTYPE][MaxEvent][256];
new String:TargetEventArg[MAXENTTYPE][MaxEvent][256];
new TargetButton[MAXENTTYPE];
new bool:L4D2Version = true;

BecomeIntoTarget(entity,const String:command[],maxlen=1024)
{
	if(maxlen<=0) maxlen=1024;
	new String:sArrayCmd[MaxEvent][64];
	new String:sArrayCmd2[3][64];	
	new c = SplitStringEx(command,_,sArrayCmd,MaxEvent);
	new b  = 0;
	if (c<0) ThrowError("机关板没有事件或语法不对!");
	new bool:btn;
	for (new i = 0;i<c;i++)
	{
		b = SplitStringEx(sArrayCmd[i],",",sArrayCmd2,3);
		if (b<0) ThrowError("事件或语法不对!序列号:%d",b);	
		TargetObject[EntTypeCount][i] = StringToInt(sArrayCmd2[0]);
		strcopy(TargetEventName[EntTypeCount][i],256,sArrayCmd2[1]);
		strcopy(TargetEventArg[EntTypeCount][i],256,sArrayCmd2[2]);	
		if (StrEqual(TargetEventName[EntTypeCount][i],"Use"))
		{
			btn = true;
		}
		#if DEBUG
			LogMessage("%d:%d:%s:%s",i,TargetObject[EntTypeCount][i],TargetEventName[EntTypeCount][i],TargetEventArg[EntTypeCount][i]);
		#endif	
	}
	if (btn)
	{
		TargetButton[EntTypeCount] = CreateButton(entity);
		SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
		SetEntProp(entity, Prop_Send, "m_nGlowRange",  150);
	}
	TargetEventCount[EntTypeCount] = c;
	nType[EntTypeCount] = Type_Target;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_StartTouch,SDKCallBackTarget_StartTouch);
	SDKHook(entity,SDKHook_StartTouch,SDKCallBackTarget_StartTouch);		
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackTarget_Touch);
	SDKHook(entity,SDKHook_Touch,SDKCallBackTarget_Touch);	
	
}

ShowChooseTargetFlagsMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseTargetFlags);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请设置机关板的类型。编号:%d",entity);
	AddMenuItem(menu,"item1","<重要>设置触发事件");
	AddMenuItem(menu,"item2","完成");	
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseTargetFlags(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			switch(item)
			{
				case 0:
					ShowChooseTargetEventMenu(client,NowEntity);
				case 1:
				{
					if (TargetEventCount[EntTypeCount] <=0)
					{
						PrintToChat(client,"创建失败!没有事件响应.");
						ShowChooseTargetFlagsMenu(client,NowEntity);
					}
					else
					{
						new String:sCmd[256];
						new i = 0;
						while(i<TargetEventCount[EntTypeCount])
						{
							if (!StrEqual(TargetEventName[EntTypeCount][i],"") && TargetObject[EntTypeCount][i] >MaxClients && IsValidEdict(TargetObject[EntTypeCount][i]))
							{
								new String:nowCmd[64];
								Format(nowCmd,sizeof nowCmd,"%d,%s,%s\n",TargetObject[EntTypeCount][i],TargetEventName[EntTypeCount][i],TargetEventArg[EntTypeCount][i]);
								#if DEBUG
									LogMessage(nowCmd);
								#endif
								StrCat(sCmd,sizeof sCmd,nowCmd);						
							}
							
							i++;

						}
						BecomeIntoTarget(NowEntity,sCmd,256);
					}
				}
			}
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

ShowChooseTargetEventMenu(client,entity)
{
	new String:sTemp[256];
	new Handle:menu = CreateMenu(MenuHandler_TargetEventFlags);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请设置机关板的事件。选择事件可以删除事件。编号:%d",entity);
	Format(sTemp,sizeof sTemp,"添加事件:目前有%d个",TargetEventCount[EntTypeCount]);		
	AddMenuItem(menu,"item1",sTemp);
	for (new i = 0;i<TargetEventCount[EntTypeCount];i++)
	{
		if(TargetObject[EntTypeCount][i]>MaxClients && IsValidEdict(TargetObject[EntTypeCount][i]) && !StrEqual(TargetEventName[EntTypeCount][i],""))
		{
			new String:sTemp2[256];
			if (StrEqual(TargetEventName[EntTypeCount][i],"StartTouch"))
				Format(sTemp2,sizeof sTemp2,"首次被碰到");
			else if (StrEqual(TargetEventName[EntTypeCount][i],"Touch"))
				Format(sTemp2,sizeof sTemp2,"碰到");
			else if (StrEqual(TargetEventName[EntTypeCount][i],"Use"))
				Format(sTemp2,sizeof sTemp2,"使用");				
			Format(sTemp,sizeof sTemp,"事件对象:%d,事件名:%s,事件参数:%s",TargetObject[EntTypeCount][i],sTemp2,TargetEventArg[EntTypeCount][i]);	
			Format(sTemp2,sizeof sTemp2,"%d",i);
			AddMenuItem(menu,sTemp2,sTemp);				
		}
		else TargetObject[EntTypeCount][i] = 0;

	}

	AddMenuItem(menu,"item3","完成");	
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_TargetEventFlags(Handle:menu, MenuAction:action, client, item)
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
					ShowChooseTargetAddEventMenu(client,NowEntity);
				}
			}
			if(item>0 && item<GetMenuItemCount(menu)-1)
			{
				decl String:sItem[256],item2;
				GetMenuItem(menu,item,sItem,sizeof sItem);
				item2 = StringToInt(sItem);
				for (new i = item2;i<TargetEventCount[EntTypeCount]-item2;i++)
				{
					if (i==TargetEventCount[EntTypeCount]-1)
						continue;
					TargetObject[EntTypeCount][i] = TargetObject[EntTypeCount][i+1];
					strcopy(TargetEventName[EntTypeCount][i],256,TargetEventName[EntTypeCount][i+1]);
					strcopy(TargetEventArg[EntTypeCount][i],256,TargetEventArg[EntTypeCount][i+1]);
				}
				TargetEventCount[EntTypeCount]--;
				ShowChooseTargetEventMenu(client,NowEntity);
			}
			else if (item == GetMenuItemCount(menu)-1)
			{
				ShowChooseTargetFlagsMenu(client,NowEntity);
			}
			
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

ShowChooseTargetAddEventMenu(client,entity)
{
	new index = TargetEventCount[EntTypeCount];
	new String:sTemp[256];
	new Handle:menu = CreateMenu(MenuHandler_TargetAddEventFlags);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请编辑事件(选择它们可以变换),编号:%d,事件编号:%d",EntTypeCount,index);
	Format(sTemp,sizeof sTemp,"<重要>触发对象(可以是自己):%d",TargetObject[EntTypeCount][index]);		
	AddMenuItem(menu,"item1",sTemp);		
	
	if (StrEqual(TargetEventName[EntTypeCount][index],"StartTouch"))
		Format(sTemp,sizeof sTemp,"首次被碰到");
	else if (StrEqual(TargetEventName[EntTypeCount][index],"Touch"))
		Format(sTemp,sizeof sTemp,"碰到(会连续触发)");	
	else if (StrEqual(TargetEventName[EntTypeCount][index],"Use"))
		Format(sTemp,sizeof sTemp,"使用(玩家按下使用键)");			
	else	 Format(sTemp,sizeof sTemp,"无");	
	Format(sTemp,sizeof sTemp,"事件名:%s",sTemp);	
	AddMenuItem(menu,"name",sTemp);	

	if (StrEqual(TargetEventArg[EntTypeCount][index],""))
		Format(sTemp,sizeof sTemp,"无");
	else Format(sTemp,sizeof sTemp,TargetEventArg[EntTypeCount][index]);
	Format(sTemp,sizeof sTemp,"事件参数(每个数字代表不同效果):%s",sTemp);	
	AddMenuItem(menu,"arg",sTemp);	
	AddMenuItem(menu,"item3","完成");	
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_TargetAddEventFlags(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			new index = TargetEventCount[EntTypeCount];
			switch(item)
			{
				case 0:
				{
					TargetObject[EntTypeCount][index] = GetClientAimTargetEx(client);
					if (TargetObject[EntTypeCount][index]<=MaxClients)
					{
						TargetObject[EntTypeCount][index] = 0;
						PrintToChat(client,"\x03无效的对象!");
					}
					ShowChooseTargetAddEventMenu(client,NowEntity);
					
				}
				case 1:
				{
					if (StrEqual(TargetEventName[EntTypeCount][index],""))
						Format(TargetEventName[EntTypeCount][index],256,"StartTouch");	
					else if(StrEqual(TargetEventName[EntTypeCount][index],"StartTouch"))
						Format(TargetEventName[EntTypeCount][index],256,"Touch");
					else if(StrEqual(TargetEventName[EntTypeCount][index],"Touch"))
						Format(TargetEventName[EntTypeCount][index],256,"Use");	
					else if(StrEqual(TargetEventName[EntTypeCount][index],"Use"))
						Format(TargetEventName[EntTypeCount][index],256,"");						
					ShowChooseTargetAddEventMenu(client,NowEntity);	
				}
				case 2:
				{
					if (StrEqual(TargetEventArg[EntTypeCount][index],""))
						Format(TargetEventArg[EntTypeCount][index],256,sp_enable);	
					else if(StrEqual(TargetEventArg[EntTypeCount][index],sp_enable))
						Format(TargetEventArg[EntTypeCount][index],256,sp_disable);
					else if(StrEqual(TargetEventArg[EntTypeCount][index],sp_disable))
						Format(TargetEventArg[EntTypeCount][index],256,sp_p1);	
					else if(StrEqual(TargetEventArg[EntTypeCount][index],sp_p1))
						Format(TargetEventArg[EntTypeCount][index],256,sp_p2);	
					else if(StrEqual(TargetEventArg[EntTypeCount][index],sp_p2))
						Format(TargetEventArg[EntTypeCount][index],256,sp_p3);	
					else if(StrEqual(TargetEventArg[EntTypeCount][index],sp_p3))
						Format(TargetEventArg[EntTypeCount][index],256,"");							
					ShowChooseTargetAddEventMenu(client,NowEntity);				
				}
				case 3:
				{
					if(TargetObject[EntTypeCount][TargetEventCount[EntTypeCount]]>MaxClients && IsValidEdict(TargetObject[EntTypeCount][TargetEventCount[EntTypeCount]]) && !StrEqual(TargetEventName[EntTypeCount][TargetEventCount[EntTypeCount]],""))
					{
						TargetEventCount[EntTypeCount]++;			
					}				
					
					ShowChooseTargetEventMenu(client,NowEntity);
				}
			}
			
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

//code modify from  "[L4D & L4D2] Extinguisher and Flamethrower", SilverShot;
CreateButton(entity )
{ 
	decl String:sTemp[16];
	new button;
	new bool:type=true;
	if(type)button = CreateEntityByName("func_button");
	else button = CreateEntityByName("func_button_timed"); 
 
	if(type )
	{
		DispatchKeyValue(button, "spawnflags", "1025");
		DispatchKeyValue(button, "wait", "1");
	}
	else
	{
		DispatchKeyValue(button, "spawnflags", "0");
		DispatchKeyValue(button, "auto_disable", "1");
		Format(sTemp, sizeof(sTemp), "%f", 5.0);
		DispatchKeyValue(button, "use_time", sTemp);
	}
	DispatchSpawn(button);
	AcceptEntityInput(button, "Enable");
	ActivateEntity(button);

	Format(sTemp, sizeof(sTemp), "ft%d", button);
	DispatchKeyValue(button, "targetname", sTemp);
	SetVariantString(sTemp);
	AcceptEntityInput(entity, "SetParent", button, button, 0);
	TeleportEntity(button, Float:{0.0, 0.0, 0.0}, NULL_VECTOR, NULL_VECTOR);
	Format(sTemp, sizeof(sTemp), "target%d",  button );
	DispatchKeyValue(entity, "targetname", sTemp);	
	DispatchKeyValue(button, "glow", sTemp);	

	SetEntProp(button, Prop_Send, "m_nSolidType", 0, 1);
	SetEntProp(button, Prop_Send, "m_usSolidFlags", 4, 2);

	new Float:vMins[3] = {-5.0, -5.0, -5.0}, Float:vMaxs[3] = {5.0, 5.0, 5.0};
	SetEntPropVector(button, Prop_Send, "m_vecMins", vMins);
	SetEntPropVector(button, Prop_Send, "m_vecMaxs", vMaxs);

	if( L4D2Version )
	{
		SetEntProp(button, Prop_Data, "m_CollisionGroup", 1);
		SetEntProp(button, Prop_Send, "m_CollisionGroup", 1);
	}
	 
	//SetEntProp(entity, Prop_Data, "m_iMinHealthDmg", 99999);
	//HookSingleEntityOutput(entity, "OnHealthChanged", OnHealthChanged, true);

	if( type )
	{	
		HookSingleEntityOutput(button, "OnPressed", OnPressed);
	}
	else
	{
		SetVariantString("OnTimeUp !self:Enable::1:-1");
		AcceptEntityInput(button, "AddOutput");
		HookSingleEntityOutput(button, "OnTimeUp", OnPressed);
	}
	return button;
}

//按下回调
public OnPressed(const String:output[], caller, client, Float:delay)
{
	new id = FindIdByButton(caller);
	if(id==-1)return;
	if (nType[id]!=Type_Target)
		return;
	if (TargetEventCount[id]>0)
	{
		for (new i = 0;i<TargetEventCount[id];i++)
		{
			if (StrEqual(TargetEventName[id][i],"Use"))
				EntityCommand(TargetObject[id][i],TargetEventArg[id][i],caller,client);
		}	
	}
	EmitSoundFromPlayer(client,"player/suit_denydevice.wav");	
}

public SDKCallBackTarget_StartTouch(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Target)
	{
		SDKUnhook(entity,SDKHook_StartTouch,SDKCallBackTarget_StartTouch);
		return;
	}
	if (TargetEventCount[id]>0)
	{
		for (new i = 0;i<TargetEventCount[id];i++)
		{
			if (StrEqual(TargetEventName[id][i],"StartTouch"))
				EntityCommand(TargetObject[id][i],TargetEventArg[id][i],entity,toucher);
		}	
	}
}

public SDKCallBackTarget_Touch(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Target)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackTarget_Touch);
		return;
	}
	if (TargetEventCount[id]>0)
	{
		for (new i = 0;i<TargetEventCount[id];i++)
		{
			if (StrEqual(TargetEventName[id][i],"Touch"))
				EntityCommand(TargetObject[id][i],TargetEventArg[id][i],entity,toucher);
		}	
	}
}

stock EntityCommand(entity,const String:command[],caller=-1,any:data=-1)
{
	#if DEBUG
		LogMessage("entity:%d,command:%s,caller:%d,data:%d",entity,command,caller,data);
	#endif
	if (IsValidEdict(entity))
	{
		if (StrEqual(command,sp_enable))
		{
			SpawnFlags[entity] = StringToInt(sp_enable);
		}
			
		else if (StrEqual(command,sp_disable))
		{
			SpawnFlags[entity] = StringToInt(sp_disable);
		}
		else if (StrEqual(command,sp_p1))
		{
			new id = FindIdEntPropByEntity(entity);
			if(id==-1)return;
			switch(nType[id])
			{
				case Type_Break:
					BreakIt(entity);
				case Type_BreakEx:
					BreakItEx(entity);
				case Type_Lift:
					TeleportEntity(liftinfo[id][0],liftpathpos[id][0],NULL_VECTOR,NULL_VECTOR);			
			}
		}
		else if (StrEqual(command,sp_p2))
		{
			new id = FindIdEntPropByEntity(entity);
			if(id==-1)return;		
			switch(nType[id])
			{
				case Type_Lift:
				{
					AcceptEntityInput(liftinfo[id][0],"Toggle",-1,caller);
				}
					
				case Type_Rot:
					AcceptEntityInput(rotrot[id],"Toggle",-1,caller);		
				case Type_Laser:
					AcceptEntityInput(laserprop[id],"Toggle",-1,caller);
				case Type_Teleport:
				{
					#if DEBUG
						LogMessage("data=%d",data);
					#endif
					TeleportPlayer(data,Pos[id]);
				}
					
			}
		}
		else if (StrEqual(command,sp_p3))
			AcceptEntityInput(entity,"Kill",-1,caller);
	}
}

FindIdByButton(button)
{
	for (new i = 0;i<EntTypeCount;i++)
	{
		if (TargetButton[i] == button)
		{
			#if DEBUG
				LogMessage("Find Target:%d",i);
			#endif
			return i;
		}
	}		
	return -1;
}
