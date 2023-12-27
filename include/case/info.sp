#include <sourcemod>
#define MaxInfoSize 256
new String:InfoMessage[MAXENTTYPE][MaxInfoSize];
new String:InfoIcon[MAXENTTYPE][MaxInfoSize];
new InfoColor[MAXENTTYPE][3];
new InfoTime[MAXENTTYPE];

BecomeIntoInfo(entity,String:sMessage[],String:sIcon[],color[3],showtime=5)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	nType[EntTypeCount] = Type_Info;
	EntProp[EntTypeCount] = entity;	
	strcopy(InfoMessage[EntTypeCount],MaxInfoSize,sMessage);
	strcopy(InfoIcon[EntTypeCount],MaxInfoSize,sIcon);
	CopyVector(InfoColor[EntTypeCount],color);
	InfoTime[EntTypeCount]=showtime;
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_StartTouch,SDKCallBackInfo_Touch);
	SDKHook(entity,SDKHook_StartTouch,SDKCallBackInfo_Touch);
}

public Action:CmdText(client,args)
{
	if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
	decl String:clsname[256];
	GetEdictClassname(NowEntity,clsname,sizeof clsname);
	if (StrEqual(clsname,"player"))
	{
		PrintToChat(client,"\x03不能把玩家作为你的目标!");
		return;
	}
	new id = FindIdEntPropByEntity(NowEntity);
	if (id==-1)
	{
		if (args < 1 && StrEqual(InfoMessage[EntTypeCount],""))
		{
			PrintToChat(client,"\x03用法:!ett <消息>.\n例:!ett \"abcdefg\"");
			return;
		}
		else if (args < 1 && !StrEqual(InfoMessage[EntTypeCount],""))
		{
			strcopy(InfoMessage[EntTypeCount],MaxInfoSize,"");
			PrintToChat(client,"\x03成功清空文本(编号:%d)",NowEntity);
			ShowChooseInfoFlagsMenu(client,NowEntity);
			return;
		}		
		decl String:text[256];
		GetCmdArg(1,text,sizeof text);
		StrCat(InfoMessage[EntTypeCount],sizeof text,text);
		PrintToChat(client,"\x03成功输入文本(编号:%d):\x04%s",NowEntity,InfoMessage[EntTypeCount]);
		ShowChooseInfoFlagsMenu(client,NowEntity);
	}
}

