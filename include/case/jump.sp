#include <sourcemod>

new Float:jumppower[MAXENTTYPE];

BecomeIntoJump(entity,Float:power)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	
	SetEntityRenderColor(entity,255,165,0,255);
	jumppower[EntTypeCount] = power;
	nType[EntTypeCount] = Type_Jump;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackJump_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackJump_Touched);
}

JumpPerson(person,Float:power=1.0)
{
	if (person>MaxClients && IsValidEdict(person))return;
	new Handle:pack = CreateDataPack();
	WritePackCell(pack,person);
	WritePackFloat(pack,power);
	CreateTimer(0.2,TimerJump,pack);
}

public Action:TimerJump(Handle:timer,any:pack)
{
	ResetPack(pack);
	new person = ReadPackCell(pack);
	new Float:power = ReadPackFloat(pack);	
	new Float:velo[3];
	velo[0] = GetEntPropFloat(person, Prop_Send, "m_vecVelocity[0]");
	velo[1] = GetEntPropFloat(person, Prop_Send, "m_vecVelocity[1]");
	velo[2] = GetEntPropFloat(person, Prop_Send, "m_vecVelocity[2]");
	
	//falling or jumping?
	if (velo[2] != 0)return;

	//add only velocity in z-direction
	new Float:vec[3];
	vec[0] = velo[0];
	vec[1] = velo[1];
	vec[2] = velo[2] + power*300.0;

	TeleportEntity(person, NULL_VECTOR, NULL_VECTOR, vec);
	
	EmitSoundFromPlayer(person,"buttons/blip1.wav");	
}

ShowChooseJumpPowerMenu(client,entity)
{
	new Handle:menu = CreateMenu(MenuHandler_ChooseJumpPower);
	SetMenuExitButton(menu,true);
	SetMenuTitle(menu,"请选择弹跳板的力度,编号:%d",entity);
	AddMenuItem(menu,"1.0","小");
	AddMenuItem(menu,"1.7","较小");
	AddMenuItem(menu,"3.4","中");	
	AddMenuItem(menu,"4.0","大");
	AddMenuItem(menu,"5.0","最大");
	DisplayMenu(menu,client,MENU_TIME_FOREVER);
	NowEntity = entity;
}

public MenuHandler_ChooseJumpPower(Handle:menu, MenuAction:action, client, item)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if (NowEntity<=0 || !IsValidEdict(NowEntity))return;
			decl String:sType[64];
			new Float:power =0.0;
			GetMenuItem(menu,item,sType,sizeof sType);
			power = StringToFloat(sType);
			if (power<0.0)return;
			BecomeIntoJump(NowEntity,power);
		}
		case MenuAction_Cancel:
		{
			
		}
	}
}

public SDKCallBackJump_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Jump)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackJump_Touched);
		return;
	}
	if (toucher<MaxClients && !IsPlayerAlive(toucher))
		return;
	JumpPerson(toucher,jumppower[id]);
}