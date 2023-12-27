#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define DEBUG true
#pragma semicolon				1
#define Version "11.0"
#define CVAR_FLAGS FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY

#define MAXENTTYPE 100
#define ARRAY_SIZE 2150

#define Type_Fire 1
#define Type_Ice 2
#define Type_Jump 3
#define Type_Throw 4
#define Type_Break 5
#define Type_Teleport 6
#define Type_Die 7
#define Type_Shake 8
#define Type_Auto 9
#define Type_Heavy 10
#define Type_BreakEx 11
#define Type_Lift 12
#define Type_Laser 13
#define Type_Rot 14
#define Type_Info 15
#define Type_Target 16
#define Type_HaiMian 17
#define Type_XiWu 18
#define Type_ChanSong 19

//ArgFlags
#define sp_enable "0" //all -- 启用
#define sp_disable "1" //all -- 关闭
#define sp_p1 "4" //Break -- 破碎 BreakEx -- 破碎 Lift -- 回到开始的位置
#define sp_p2 "6" //Rot -- 继续/停止 Lift -- 继续/停止 Laser -- 开启/关闭 Teleport -- 直接传送玩家
#define sp_p3 "8" //删除

new NowEntity;
new EntTypeCount = 0;
new EntProp[MAXENTTYPE];
new SpawnFlags[ARRAY_SIZE];
new nType[MAXENTTYPE];

#include "case/xb.sp"
#include "case/fire.sp"
#include "case/ice.sp"
#include "case/jump.sp"
#include "case/throw.sp"
#include "case/break.sp"
#include "case/teleport.sp"
#include "case/die.sp"
#include "case/shake.sp"
#include "case/auto.sp"
#include "case/heavy.sp"
#include "case/breakex.sp"
#include "case/lift.sp"
#include "case/laser.sp"
#include "case/rot.sp"
#include "case/info.sp"
#include "case/target.sp"
#include "case/hm.sp"
#include "case/xw.sp"
#include "case/cs.sp"
#include "case/saveandload.sp"

public Plugin:myinfo =
{
	name="特殊实体_更新更多功能",
	author="BananaCat707,Xiaobao",
	description="",
	version=Version,
	url="https://github.com/BananaCat707/myplugins"
};

public OnPluginStart()
{
	decl String:game_name[64];
	GetGameFolderName(game_name, sizeof(game_name));
	if (!StrEqual(game_name, "left4dead", false) && !StrEqual(game_name, "left4dead2", false))
		SetFailState("此插件只支持求生之路2,L4D2.");
	
	RegAdminCmd("sm_et",CmdSetType,ADMFLAG_ROOT,"打开特殊实体菜单.");
	RegAdminCmd("sm_etp",CmdLoadAndSave,ADMFLAG_ROOT,"打开保存和读取菜单.");
	RegAdminCmd("sm_ett",CmdText,ADMFLAG_ROOT,"设置讯息板的标题.");
	RegAdminCmd("sm_esp",CmdSetSpawnFlags,ADMFLAG_ROOT,"设置标志.");
	
	HookEvent("player_spawn",player_spawn);
	HookEvent("round_start",round_start);
	
}

public OnMapStart()
{
	CreateTimer(15.0,TimerLoad);
	g_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheSound("player/suit_denydevice.wav");	
	PrecacheSound("level/startwam.wav");	
	PrecacheSound("buttons/blip1.wav");	
	liftbeamcolor[0] = GetRandomInt(0,255);
	liftbeamcolor[1] = GetRandomInt(0,255);	
	liftbeamcolor[2] = GetRandomInt(0,255);
	liftbeamcolor[3] = 255;	
}

