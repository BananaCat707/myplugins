#include <sourcemod>
new FireTime[MAXPLAYERS+1];
new PointHurt = 0;

BecomeIntoFire(entity)
{
	if (entity<=0 ||!IsValidEdict(entity))return;
	
	SetEntityRenderColor(entity,255,0,0,255);
	nType[EntTypeCount] = Type_Fire;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
	SDKUnhook(entity,SDKHook_Touch,SDKCallBackFire_Touched);
	SDKHook(entity,SDKHook_Touch,SDKCallBackFire_Touched);
}

FirePerson(victim,Float:damage=1.0)
{
	if(PointHurt > 0)
	{
		if(IsValidEdict(PointHurt))
		{
			if(victim>0 && IsValidEdict(victim))
			{		
				decl String:N[20];
				Format(N, 20, "target%d", victim);
				DispatchKeyValue(victim,"targetname", N);
				DispatchKeyValue(PointHurt,"DamageTarget", N); 
				DispatchKeyValueFloat(PointHurt,"Damage", damage);
				DispatchKeyValue(PointHurt, "DamageType", "8"); 
				AcceptEntityInput(PointHurt,"Hurt");
			}
		}
		else 
		{	
			PointHurt=CreatePointHurt();
			FirePerson(victim,damage);
		}	
	}
	else
	{	
		PointHurt=CreatePointHurt();
		FirePerson(victim,damage);
	}	
}

public SDKCallBackFire_Touched(entity,toucher)
{
	new id = FindIdEntPropByEntity(entity);
	if(id==-1)return;
	if (nType[id]!=Type_Fire)
	{
		SDKUnhook(entity,SDKHook_Touch,SDKCallBackFire_Touched);
		return;
	}
	if (toucher<MaxClients && IsPlayerAlive(toucher))
	{
		FireTime[toucher]++;
		if (FireTime[toucher]<=15)
			return;
		else FireTime[toucher] = 0;
	}
	FirePerson(toucher,5.0);
}

CreatePointHurt()
{
	new pointHurt=CreateEntityByName("point_hurt");
	if(pointHurt)
	{		
		DispatchKeyValue(pointHurt,"Damage","10");
		DispatchSpawn(pointHurt);
	}
	return pointHurt;
}