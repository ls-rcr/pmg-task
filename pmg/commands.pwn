CMD:pmg(playerid, params[])
{
    new arg[24], arg1[256]; 
    if(sscanf(params, "s[24]S()", arg, arg1)) 
        return SendClientMessage(playerid, -1, usage);
    if(!strcmp(arg, "create"))
    {
        PMGCreateCommand(playerid, arg1);
    }
    else if(!strcmp(arg, "say"))
    {
        PMGSay(playerid, arg1);
    }
    else if(!strcmp(arg, "invite"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg invite <id>");
        PMGInvite(playerid, id);
    }
    else if(!strcmp(arg, "join"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg join <id>");
        PMGJoin(playerid, id);
    }
    else if(!strcmp(arg, "select"))
    {
        PMGSelect(playerid);
    } 
    else if(!strcmp(arg, "leave"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg leave <group id>");
        PMGLeave(playerid, id);
    }
    else if(!strcmp(arg, "delete"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg delete <group id>");
        PMGDelete(playerid, id);
    }
    else if(!strcmp(arg, "manage"))
    {
        PMGManage(playerid);
    }
    else
    {
        SendClientMessage(playerid, -1, usage);
    }       
    return 1;
}

CMD:pmginfo(playerid, params[])
{
    new id, str[128], sid;
    if(sscanf(params, "d", id)) 
        return SendClientMessage(playerid, -1, "Usage: /pmginfo <id>");
    sid = primaryPMG[id];
    format(str, sizeof(str), "PMG RANK NAME: %s, PMG ID: %d", pmgRankInfo[sid][pmgMemberInfo[id][sid][pmg_member_rankid]][pmg_rank_name], sid);
    SendClientMessage(playerid, -1, str);
    return 1;
}