public Action:CmdSetType(client,args)
{
	new entity = GetClientAimTargetEx(client);
	if (entity==0)return;
	NowEntity = 0;
	decl String:szTemp[255];
	
	decl String:clsname[256];
	GetEdictClassname(entity,clsname,sizeof clsname);
	if (StrEqual(clsname,"player"))
	{
		PrintToChat(client,"\x03不能把玩家作为你的目标!");
		return;
	}
	new id = FindIdEntPropByEntity(entity);
	if (id==-1)
		ShowChooseTypeMenu(client,entity);
	else SetEntitySpecialType(client,entity,0);
	
}

public Action:CmdSetSpawnFlags(client,args)
{
	new String:sTemp[20];
	new entity,sp;
	if(args<2)
	{
		ReplyToCommand(client,"用法:sm_esp \"[实体编号]\" \"[标志]\"");
		return;
	}
	GetCmdArg(1,sTemp,sizeof sTemp);
	entity = StringToInt(sTemp);
	GetCmdArg(2,sTemp,sizeof sTemp);
	sp = StringToInt(sTemp);	
	SpawnFlags[entity] = sp;
	ReplyToCommand(client,"设置实体的标志成功,编号:%d 标志:%d。",entity,sp);	
}

ShowChooseTypeMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseType);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择类型,编号:%d\n注:X*X为可选的,不建议使用",entity);
	AddMenuItem(menu,"1","燃烧板(顾名思义,燃烧的实体,玩家或小丧尸碰到都烧)");
	AddMenuItem(menu,"2","滑冰板(改变玩家的速度)");
	AddMenuItem(menu,"3","弹跳板(让玩家飞)");
	AddMenuItem(menu,"4","投掷板(让玩家飞EX)");	
	AddMenuItem(menu,"5","血量板(让玩家打的实体)");		
	AddMenuItem(menu,"6","传送板(传送玩家到指定坐标)");	
	AddMenuItem(menu,"7","黑洞板(实体碰到要不是死要不是消失)");	
	AddMenuItem(menu,"8","X摇晃板X(玩家碰到摇个不停)");	
	AddMenuItem(menu,"9","X移动板X(自动移动玩家)");	
	AddMenuItem(menu,"10","重力板(改变玩家的重力)");	
	AddMenuItem(menu,"11","破碎板(破碎的板子 坑爹货)");
	AddMenuItem(menu,"12","电梯板(移动板子超级版)");
	AddMenuItem(menu,"13","激光板(烧烤板子)");
	AddMenuItem(menu,"14","旋转板(旋转板子)");
	AddMenuItem(menu,"15","讯息板(提示信息)");	
	AddMenuItem(menu,"16","机关板(触发用)");
	AddMenuItem(menu,"17","海绵板(执行特殊事件(请不要使用))");	
	AddMenuItem(menu,"18","吸物板(吸物品)");
	//AddMenuItem(menu,"19","传送带(自动移动玩家Ex)");	
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseType(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			decl String:sType[64];
			new type =0;
			GetMenuItem(menu,item,sType,sizeof sType);
			type = StringToInt(sType);
			if (type<0)return;
			SetEntitySpecialType(client,NowEntity,type);
			PrintToChat(client,"\x03设置成功!\x04编号:%d",NowEntity);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

FindIdEntPropByEntity(entity)
{
	for (new id = 0;id<EntTypeCount;id++)
	{
		if (EntProp[id] == entity)
			return id;
	}
	return -1;
}

//设置特殊类型,0为删除特殊类型
SetEntitySpecialType(client,entity,type=0)
{
	if (type==0)
	{
		new id = FindIdEntPropByEntity(entity);
		#if DEBUG
			LogMessage("SetEntType:%d,id:%d",entity,id);
		#endif
		if (id!=-1 && nType[id]>0)
		{
			//删除实体类型
			if (nType[id] == Type_Lift)
			{
				if (liftinfo[id][0]>MaxClients && IsValidEdict(entity))
					RemoveEdict(liftinfo[id][0]);
				if (liftinfo[id][2]>0)
				{
					for (new i = 0;i<liftinfo[id][2];i++)
					{
						if (liftpath[id][i]>MaxClients && IsValidEdict(liftpath[id][i]))
						{
							if (i==0)
								UnhookSingleEntityOutput(liftpath[id][i],"OnPass",EntityOutput_OnPass_Start);
							else if (i==liftinfo[id][2]-1)
								UnhookSingleEntityOutput(liftpath[id][i],"OnPass",EntityOutput_OnPass_End);
							RemoveEdict(liftpath[id][i]);
						}
							
					}
				}
				
			}	
			else if (nType[id] == Type_Rot)
			{
				if (rotrot[id]>MaxClients && IsValidEdict(rotrot[id]))
					RemoveEdict(rotrot[id]);
				if (rotent[id]>MaxClients && IsValidEdict(rotent[id]))
					RemoveEdict(rotent[id]);					
			}	
			else if (nType[id] == Type_Laser)
			{
				if (laserprop[id]>MaxClients && IsValidEdict(laserprop[id]))
					RemoveEdict(laserprop[id]);	
			}				
			else if (nType[id]== Type_Target)
			{
				for (new j = 0;j<TargetEventCount[id];j++)
				{
					TargetObject[id][j] = 0;
					strcopy(TargetEventName[id][j],256,"");
					strcopy(TargetEventArg[id][j],256,"");
				}
				TargetEventCount[id] = 0;
				if (!IsValidEdict(TargetButton[id]) && TargetButton[id]!=0)
				{
					RemoveEdict(TargetButton[id]);
					TargetButton[id] = 0;
				}
			}	
			nType[id]=0;
			EntProp[id] = 0;
			icespeed[id] = 0.0;
			jumppower[id] = 0.0;
			throwpower[id] = 0.0;
			MaxHealth[id] = 0;
			Health[id] = 0;
			liftinfo[id][1] = 0;
			liftinfo[id][0] = 0;
			liftinfo[id][2] = 0;		
			liftshowbeam[id] = false;
			liftdamage[id] = false;
			CopyVector(Pos[id],NULL_VECTOR,3);
			rotspeed[id] = 0;
			rotpoint[id] = Float:{0.0,0.0,0.0};
			rotentpoint[id] = Float:{0.0,0.0,0.0};
			rotrot[id] = 0;
			rotent[id] = 0;	
			strcopy(InfoMessage[id],MaxInfoSize,"");
			strcopy(InfoIcon[id],MaxInfoSize,"");
			CopyVector(InfoColor[id],NULL_VECTOR);	
			PrintToChat(client,"\x03移除成功!编号:\x04%d",entity);
			SetEntityRenderColor(entity,255,255,255,255);
			SetEntityRenderFx(entity,RENDERFX_NONE);
			SetEntProp(entity, Prop_Send, "m_iGlowType", 0);			
			return true;
		}
		else return false;
	}
	
	switch(type)
	{
		case Type_Fire:
		{
			BecomeIntoFire(entity);
		}
		case Type_Ice:
		{
			ShowChooseIceSpeedMenu(client,entity);
		}		
		case Type_Jump:
		{
			ShowChooseJumpPowerMenu(client,entity);
		}	
		case Type_Throw:
		{
			ShowChooseThrowPowerMenu(client,entity);
		}		
		case Type_Break:
		{
			ShowChooseBreakHealthMenu(client,entity);
		}			
		case Type_Teleport:
		{
			ShowChooseTelePosMenu(client,entity);
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
		case Type_Heavy:
		{
			ShowChooseHeaPowerMenu(client,entity);
		}	
		case Type_BreakEx:
		{
			ShowChooseBreakExFlagsMenu(client,entity);
		}		
		case Type_Lift:
		{
			ShowChooseLiftFlagsMenu(client,entity);
		}			
		case Type_Laser:
		{
			ShowChooseLaserFlagsMenu(client,entity);
		}		
		case Type_Rot:
		{
			ShowChooseRotFlagsMenu(client,entity);
		}	
		case Type_Info:
		{
			ShowChooseInfoFlagsMenu(client,entity);
		}		
		case Type_Target:
		{
			ShowChooseTargetFlagsMenu(client,entity);
		}
		case Type_HaiMian:
		{
			BecomeIntoHaiMian(entity);
		}		
		case Type_XiWu:
		{
			BecomeIntoXiWu(entity,500.0);
		}		
		case Type_ChanSong:
		{
			new Float:angles[3];
			GetClientAbsOrigin(client,angles);
			BecomeIntoChuanSong(entity,angles);
		}			
	}
	return true;
}

public Action:round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	EntTypeCount = 0;
	CreateTimer(5.0,TimerLoad);
}

public Action:player_spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetEventInt(event, "userid");
	client = GetClientOfUserId(client);
	if (client<=0)return;
	else SetEntityGravity(client,1.0);
}

