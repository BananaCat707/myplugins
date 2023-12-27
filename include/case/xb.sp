GetClientCurPos(client,Float:pos[3])
{
	decl Float:VecOrigin[3],Float:VecAngles[3];
	GetClientEyePosition(client, VecOrigin);
	GetClientEyeAngles(client, VecAngles);	
	TR_TraceRayFilter(VecOrigin, VecAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	if(TR_DidHit(INVALID_HANDLE))
	{
		TR_GetEndPosition(pos);
	}
}

public GetClientAimTargetEx(client)
{
	decl Float:VecOrigin[3],Float:VecAngles[3];
	GetClientEyePosition(client, VecOrigin);
	GetClientEyeAngles(client, VecAngles);	
	TR_TraceRayFilter(VecOrigin, VecAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	if(TR_DidHit(INVALID_HANDLE))
	{
		return TR_GetEntityIndex();
	}
	return -1;
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity == data) // Check if the TraceRay hit the itself.
	{
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}

stock CheatCommand(Client, const String:command[], const String:arguments[]=NULL_STRING)
{
    if (!Client) return;
    new flags = GetCommandFlags(command);
    SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    FakeClientCommand(Client, "%s %s", command, arguments);
    SetCommandFlags(command, flags);
}

stock EmitSoundFromPlayer(client,const String:sound[])
{
	if (!IsClientInGame(client))return;
	decl Float:pos[3];
	GetClientAbsOrigin(client,pos);
	if (!IsSoundPrecached(sound))
		PrecacheSound(sound);
	EmitAmbientSound(sound,pos);
}

stock CopyVector(any:data[],any:source[],maxlen=3)
{
	if(maxlen<1)maxlen=3;
	for (new i=0;i<maxlen;i++)
		data[i] = source[i];
}

public bool:KvGetBool(Handle:kv,const String:key[])
{
	new i =KvGetNum(kv,key);
	return (i==1);
}

SplitStringEx(const String:source[],const String:split[]="\n",const String:array[][],maxarray)
{
	new String:buffer[strlen(source)];
	new p = 0;
	new lp = 0;
	while(p<maxarray)
	{
		if (p==0)
			strcopy(buffer,strlen(source)+1,source);
		lp = StrContains(buffer,split);	
		if (lp!=-1)
		{
			strcopy(array[p],lp+1,buffer);
			if (!StrEqual(array[p],""))
				ReplaceStringEx(buffer,strlen(source),array[p],"");
			ReplaceStringEx(buffer,strlen(source),split,"");
		}
		else
		{
			strcopy(array[p],strlen(buffer)+1,buffer);
			break;
		}
		p++;
	}
	return p;
}

