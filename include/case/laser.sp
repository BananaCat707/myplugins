#include <sourcemod>

new laserdamage[MAXENTTYPE];
new laserwidth[MAXENTTYPE];
new laserprop[MAXENTTYPE];
new Float:laserpos[MAXENTTYPE][3];

BecomeIntoLaser(entity,damage=100,width=2,Float:pos[3])
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	decl String:sTemp[64];
	new laser = CreateEntityByName("env_laser");
	if(laser==-1)ThrowError("创建射线失败!");
	Format(sTemp,sizeof sTemp,"%d",damage);	
	DispatchKeyValue(laser,"damage",sTemp);
	DispatchKeyValue(laser,"texture","sprites/laserbeam.spr");
	Format(sTemp,sizeof sTemp,"%d %d %d",GetRandomInt(0,255),GetRandomInt(0,255),GetRandomInt(0,255));	
	DispatchKeyValue(laser,"rendercolor",sTemp);
	Format(sTemp,sizeof sTemp,"%d",width);
	DispatchKeyValue(laser,"width",sTemp);
	DispatchKeyValue(laser,"NoiseAmplitude","1");
	
	Format(sTemp,sizeof sTemp,"postar_%d",entity);
	DispatchKeyValue(entity,"targetname",sTemp);
	DispatchKeyValue(laser,"LaserTarget",sTemp);
	
	DispatchSpawn(entity);
	
	DispatchSpawn(laser);
	ActivateEntity(laser);
	
	TeleportEntity(laser,pos,NULL_VECTOR,NULL_VECTOR);
	AcceptEntityInput(laser,"TurnOn");
	
	nType[EntTypeCount] = Type_Laser;
	laserprop[EntTypeCount] = laser;
	laserdamage[EntTypeCount]=damage;
	laserpos[EntTypeCount] = pos;	
	laserwidth[EntTypeCount] = width;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
}

ShowChooseLaserFlagsMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseLaserFlags);
	SetMenuExitButton(menu,true);
	decl String:sTemp[256];
	SetMenuTitle(menu,"请设置激光板的类型。编号:%d",entity);
	
	Format(sTemp,sizeof sTemp,"高度+1.目前:%d",laserwidth[EntTypeCount]);
	AddMenuItem(menu,"item1",sTemp);
	Format(sTemp,sizeof sTemp,"高度-1.目前:%d",laserwidth[EntTypeCount]);
	AddMenuItem(menu,"item2",sTemp);	
	Format(sTemp,sizeof sTemp,"伤害+10.目前:%d",laserdamage[EntTypeCount]);	
	AddMenuItem(menu,"item3",sTemp);
	Format(sTemp,sizeof sTemp,"伤害-10.目前:%d",laserdamage[EntTypeCount]);	
	AddMenuItem(menu,"item4",sTemp);	
	Format(sTemp,sizeof sTemp,"<重要>把当前位置定为路径点(%d %d %d)",RoundToFloor(laserpos[EntTypeCount][0]), RoundToFloor(laserpos[EntTypeCount][1]), RoundToFloor(laserpos[EntTypeCount][2]));		
	AddMenuItem(menu,"item5",sTemp);
	AddMenuItem(menu,"item6","完成");		
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseLaserFlags(Handle:menu, MenuAction:action, client, item)
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
					laserwidth[EntTypeCount]+=1;
					ShowChooseLaserFlagsMenu(client,NowEntity);
				}
				case 1:
				{
					if (laserwidth[EntTypeCount]>1)
					{
						laserwidth[EntTypeCount]-=1;
					}
					ShowChooseLaserFlagsMenu(client,NowEntity);
				}
				case 2:
				{
					laserdamage[EntTypeCount]+=10;
					ShowChooseLaserFlagsMenu(client,NowEntity);
				}
				case 3:
				{
					if (laserdamage[EntTypeCount]>0)
					{
						laserdamage[EntTypeCount]-=10;
					}
					ShowChooseLaserFlagsMenu(client,NowEntity);
				}
				case 4:
				{
					GetClientAbsOrigin(client,laserpos[EntTypeCount]);	
					ShowChooseLaserFlagsMenu(client,NowEntity);
				}
				case 5:
				{
					if (laserpos[EntTypeCount][0] == 0.0 && laserpos[EntTypeCount][1] == 0.0 && laserpos[EntTypeCount][2] == 0.0)
					{
						PrintToChat(client,"\x03请先定义好激光的路径点!");
						ShowChooseLaserFlagsMenu(client,NowEntity);
						return;
					}
					if (laserwidth[EntTypeCount] == 0)
						laserwidth[EntTypeCount] = 2;
					BecomeIntoLaser(NowEntity,laserdamage[EntTypeCount],laserwidth[EntTypeCount],laserpos[EntTypeCount]);
				}
			}
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}