ShowChooseInfoFlagsMenu(client,entity)
{
	decl String:sTemp[256];
	new Handle:menu = CreateMenu(MenuHandler_ChooseInfoFlags);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择讯息板的类型,编号:%d (输入!ett设置文本)",entity);
	Format(sTemp,sizeof sTemp,"文本:%s",InfoMessage[EntTypeCount]);	
	AddMenuItem(menu,"item1",sTemp,ITEMDRAW_DISABLED);	
	
	if (StrEqual(InfoIcon[EntTypeCount],""))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):无");	
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_tip"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):提示");
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_info"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):信息");	
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_shield"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):防御");	
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_alert"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):警告");	
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_alert_red"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):强制警告");	
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_skull"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):骷髅头");
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_no"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):禁止");		
	else if (StrEqual(InfoIcon[EntTypeCount],"icon_arrow_up"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):前面");	
	else if (StrEqual(InfoIcon[EntTypeCount],"+jump"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):跳跃键");	
	else if (StrEqual(InfoIcon[EntTypeCount],"+attack"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):攻击键1");	
	else if (StrEqual(InfoIcon[EntTypeCount],"+attack2"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):攻击键2");	
	else if (StrEqual(InfoIcon[EntTypeCount],"+duck"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):蹲键");	
	else if (StrEqual(InfoIcon[EntTypeCount],"+speed"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):Shift键");	
	else if (StrEqual(InfoIcon[EntTypeCount],"+reload"))
		Format(sTemp,sizeof sTemp,"消息图标(选择可切换):装弹键");			
	AddMenuItem(menu,"item2",sTemp);		
	
	
	if (InfoColor[EntTypeCount][0] == 255 && InfoColor[EntTypeCount][1] == 255 && InfoColor[EntTypeCount][2] == 255)
		Format(sTemp,sizeof sTemp,"消息颜色(选择可切换):白色");	
	else if (InfoColor[EntTypeCount][0] == 0 && InfoColor[EntTypeCount][1] == 0 && InfoColor[EntTypeCount][2] == 0)
		Format(sTemp,sizeof sTemp,"消息颜色(选择可切换):黑色");
	else if (InfoColor[EntTypeCount][0] == 0 && InfoColor[EntTypeCount][1] == 0 && InfoColor[EntTypeCount][2] == 255)
		Format(sTemp,sizeof sTemp,"消息颜色(选择可切换):蓝色");		
	else if (InfoColor[EntTypeCount][0] == 0 && InfoColor[EntTypeCount][1] == 255 && InfoColor[EntTypeCount][2] == 0)
		Format(sTemp,sizeof sTemp,"消息颜色(选择可切换):绿色");		
	else if (InfoColor[EntTypeCount][0] == 255 && InfoColor[EntTypeCount][1] == 0 && InfoColor[EntTypeCount][2] == 0)
		Format(sTemp,sizeof sTemp,"消息颜色(选择可切换):红色");				
	AddMenuItem(menu,"item3",sTemp);
	AddMenuItem(menu,"item4","完成");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseInfoFlags(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			switch(item)
			{
				case 1:
				{
					if (StrEqual(InfoIcon[EntTypeCount],""))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_tip");	
					else if(StrEqual(InfoIcon[EntTypeCount],"icon_tip"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_info");
					else if(StrEqual(InfoIcon[EntTypeCount],"icon_info"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_shield");	
					else if (StrEqual(InfoIcon[EntTypeCount],"icon_shield"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_alert");	
					else if(StrEqual(InfoIcon[EntTypeCount],"icon_alert"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_alert_red");
					else if(StrEqual(InfoIcon[EntTypeCount],"icon_alert_red"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_skull");
					else if(StrEqual(InfoIcon[EntTypeCount],"icon_skull"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_no");	
					else if(StrEqual(InfoIcon[EntTypeCount],"icon_no"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"icon_arrow_up");							
					else if(StrEqual(InfoIcon[EntTypeCount],"icon_arrow_up"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"+jump");
					else if(StrEqual(InfoIcon[EntTypeCount],"+jump"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"+attack");
					else if(StrEqual(InfoIcon[EntTypeCount],"+attack"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"+attack2");
					else if(StrEqual(InfoIcon[EntTypeCount],"+attack2"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"+duck");
					else if(StrEqual(InfoIcon[EntTypeCount],"+duck"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"+speed");
					else if(StrEqual(InfoIcon[EntTypeCount],"+speed"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"+reload");
					else if(StrEqual(InfoIcon[EntTypeCount],"+reload"))
						Format(InfoIcon[EntTypeCount],MaxInfoSize,"");
						
					ShowChooseInfoFlagsMenu(client,NowEntity);
				}			
				case 2:
				{
					if (InfoColor[EntTypeCount][0] == 0 && InfoColor[EntTypeCount][1] == 0 && InfoColor[EntTypeCount][2] == 0)
						InfoColor[EntTypeCount] = {255,255,255};	
					else if (InfoColor[EntTypeCount][0] == 255 && InfoColor[EntTypeCount][1] == 255 && InfoColor[EntTypeCount][2] == 255)
						InfoColor[EntTypeCount] = {0,0,255};
					else if (InfoColor[EntTypeCount][0] == 0 && InfoColor[EntTypeCount][1] == 0 && InfoColor[EntTypeCount][2] == 255)
						InfoColor[EntTypeCount] = {0,255,0};
					else if (InfoColor[EntTypeCount][0] == 0 && InfoColor[EntTypeCount][1] == 255 && InfoColor[EntTypeCount][2] == 0)
						InfoColor[EntTypeCount] = {255,0,0};
					else if (InfoColor[EntTypeCount][0] == 255 && InfoColor[EntTypeCount][1] == 0 && InfoColor[EntTypeCount][2] == 0)
						InfoColor[EntTypeCount] = {0,0,0};					
					ShowChooseInfoFlagsMenu(client,NowEntity);
				}
				
				case 3:
				{
					if (StrEqual(InfoMessage[EntTypeCount],""))
					{
						PrintToChat(client,"\x03创建失败!消息文本为空!");
						return;
					}
					BecomeIntoInfo(NowEntity,InfoMessage[EntTypeCount],InfoIcon[EntTypeCount],InfoColor[EntTypeCount]);
				}
			}
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

public SDKCallBackInfo_Touch(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Info)
	{
		SDKUnhook(entity,SDKHook_StartTouch,SDKCallBackInfo_Touch);
		return;
	}
	if (toucher<MaxClients && IsPlayerAlive(toucher))
	{
		if (StrContains(InfoIcon[id],"+")!=-1)
		{
			DisplayInstructorHint(toucher,InfoMessage[id],"use_binding",InfoIcon[id],InfoColor[id],InfoTime[id]);
		}
		else DisplayInstructorHint(toucher,InfoMessage[id],InfoIcon[id],"",InfoColor[id],InfoTime[id]);
	}
	
}

stock DisplayInstructorHint(client, String:s_Message[256], String:s_Icon[],String:s_Binding[],color[3],showtime=5)
{
	if (IsClientInGame(client)) ClientCommand(client, "gameinstructor_enable 1");
	decl i_Ent, String:s_TargetName[32], Handle:h_RemovePack,String:sTemp[64];
	
	i_Ent = CreateEntityByName("env_instructor_hint");
	FormatEx(s_TargetName, sizeof(s_TargetName), "hint%d", client);
	ReplaceString(s_Message, sizeof(s_Message), "\n", "");
	DispatchKeyValue(client, "targetname", s_TargetName);
	DispatchKeyValue(i_Ent, "hint_target", s_TargetName);
	Format(sTemp,sizeof sTemp,"%d",showtime);	
	DispatchKeyValue(i_Ent, "hint_timeout",sTemp );
	DispatchKeyValue(i_Ent, "hint_range", "0.01");
	Format(sTemp,sizeof sTemp,"%d %d %d",color[0],color[1],color[2]);
	DispatchKeyValue(i_Ent, "hint_color", sTemp);
	DispatchKeyValue(i_Ent, "hint_caption", s_Message);
	if (StrEqual(s_Icon,"use_binding") && !StrEqual(s_Binding,""))
	{
		DispatchKeyValue(i_Ent, "hint_icon_onscreen", "use_binding");	
		DispatchKeyValue(i_Ent, "hint_binding", s_Binding);
	}
	else DispatchKeyValue(i_Ent, "hint_icon_onscreen", s_Icon);	
	

	DispatchSpawn(i_Ent);
	AcceptEntityInput(i_Ent, "ShowHint");
	
	h_RemovePack = CreateDataPack();
	WritePackCell(h_RemovePack, client);
	WritePackCell(h_RemovePack, i_Ent);
	CreateTimer(float(showtime), RemoveInstructorHint, h_RemovePack);
}

public Action:RemoveInstructorHint(Handle:h_Timer, Handle:h_Pack)
{
	decl i_Ent, i_Client;
	ResetPack(h_Pack, false);
	i_Client = ReadPackCell(h_Pack);
	i_Ent = ReadPackCell(h_Pack);
	CloseHandle(h_Pack);
	
	if (!i_Client || !IsClientInGame(i_Client))
		return Plugin_Handled;
	
	if (IsValidEntity(i_Ent))
			RemoveEdict(i_Ent);
		
	DispatchKeyValue(i_Client, "targetname", "");
		
	return Plugin_Continue;
}

