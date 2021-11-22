CMD:pmg(playerid, params[])
{
    new arg[24], arg1[256]; 
    // It would probably be easier to just put sscanf checks in sub command if statements, like the invite sub command does.
    // Avoids the need to do argument checks in the sub command function (PMGCreateCMD, PMGSayCMD etc.).
    if(sscanf(params, "s[24]S()", arg, arg1)) 
        return SendClientMessage(playerid, -1, usage);

    if(!strcmp(arg, "create"))
    {
        PMGCreateCMD(playerid, arg1);
    }

    else if(!strcmp(arg, "say")) // Maybe better if 'else if' statements do not have whitespace between them.
    {
        PMGSayCMD(playerid, arg1);
    }

    else if(!strcmp(arg, "invite"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg invite <id>");
        PMGInviteCMD(playerid, id);
    }

    else if(!strcmp(arg, "join"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg join <id>");
        PMGJoinCMD(playerid, id);
    }

    else if(!strcmp(arg, "select"))
    {
        PMGSelectCMD(playerid);
    } 

    else if(!strcmp(arg, "leave"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg leave <group id>");
        PMGLeaveCMD(playerid, id);
    }

    else if(!strcmp(arg, "delete"))
    {
        new id;
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg delete <group id>");
        PMGDeleteCMD(playerid, id);
    }

    else if(!strcmp(arg, "manage"))
    {
        PMGManageCMD(playerid);
    }

    else
    {
        SendClientMessage(playerid, -1, usage);
    } 

    return 1;
}