public Action:TimerLoad(Handle:timer)
{
	LoadFromFile(0);
	
	PrintToChatAll("\x04[提示]\x03特殊实体载入完成!");
}

public OnEntityDestroyed(entity)
{
	new id = FindIdEntPropByEntity(entity);
	if (id==-1)return;
	if (nType[id] == Type_Lift)
	{
		if (liftinfo[id][0]>MaxClients && IsValidEdict(entity))
			RemoveEdict(liftinfo[id][0]);
		if (liftinfo[id][2]>0)
		{
			for (new i = 0;i<liftinfo[id][2];i++)
			{
				if (liftpath[id][i]>MaxClients && IsValidEdict(liftpath[id][i]))
				{
					if (i==0)
						UnhookSingleEntityOutput(liftpath[id][i],"OnPass",EntityOutput_OnPass_Start);
					else if (i==liftinfo[id][2]-1)
						UnhookSingleEntityOutput(liftpath[id][i],"OnPass",EntityOutput_OnPass_End);
					RemoveEdict(liftpath[id][i]);
				}
					
			}
		}
		
	}	
	else if (nType[id] == Type_Rot)
	{
		if (rotrot[id]>MaxClients && IsValidEdict(rotrot[id]))
			RemoveEdict(rotrot[id]);
		if (rotent[id]>MaxClients && IsValidEdict(rotent[id]))
			RemoveEdict(rotent[id]);					
	}	
	else if (nType[id] == Type_Laser)
	{
		if (laserprop[id]>MaxClients && IsValidEdict(laserprop[id]))
			RemoveEdict(laserprop[id]);	
	}				
	else if (nType[id]== Type_Target)
	{
		for (new j = 0;j<TargetEventCount[id];j++)
		{
			TargetObject[id][j] = 0;
			strcopy(TargetEventName[id][j],256,"");
			strcopy(TargetEventArg[id][j],256,"");
		}
		TargetEventCount[id] = 0;
		if (!IsValidEdict(TargetButton[id]) && TargetButton[id]!=0)
		{
			RemoveEdict(TargetButton[id]);
			TargetButton[id] = 0;
		}
	}	
	nType[id]=0;
	EntProp[id] = 0;
	icespeed[id] = 0.0;
	jumppower[id] = 0.0;
	throwpower[id] = 0.0;
	MaxHealth[id] = 0;
	Health[id] = 0;
	liftinfo[id][1] = 0;
	liftinfo[id][0] = 0;
	liftinfo[id][2] = 0;		
	liftshowbeam[id] = false;
	liftdamage[id] = false;
	CopyVector(Pos[id],NULL_VECTOR,3);
	rotspeed[id] = 0;
	rotpoint[id] = Float:{0.0,0.0,0.0};
	rotentpoint[id] = Float:{0.0,0.0,0.0};
	rotrot[id] = 0;
	rotent[id] = 0;	
	strcopy(InfoMessage[id],MaxInfoSize,"");
	strcopy(InfoIcon[id],MaxInfoSize,"");
	CopyVector(InfoColor[id],NULL_VECTOR);	
}
#define ShowHit true
public OnGameFrame()
{
	ShowLiftPathBeam();
}
