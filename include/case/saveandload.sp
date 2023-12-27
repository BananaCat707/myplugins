#include <sourcemod>

public Action:CmdLoadAndSave(client,args)
{
	new Handle:menu = CreateMenu(MenuHandler_LoadAndSave);
	SetMenuTitle(menu,"保存/读取菜单");
	SetMenuExitButton(menu,true);
	AddMenuItem(menu,"item1","保存当前地图文件");
	AddMenuItem(menu,"item2","读取当前地图文件");	
	AddMenuItem(menu,"item3","让所有的电梯板都显示路径");
	AddMenuItem(menu,"item4","让所有的电梯板都隐藏路径");	
	AddMenuItem(menu,"item5","让所有的电梯板都停下来");
	AddMenuItem(menu,"item6","让所有的电梯板都继续");		
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
}

public MenuHandler_LoadAndSave(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(item)
			{
				case 0:
				{
					SaveToFile(client);
				}
				case 1:
				{
					LoadFromFile(client);
				}				
				case 2:
				{
					for (new id = 0;id<EntTypeCount;id++)
					{
						if (IsValidEdict(EntProp[id]) && nType[id] == Type_Lift && liftinfo[id][2]>=2)
							liftshowbeam[id] = true;
					}
				}
				case 3:
				{
					for (new id = 0;id<EntTypeCount;id++)
					{
						if (IsValidEdict(EntProp[id]) && nType[id] == Type_Lift && liftinfo[id][2]>=2)
							liftshowbeam[id] = false;
					}
				}
				case 4:
				{
					for (new id = 0;id<EntTypeCount;id++)
					{
						if (IsValidEdict(EntProp[id]) && nType[id] == Type_Lift && IsValidEdict(liftinfo[id][0]))
							AcceptEntityInput(liftinfo[id][0],"Stop");
					}					
				}
				case 5:
				{
					for (new id = 0;id<EntTypeCount;id++)
					{
						if (IsValidEdict(EntProp[id]) && nType[id] == Type_Lift && IsValidEdict(liftinfo[id][0]))
							AcceptEntityInput(liftinfo[id][0],"Resume");
					}							
				}				
			}
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

stock SaveToFile(client=0)
{
	decl String:map[256], String:FileNameS[256];
	new Handle:file = INVALID_HANDLE;
	GetCurrentMap(map, sizeof(map));
	BuildPath(Path_SM, FileNameS, sizeof(FileNameS), "data/EntType/%s.txt", map);
	if (FileExists(FileNameS))
	{
		decl String:newfile[256];
		BuildPath(Path_SM, newfile, sizeof(newfile), "data/EntType/%s.bak", map);	
		if (FileExists(newfile))
			DeleteFile(newfile);
		RenameFile(newfile,FileNameS);
		ReplyToCommand(client,"保存文件的数据的文件已经存在，已经备份了!");
		
	}
	file = OpenFile(FileNameS, "a+");
	if(file == INVALID_HANDLE)
	{
		ReplyToCommand(client, "打开文件失败!可能是没有找到目录。\n请在addons/data目录里创建一个名为EntType的文件夹。");
		return;
	}
	decl Float:vecOrigin[3],String:sModel[256], String:sTime[256];
	new count = 0;
	FormatTime(sTime, sizeof(sTime), "%Y/%m/%d");
	WriteFileLine(file, "//----------特殊实体数据 (YY/MM/DD): [%s] ---------------||", sTime);
	WriteFileLine(file, "//----------创建人: %N----------------------||", client);
	WriteFileLine(file, "");
	WriteFileLine(file, "\"EntType\"");
	WriteFileLine(file, "{");
	for(new i=MaxClients; i < ARRAY_SIZE; i++)
	{
		new id = FindIdEntPropByEntity(i);
		if (id==-1)continue;
		if(nType[id]>0 && IsValidEdict(EntProp[id]))
		{
			count++;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecOrigin);
			GetEntPropString(i, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
			
			WriteFileLine(file, "	\"EntType_%i\"", count);
			WriteFileLine(file, "	{");
			WriteFileLine(file, "		\"origin\" \"%d %d %d\"", RoundToFloor(vecOrigin[0]), RoundToFloor(vecOrigin[1]), RoundToFloor(vecOrigin[2]));
			WriteFileLine(file, "		\"model\"	 \"%s\"", sModel);
			WriteFileLine(file, "		\"Type\" \"%d\"", nType[id]);
			WriteFileLine(file, "		\"Ice_Speed\" \"%f\"", icespeed[id]);	
			WriteFileLine(file, "		\"Jump_power\" \"%f\"", jumppower[id]);		
			WriteFileLine(file, "		\"Throw_Power\" \"%f\"", throwpower[id]);	
			WriteFileLine(file, "		\"Break_Helth\" \"%d\"", MaxHealth[id]);
			WriteFileLine(file, "		\"TP_Pos\" \"%f %f %f\"", Pos[id][0], Pos[id][1], Pos[id][2]);
			WriteFileLine(file, "		\"Heavy\" \"%f\"", heavypower[id]);
			WriteFileLine(file, "		\"IsShot\" \"%d\"", bShot[id]);			
			WriteFileLine(file, "		\"IsTouch\" \"%d\"", bTouch[id]);		
			WriteFileLine(file, "		\"LiftSpeed\" \"%d\"", liftinfo[id][1]);
			WriteFileLine(file, "		\"ShowBeam\" \"%d\"", liftshowbeam[id]);
			WriteFileLine(file, "		\"LiftDamage\" \"%d\"", liftdamage[id]);	
			WriteFileLine(file, "		\"PathCount\" \"%d\"", liftinfo[id][2]);					
			if (nType[id] == Type_Lift)
			{
				for (new path = 0;path<liftinfo[id][2];path++)
				{
					WriteFileLine(file, "		\"PathPos_%d\" \"%d %d %d\"",path, RoundToFloor(liftpathpos[id][path][0]), RoundToFloor(liftpathpos[id][path][1]), RoundToFloor(liftpathpos[id][path][2]));	
				}
			}
			WriteFileLine(file, "		\"LaserEndPos\" \"%f %f %f\"", laserpos[id][0],laserpos[id][1],laserpos[id][2]);			
			WriteFileLine(file, "		\"LaserWidth\" \"%d\"", laserwidth[id]);	
			WriteFileLine(file, "		\"LaserDamage\" \"%d\"", laserdamage[id]);		
			WriteFileLine(file, "		\"RotatingSpeed\" \"%d\"", rotspeed[id]);	
			WriteFileLine(file, "		\"RotatingPoint\" \"%f %f %f\"", rotpoint[id][0],rotpoint[id][1],rotpoint[id][2]);	
			WriteFileLine(file, "		\"RotatingEntPoint\" \"%f %f %f\"", rotentpoint[id][0],rotentpoint[id][1],rotentpoint[id][2]);
			WriteFileLine(file, "		\"InfoMessage\" \"%s\"", InfoMessage[id]);
			WriteFileLine(file, "		\"InfoIcon\" \"%s\"", InfoIcon[id]);			
			WriteFileLine(file, "		\"InfoColor\" \"%d %d %d\"", InfoColor[id][0],InfoColor[id][1],InfoColor[id][2]);	
			WriteFileLine(file, "		\"TargetEventCount\" \"%d\"", TargetEventCount[id]);				
			if (nType[id] == Type_Target)
			{
				for (new event = 0;event<TargetEventCount[id];event++)
				{
					if (IsValidEdict(TargetObject[id][event]))
					{
						new Float:obpos[3];
						GetEntPropVector(TargetObject[id][event],Prop_Send,"m_vecOrigin",obpos);
						WriteFileLine(file, "		\"EventObject_%d\" \"%f %f %f\"",event,obpos[0], obpos[1], obpos[2]);	
						WriteFileLine(file, "		\"Event_%d\" \"%s,%s\"",event,TargetEventName[id][event],TargetEventArg[id][event]);	
					}
					
				}
			}
			WriteFileLine(file, "		\"SpawnFlags\" \"%d\"", SpawnFlags[i]);		
			WriteFileLine(file, "	}");
			WriteFileLine(file, "	");
		}	
	}
	WriteFileLine(file, "	\"total_cache\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"total\" \"%i\"", count);
	WriteFileLine(file, "	}");
	WriteFileLine(file, "}");
	FlushFile(file);
	CloseHandle(file);
	ReplyToCommand(client,"保存成功!\n文件路径:%s",FileNameS);
}

stock LoadFromFile(client)
{
	new Handle:keyvalues = INVALID_HANDLE;
	decl String:KvFileName[256], String:map[256], String:name[256];
	GetCurrentMap(map, sizeof(map));
	BuildPath(Path_SM, KvFileName, sizeof(KvFileName), "data/EntType/%s.txt", map);
	if(!FileExists(KvFileName))
		return;
	keyvalues = CreateKeyValues("EntType");
	FileToKeyValues(keyvalues, KvFileName);
	KvRewind(keyvalues);
	if(KvJumpToKey(keyvalues, "total_cache"))
	{
		new max = KvGetNum(keyvalues, "total", 0);
		if(max <= 0)
			return;
		decl String:model[256], Float:vecOrigin[3];
		KvRewind(keyvalues);
		for(new count=1; count <= max; count++)
		{
			Format(name, sizeof(name), "EntType_%i", count);
			if(KvJumpToKey(keyvalues, name))
			{
				new type;		
				KvGetVector(keyvalues, "origin", vecOrigin);
				KvGetString(keyvalues, "model", model, sizeof(model));
				
				type = KvGetNum(keyvalues,"Type");
			
				if (type>0)
				{
					new Float:pos[3];
					for (new entity = MaxClients;entity<ARRAY_SIZE;entity++)
					{
						if (IsValidEdict(entity))
						{
							SpawnFlags[entity] = KvGetNum(keyvalues,"SpawnFlags"); 
							decl String:clsname[256];
							GetEdictClassname(entity,clsname,sizeof clsname);
							new id = FindIdEntPropByEntity(entity);
							if (id==-1 && StrContains(clsname,"prop_")!=-1)
							{
								decl String:sModel[256];
								GetEntPropString(entity,Prop_Data,"m_ModelName",sModel,sizeof sModel);
								GetEntPropVector(entity,Prop_Send,"m_vecOrigin",pos);
								
								if (RoundToFloor(vecOrigin[0]) == RoundToFloor(pos[0]) && RoundToFloor(vecOrigin[1]) == RoundToFloor(pos[1]) && RoundToFloor(vecOrigin[2]) == RoundToFloor(pos[2]) && StrEqual(sModel,model))
								{
									switch(type)
									{
										case Type_Fire:BecomeIntoFire(entity);
										case Type_Ice:
										{
											BecomeIntoIce(entity,KvGetFloat(keyvalues,"Ice_Speed"));
										}
										case Type_Jump:
										{
											BecomeIntoJump(entity,KvGetFloat(keyvalues,"Jump_power"));
										}
										case Type_Throw:
										{
											BecomeIntoThrow(entity,KvGetFloat(keyvalues,"Throw_Power"));
										}
										case Type_Break:BecomeIntoBreak(entity,KvGetNum(keyvalues,"Break_Helth"));
										case Type_Teleport:
										{
											new Float:tele[3];
											KvGetVector(keyvalues,"TP_Pos",tele);
											BecomeIntoTeleport(entity,tele);	
										}
										case Type_Die:
										{	
											BecomeIntoDie(entity);
										}
										case Type_Shake:
										{	
											BecomeIntoShake(entity);	
										}
										case Type_Auto:
										{
											BecomeIntoRun(entity);
										}
										case Type_Heavy:BecomeIntoHeavy(entity,KvGetFloat(keyvalues,"Heavy"));	
										case Type_BreakEx:
										{
											new shot,touch;	
											new bool:s,bool:t;
											shot = KvGetNum(keyvalues,"IsShot");
											touch = KvGetNum(keyvalues,"IsTouch");
											if (shot==1)
												s=true;
											if (touch==1)
												t=true;
		
											BecomeIntoBreakEx(entity,s,t);	
										}
										case Type_Lift:
										{
											new speed,pacount;
											new Float:papos[MaxLiftPath][3];
											new bool:showbeam,bool:bDamage;
											
											pacount = KvGetNum(keyvalues,"PathCount");
											showbeam = KvGetBool(keyvalues,"ShowBeam");
											speed = KvGetNum(keyvalues,"LiftSpeed");
											bDamage = KvGetBool(keyvalues,"LiftDamage");
											for (new path = 0;path<pacount;path++)
											{
												decl String:sTemp2[256];
												Format(sTemp2,sizeof sTemp2,"PathPos_%d",path);
												KvGetVector(keyvalues,sTemp2,papos[path]);
											}
											liftshowbeam[EntTypeCount] = showbeam;
											
											BecomeIntoLift(entity,speed,pacount,papos,bDamage,SpawnFlags[entity]);
											
										}
										case Type_Laser:
										{
											new Float:endpos[3];		
											new ldamage,lwidth;			
											ldamage = KvGetNum(keyvalues,"LaserDamage");
											lwidth = KvGetNum(keyvalues,"LaserWidth");
											KvGetVector(keyvalues,"LaserEndPos",endpos);
								
											BecomeIntoLaser(entity,ldamage,lwidth,endpos);
											
										}	
										case Type_Rot:
										{
											new ringspeed = KvGetNum(keyvalues,"RotatingSpeed");
											new Float:point[3],Float:entpoint[3];
											KvGetVector(keyvalues,"RotatingPoint",point);
											KvGetVector(keyvalues,"RotatingEntPoint",entpoint);
											BecomeIntoRotating(entity,ringspeed,point,entpoint,SpawnFlags[entity]);
											
										}	
										case Type_Info:
										{
											new String:msg[256],String:ico[256],Float:cl[3],cl2[3];
											KvGetString(keyvalues,"InfoMessage",msg,256);
											KvGetString(keyvalues,"InfoIcon",ico,256);
											KvGetVector(keyvalues,"InfoColor",cl);
											cl2[0] = RoundToFloor(cl[0]);
											cl2[1] = RoundToFloor(cl[1]);
											cl2[2] = RoundToFloor(cl[2]);
											BecomeIntoInfo(entity,msg,ico,cl2);
											
										}	
										case Type_Target:
										{
											new String:command[1024];
											new String:namearg[256];
											new Float:epos[3];
											
											
											new eventcount = KvGetNum(keyvalues,"TargetEventCount");
											for (new event = 0;event<eventcount;event++)
											{
												new String:sTemp2[256];
												Format(sTemp2,sizeof sTemp2,"EventObject_%d",event);
												KvGetVector(keyvalues,sTemp2,epos);
												new object = FindEntityByPos(epos);								
												if(object==-1)
													continue;
												Format(sTemp2,sizeof sTemp2,"Event_%d",event);	
												KvGetString(keyvalues,sTemp2,namearg,sizeof namearg);	
												if (!StrEqual(namearg,"") && IsValidEdict(object))
												{
													new String:nowCmd[64];
													Format(nowCmd,sizeof nowCmd,"%d,%s\n",object,namearg);
													StrCat(command,sizeof command,nowCmd);						
												}
											}
											
											BecomeIntoTarget(entity,command,1024);
											
										}										
									}
									break;
								}
							}
						}
						
					}
				}
				KvRewind(keyvalues);
			}
			else
			{
				break;
			}
		}
	}
	CloseHandle(keyvalues);
	ReplyToCommand(client,"载入地图文件成功!文件:%s",KvFileName);
}

stock FindEntityByPos(Float:pos[3])
{
	for (new entity = MaxClients;entity<ARRAY_SIZE;entity++)
	{
		if (IsValidEdict(entity))
		{
			decl String:clsname[256];
			GetEdictClassname(entity,clsname,sizeof clsname);
			if (StrContains(clsname,"prop_")!=-1)
			{
				decl Float:vecOrigin[3];
				GetEntPropVector(entity,Prop_Send,"m_vecOrigin",vecOrigin);
				
				if (RoundToFloor(vecOrigin[0]) == RoundToFloor(pos[0]) && RoundToFloor(vecOrigin[1]) == RoundToFloor(pos[1]) && RoundToFloor(vecOrigin[2]) == RoundToFloor(pos[2]))
				{
					return entity;
				}
			}
		}		
	}	
	return -1;
}