new Float:XwDis[MAXENTTYPE];
BecomeIntoXiWu(entity,Float:dis)
{
	if (!IsValidEdict(entity) || !entity)return;
	XwDis[EntTypeCount] = dis;
	CreateTimer(0.2,TimerXiWu,entity,TIMER_REPEAT);
	
	nType[EntTypeCount] = Type_XiWu;
	EntProp[EntTypeCount] = entity;	
	EntTypeCount++;
}

public Action:TimerXiWu(Handle:timer,any:entity)
{
	new id = FindIdEntPropByEntity(entity);
	if(id ==-1)
	{
		KillTimer(timer);
		return;
	}
	
	for (new tar = 1;tar<GetMaxEntities();tar++)
	{
		if (IsValidEdict(tar))
		{
			new String:clsname[256];
			GetEdictClassname(tar,clsname,sizeof clsname);
			if (StrEqual(clsname,"player"))
			{
				new Float:vecOrigin[3],Float:pos[3],Float:vec[3];
				GetEntPropVector(tar,Prop_Send,"m_vecOrigin",vecOrigin);
				GetEntPropVector(entity,Prop_Send,"m_vecOrigin",pos);
				new Float:dis = GetVectorDistance(vecOrigin,pos);
				if (dis<XwDis[id])
				{
					if(dis>100.0)dis = 100.0;
					SubtractVectors(pos,vecOrigin,vec);
					NormalizeVector(vec, vec);
					ScaleVector(vec,0.5*dis);
					LogMessage("%f,%f,%f",vec[0],vec[1],vec[2]);
					
					TeleportEntity(tar,NULL_VECTOR,NULL_VECTOR,vec);
				}				
			}

			
		}
	}
}