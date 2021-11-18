CMD:pmg(playerid, params[])
{
    new arg[24], arg1[256]; 
    if(sscanf(params, "s[24]S", arg, arg1)) 
        return SendClientMessage(playerid, -1, usage);
    if(!strcmp(arg, "create"))
        {
            if(GetPVarInt(playerid, "groupCreated"))
                return SendClientMessage(playerid, -1, "You have already created a private messaging group!");
            if(0 < strlen(arg1) < MAX_PMG_NAME)
            {
                new str[128];
                SetPVarInt(playerid, "groupCreated", 1);
                //CreatePMG(playerid, arg1);
                format(str, sizeof(str), "You have succesfully created a private messaging group called: '%s'", arg1);
                SendClientMessage(playerid, -1, str);

                pmgInfo[playerid][pmgid] = playerid;
                format(pmgInfo[playerid][pmgname], MAX_PMG_NAME, arg1);

                selectedPMG[playerid] = playerid;
                pmgMemberInfo[playerid][playerid][pmg_member_id] = playerid;
                pmgMemberInfo[playerid][playerid][pmg_member_pmgid] = pmgInfo[playerid][pmgid];
                format(pmgMemberInfo[playerid][playerid][pmg_member_name], MAX_PLAYER_NAME, PlayerName(playerid));
                /*SetMemberInfo(playerid, playerid);
                format(str, sizeof(str), "[DEBUG] PMG Name: %s, SelectedPMG: %d", pmgInfo[playerid][pmgname], selectedPMG[playerid]);
                SendClientMessage(playerid, -1, str);*/
            }
            else 
            {            
                return SendClientMessage(playerid, -1, "Usage: /pmg create <name>");
            }
        }
    if(!strcmp(arg, "say"))
        {
            if(selectedPMG[playerid] == -1)
                return SendClientMessage(playerid, -1, "You do not have any private messaging groups selected.");
            if(strlen(arg1) > 0)
            {
                new selid, str[128];
                selid = selectedPMG[playerid];
                format(str, sizeof(str), "PMG - %s(%d): %s", PlayerName(playerid), playerid, arg1);
                for (new i; i < MAX_PLAYERS; i++)
                {
                    if(selectedPMG[i] == selid)
                        SendClientMessage(i, -1, str);
                }
            }
            else 
            {            
                return SendClientMessage(playerid, -1, "Usage: /pmg say <message>");
            }
        }
    if(!strcmp(arg, "invite"))
        {
            new id, str[128];
            if(sscanf(params, "s[24]d", arg, id)) 
                return SendClientMessage(playerid, -1, "Usage: /pmg invite <id>");
            {
                if(!GetPVarInt(playerid, "groupCreated"))
                    return SendClientMessage(playerid, -1, "You do not have a private messaging group! Make one using: /pmg create <name>");
                if(!IsPlayerConnected(id))
                    return SendClientMessage(playerid, -1, "ERROR: Player is not connected!");
                if(id == playerid)
                    return SendClientMessage(playerid, -1, "ERROR: You cannot invite yourself!");
                //format(pmgInfo[playerid][pmginvites], MAX_PMG_NAME, "%d", id);
                //pmgInfo[playerid][pmginvites] = id;
                pmgInvite[id][playerid] = true;
                format(str, sizeof(str), "You have invited %s(%d) to your private messaging group!", PlayerName(id), id);
                SendClientMessage(playerid, -1, str);
                format(str, sizeof(str), "You have been invited to %s by %s(%d)", pmgInfo[playerid][pmgname], PlayerName(playerid), playerid);
                SendClientMessage(id, -1, str);
            }
        }
    if(!strcmp(arg, "join"))
        {
            new id, str[128];
            if(sscanf(params, "s[24]u", arg, id)) 
                return SendClientMessage(playerid, -1, "Usage: /pmg join <id>");
            {
                if(!IsPlayerConnected(id))
                    return SendClientMessage(playerid, -1, "ERROR: Player is not connected!");

                if(id == playerid)
                    return SendClientMessage(playerid, -1, "You cannot join your own group!");

                //format(pmgInfo[playerid][pmginvites], MAX_PMG_NAME, "%d", id);
                for(new i; i < MAX_PMG_OPEN_INVITES; i++)
                {
                    if(pmgInvite[playerid][id] == true)
                    {
                        format(str, sizeof(str), "You have joined the group: %s", pmgInfo[id][pmgname]);
                        SendClientMessage(playerid, -1, str);
                        selectedPMG[playerid] = id;
                        pmgMemberInfo[playerid][id][pmg_member_id] = playerid;
                        pmgMemberInfo[playerid][id][pmg_member_pmgid] = pmgInfo[id][pmgid];
                        format(pmgMemberInfo[playerid][id][pmg_member_name], MAX_PLAYER_NAME, PlayerName(playerid));
                        pmgInvite[playerid][id] = false;
                    /*    SetMemberInfo(playerid, id);
                        format(str, sizeof(str), "MEMBER ID: %d, GROUP ID: %d", pmgMemberInfo[playerid][id][pmg_member_id], pmgMemberInfo[playerid][id][pmg_member_pmgid]);
                        SendClientMessage(playerid, -1, str);
                        format(pmgMemberInfo[playerid][id][pmg_member_pmgid], sizeof(id), pmgInfo[id][pmgid]);*/
                        SetPVarInt(playerid, "joinedGroup", 1);
                    }
                }

                if(!GetPVarInt(playerid, "joinedGroup"))
                    return SendClientMessage(playerid, -1, "You haven't been invited to his/her group!");
                SetPVarInt(playerid, "joinedGroup", 0);
            }
        }
    if(!strcmp(arg, "select"))
        {
            if(selectedPMG[playerid] == -1)
                return SendClientMessage(playerid, -1, "You are not in any groups.");
            
            new goptions[256], pmgoptions[256], str[256], options, groupoptions[MAX_PMG_MEMBER_GROUPS], optionid;
            for(new i; i < MAX_PMG_GROUPS; i++)
            {
                if(pmgMemberInfo[playerid][i][pmg_member_pmgid] == i)
                {
                    format(str, sizeof(str), "PMG ID: %d, PMG NAME: %s", pmgInfo[i][pmgid], pmgInfo[i][pmgname]);
                    SendClientMessage(playerid, -1, str);
                    format(pmgoptions, sizeof(pmgoptions), "(%d) - %s\n", pmgMemberInfo[playerid][i][pmg_member_pmgid], pmgInfo[i][pmgname]);
                    strcat(goptions, pmgoptions, sizeof(goptions));
                    format(str, sizeof(str), "PMG MEMBER ID: %d, PMG MEMBER NAME: %s", pmgInfo[i][pmgid], pmgInfo[i][pmgname]);
                    SendClientMessage(playerid, -1, str);
                    groupoptions[options] = pmgInfo[i][pmgid];
                    options++;
                }
            }
            inline Response(playerId, dialogid, response, listitem, string:inputtext[])
            {
            #pragma unused playerId, dialogid, inputtext, response, listitem
                if(response)
	            {	    
                    optionid = groupoptions[listitem];
                    format(str, sizeof(str), "PMG: Selected '%s' as primary group.", pmgInfo[optionid][pmgname]);
                    SendClientMessage(playerid, -1, str);
                    selectedPMG[playerid] = optionid;
                }
            }       
            Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Select a PMG:", goptions, "Select", "Cancel"); 
            SendClientMessage(playerid, -1, "showing dialog..");
        } 

    if(!strcmp(arg, "leave"))
    {
        new id, str[128];
        if(sscanf(params, "s[24]d", arg, id)) 
            return SendClientMessage(playerid, -1, "Usage: /pmg leave <group id>");
        
        if(pmgMemberInfo[playerid][id][pmg_member_pmgid] == id)
        {
            pmgMemberInfo[playerid][id][pmg_member_id] = -1;
            pmgMemberInfo[playerid][id][pmg_member_pmgid] = -1;
            format(pmgMemberInfo[playerid][id][pmg_member_name], MAX_PLAYER_NAME, "INVALID NAME");
            if(selectedPMG[playerid] == id)
                selectedPMG[playerid] = -2;
            format(str, sizeof(str), "PMG: You have left '%s'!", pmgInfo[id][pmgname]);
            SendClientMessage(playerid, -1, str);
        }
        else
        {
            SendClientMessage(playerid, -1, "You are not in this group!");
        }
    }
    return 1;
}

CMD:pmginfo(playerid, params[])
{
    new id, str[128], sid;
    if(sscanf(params, "d", id)) 
        return SendClientMessage(playerid, -1, "Usage: /pmginfo <id>");
    sid = selectedPMG[id];
   /* format(str, sizeof(str), "PMG GROUP ID: %d, PMG GROUP NAME: %s", pmgInfo[id][pmgid], pmgInfo[sid][pmgname]);
    SendClientMessage(playerid, -1, str);
    SendClientMessage(playerid, -1, " ");
    format(str, sizeof(str), "selectedpmg: %d", selectedPMG[id]);
    SendClientMessage(playerid, -1, str);*/
    format(str, sizeof(str), "SID = %d | PMG MEMBER GROUP ID = %d | PMG MEMBER GROUP NAME = %s", sid, pmgMemberInfo[id][sid][pmg_member_pmgid], pmgInfo[sid][pmgname]);
    SendClientMessage(playerid, -1, str);
    return 1;
}